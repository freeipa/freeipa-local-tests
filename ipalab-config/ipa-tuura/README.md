# FreeIPA integration with Keycloak using ipa-tuura bridge

This lab sets up an environment that integrates [FreeIPA](https://freeipa.org) and [Keycloak](https://keycloak.org) identity management deployments using the **ipa-tuura** bridge via Keycloak's User Federation feature.

**ipa-tuura** is a service that exposes identity and authentication domains through a set of Django applications, enabling centralized management of users, groups, and authentication methods.


## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Build the container image and instantiate containers:

```
ipalab-config lab_ipa_tuura.yml
cd ipa-tuura-keycloak
podman-compose build
podman-compose up -d
```

At this stage, the environment consists of three containers:  
- A container based on the official Keycloak image  
- A container ready for deploying FreeIPA  
- The **ipa-tuura** service container, which bridges FreeIPA and Keycloak by integrating them through Keycloak's User Federation storage

Deploy the IPA cluster using
[ansible-freeipa](https://gtihub.com/freeipa/ansible-freeipa):

```
ansible-galaxy collection install \
    freeipa.ansible_freeipa \
    containers.podman
ansible-playbook -i inventory.yml \
    ${HOME}/.ansible/collections/ansible_collections/freeipa/ansible_freeipa/playbooks/install-cluster.yml
```

The provided Keycloak container uses a self-signed certificate that is
unkown to the ipa-tuura container. The certificate is found in the container
`keycloak` at the path `/opt/keycloak/conf/cert.pem`. This certificate
must be added to the list of trusted certificates on the ipa-tuura
container. This can be achieved by executing:

```
keycloak/trust_keycloak.sh ipatuura
```

## Using Keycloak web interface

Since the whole environment runs using rootles containers, in a Podman
virtual network, direct access to the host ports is not possible, but
can be achieved using `podman unshare`. For example, to _ssh_ into the
container (if `sshd` is available) or to access the `httpd` server.

When using [Firefox](https://mozilla.org/firefox) a profile is needed
to access the containers URLs, and to ease access the script
`scripts/open-firefox.sh` is provided. This script will manage the
Firefox profile and call `firefox` with the proper configuration for
`podman unshare`, allowing access to Keycloak and WebUI.

Before starting Firefox, add the entries found in the generated `hosts`
file to your machine `/etc/hosts` so the host names can be resolved. The
file `hosts` has all the containers entries needed, add it with:

```
sudo bash -c "cat hosts >> /etc/hosts"
```

Start the Keycloak web interface with:

```
scripts/open-firefox.sh https://keycloak.example.test:8443
```

Start the IPA WebUI with:

```
scripts/open-firefox.sh https://server.ipa.test:443
```

In a similar fashion you can access the Bridge API with:

```
scripts/open-firefox.sh https://ipatuura.ipa.test:443
```


## Setting up Keycloak's User Federation Storage


In order to interconnect both identity management systems, the **ipa-tuura** service must be added as part of Keycloak's *User Federation* storage.

```json
                  ./kcadm.sh create components \
                    -r master \
                    -s name=scimipa \
                    -s providerId=scim \
                    -s providerType=org.keycloak.storage.UserStorageProvider \
                    -s 'config.scimurl=["bridge.ipa.test"]' \
                    -s 'config.loginusername=["scim"]' \
                    -s 'config.loginpassword=["Secret123"]' \
                    -s 'config.domain=["ipa.test"]' \
                    -s 'config.domainname=["ipa.test"]' \
                    -s 'config.domaindesc=["Bridge_to_ipa"]' \
                    -s 'config.domainurl=["https://idm.ipa.test"]' \
                    -s 'config.domainclientid=["admin"]' \
                    -s 'config.domainclientsecret=["Secret123"]' \
                    -s 'config.idprovider=["ipa"]' \
                    -s 'config.cacert=["/etc/ipa/ca.crt"]' \
                    -s 'config.users_dn=["ou=people,dc=ipa,dc=test"]' \
                    -s 'config.extraattrs=["mail:mail, sn:sn, givenname:givenname"]' \
                    -s 'config.addintgdomain=["True"]' \
                    -s 'config.enabled=["True"]' \
                    -s 'config.keycloak_hostname=["keycloak.ipa.test"]'
```

CHECK IF WE CAN CREATE A JSON and rely on kcreg:

```json
{
  "enabled" : true,
  "clientAuthenticatorType" : "client-secret",
  "redirectUris" : [ "https://${IPASERVER}/ipa/idp/*" ],
  "webOrigins" : [ "https://${IPASERVER}" ],
  "protocol" : "openid-connect",
  "attributes" : {
    "oauth2.device.authorization.grant.enabled" : "true",
    "oauth2.device.polling.interval": "5"
  }
}
```


To create the OIDC client for Keycloak, you can use the script provided
by `ipalab-config`. The script requires the IPA FQDN, an OIDC client ID
and the OIDC client password. Execute:

```
keycloak/keycloak_add_oidc_client.sh \
    server.ipa.test \
    ipa_oidc_client \
    Secret123
```

Now, we can start adding some users to IPA deploytment, and check if they are automatically provisioned in Keycloak by running:

```
ansible-playbook -i inventory.yml playbooks/add_ipa_users.yml
```

## Testing the setup

To test the setup, create a user on IPA using:

```
ansible-playbook -i inventory.yml playbooks/add_user_auth_idp.yml
```

Perform login with user `jdoe` on Keycloak web interface:

```
scripts/open-firefox.sh https://keycloak.example.test:8443/realms/master/account
```


## Troubleshooting

ADD ipa-tuura troubleshooting

If anything goes wrong, you can search `journalctl` for `ipa-otpd`
entries.

To increase the log level, set the `oidc_child` debug level in
`/etc/ipa/default.conf` by setting:

```
[global]
oidc_child_debug_level=10
```

Valid values are between 0 and 10 and any value above 6 includes debug
output from `libcurl` utility.
