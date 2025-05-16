Require ssh
Require klist
Require smbclient

Set Theme GruvboxDark
Set Shell "bash"
Set FontSize 18
Set Width 1920
Set Height 1080
Output localkdc-demo.webm

Type "# Welcome to the local KDC demo!"
Enter
Type "# Local KDC runs Kerberos services on demand over UNIX domain socket"
Enter
Type "# Let's start by logging into the system as a test user with a password"
Enter
Sleep 1s
Type "ssh testuser@ab.localkdc.test"
Enter
Wait /\)\?/
Type "yes"
Enter
Wait /password:/
Type "Secret123"
Enter
Wait /\]\$/
Type "# We are in. Kerberos ticket was obtained upon login:"
Enter
Type "klist"
Enter
Wait /\]\$/
Type "# Communication with KDC is done over UNIX domain socket"
Enter
Wait /\]\$/
Type "KRB5_TRACE=/dev/stdout kvno -S host `hostname` | grep socket"
Enter
Wait /\]\$/
Sleep 5s
Hide
Type "clear"
Enter
Show
Type "# We can use Kerberos tickets to access other applications"
Enter
Type "id"
Enter
Wait /\]\$/
Type "# The user belongs to the 'wheel' group and can use SUDO"
Enter
Type "authselect current"
Enter
Wait /\]\$/
Type "# Authenticate SUDO with GSSAPI, press ENTER and no password: "
Enter
Sleep 2s
Type "sudo -i"
Enter
Wait /password for/
Enter
Wait /\]#/
Type "id"
Enter
Wait /\]#/
Type "systemctl status localkdc.socket"
Enter
Wait /\]#/
Sleep 3s
Ctrl+D
Type "klist"
Enter
Sleep 3s
Hide
Type "clear"
Enter
Show
Type "# Access a home SMB share on the same machine with Kerberos authentication: "
Enter
Sleep 2s
Type "smbclient --use-kerberos=required --use-krb5-ccache=KCM: --client-protection=encrypt //`hostname`/homes"
Enter
Wait /\\>/
Type "dir"
Enter
Wait /\\>/
Ctrl+D
Sleep 1s
Type "# Samba client obtained a Kerberos service ticket to CIFS service (Samba)"
Enter
Type "klist"
Enter
Wait /\]\$/
Sleep 4s
Type "# We can also check the Samba audit events:"
Enter
Type "sudo grep AuthZ /var/log/samba/audit.log | tail -1"
Enter
Sleep 8s
Hide
Type "clear"
Enter
Show
Type "# Access a home SMB share on a different machine with Kerberos IAKerb extension: "
Enter
Type "# This time we would type a password but Samba will not use NTLM protocol"
Enter
Type "# Notice also we do not specify any Kerberos realm"
Enter
Wait /\]\$/
Type "smbclient -U testuser --client-protection=encrypt //asn.localkdc.test/homes"
Enter
Wait /\]:/
Type "Secret123"
Enter
Wait /\\>/
Type "dir"
Enter
Ctrl+D
Wait /\]\$/
Sleep 2s
Type "# Let us check whether the Samba authenticated via IAKerb extension:"
Enter
Sleep 1s
Type "ssh testuser@asn.localkdc.test"
Enter
Wait /\)\?/
Type "yes"
Enter
Wait /password:/
Type "Secret123"
Enter
Wait /\]\$/
Type "sudo -i"
Enter
Wait /password for/
Enter
Wait /\]#/
Type "grep AuthZ /var/log/samba/audit.log | tail -1"
Enter
Sleep 6s
Ctrl+D
Ctrl+D
Sleep 4s
Hide
Type "clear"
Enter
Show
Type "# This also works over IP addresses: "
Enter
Sleep 2s
Type "kdestroy -A"
Enter
Sleep 1s
Type "smbclient -U testuser --client-protection=encrypt --use-kerberos=required --use-krb5-ccache=KCM: //192.168.221.3/homes"
Enter
Wait /\]:/
Type "Secret123"
Enter
Wait /\\>/
Sleep 1s
Type "dir"
Enter
Ctrl+D
Type "klist"
Enter
Sleep 4s
Ctrl+D
Ctrl+D
Ctrl+D
Type "# Thank you!"
Enter
Ctrl+D

