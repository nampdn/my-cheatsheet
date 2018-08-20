# How to mount remote disk

## Install SSHFS on the client side:

```
sudo apt-get install sshfs
```

## Create mount point:

```
mkdir /mnt/<mounted_disk>
```

## Mount:

```bash
sudo sshfs -p <PORT> -o allow_other <user>@<host>:<root_path_to_mount> /mnt/<mounted_disk>
```
