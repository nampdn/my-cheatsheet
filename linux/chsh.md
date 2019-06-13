# Change Default Shell

The following prevents locked-down accounts from changing their shells, and selectively lets people use chsh themselves WITHOUT sudo or su:

Simple setup that is still secure:
Add this very top of /etc/pam.d/chsh:
```bash
# This allows users of group chsh to change their shells without a password.
#
# Per: http://serverfault.com/questions/202468/changing-the-shell-using-chsh-via-the-command-line-in-a-script
#
auth       sufficient   pam_wheel.so trust group=chsh
```

Create the chsh group:
```bash
groupadd chsh
```

```bash
For any user allowed to change their shell:
    `usermod -a -G chsh username`
Money shot:

```bash
user@host:~$ getent passwd $USER
user:x:1000:1001::/home/user:/bin/bash
user@host:~$ chsh -s `which zsh`
user@host:~$ getent passwd $USER
user:x:1000:1001::/home/user:/usr/bin/zsh
user@host:~$ 
```
