#!/bin/bash -eu

# vcr: -- This script is used to creath the vhs tape using vcr
# vcr: -- vcr: https://github.com/rjeffman/vcr

# vcr: hide
export PS1='[\\W]$ '
command -v deactivate && deactivate
rm -rf /tmp/ipa-tuura-keycloak

# vcr: clear show
# Install support software
python3 -m venv /tmp/ipa-tuura-keycloak
. /tmp/ipa-tuura-keycloak/bin/activate
pip install -r requirements.txt

# vcr: clear
# Create and activate the configuration
ipalab-config lab_ipa_tuura.yml
cd ipa-tuura-keycloak
podman-compose build
podman-compose up -d

# Trust Keycloak self-signed certificate
keycloak/trust_keycloak.sh ipatuura

# vcr: clear
# Install containers.podman collection
ansible-galaxy collection install containers.podman
# Install freeipa.ansible_freeipa collection
ansible-galaxy collection install freeipa.ansible_freeipa

# vcr: clear
# Video cut to deploy IPA cluster
# ansible-playbook -i inventory.yml ${ansible_freeipa_collection_path}\install-cluster.yml
# vcr: -- Hide IPA installation for smaller video.
# vcr: hide timeout=10m
ansible-playbook -i inventory.yml ~/.ansible/collections/ansible_collections/freeipa/ansible_freeipa/playbooks/install-cluster.yml

# vcr: show
# Create Keycloak OIDC client
keycloak/keycloak_add_oidc_client.sh  server.ipa.test ipa_oidc_client Secret123

# Configure IDP endpoint in IPA
# ansible-playbook -i inventory.yml playbooks/idp_keycloak.yml

# Test Automatic provisioning with user 'jdoe'

# Add user to IPA
ansible-playbook -i inventory.yml playbooks/add_user_auth_idp.yml

# Authenticate in Keycloak
#keycloak/keycloak_add_user.sh jdoe jdoe@example.test userPASS

# kinit user jdoe on IPA server
#podman exec server kinit -n -c /fast.ccache
# vcr: timeout=5s
#podman exec server kinit -T /fast.ccache jdoe

# Some issues may be present in this demo, and for a complete execution, access to a browser is needed.

