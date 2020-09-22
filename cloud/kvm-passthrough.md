# KVM passthrough Ubuntu 18.04

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


