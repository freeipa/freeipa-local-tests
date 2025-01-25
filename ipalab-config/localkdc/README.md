# Running localkdc demo with ipalab-config

## Preparing the environment

Create the configuration:

```
python3 -m venv /tmp/ipalab
. /tmp/ipalab/bin/activate
pip install -r requirements.txt
```

Build the container images and containers:

```
ipalab-config ipalab-localkdc.yaml
cd localkdc
podman build -t fedora-localkdc containerfiles/Containerfile.localkdc .
podman-compose up -d
```

Deploy the local KDC demo nodes:

```
cd localkdc
ansible-playbook -i inventory.yml playbooks/configure-localkdc.yaml
```

## Exploring the local KDC

One can login to the local KDC demo systems as root using `podman exec`:

```
podman exec -ti ab.localkdc.test bash
```

The demo playbook does not deploy FreeIPA despite using `ipalab-config`.
Instead, it sets up two separate Linux clients which both have their own local
KDCs and the same local user, 'testuser', with a password 'Secret123'. This
user is added to `wheel` group.

`ipalab-config` creates a pod which has its own network, named after the
cluster name, as specified in the configuration file. For the local KDC demo,
it is `ipanet-localkdc`. Once pod is up and running, other containers can join
that network namespace. We can use this feature to run other applications and
get access to the local hosts externally.

For example, in order to connect to a host using `ssh` client, we can use

```
$ podman run -ti --network ipanet-localkdc fedora-toolbox:latest \
             ssh -l testuser ab.localkdc.test
```

This approach has a benefit of being able to automatically resolve the demo
hostnames because `podman` will set up `/etc/hosts` inside the new container
instance. `fedora-toolbox` container image already contains `ssh` client.

### Demo system configuration

Each system is configured to use SSSD with following settings. SSSD
configuration defines a POSIX domain 'localkdc':

  - id provider is proxying to `nss_files.so` NSS module
  - auth provider is `krb5`, configured to use local KDC realm on each machine
  - PAM services are configured to allow GSSAPI authentication in `sudo` and
    `sudo-i` services

PAM stack is configured with the help of `authselect` tool and uses SSSD
profile with following features enabled:

  - `with-mkhomedir`, to create home directories automatically on login
  - `with-gssapi`, to enable use of `pam_sss_gss` PAM module for GSSAPI
    authentication 

### Add a new user

Since authentication of the user accounts is handled with the help of local
KDC, a separate database of Kerberos principals is maintained in addition to
the system-wide user store in `/etc/passwd`.

A new user account can be added with `useradd` tool. However, in order to set a
password for this new account, a Kerberos principal needs to be added with
`localkdc-kadmin` tool. `localkdc-kadmin` is a wrapper around `kadmin.local`
tool to work on the local KDC database.

```
# useradd newuser
# localkdc-kadmin addprinc newuser
```

### Use of Kerberos tools

MIT Kerberos library used in the local KDC demo is modified to support UNIX
domain sockets for communication with the KDC. This functionality has been
merged upstream (and not yet released as of January 2025). However, socket
activation support isn't merged yet, its development continues.

Standard Kerberos tools (`kinit`, `klist`, `kvno`, ...) do work transparently
with socket-activated UNIX domain socket transport. In order to see that a tool
is communicating over UNIX domain socket, one can use `KRB5_TRACE=/dev/stdout`
environment variable. This will enable internal `libkrb5` tracing and will show
how communication is happening.

In the example below we first connect to the host over SSH protocol and
authenticate with a password. This is verified by SSSD using `pam_sss` PAM
module and produces an initial ticket granting ticket (TGT) in the Kerberos
credentials cache which can be seen with the help of `klist` command:

```
$ podman run -ti --network ipanet-localkdc registry.fedoraproject.org/fedora-toolbox:latest \
         ssh -l testuser ab.localkdc.test
The authenticity of host 'ab.localkdc.test (192.168.221.2)' can't be established.
ED25519 key fingerprint is SHA256:DJEnxvJgd50csPmB3+bgHH2+Qfgr0y3Bnfrr7lEo1nA.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ab.localkdc.test' (ED25519) to the list of known hosts.
testuser@ab.localkdc.test's password:
Last login: Sat Jan 25 12:00:39 2025 from 192.168.221.8
[testuser@ab ~]$ klist
Ticket cache: KCM:1000:81791
Default principal: testuser@AB.LOCALKDC.SITE

Valid starting     Expires            Service principal
01/25/25 12:01:21  01/26/25 12:01:21  krbtgt/AB.LOCALKDC.SITE@AB.LOCALKDC.SITE
	renew until 02/01/25 12:01:21
```

