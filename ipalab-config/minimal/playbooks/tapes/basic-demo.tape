Require ssh
Require klist

Set Theme GruvboxDark
Set Shell "bash"
Set FontSize 16
Set Width 1200
Set Height 800
Output basic-demo.webm

Type "# Welcome to the demo!"
Enter
Type "# Let's start by logging into the system as an admin with a password"
Enter
Sleep 1s
Type "ssh admin@`hostname -f`"
Enter
Wait+Line / Password:/
Type "Secret123"
Enter
Wait+Line /-sh-|\]\$/
Type "# We are in. Kerberos ticket was obtained upon login:"
Enter
Type "klist"
Enter
Sleep 2
Type "# Try to access IPA API"
Enter
Type "ipa ping"
Enter
Sleep 2
Type "# Done!"
Enter
Ctrl+D
