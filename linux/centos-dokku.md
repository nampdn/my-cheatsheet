# CentOS Dokku setup

## Fix .sshcommand

```
echo '/usr/bin/dokku' > /home/dokku/.sshcommand
chmod 0644 /home/dokku/.sshcommand
chown dokku:root /home/dokku/.sshcommand
```
