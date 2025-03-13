Require ssh
Require klist
Require smbclient

Set Theme GruvboxDark
Set Shell "bash"
Set FontSize 16
Set Width 1200
Set Height 800
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
Sleep 2s
Type "yes"
Enter
Sleep 2s
Type "Secret123"
Enter
Sleep 2s
Type "# We are in. Kerberos ticket was obtained upon login:"
Enter
Type "klist"
Enter
Sleep 2s
Type "# Communication with KDC is done over UNIX domain socket"
Enter
Sleep 1s
Type "KRB5_TRACE=/dev/stdout kvno -S host `hostname` | grep socket"
Enter
Sleep 5s
Hide
Type "clear"
Enter
Show
Type "# We can use Kerberos tickets to access other applications"
Enter
Type "id"
Enter
Sleep 3s
Type "# The user belongs to the 'wheel' group and can use SUDO"
Enter
Type "authselect current"
Enter
Sleep 2s
Type "# Authenticate SUDO with GSSAPI, press ENTER and no password: "
Enter
Sleep 2s
Type "sudo -i"
Enter
Sleep 1s
Enter
Sleep 2s
Type "id"
Enter
Sleep 2s
Type "systemctl status localkdc.socket"
Enter
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
Sleep 2s
Enter
Sleep 1s
Type "dir"
Enter
Sleep 2s
Ctrl+D
Sleep 1s
Type "# Samba client obtained a Kerberos service ticket to CIFS service (Samba)"
Enter
Type "klist"
Enter
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
Sleep 2s
Type "smbclient -U testuser --client-protection=encrypt //asn.localkdc.test/homes"
Enter
Sleep 1s
Type "Secret123"
Enter
Sleep 1s
Type "dir"
Enter
Ctrl+D
Sleep 2s
Type "# Let us check whether the Samba authenticated via IAKerb extension:"
Enter
Sleep 1s
Type "ssh testuser@asn.localkdc.test"
Enter
Sleep 1s
Type "yes"
Enter
Sleep 1s
Type "Secret123"
Enter
Sleep 1s
Type "sudo -i"
Enter
Sleep 1s
Enter
Sleep 1s
Type "grep AuthZ /var/log/samba/audit.log | tail -1"
Enter
Sleep 6s
Ctrl+D
Ctrl+D
Ctrl+D
Sleep 2s
Type "# Thank you!"
Enter
Ctrl+D

