# Running IPA-to-IPA trust with ipalab-config

The containers need to be run as `root` due to `subuid` and `subgui` limits.

```nohl
sh# whoami
root
```

## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Build the containers:

```
ipalab-config -f containerfile-fedora ipalab-idmtoidm-trust.yaml
podman-compose -f idm2idm-trust/compose.yml up -d --build
ansible-galaxy collection install -r idm2idm-trust/requirements.yml
```

Deploy the IPA cluster:

```
ansible-playbook -i idm2idm-trust/inventory.yml idm2idm-trust/playbooks/install-cluster.yml
```

Establish trust:

```
ansible-galaxy collection install ansible.posix
ansible-playbook -i idm2idm-trust/inventory.yml establish-trust.yaml
```
