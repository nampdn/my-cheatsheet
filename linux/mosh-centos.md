# How to install MOSH Server

## Install Mosh

```shell
sudo yum install -y mosh
sudo firewall-cmd --zone=public --add-service=mosh --permanent
sudo firewall-cmd --reload
```
