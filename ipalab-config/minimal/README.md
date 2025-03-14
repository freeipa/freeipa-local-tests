# Minimal FreeIPA deployment with ipalab-config



## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Build the container image and instantiate containers:

```
ipalab-config minimal.yaml
cd minimal
podman build -f containerfiles/Containerfile.minimal -t ipalab-minimal-demo .
podman-compose up -d
```


At this point a podman pod with two container instances should be created

```
$ podman pod ps -f name=minimal
POD ID        NAME         STATUS      CREATED         INFRA ID    # OF CONTAINERS
eaa61b561fdc  pod_minimal  Running     18 minutes ago              2
```

`ipalab-config` creates a pod which has its own network, named after the
cluster name, as specified in the configuration file. For the minimal IPA demo,
it is `ipanet-minimal`. Once pod is up and running, other containers can join
that network namespace. We can use this feature to run other applications and
get access to the local hosts externally.

A network associated with the pod can also be inspected:

```
$ podman network inspect ipanet-minimal \
    --format "{{range .Containers}}Host name: {{.Name}}\n\tNetwork: {{range .Interfaces}}{{range .Subnets}}{{.IPNet}}{{end}}{{end}}\n{{end}}"
Host name: client.minimal.test
	Network: 192.168.111.3/24
Host name: dc.minimal.test
	Network: 192.168.111.2/24
```

## Deploy the environment

After `podman-compose up -d`, we can deploy the environment using
ansible-freeipa playbooks. These playbooks installed by `ipalab-config`
automatically:

```
ansible-playbook -i inventory.yml ${HOME}/.ansible/collections/ansible_collections/freeipa/ansible_freeipa/playbooks/install-cluster.yml
```

After successful run of the playbook two FreeIPA systems would be provisioned:

- `dc.minimal.test` is the FreeIPA server

- `client.minimal.test` is FreeIPA client enrolled into `MINIMAL.TEST`
  deployment against `dc.minimal.test` IPA server.


## Explore the environment

In order to connect to a host using `ssh` client, we can use

```
$ podman run -ti --network ipanet-minimal fedora-toolbox:latest \
             ssh -l admin client.minimal.test
```

This approach has the benefit of being able to automatically resolve the demo
hostnames because `podman` will set up `/etc/hosts` inside the new container
instance. `fedora-toolbox` container image already contains `ssh` client.

Alternatively, `podman exec` can be used to run commands as root:

```
$ podman exec -ti client.minimal.test bash
[root@client /]# id
uid=0(root) gid=0(root) groups=0(root)
```

## Record a demo

Video recording is built upon excellent
[VHS](https://github.com/charmbracelet/vhs) tool. A pre-built version for
Fedora is provided in [COPR
abbra/vhs](https://copr.fedorainfracloud.org/coprs/abbra/vhs/). This build also
includes a fix from the upstream
[PR#551](https://github.com/charmbracelet/vhs/pull/551).

The lab includes a sample tape to record a video. Ansible playbook
`playbooks/record-demo.yaml` can be used to perform this operation. 
VHS tool is not pre-installed in the images and thus the playbook will enable
COPR repository first, install the tool and then will copy
`playbooks/tapes/basic-demo.tape` to the `client.minimal.test` system and run
the `vhs` tool.

VHS needs embedded browser for its operation. It will cache Chromium build on
first run.

```
$ ansible-playbook -i inventory.yml playbooks/record-demo.yaml
```

Resulting video is then fetched to `results/basic-demo.webm`.


 