In a separate console obtained with the help of `podman exec -ti ab.localkdc.test`,
we can see that the local KDC did accept this connection over UNIX domain scoket and
issued the Kerberos ticket, as recorded in the `/var/log/localkdc.log` (the
output excerpt has been reformatted for convenience):

```
Jan 25 12:01:21 ab.localkdc.test krb5kdc[781](info): AS_REQ
   (6 etypes {aes256-cts-hmac-sha384-192(20), aes128-cts-hmac-sha256-128(19),
              aes256-cts-hmac-sha1-96(18), aes128-cts-hmac-sha1-96(17),
              camellia256-cts-cmac(26), camellia128-cts-cmac(25)})
   /run/localkdc/kdc.sock: ISSUE: authtime 1737806481, 
   etypes {rep=aes256-cts-hmac-sha384-192(20), tkt=aes256-cts-hmac-sha384-192(20), ses=aes256-cts-hmac-sha384-192(20)},
   testuser@AB.LOCALKDC.SITE for krbtgt/AB.LOCALKDC.SITE@AB.LOCALKDC.SITE
```

After that, we can ask for a service ticket to a different service, in this
case it would be `host/ab.localkdc.test`. By using `KRB5_TRACE=/dev/stdout`,
internal `libkrb5` tracing is enabled, showing that the program communicates
with the KDC over the UNIX domain socket:

```
[testuser@ab ~]$ KRB5_TRACE=/dev/stdout kvno -S host `hostname` | grep 'domain socket'
[988] 1737806486.208476: Sending TCP request to UNIX domain socket /run/localkdc/kdc.sock
[988] 1737806486.208477: Received answer (1234 bytes) from UNIX domain socket /run/localkdc/kdc.sock
[988] 1737806486.208478: Terminating TCP connection to UNIX domain socket /run/localkdc/kdc.sock
```

### Using Samba with local KDC from the local machine

Once initial Kerberos ticket granting ticket is obtained, it can be used to
sign-in to different applications. The demo comes with Samba server
pre-configured and `smbclient` can be used to authenticate without passwords:

```
$ smbclient --use-kerberos=required --use-krb5-ccache=KCM: --client-protection=encrypt //`hostname`/homes
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Sat Jan 25 12:08:24 2025
  ..                                  D        0  Sat Jan 25 12:08:24 2025
  .bash_logout                        H       18  Mon Aug 12 00:00:00 2024
  .bash_profile                       H      144  Mon Aug 12 00:00:00 2024
  .bashrc                             H      522  Mon Aug 12 00:00:00 2024
  .bash_history                       H      149  Sat Jan 25 12:01:14 2025
  .cache                             DH        0  Sat Jan 25 12:08:24 2025

		998523904 blocks of size 1024. 589686508 blocks available
smb: \> 

```

From the separate session obtained with the help of `podman exec -ti ab.localkdc.test`,
we can see that this connection has indeed been established:

```
$ podman exec -ti ab.localkdc.test smbstatus

Samba version 4.21.3
PID     Username     Group        Machine                                   Protocol Version  Encryption           Signing
----------------------------------------------------------------------------------------------------------------------------------------
1091    testuser     testuser     192.168.221.2 (ipv4:192.168.221.2:43092)  SMB3_11           AES-128-GCM          AES-128-GMAC

Service      pid     Machine       Connected at                     Encryption   Signing
---------------------------------------------------------------------------------------------
testuser     1091    192.168.221.2 Sat Jan 25 12:17:22 PM 2025 UTC  -            -

No locked files
```

### Using Samba with local KDC from the remote machine

We can connect to Samba also from the remote machine. In this case, the client
system will not have access to the local KDC on the machine where Samba is
running. However, `smbclient` will be able to use IAKerb protocol extension to
proxy Kerberos requests to the local KDC.

```
$ podman exec -ti asn.localkdc.test smbclient -U testuser@AB.LOCALKDC.SITE //ab.localkdc.test/homes
Password for [testuser@AB.LOCALKDC.SITE]:
....
smb: \>
```

An authentication in this case will use Kerberos mechanism but will require
password to proxy the request to the local KDC on Samba server side over the
SMB3 connection.


