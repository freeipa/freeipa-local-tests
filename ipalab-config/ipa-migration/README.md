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
podman-compose -f ipalab-migration/compose.yml up -d --build
ansible-galaxy collection install -r ipalab-migration/requirements.yml
```

Deploy the IPA cluster:

```
ansible-playbook -i ipalab-migration/inventory.yml ipalab-migration/playbooks/install-cluster.yml
```

Migrate from origin to target deployment:

```
ansible-galaxy collection install ansible.posix
ansible-playbook -i ipa-migration/inventory.yml ipa-migration/playbooks/ipa-migrate.yaml
```
