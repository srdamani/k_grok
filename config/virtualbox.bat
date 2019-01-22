@echo off
set VM_DISK_DIR=%userprofile%\vm_disks

pushd %VM_DISK_DIR%
for %%f in (*.vdi) do set VDI=%%f

set VMNAME=nforeste-k_grok

for /f "tokens=2 delims='" %%i in ('vboxmanage hostonlyif create') do set ADAPTER_NAME=%%i

vboxmanage dhcpserver add --ifname "%ADAPTER_NAME%" --ip 192.168.56.2 --netmask 255.255.255.0 --lowerip 192.168.56.3 --upperip 192.168.56.254 --enable
vboxmanage createvm --name %VMNAME% --register
vboxmanage modifyvm %VMNAME% --ostype Ubuntu_64
vboxmanage modifyvm %VMNAME% --memory 2000
vboxmanage storagectl %VMNAME% --name SATA --add sata --portcount 2 --controller IntelAhci --bootable on
vboxmanage storageattach %VMNAME% --storagectl SATA --port 0 --device 0 --type hdd --medium "%VDI%"
vboxmanage modifyvm %VMNAME% --nic1 nat --nictype1 virtio
vboxmanage modifyvm %VMNAME% --nic2 hostonly --nictype2 82540EM
vboxmanage modifyvm %VMNAME% --hostonlyadapter2 "%ADAPTER_NAME%"
vboxmanage startvm %VMNAME%

popd
