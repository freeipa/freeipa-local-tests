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

## Create some objects in the origin server

To deploy identity materials to the origin server, follow these steps.


Generate data (users, groups, hosts, sudorules, hbacrules, ...) as an ldif file, and copy the file to the origin server container:

```
python ./scripts/create-data-ldif.py > data.ldif
podman cp data.ldif m1.origin.test:/tmp/data.ldif
```

Access the origin server container, and add the content (the server must be in migration mode to allow pre-hashed passwords):

```
podman exec -it m1.origin.test bash
echo Secret123 | kinit
ipa config-mod --enable-migration=true
ldapadd -x -D 'cn=directory manager' -W < data.ldif
ipa config-mod --enable-migration=false
```


Alternatively you can also add users and groups using regular ansible playbooks:

```
ansible-playbook -i inventory.yml playbooks/users_present.yml
ansible-playbook -i inventory.yml playbooks/groups_present.yml
```

## Test migration procedure

Now, to test the migration process, access the target server container:

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


## Troubleshooting
Disaster recovery. The following commands are commonly used to stop all containers, prune unused resources, and remove images:

```
podman stop --all
podman system prune --all --force && podman rmi --all
```

Connect to the Containers:

```
podman ps
podman exec -it <name> bash
```
