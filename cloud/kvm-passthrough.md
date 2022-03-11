# KVM passthrough Ubuntu 18.04
https://www.youtube.com/watch?v=oSpGggczD2Y

https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Setting_up_IOMMU

https://heiko-sieger.info/running-windows-10-on-linux-using-kvm-with-vga-passthrough/#About_keyboard_and_mouse

https://blog.zerosector.io/2018/07/28/kvm-qemu-windows-10-gpu-passthrough/


## Nested KVM

```xml
<cpu mode='host-passthrough' check='none'/>
```

## Steps

### Step 1: Install packages.

```
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager ovmf
```

### Step 2: Create blacklist-nouveau.conf

```
sudo vim /etc/modprobe.d/blacklist-nouveau.conf
```

Include the following:

```
blacklist nouveau
options nouveau modeset=0
```


### Step 3: Edit grub
```
sudo vim /etc/default/grub
```

```conf
GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"
```

Update your GRUB config
```
sudo update-grub
```

Determine your PCI ID's for your GPU
Run:
```
lspci -nn | grep -i nvidia

01:00.0 VGA compatible controller [0300]: NVIDIA Corporation Device [10de:1e04] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:10f7] (rev a1)
01:00.2 USB controller [0c03]: NVIDIA Corporation Device [10de:1ad6] (rev a1)
01:00.3 Serial bus controller [0c80]: NVIDIA Corporation Device [10de:1ad7] (rev a1)
```

Note it down!

Add your kernel module for VFIO-PCI
```
sudo vim /etc/modprobe.d/vfio.conf
```
i.e.
```
options vfio-pci ids=8086:1901,10de:1e04,10de:10f7,10de:1ad6,10de:1ad7
```
Add an entry to automatically load the module

```
sudo echo 'vfio-pci' > /etc/modules-load.d/vfio-pci.conf
cat /etc/modules-load.d/vfio-pci.conf
vfio-pci
```

Regenerate the kernel initramfs:

```
sudo update-initramfs -u
```

Reboot your device!

Confirm IOMMU is functioning.
```
dmesg | grep -E "DMAR|IOMMU"

[    0.000000] ACPI: DMAR 0x00000000393784B8 0000A8 (v01 ALASKA A M I    00000002      01000013)
[    0.000000] DMAR: IOMMU enabled
[    0.004000] DMAR: Host address width 39
[    0.004000] DMAR: DRHD base: 0x000000fed90000 flags: 0x0
[    0.004000] DMAR: dmar0: reg_base_addr fed90000 ver 1:0 cap 1c0000c40660462 ecap 19e2ff0505e
[    0.004000] DMAR: DRHD base: 0x000000fed91000 flags: 0x1
[    0.004000] DMAR: dmar1: reg_base_addr fed91000 ver 1:0 cap d2008c40660462 ecap f050da
[    0.004000] DMAR: RMRR base: 0x0000003988e000 end: 0x00000039ad7fff
[    0.004000] DMAR: RMRR base: 0x0000003b000000 end: 0x0000003f7fffff
[    0.004000] DMAR-IR: IOAPIC id 2 under DRHD base  0xfed91000 IOMMU 1
[    0.004000] DMAR-IR: HPET id 0 under DRHD base 0xfed91000
[    0.004000] DMAR-IR: Queued invalidation will be enabled to support x2apic and Intr-remapping.
[    0.004000] DMAR-IR: Enabled IRQ remapping in x2apic mode
[    1.218527] DMAR: No ATSR found
[    1.218563] DMAR: dmar0: Using Queued invalidation
[    1.218654] DMAR: dmar1: Using Queued invalidation
[    1.218876] DMAR: Setting RMRR:
[    1.218936] DMAR: Setting identity map for device 0000:00:02.0 [0x3b000000 - 0x3f7fffff]
[    1.218980] DMAR: Setting identity map for device 0000:00:14.0 [0x3988e000 - 0x39ad7fff]
[    1.218988] DMAR: Prepare 0-16MiB unity mapping for LPC
[    1.219024] DMAR: Setting identity map for device 0000:00:1f.0 [0x0 - 0xffffff]
[    1.219201] DMAR: Intel(R) Virtualization Technology for Directed I/O
```

