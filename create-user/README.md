# create-user

The ansible playbook creates a user on idrac. The current configuration creates a user with minimal permissions for monitoring.

You can run the playbook like:

```
ansible-playbook -i hosts.yaml configure_idrac_users.yaml -e idrac_new_user_id=20 -e idrac_new_username=root -e idrac_new_password=calvin
```

It will overwrite the user at `idrac_new_user_id`.

The iDrac privilge `0x9` gives permission to login and see logs.
