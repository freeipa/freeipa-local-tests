# Using ipalab-config for Testing Complex FreeIPA Features

**ipalab-config** is a tool designed to create the necessary configuration to experiment with FreeIPA and ansible-freeipa using containers. It generates the files required to compose containers (using tools like `podman-compose`) and deploy FreeIPA on them using the ansible-freeipa collection.

ipalab-config:
- Simplifies testing and experimentation with FreeIPA.
- Facilitates deployment of FreeIPA clusters in a containerized environment.
- Seamless integration with the ansible-freeipa collection for automation.


## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Then iplab-config tool can be used for building the containers, generating the configuration files (podman-compose) as well as deploying FreeIPA in the clusters.


## Use Cases

### FreeIPA-to-FreeIPA Trust
This use case demonstrates the setup and testing of trust relationships between two FreeIPA domains. Detailed instructions can be found in the [ipa-trust README](./ipa-trust/README.md).

### FreeIPA-to-FreeIPA Migration
This use case focuses on migrating FreeIPA setups between environments.
Detailed instructions can be found in the [ipa-migration README](./ipa-migration/README.md).

