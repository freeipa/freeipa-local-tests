# Running ipa-migration with ipalab-config

This folder provides some scripts, playbooks and configuration files to automate the creation of an environment to test IPA-to-IPA migration using in a local machine. The environment created contains two IPA servers each hosting its own realm.

## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Build the containers:

```
ipalab-config -f containerfile-fedora -p playbooks ipalab-migration.yaml
cd ipalab-migration
podman-compose up -d --build
ansible-galaxy collection install -r requirements.yml
```

Deploy the IPA cluster:

```
ansible-playbook -i inventory.yml playbooks/install-cluster.yml
```

To test ipa-migration, first create some objects in the origin server:

```
ansible-playbook -i inventory.yml playbooks/users_present.yml
```

Access the target server container:

```
podman exec -it m2.target.test bash
```

Obtain an IPA administrator TGT ticket (in this example the password is Secret123):
```
echo Secret123 | kinit
```

Put the server into migration mode:
```
ipa config-mod --enable-migration=true
```

Execute the ipa-migration tool, and answer to the questions:

```
ipa-migrate prod-mode m1.origin.test
```

