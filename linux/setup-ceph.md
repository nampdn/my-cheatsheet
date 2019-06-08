# How to setup a production Ceph server

1. Quick memorable script for initial CentOS server:

* In any server do initial setup:
```
curl https://scripts.barajs.dev/linux/new-centos.sh | bash -s
```

* Prepare for ceph node:
```
curl https://scripts.barajs.dev/ceph-centos.sh | bash -s -- "ceph-username" "ceph-password"
```

2. Install `ceph-deploy` node:

```
sudo yum install -y ceph-deploy
```

## Install required dependencies

## Grant SSH access to all nodes

## Modify DNS hosts file

## Create Ceph Monitor

## Transfer Ceph Admin Configuration

## Create Ceph MGR

## Create OSD

## Create Ceph FileSystem

## Mount Ceph FS

## Install Ceph Admin

* Prepare non-password user in a client:

```
echo -e 'Defaults:ubuntu !requiretty\nubuntu ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/ceph 
chmod 440 /etc/sudoers.d/ceph
```

## Create Ceph Block Device Storage

## Mount Ceph RBD
