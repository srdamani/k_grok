#! /bin/bash
# Download Virtualbox
# https://www.virtualbox.org/wiki/Downloads

# Download Ubuntu or Centos Virtual Disk Image (VDI)

# osboxes.org has many
# http://www.osboxes.org/ubuntu/
# http://www.osboxes.org/centos/
# 
# Username: osboxes
# Password: osboxes.org

# Extract 7zipped VDI file, move to desired location
# if your OS doesn't have a 7zip utility installed, you can download one from 7-zip.org
# 7za e <archive file>, or on Mac OS X, you could double click on the .7z file if using Keka 
# (Keka is available for free at https://www.keka.io/en/)

# Immediately following are instructions for the Virtualbox GUI. Command line instructions are at the end.

# Launch VirtualBox, press New button

# Name: k_grok-<username>, Type: Linux, etc.
# Use an existing virtual hard disk file, click on folder symbol to the right of the drop-down menu

# Do not power on the VM yet. Otherwise you cannot change Machine Settings
# [Virtualbox or File]->Preferences, Network, Host-only Networks, right top +
# Machine->Settings,
# System, Processors: 2, etc., whatever
# Network, Adapter 2, Enable, Attached to: Host-only Adapter

# Power on VM

# Log in as root, using password 'osboxes.org'

# Change passwords for root user and osboxes user. You can do this as root with these commands:
# passwd
# passwd osboxes

# Boot into multi-user (non-graphical mode) by default

# ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target 

# If Ubuntu, then:
# click on Ubuntu button and search for "term" to get the terminal
# sudo apt-get update
# apt-get install openssh-server

# If Centos, then:
# right click on desktop, open terminal
# edit /etc/sysconfig/network-scripts/ifcfg-enp0s3 to make it look like this:
# TYPE=Ethernet
# BOOTPROTO=dhcp
# DEFROUTE=yes
# NAME=enp0s3
# UUID=<USE THE UUID IN YOUR FILE>
# DEVICE=enp0s3
# ONBOOT=yes
# service network restart
# ifconfig | grep -A2 enp0 | grep 192

# ssh from your host to your VM as user osboxes to the IP address you just grepped

# Assuming you have downloaded a compressed osbox image into $VMDIR,
# and then uncompressed it with a command such as the following:
# p7zip -d Ubuntu_16.10_Yakkety-VB-64bit.7z

# Variable Init phase
export VM_DISK_DIR=$HOME/vm_disks
export VDI="$VM_DISK_DIR/ubuntu.vdi"
export VMNAME=k_grok
# determine your host's primary network adapter ...
# this may work on Linux
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export HOST_ADAPTER=$(ip link show up | grep "<BROAD" | cut -f2 -d":")
else
  # this may work on Mac OS X
  export HOST_ADAPTER=$(ifconfig | grep -B4 "status: active" | grep -B3 "inet " | head -1 | cut -f1 -d":")
fi

# Host configuration phase
# On your host:
vboxmanage hostonlyif create
# Assuming vboxnet1 was created
vboxmanage dhcpserver add --ifname vboxnet1 --ip 192.168.56.2 --netmask 255.255.255.0 --lowerip 192.168.56.3 --upperip 192.168.56.254 --enable

# For more info about these instructions, see:
# https://www.virtualbox.org/manual/ch08.html
# http://www.howopensource.com/2011/06/how-to-use-virtualbox-in-terminal-commandline/
# http://www.edwardstafford.com/2009/09/13/virtualbox-and-bridged-networking-on-a-headless-ubuntu-server-host/
# http://serverfault.com/questions/128685/how-can-i-get-the-bridged-ip-address-of-a-virtualbox-vm-running-in-headless-mode

# VM creation phase
vboxmanage createvm --name $VMNAME --register
vboxmanage modifyvm $VMNAME --ostype Ubuntu_64
vboxmanage modifyvm $VMNAME --memory 2000

# VM storage config phase
vboxmanage storagectl $VMNAME --name SATA --add sata --portcount 2 --controller IntelAhci --bootable on
vboxmanage storageattach $VMNAME --storagectl SATA --port 0 --device 0 --type hdd --medium "$VDI"

# VM network config phase
vboxmanage modifyvm $VMNAME --nic1 nat --nictype1 virtio
vboxmanage modifyvm $VMNAME --nic2 hostonly --nictype2 82540EM
vboxmanage modifyvm $VMNAME --hostonlyadapter2 vboxnet1

# VM console config phase (optional)
# send serial console to a log file
vboxmanage modifyvm $VMNAME --uart1 0x3F8 4
vboxmanage modifyvm $VMNAME --uartmode1 file /tmp/k_grok-serial.log
# this slows booting down, so if desired you can disable with
# vboxmanage modifyvm $VMNAME --uartmode1 disconnected

# VM Startup phase
# Start VM
vboxmanage startvm $VMNAME

# End of phases
# password osboxes.org
# start a terminal (either right click or search using the first panel button)
# sudo -i
# password osboxes.org
# apt update
# apt upgrade
# apt install openssh-server git
#
# ssh osboxes@$(arp -a | perl -ne '/\((.*)\) .*[0-9a-f] on vboxnet0 ifscope \[ethernet\]/ && print $1')
# mkdir ~/src
# cd ~/src
# git clone https://github.com/agshew/k_grok.git
