# Install MAAS in Hetzner

## 1. Create vSwitch

https://docs.hetzner.com/robot/dedicated-server/network/vswitch

## 1.1 Provisioning Dedicated Instant

- Boot to Linux x64 rescue:

```
# installimage
```

- Chose Ubuntu 20.04 minimal
- Edit config

```
# reboot
```

## 1.2 Configure networking:

### Config vlans

Example configuration systemd and netplan (e.g.Ubuntu 18.04)
Newer instances of installimage create netplan-based network configurations on Ubuntu 18.04. The /etc/systemd/network/ directory will be empty. To set up the VLAN, you need to change the netplan file:

```yaml
#/etc/netplan/01-netcfg.yaml
### Hetzner Online GmbH installimage
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s31f6:
      addresses:
...
  vlans:
    enp0s31f6.4000:
      id: 4000
      link: enp0s31f6
      mtu: 1400
      addresses:
        - 192.168.100.2/24
```
After that you have to execute the following commands and the network should be available:

```bash
sudo /lib/netplan/generate
sudo systemctl restart systemd-networkd
```

### Use bridges

```
apt install -y bridges-utils
```

```yaml
### Hetzner Online GmbH installimage
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s31f6:
      addresses:
        - 95.216.xx.yy/32
        - 2a01:4f9:2b:352::2/64
      routes:
        - on-link: true
          to: 0.0.0.0/0
          via: 95.216.xx.z
      gateway6: fe80::1
      nameservers:
        addresses:
          - 213.133.98.98
          - 213.133.99.99
          - 213.133.100.100
          - 2a01:4f8:0:1::add:1010
          - 2a01:4f8:0:1::add:9898
          - 2a01:4f8:0:1::add:9999
  vlans:
    enp0s31f6.4000:
      id: 4000
      link: enp0s31f6
      mtu: 1400
  bridges:
    br0:
      addresses: [10.1.0.2/16]
      interfaces: [enp0s31f6.4000]
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1]
      parameters:
        stp: true
        forward-delay: 4
```


### Enable NAT forwarding
1. https://askubuntu.com/questions/1003592/how-do-i-give-vlans-internet-access

## 2. Configure LXD:

### 2.1 Install lxd

1. https://discourse.maas.io/t/non-snap-maas-installs/1308
2. https://discourse.maas.io/t/install-with-lxd/757
3. https://discourse.maas.io/t/maas-installation-from-a-snap/773

Install LXD and ZFS
Begin by installing LXD and ZFS:
```
sudo apt install lxd zfsutils-linux
sudo modprobe zfs
sudo lxd init
```
The sudo lxd init command will trigger a series of configuration questions. Except in the case where the randomly chosen subnet may conflict with an existing one in your local environment, all questions can be answered with their default values.

The bridge network is configured via a second round of questions and is named lxdbr0 by default.

Create a LXC profile for MAAS
First create a container profile by making use of the ‘default’ profile:
```
lxc profile copy default maas
```
Second, bind the network interface inside the container (eth0) to the bridge on the physical host (lxdbr0):
```
lxc profile device set maas eth0 parent lxdbr0
```
Thirdly, the maas container profile needs to be edited to include a specific set of privileges. Enter the following to open the profile in your editor of choice:
```
lxc profile edit maas
```
And replace the {} after config with the following (excluding config:):
```
config:
  raw.lxc: |-
    lxc.cgroup.devices.allow = c 10:237 rwm
    lxc.apparmor.profile = unconfined
    lxc.cgroup.devices.allow = b 7:* rwm
  security.privileged: "true"
```
The final step adds the 8 necessary loop devices to LXC:
```
for i in `seq 0 7`; do lxc profile device add maas loop$i unix-block path=/dev/loop$i; done
```
When correctly configured, the above command outputs Device loop0 added to maas for each loop device.

Launch and access the LXD container
Launch the LXD container:
```
lxc launch -p maas ubuntu:18.04 bionic-maas
```
Once the container is running, it can be accessed with:
```
lxc exec bionic-maas bash
```

### 2.2 Setup PostgresQL container

#### Initialise MAAS for a production configuration
To install MAAS in a production configuration, you need to setup PostgreSQL, as described below.

##### Setting up PostgreSQL from scratch
To set up PostgreSQL, even if it’s running on a different machine, you can use the following procedure:

You will need to install PostgreSQL on the machine where you want to keep the database. This can be the same machine as the MAAS region/rack controllers or a totally separate machine. If PostgreSQL (version 10 or better) is already running on your target machine, you can skip this step. To install PostgreSQL, run these commands:
```bash
 sudo apt update -y
 sudo apt install -y postgresql
```

Change Postgres listen addresses
```bash
vim /etc/postgresql/10/main/postgresql.conf
```

```conf
#listen_addresses = 'localhost'
```

```bash
vim /etc/postgresql/10/main/pg_hba.conf
```

```conf
Modify this section:
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
To this:
# IPv4 local connections:
host    all             all             0.0.0.0/0            md5
```

```
sudo ufw allow 5432/tcp
sudo systemctl restart postgresql
```

You want to make sure you have a suitable PostgreSQL user, which can be accomplished with the following command, where $MAAS_DBUSER is your desired database username, and $MAAS_DBPASS is the intended password for that username. Note that if you’re executing this step in a LXD container (as root, which is the default), you may get a minor error, but the operation will still complete correctly.
```
 sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
```
Create the MAAS database with the following command, where $MAAS_DBNAME is your desired name for the MAAS database (typically known as maas). Again, if you’re executing this step in a LXD container as root, you can ignore the minor error that results.
```
 sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
```
Edit /etc/postgresql/10/main/pg_hba.conf and add a line for the newly created database, replacing the variables with actual names. You can limit access to a specific network by using a different CIDR than 0/0.
```
 host    $MAAS_DBNAME    $MAAS_DBUSER    0/0     md5
```
You can then initialise MAAS via the following command:
```
 sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS
```

### 2.3 Setup MAAS container

```
root@host ~ # lxc config set maas raw.lxc "lxc.mount.auto=sys:rw"
root@host ~ # lxc config set maas security.nesting "true"
```

```
root@host ~ # lxc config show maas
architecture: x86_64
config:
  image.architecture: amd64
  image.description: ubuntu 18.04 LTS amd64 (release) (20200807)
  image.label: release
  image.os: ubuntu
  image.release: bionic
  image.serial: "20200807"
  image.type: squashfs
  image.version: "18.04"
  raw.lxc: lxc.mount.auto=sys:rw
  security.nesting: "true"
  security.privileged: "true"
  volatile.base_image: a92eaa65a5c5e53c6bf788b4443f4e5d2afac1665486247c336aa90959522bb6
  volatile.eth0.host_name: vethb0492502
  volatile.eth0.hwaddr: 00:16:3e:71:7c:86
  volatile.idmap.base: "0"
  volatile.idmap.current: '[]'
  volatile.idmap.next: '[]'
  volatile.last_state.idmap: '[]'
  volatile.last_state.power: RUNNING
devices: {}
ephemeral: false
profiles:
- maas
stateful: false
description: ""
```

```
sudo apt install -y snapd
snap install maas
```

```
# export MAAS_DBUSER=maas
# export MAAS_DBPASS=password
# export MAAS_DBNAME=maas
# export POSTGRES_HOST=10.1.0.4
# maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$POSTGRES_HOST/$MAAS_DBNAME"
```