This should return results!

Confirm VIFO is functioning.

```
dmesg | grep -i vfio

[    8.835590] VFIO - User Level meta-driver version: 0.3
[    8.838926] vfio_pci: add [8086:1901[ffffffff:ffffffff]] class 0x000000/00000000
[    8.838961] vfio-pci 0000:01:00.0: vgaarb: changed VGA decodes: olddecodes=io+mem,decodes=io+mem:owns=none
[    8.856051] vfio_pci: add [10de:1e04[ffffffff:ffffffff]] class 0x000000/00000000
[    8.876087] vfio_pci: add [10de:10f7[ffffffff:ffffffff]] class 0x000000/00000000
[    8.876880] vfio_pci: add [10de:1ad6[ffffffff:ffffffff]] class 0x000000/00000000
[    8.896103] vfio_pci: add [10de:1ad7[ffffffff:ffffffff]] class 0x000000/00000000
[   31.872036] vfio-pci 0000:01:00.0: enabling device (0000 -> 0003)
[   31.980174] vfio_ecap_init: 0000:01:00.0 hiding ecap 0x1e@0x258
[   31.980188] vfio_ecap_init: 0000:01:00.0 hiding ecap 0x19@0x900
[ 5028.936063]  intel_rapl_perf snd soundcore mei_me mei wmi_bmof intel_wmi_thunderbolt shpchp intel_pch_thermal mac_hid acpi_pad sch_fq_codel vfio_pci vfio_virqfd vfio_iommu_type1 vfio irqbypass ib_iser rdma_cm iw_cm ib_cm ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi parport_pc ppdev lp parport sunrpc ip_tables x_tables autofs4 btrfs zstd_compress raid10 raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0 multipath linear hid_apple hid_generic usbhid hid i915 crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcbc i2c_algo_bit drm_kms_helper aesni_intel e1000e syscopyarea aes_x86_64 sysfillrect sysimgblt crypto_simd fb_sys_fops nvme ptp glue_helper drm cryptd ahci nvme_core pps_core libahci wmi video
```

Download ISO Windows Driver:
https://docs.fedoraproject.org/quick-docs/en-US/creating-windows-virtual-machines-using-virtio-drivers.html

Customise your VM to ensure you have the following:

Chipset is Q35
If your going to not use SPICE to passthrough your audio change the sound card from ich6 to ac97 - we'll get more into later.
ac97
OVMF is used instead of BIOS for EFI functionality
Windows 10 ISO image as the source on a SATA CD Drive
Added a second SATA CD Drive and specified the VirtIO ISO image as the source on a second SATA CD Drive
Add the PCI devices for your NVidia Card and it's High Definition Audio Controller:



