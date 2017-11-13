# How to create a partition above 2TB in linux

## Requirements
Install `parted`:
```bash
apt-get install -y parted
```
## Identify your hard drive

Find your drive names: 
```bash
lsblk
```

Run fdisk for selected drive for info:

```bash
fdisk -l /dev/<your harddrive name here>

# Example:
fdisk -l /dev/sdb
```

## Creating the partition table

Run parted: `parted /dev/<your harddrive name here>`
```bash
parted /dev/sdb
```
## Create the GPT partition table
To create a GPT partition table:
```bash
mklabel gpt
```
### Set the unit to GB
```bash
unit GB
```
### Create the partition
```bash
mkpart primary <from GB> <to GB>

# Example:
mkpart primary 0.0GB 4000.8GB
```

### View the partition table
To view the partition table:
```bash
print
```
Quit parted:
```bash
quit
```

## Create the filesystem

```bash
mkfs.ext4 /dev/<your drivename and partition number here>

# Example:
mkfs.ext4 /dev/sdb1
```

### Add the partition to fstab and mounting it
Create new directory for mount point:
```bash
mkdir /<your mount dir>

# Example
mkdir /store
```

Open fstab file:
```bash
vim /etc/fstab
```

Add the following line at the bottom:
```bash
/dev/<your drivename and partition number>               /store                  <your filesystem>    defaults        0 0

# Example:
/dev/sdb1              /store                  ext4    defaults        0 0
```
## Mount the partition
```bash
mount /<your mount dir>

# Example:
mount /store
```


