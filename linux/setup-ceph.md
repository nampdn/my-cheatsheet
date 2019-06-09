# How to setup a production Ceph server

1. Quick memorable script for initial CentOS server:

* In any server do initial setup:
```bash
curl https://scripts.barajs.dev/linux/new-centos.sh | bash -s
```

* Prepare for ceph node:
```bash
curl https://scripts.barajs.dev/ceph-centos.sh | bash -s -- "ceph-username" "ceph-password"
```

2. Install `ceph-deploy` node:

```bash
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

```bash
# Ubuntu Client:
echo -e 'Defaults:ubuntu !requiretty\nubuntu ALL = (root) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ceph 
sudo chmod 440 /etc/sudoers.d/ceph

# Centos Client:
echo -e 'Defaults:cent !requiretty\ncent ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/ceph 
chmod 440 /etc/sudoers.d/ceph 
```

## Create Ceph Block Device Storage

```bash
rbd create -s 1024 cephfs_data/store
rbd ls cephfs_data/store
rbd feature disable cephfs_data/store object-map fast-diff deep-flatten
sudo rbd map cephfs_data/store
sudo mkfs.xfs /dev/rbd0
sudo mount /dev/rbd0 /mnt
df -hT
```

## Mount Ceph RBD
