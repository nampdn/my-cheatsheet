Tested on Debian.

Edit the default locale:
```
sudo vim /etc/default/locale
```
Add the following:
```
LANGUAGE=en_US.UTF-8
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
```
Run these commands:
```
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
```
Note if you're connecting to a server the issue might be on either your machine or the server.
