#!/run/current-system/sw/bin/env bash

#qemu-img create -f qcow2 ReactOS.qcow2 80G

#qemu-system-i386 -m 1G -drive if=ide,index=0,media=disk,file=ReactOS.qcow2 -drive if=ide,index=2,media=cdrom,file=$HOME/Downloads/iso/reactos-bootcd-0.4.15-dev-2707-gd042f51-x86-gcc-lin-dbg.iso -boot order=d -serial file:ReactOS.log

#qemu-system-i386 \
qemu-system-x86_64 \
	-m 4G \
	-drive if=ide,index=0,media=disk,file=Windows10.qcow2 \
	-drive if=ide,index=2,media=cdrom,file=$HOME/Downloads/iso/Windows10.iso \
	-boot order=d \
	-serial file:Windows10.log \
	#-netdev user,id=net0 -device virtio-net-pci,netdev=net0
	#-net user,smb=$HOME/Downloads \
	#-net user \
	#-net nic,model=virtio

#qemu-system-x86_64 \
#    -net user,smb=/absolute/path/to/folder \
#    -net nic,model=virtio \
#    ...

#qemu-system-x86_64 -m 2048 -cdrom /home/najib/Downloads/iso/Win10_Pro_1511_English_x64_july_2016.iso -hda /mnt/Windows.qcow2 -net nic -net user &
