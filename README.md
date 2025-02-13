# Run complex FreeIPA tests in your podman compose

This project demonstrates how complex multi-system FreeIPA deployments can be
tested locally. The test environment is built with the help of
[podman](https://podman.io) and orchestrated with
[ipalab-config](https://github.com/rjeffman/ipalab-config) and
[podman-compose](https://github.com/containers/podman-compose) tools. FreeIPA
environment is deployed with the help of
[ansible-freeipa](https://github.com/freeipa/ansible-freeipa).

## Demo labs

Following configurations provided as 'labs' that can be reproduced using
`ipalab-config` tool and the configurations from this project:

 - [minimal deployment](ipalab-config/minimal/README.md), consisting of a
   FreeIPA server and a FreeIPA client enrolled into it.

 - [local KDC](ipalab-config/localkdc/README.md), consisting of two
   standalone machines, not enrolled into any domain. Each machine runs its own
   Kerberos KDC exposed to local applications over UNIX domain socket, with socket
   activation handled by systemd. See ["localkdc - local authentication hub"](https://fosdem.org/2025/schedule/event/fosdem-2025-5618-localkdc-a-general-local-authentication-hub/)
   talk at FOSDEM 2025. This is currently a work in progress.

 - [FreeIPA deployment migration](ipalab-config/ipa-migrate/README.md),
   demonstrating how IPA data can be migrated between separate test and
   production deployments. See ["FreeIPA-to-FreeIPA Migration: Current
   Capabilities and Use Cases"](https://fosdem.org/2025/schedule/event/fosdem-2025-5175-freeipa-to-freeipa-migration-current-capabilities-and-use-cases/)
   talk at FOSDEM 2025.

 - [FreeIPA trust](ipalab-config/ipa-trust/README.md), demonstrating how two
   separate IPA deployments can be set up to trust each other. See ["Building Cross-Domain Trust Between FreeIPA Deployments"](https://fosdem.org/2025/schedule/event/fosdem-2025-5178-building-cross-domain-trust-between-freeipa-deployments/) talk at FOSDEM 2025. This is currently a work in progress.

## Demo recordings

Some of the demo labs have automated recording of the operations that could be performed on them.
Video recording is built upon excellent
[VHS](https://github.com/charmbracelet/vhs) tool. A pre-built version for
Fedora is provided in [COPR
abbra/vhs](https://copr.fedorainfracloud.org/coprs/abbra/vhs/). This build also
includes a fix from the upstream
[PR#551](https://github.com/charmbracelet/vhs/pull/551).

### Minimal deployment demo

This demo recording includes a minimal use of FreeIPA command line:

 - an administrator logs into a client system over SSH using a password
 - Kerberos ticket is obtained automatically by the SSSD
 - IPA command line tool can authenticate to IPA server using Kerberos

![Watch demo](images/basic-demo.webm)

### Local KDC demo

The local KDC demo is more evolved:

 - a user logs into their own machine over SSH using a password
 - Kerberos ticket is obtained automatically by the SSSD from the local KDC which is activated on demand
 - User then uses a Kerberos ticket to authenticate to SUDO and obtain root privileges
 - The user also uses the Kerberos ticket to authenticate to Samba server running locally
 - Finally, the user authenticates with Kerberos IAKerb extension to a remotely running Samba server, removing completely a need for NTLM authentication protocol

![Watch demo](images/localkdc-demo.webm)

### IPA to IPA trust demo

This is a minimalistic demo of how users and groups from one IPA environment
can be resolved in the other IPA environment. There is a trust agreement
established between both IPA environments, similarly how IPA can establish a
forest level trust with Active Directory.

![Watch demo](images/ipa2ipa-trust-demo.webm)

