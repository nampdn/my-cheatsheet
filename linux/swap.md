# How to Setup Swap on Ubuntu 18.04 & 16.04 LTS

Source [TecAdmin](https://tecadmin.net/enable-swap-on-ubuntu/)

Swap is very useful for that system which required more RAM that physical available. If memory is full and system required more RAM to run applications properly it check for swap space and transfer files there. In general terms, swap is a part of the hard disk used as RAM on the system.

I have a virtual machine running which don’t have swap on it. Many times services got crashed due to insufficient memory. In this situation creation of Swap file is better to keep them up. This article will help you to create a swap file on Linux system after installation.

Check System Swap – Before working make sure that system has already swap enabled. If there is no swap, you will get output header only.
```
sudo swapon -s
```
Create Swap File – Lets create a file to use for swap in system of required size. Before making file make sure you have enough free space on disk. Generally, it recommends that swap should be equal to double of installed physical memory.
I have 2GB memory in my system. So I am creating swap of 4GB in size.
```
sudo fallocate -l 4G /swapfile
chmod 600 /swapfile

# Make It Swap – Now make is swap usable file using mkswap command.
sudo mkswap /swapfile

# Enable Swap – Now setup the swap for system using swapon command.
sudo swapon /swapfile

# Now again check that swap is enabled or not. You will see results something like below.
sudo swapon -s
```
```
Filename                Type        Size    Used    Priority
/swapfile               file        4194300 0       -1
```

Setup Swap Permanent – Append the following entry in /etc/fstab file to enable swap on system reboot.
```
vim /etc/fstab

# Edit file
/swapfile   none    swap    sw    0   0
```
Setup Kernel Parameter – Now change the swappiness kernel parameter as per your requirement. It tells the system how often system utilize this swap area.
Edit /etc/sysctl.conf file and append following configuration in file.
```
sudo vim /etc/sysctl.conf
vm.swappiness=10
```
Now reload the sysctl configuration file
```
sudo sysctl -p
```
At this point, you have successfully enabled swap on your Ubuntu system.
