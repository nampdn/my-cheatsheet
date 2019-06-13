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

## Ceph Deploy

```bash
mkdir ~/ceph

cd ~/ceph

ceph-deploy new node1

ceph-deploy admin deployer node1 node2 node3
```

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




# Remove OSD

Remove an OSD from cluster gracefully
Here, I will discuss the process of removing an OSD from Ceph cluster gracefully without impacting the customer operations and network bandwidth. Please refer the below process to remove an OSD from the cluster.

Pre-requisites:

To make less impact  the ceph client/user operations performance, set the below configuration options and should be rolled-backed to default after the OSD removal process:
```bash
# ceph tell osd.* injectargs '--osd_max_backfills 1'              // Default 10
# ceph tell osd.* injectargs '--osd_recovery_max_active 1'        // Default 15
# ceph tell osd.* injectargs '--osd_recovery_op_priority 1'       // Default 10
# ceph tell osd.* injectargs '--osd_recovery_max_single_start 1'  // Default 5
Note: The above setting will slow down the recovery/backfill process and prolongs the osd removal process.
```
Step#1:

Reduce the OSD’s weight from 1 to 0 gradually -1 offset. For ex:

1 -> 0.9 -> 0.8 -> 0.7 -> 0.6 -> 0.5 -> 0.4 -> 0.3 -> 0.2 -> 0.1 -> 0.0
```bash
$ ceph osd  crush reweight osd.{osd-id}  <new_weight> 
 //  Where new_weight is 0.9 -> 0.0
 // Where id is osd-id like osd.0, isd.1 etc.
```
For ex: ceph osd crush reqeight osd.1 0.9

Note: With each new_weight, ceph cluster starts to do the re-balance
      starts by moving the data from this OSD to other OSDs.
Step#2:

Now, take out the OSD, which is in ceph cluster using the below command:
```bash
$ ceph osd out osd.{osd-id}
```
For ex: ceph osd out osd.1
Step#3:

Now, stop the OSD process/daemon and
```bash
$ /etc/init.d/ceph  stop  osd.{osd-id}
```
For ex: /etc/init.d/ceph stop osd.1   
Note: Above command requires sudo access
Once you stop the OSD, it is down.

Step#4:

Remove the specific OSD from the cluster’s crushmap.
```bash
$ ceph osd crush remove  osd.{osd-id}
```
For ex: ceph osd crush remove osd.1
Step#5:

Remove the OSD authentication key from the cluster.
```bash
$ ceph auth del osd.{osd-id}
```
For ex: ceph auth del osd.1
Step#6:

Now remove the osd
```bash
$ceph osd rm {osd-id}
#for ex: $ ceph osd rm 1
```

Rollback all the configurations set before starting the step#1:
```bash
# ceph tell osd.* injectargs '--osd_max_backfills 10'            // Default 10
# ceph tell osd.* injectargs '--osd_recovery_max_active 15'       // Default 15 
# ceph tellosd.*inj  ectargs '--osd_recovery_op_priority 10'      // Default 10
# ceph tellosd.inj * ectargs '--osd_recovery_max_single_start 5'   // Default 5
```
NOTE: If  an OSD is down due to Hardware error, then you can skip the step#1 in the above process and just use from step#2 to remove that specific OSD.
