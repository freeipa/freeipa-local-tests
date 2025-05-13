Output out.webm
Set FontSize 16
Set Width 1200
Set Height 800
Require python3
Require podman
Sleep 2s
Hide
Type "export PS1='[\W]$ '"
Enter
Wait /.*[\$#] *$/
Type "command -v deactivate && deactivate"
Enter
Wait /.*[\$#] *$/
Type "rm -rf /tmp/ipalab-ipa-keycloak"
Enter
Wait /.*[\$#] *$/
Ctrl+L
Show
Type "`# Install support software`"
Sleep 500ms
Enter
Sleep 5s
Type "python3 -m venv /tmp/ipalab-ipa-keycloak"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type ". /tmp/ipalab-ipa-keycloak/bin/activate"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "pip install -r requirements.txt"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Sleep 3s
Ctrl+L
Type "`# Create and activate the configuration`"
Sleep 500ms
Enter
Sleep 5s
Type "ipalab-config lab_ipa_keycloak.yml"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "cd ipa-keycloak-idp"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "podman-compose build"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "podman-compose up -d"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "`# Trust Keycloak self-signed certificate`"
Sleep 500ms
Enter
Sleep 5s
Type "keycloak/trust_keycloak.sh server"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Sleep 3s
Ctrl+L
Type "`# Install containers.podman collection`"
Sleep 500ms
Enter
Sleep 5s
Type "ansible-galaxy collection install containers.podman"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "`# Install freeipa.ansible_freeipa collection`"
Sleep 500ms
Enter
Sleep 5s
Type "ansible-galaxy collection install freeipa.ansible_freeipa"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Sleep 3s
Ctrl+L
Type "`# Video cut to deploy IPA cluster`"
Sleep 500ms
Enter
Sleep 5s
Type "`# ansible-playbook -i inventory.yml ${ansible_freeipa_collection_path}install-cluster.yml`"
Sleep 500ms
Enter
Sleep 5s
Hide
Type "ansible-playbook -i inventory.yml ~/.ansible/collections/ansible_collections/freeipa/ansible_freeipa/playbooks/install-cluster.yml"
Enter
Wait@10m  /.*[\$#] *$/
Show
Type "`# Create Keycloak OIDC client`"
Sleep 500ms
Enter
Sleep 5s
Type "keycloak/keycloak_add_oidc_client.sh  server.ipa.test ipa_oidc_client Secret123"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "`# Configure IDP endpoint in IPA`"
Sleep 500ms
Enter
Sleep 5s
Type "ansible-playbook -i inventory.yml playbooks/idp_keycloak.yml"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "`# Test IDP connection with user 'jdoe'`"
Sleep 500ms
Enter
Sleep 5s
Type "`# Create user on Keycloak`"
Sleep 500ms
Enter
Sleep 5s
Type "keycloak/keycloak_add_user.sh jdoe jdoe@example.test userPASS"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "`# Add user to IPA`"
Sleep 500ms
Enter
Sleep 5s
Type "ansible-playbook -i inventory.yml playbooks/add_user_auth_idp.yml"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Sleep 5s
Ctrl+L
Type "`# kinit user jdoe on IPA server`"
Sleep 500ms
Enter
Sleep 5s
Type "podman exec server kinit -n -c /fast.ccache"
Sleep 500ms
Enter
Wait /.*[\$#] *$/
Type "podman exec server kinit -T /fast.ccache jdoe"
Sleep 500ms
Enter
Wait@5s  /.*[\$#] *$/
Type "`# Some issues may be present in this demo, and for a complete execution, access to a browser is needed.`"
Sleep 500ms
Enter
Sleep 5s
