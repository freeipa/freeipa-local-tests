# Running IPA-to-IPA trust with ipalab-config

## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Build the containers:

```
ipalab-config -f containerfile-fedora -p playbooks ipalab-idmtoidm-trust.yaml
cd idm2idm-trust
podman-compose up -d --build
ansible-galaxy collection install -r requirements.yml
```

Deploy the IPA cluster:

```
ansible-playbook -i inventory.yml playbooks/install-cluster.yml
```

Establish trust:

```
ansible-galaxy collection install ansible.posix
ansible-playbook -i inventory.yml playbooks/establish-trust.yaml
```
