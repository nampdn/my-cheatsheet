Source: https://yping88.medium.com/use-ubuntu-server-20-04-cloud-image-to-create-a-kvm-virtual-machine-with-fixed-network-properties-62ecae025f6c

Use Ubuntu Server Cloud Image to Create a KVM Virtual Machine with Fixed Network Properties

Image by Emma Ping
In most cases, users can perform their tasks against KVM Virtual Machines (VM) without knowing their network configuration, such as the Media Access Control (MAC) addresses and the network interface names. KVM automatically generates a MAC address and assigns a default network interface name and a dynamic IP address for the guest VM if a user does not provide them when creating the VM.
However, it will sometimes require static or fixed values to configure some network properties before setting up a guest VM, especially when it comes to VM provisioning.
This post is a step-by-step tutorial that will help you to create a KVM VM using Ubuntu server 20.04 cloud image with the following network properties: a static MAC address, a pre-defined network interface name, and a static internal IP address.
Preparation
Re-synchronize the package index files from their sources and install the newest versions of all packages currently installed on the system:
$ sudo apt update && sudo apt upgrade -y
$ sudo apt update
You can check if the server supports Virtualization Technology (VT) in various methods. In this post, you use a tool, virt-host-validate, to validates that the server is configured in a suitable way to run libvirt hypervisor drivers:
$ sudo apt install -y libvirt-clients
$ sudo virt-host-validate
The validation tool will report the following warning message if the server has Intel processors. It is expected because the validation tool does not check Secure Guest on Intel processors:
QEMU: Checking for secure guest support: WARN (Unknown if this platform has Secure Guest support)
If the server has Intel processors with only VT-x (vmx) support but no VT-d support, the validation tool will report the following warning message that you can ignore:
QEMU: Checking for device assignment IOMMU support: WARN (No ACPI DMAR table found, IOMMU either disabled in BIOS or not supported by this hardware platform)
You may also see the following warning message from the validation tool for Intel processors:
QEMU: Checking if IOMMU is enabled by kernel: WARN (IOMMU appears to be disabled in kernel. Add intel_iommu=on to kernel cmdline arguments)
The solution to this issue is to enable IOMMU in your GRUB boot parameters. You can do this by setting the following in /etc/default/grub:
GRUB_CMDLINE_LINUX_DEFAULT=”intel_iommu=on”
Then update the GRUB and reboot the server:
$ sudo update-grub
$ sudo reboot
Installation of KVM and Associate Packages
Run the following command to install KVM and associate VM management packages:
$ sudo apt install -y qemu-kvm \
                      libvirt-daemon-system \
                      bridge-utils \
                      virtinst
You can verify if the libvirt daemon is active and enabled:
$ sudo systemctl status libvirtd
Run the following command to install cloud image management utilities, cloud-image-utils:
$ sudo apt install -y cloud-image-utils
You also need to add your local user to the kvm and libvirt groups:
$ sudo usermod -aG kvm $USER
$ sudo usermod -aG libvirt $USER
Log out and log back in to make the new group membership available.
Ubuntu Server Cloud Image
Create a directory for storing downloaded cloud images:
$ mkdir -p $HOME/kvm/base
Download Ubuntu Server 20.04 Cloud Image:
$ wget -P $HOME/kvm/base https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
Create another directory for your VM instance images:
$ mkdir -p $HOME/kvm/vm01
Create a disk image, vm01.qcow2, with 10 GB virtual size based on the Ubuntu server 20.04 cloud image:
$ qemu-img create -F qcow2 -b ~/kvm/base/focal-server-cloudimg-amd64.img -f qcow2 ~/kvm/vm01/vm01.qcow2 10G
Network Configuration
Use an internal Bash function, $RANDOM, to generate a MAC address and write it to an environment variable, MAC_ADDR. For KVM VMs it is required that the first 3 pairs in the MAC address be the sequence 52:54:00:
$ export MAC_ADDR=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
$ echo $MAC_ADDR
52:54:00:fa:e6:de
Define the ethernet interface name and the internal IP address to be used in the KVM VM:
$ export INTERFACE=eth001
$ export IP_ADDR=192.168.122.101
Create a network configuration file, network-config:
$ cat >network-config <<EOF
ethernets:
    $INTERFACE:
        addresses: 
        - $IP_ADDR/24
        dhcp4: false
        gateway4: 192.168.122.1
        match:
            macaddress: $MAC_ADDR
        nameservers:
            addresses: 
            - 1.1.1.1
            - 8.8.8.8
        set-name: $INTERFACE
version: 2
EOF
Cloud-Init Configuration
Create user-data:
$ cat >user-data <<EOF
#cloud-config
hostname: vm01
manage_etc_hosts: true
users:
  - name: vmadm
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/vmadm
    shell: /bin/bash
    lock_passwd: false
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    vmadm:vmadm
  expire: false
EOF
Create meta-data:
$ touch meta-data
Create a disk image, vm01-seed.qcow2, to attach with the network and cloud-init configuration:
$ cloud-localds -v --network-config=network-config ~/kvm/vm01/vm01-seed.qcow2 user-data meta-data
Provision a New Guest VM
Create and start a new guest VM with two disks attached, vm01.qcow2 and vm01-seed.qcow2:
$ virt-install --connect qemu:///system --virt-type kvm --name vm01 --ram 2048 --vcpus=2 --os-type linux --os-variant ubuntu20.04 --disk path=$HOME/kvm/vm01/vm01.qcow2,device=disk --disk path=$HOME/kvm/vm01/vm01-seed.qcow2,device=disk --import --network network=default,model=virtio,mac=$MAC_ADDR --noautoconsole
Check if the guest VM, vm01, is running:
$ virsh list
 Id   Name   State
----------------------
 8    vm01   running
Type the following command from the KVM host to login to the guest VM console:
$ virsh console vm01
Run the following command from the guest VM to verify the network interface name, IP address and MAC address:
vmadm@vm01:~$ ip addr show 
Type control + shift + ] to exit the guest VM console.
If everything is in order, you can connect to the guest VM using ssh from the KVM host:
$ ssh vmadm@192.168.122.101
Final Notes
Run the following commands to remove the guest KVM VM:
$ virsh destroy vm01
$ virsh undefine vm01
$ rm -rf ~/kvm/vm01
The network configuration file, network-config, is parsed, written, and applied to the guest VM as a netplan file. The netplan file is very selective about indentation, spacing, and no tabs. See the following link for additional help:
https://netplan.io/examples
The guest VM will get an IP address in the 192.168.122.0/24 address space in the default KVM network configuration. NAT is performed on traffic through a private bridge to the outside network. The guest VMs, however, will not be visible to other machines on the network. You can set up KVM to use a public bridge to make guest VMs appear as normal hosts to the rest of the network.
Thank you for reading!