```
virsh edit nuc-controller



<domain type='kvm'>
  <name>nuc-controller</name>
  <uuid>08370b11-2f8c-49ff-a646-960ccc14bc51</uuid>
  <memory unit='KiB'>21069824</memory>
  <currentMemory unit='KiB'>21069824</currentMemory>
  <vcpu placement='static' current='10'>128</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-2.11'>hvm</type>
    <loader readonly='yes' type='pflash'>/usr/share/OVMF/OVMF_CODE.fd</loader>
    <nvram>/var/lib/libvirt/qemu/nvram/nuc-controller_VARS.fd</nvram>
    <bootmenu enable='yes'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <hyperv>
      <relaxed state='on'/>
      <vapic state='on'/>
      <spinlocks state='on' retries='8191'/>
      <vendor_id state='on' value='whatever'/>
    </hyperv>
    <kvm>
      <hidden state='on'/>
    </kvm>
    <vmport state='off'/>
  </features>
  <cpu mode='host-model' check='partial'>
    <model fallback='allow'/>
    <topology sockets='8' cores='8' threads='2'/>
  </cpu>
  <clock offset='localtime'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
    <timer name='hypervclock' present='yes'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/kvm-spice</emulator>
    <disk type='network' device='disk'>
      <driver name='qemu' type='raw'/>
      <auth username='libvirt'>
        <secret type='ceph' uuid='f8e3986d-2cad-4772-b840-a31ff5f73d20'/>
      </auth>
      <source protocol='rbd' name='libvirt-data/nuc-data'>
        <host name='10.0.1.22' port='6789'/>
        <host name='10.0.0.33' port='6789'/>
      </source>
      <target dev='sdd' bus='sata'/>
      <address type='drive' controller='0' bus='0' target='0' unit='3'/>
    </disk>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='/var/lib/libvirt/images/nuc-controller.qcow2'/>
      <target dev='sde' bus='sata'/>
      <boot order='1'/>
      <address type='drive' controller='0' bus='0' target='0' unit='4'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/Win10_2004_English_x64.iso'/>
      <target dev='sdf' bus='sata'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='5'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/virtio-win-0.1.185.iso'/>
      <target dev='sdg' bus='sata'/>
      <readonly/>
      <address type='drive' controller='1' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0' model='ich9-ehci1'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1d' function='0x7'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci1'>
      <master startport='0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1d' function='0x0' multifunction='on'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci2'>
      <master startport='2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1d' function='0x1'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci3'>
      <master startport='4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1d' function='0x2'/>
    </controller>
    <controller type='sata' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
    </controller>
    <controller type='sata' index='1'>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x01' function='0x0'/>
    </controller>
    <controller type='pci' index='0' model='pcie-root'/>
    <controller type='pci' index='1' model='dmi-to-pci-bridge'>
      <model name='i82801b11-bridge'/>
    
    <address type='pci' domain='0x0000' bus='0x00' slot='0x1e' function='0x0'/>
    </controller>
    <controller type='pci' index='2' model='pci-bridge'>
      <model name='pci-bridge'/>
      <target chassisNr='2'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </controller>
    <controller type='pci' index='3' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='3' port='0x10'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0' multifunction='on'/>
    </controller>
    <controller type='pci' index='4' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='4' port='0x11'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x1'/>
    </controller>
    <controller type='pci' index='5' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='5' port='0x12'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x2'/>
    </controller>
    <controller type='pci' index='6' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='6' port='0x13'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x3'/>
    </controller>
    <controller type='pci' index='7' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='7' port='0x14'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x4'/>
    </controller>
    <controller type='pci' index='8' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      
      <target chassis='8' port='0x15'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x5'/>
    </controller>
    <controller type='pci' index='9' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='9' port='0x16'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x6'/>
    </controller>
    <controller type='pci' index='10' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='10' port='0x17'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x7'/>
    </controller>
    <controller type='pci' index='11' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='11' port='0x18'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </controller>
    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
    </controller>
    <interface type='bridge'>
      <mac address='52:54:00:bc:bd:62'/>
      <source bridge='br1'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x09' slot='0x00' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='52:54:00:85:71:fd'/>
      <source bridge='br1'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x0a' slot='0x00' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <channel type='spicevmc'>
      <target type='virtio' name='com.redhat.spice.0'/>
      <address type='virtio-serial' controller='0' bus='0' port='1'/>
    </channel>
    <input type='tablet' bus='usb'>
      <address type='usb' bus='0' port='1'/>
    </input>
    
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='spice' autoport='yes'>
      <listen type='address'/>
      <gl enable='no' rendernode='/dev/dri/by-path/pci-0000:00:02.0-render'/>
    </graphics>
    <sound model='ich6'>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x02' function='0x0'/>
    </sound>
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0'/>
    </video>
    <hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x045e'/>
        <product id='0x00cb'/>
      </source>
      <address type='usb' bus='0' port='4'/>
    </hostdev>
    <hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x04d9'/>
        <product id='0x1702'/>
      </source>
      <address type='usb' bus='0' port='5'/>
    </hostdev>
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
      </source>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </hostdev>
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x1'/>
      </source>
      <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
    </hostdev>
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x2'/>
      </source>
      <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
    </hostdev>
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x3'/>
      </source>
      <address type='pci' domain='0x0000' bus='0x07' slot='0x00' function='0x0'/>
    </hostdev>
    <redirdev bus='usb' type='spicevmc'>
      <address type='usb' bus='0' port='2'/>
    </redirdev>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x08' slot='0x00' function='0x0'/>
    </memballoon>
  </devices>
</domain>
```
