# Hetzner

## Netplan

```yaml
### Hetzner Online GmbH installimage
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s31f6:
      match:
          macaddress: 4c:52:62:0e:08:54
      set-name: enp0s31f6
  vlans:
    enp0s31f6.4000:                                                                                                                                                                                         
      id: 4000                                                                                                                                                                                              
      link: enp0s31f6                                                                                                                                                                                       
  bridges:                                                                                                                                                                                                  
    br0:                                                                                                                                                                                                    
      mtu: 1400                                                                                                                                                                                             
      addresses: [10.1.0.2/16]                                                                                                                                                                              
      interfaces: [enp0s31f6.4000]                                                                                                                                                                          
      nameservers:                                                                                                                                                                                          
        search:                                                                                                                                                                                             
          - maas                                                                                                                                                                                            
          - vgm                                                                                                                                                                                             
        addresses: [10.1.0.1, 10.1.0.10, 1.1.1.1, 1.0.0.1]                                                                                                                                                  
      parameters:                                                                                                                                                                                           
        stp: true                                                                                                                                                                                           
        forward-delay: 4                                                                                                                                                                                    
    br1:                                                                                                                                                                                                    
      interfaces: [enp0s31f6]                                                                                                                                                                               
      routes:                                                                                                                                                                                               
        - on-link: true                                                                                                                                                                                     
          to: 0.0.0.0/0                                                                                                                                                                                     
          via: 95.216.67.1                                                                                                                                                                                  
      addresses:                                                                                                                                                                                            
        - 95.216.67.44/32                                                                                                                                                                                   
        - 2a01:4f9:2b:352::2/64                                                                                                                                                                             
      gateway6: fe80::1                                                                                                                                                                                     
      nameservers:                                                                                                                                                                                          
        addresses:                                                                                                                                                                                          
          - 213.133.98.98                                                                                                                                                                                   
          - 213.133.99.99                                                                                                                                                                                   
          - 213.133.100.100                                                                                                                                                                                 
          - 2a01:4f8:0:1::add:1010                                                                                                                                                                          
          - 2a01:4f8:0:1::add:9898                                                                                                                                                                          
          - 2a01:4f8:0:1::add:9999                                                                                                                                                                          
```

## vSwitch VLAN:

```
sudo /lib/netplan/generate
sudo systemctl restart systemd-networkd
```


## IP Forwarding between interfaces:

> vim /etc/ufw/before.rules

```
*nat
:POSTROUTING ACCEPT [0:0]

# -A POSTROUTING -s 10.1.0.0/16 -o enp0s31f6 -j MASQUERADE
-A POSTROUTING -s 10.1.0.0/16 ! -d 10.1.0.0/16 -m comment --comment "Allow vlanXX to go to the Internet, masquerade as the public IP." -j MASQUERADE
# -A FORWARD -i enp0s31f6.4000 -o enp0s31f6 -j ACCEPT
COMMIT


# Don't delete these required lines, otherwise there will be errors
*filter
:ufw-before-input - [0:0]
:ufw-before-output - [0:0]
:ufw-before-forward - [0:0]
:ufw-not-local - [0:0]
# End required lines

# Allow VLANS internet
-A FORWARD -o enp0s31f6.4000 -m comment --comment "NAT for vlanXX" -j ACCEPT
-A FORWARD -i enp0s31f6.4000 -m comment --comment "NAT for vlanXX" -j ACCEPT
-A FORWARD -o br0 -m comment --comment "NAT for vlanXX" -j ACCEPT
-A FORWARD -i br0 -m comment --comment "NAT for vlanXX" -j ACCEPT

```

> vim /etc/default/ufw

```
# Set the default forward policy to ACCEPT, DROP or REJECT.  Please note that
# if you change this you will most likely want to adjust your rules
DEFAULT_FORWARD_POLICY="ACCEPT"
```

> vim /etc/sysctl.conf

```
net.ipv4.ip_forward=1
```

> sysctl -p

```console
root@server:~# sudo ufw allow from 10.1.0.0/16
```

## LXD MAAS Profile

```yaml
config:
  raw.lxc: |-
    lxc.cgroup.devices.allow = c 10:237 rwm
    lxc.apparmor.profile = unconfined
    lxc.cgroup.devices.allow = b 7:* rwm
  security.privileged: "true"
description: Default LXD profile
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: br0
    type: nic
  loop0:
    path: /dev/loop0
    type: unix-block
  loop1:
    path: /dev/loop1
    type: unix-block
  loop2:
    path: /dev/loop2
    type: unix-block
  loop3:
    path: /dev/loop3
    type: unix-block
  loop4:
    path: /dev/loop4
    type: unix-block
  loop5:
    path: /dev/loop5
    type: unix-block
  loop6:
    path: /dev/loop6
    type: unix-block
  loop7:
    path: /dev/loop7
    type: unix-block
  root:
    path: /
    pool: default
    type: disk
name: maas
```

### LXD JuJu Config

```yaml
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
  volatile.base_image: a92eaa65a5c5e53c6bf788b4443f4e5d2afac1665486247c336aa90959522bb6
  volatile.eth0.host_name: veth11e4c051
  volatile.eth0.hwaddr: 00:16:3e:72:b2:f0
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


## Libvirt

### Install libvirt

```console
root@server:# apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
```
### Virsh Network

```console
root@fi-hel-s1 ~ # cat virsh/network.xml 
<network>  
    <name>default</name>  
    <forward mode="bridge" />  
    <bridge name="br0" />  
</network>
```

> virsh edit <domain>
  
```xml
<interface type='network'>
  <mac address='52:54:00:f4:2b:e2'/>
  <source network='public'/>
  <model type='virtio'/>
  <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
</interface>
```

### Libvirt mount block device

```xml
<disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none'/>
      <source dev='/dev/sdb'/>
      <target dev='sdb' bus='virtio'/>
</disk>
```


## HAPROXY
```console
root@public-host:~# sudo apt-get update
root@public-host:~# sudo apt-get install zfsutils-linux snapd
root@public-host:~# snap install lxd
root@public-host:~# lxd init
root@public-host:~# lxc launch ubuntu:20.04 haproxy
```

On container:
```console
root@haproxy:~# vim /etc/haproxy/haproxy.cfg
```

Edit `haproxy.cfg` file:

```HAProxy
defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        option  forwardfor
        option  http-server-close
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

frontend www_frontend
        bind *:80
        acl openstack_dashboard hdr(host) -i vgm.cloud
        acl ceph_radosgw hdr(host) -i s3.vgm.cloud

        use_backend dashboard_cluster if openstack_dashboard
        use_backend radosgw_cluster if ceph_radosgw

backend dashboard_cluster
        balance leastconn
        http-request set-header X-Client-IP %[src]
        server dashboard dashboard.vgm:80 check

backend radosgw_cluster
        balance leastconn
        http-request set-header X-Client-IP %[src]
        server radosgw s3.vgm:80 check
```

On Gateway machine (with public IP):
```
*nat
:PREROUTING ACCEPT [0:0]
-A PREROUTING -p tcp -i enp0s31f6 -d 95.216.67.44/32 --dport 80 -j DNAT --to-destination 10.1.0.198:80
COMMIT
```

```console
root@public-host ~ # ufw route allow in on enp0s31f6 to 10.1.0.198 port 80 proto tcp
root@public-host ~ # lxc config device add haproxy myport80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
```
