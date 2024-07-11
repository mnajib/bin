#!/usr/bin/env bash

BOOT=c  # boot from first drive
#BOOT=d  # boot from cdrom/iso

#\\10.0.24\qemu

#qemu-img create -f qcow2 ReactOS.qcow2 80G

#qemu-system-i386 -m 1G -drive if=ide,index=0,media=disk,file=ReactOS.qcow2 -drive if=ide,index=2,media=cdrom,file=$HOME/Downloads/iso/reactos-bootcd-0.4.15-dev-2707-gd042f51-x86-gcc-lin-dbg.iso -boot order=d -serial file:ReactOS.log

function old-and-working {
  #qemu-system-i386 \
  qemu-system-x86_64 \
    -m 2G \
    -drive if=ide,index=0,media=disk,file=ReactOS.qcow2 \
    -drive if=ide,index=2,media=cdrom,file=$HOME/Downloads/iso/reactos-bootcd-0.4.15-dev-2707-gd042f51-x86-gcc-lin-dbg.iso \
    -boot order=d \
    -serial file:ReactOS.log \
    #-net user,smb=$HOME/Downloads \
    -net nic,model=virtio
}

#qemu-system-x86_64 \
#    -net user,smb=/absolute/path/to/folder \
#    -net nic,model=virtio \
#    ...

#qemu-system-x86_64 -m 2048 -cdrom /home/najib/Downloads/iso/ReactOS-0.4.13.iso -hda /mnt/ReactOS.qcow2 -net nic -net user &

function new-and-working {
  #  -tftp=${HOME}/.wine/drive_c \
  #  -drive file=$HOME/.wine/drive_c \
  #  -net user,smb=${HOME}/.wine/drive_c \
  #  --smbd
  qemu-system-i386 \
    -m 1G \
    -drive if=ide,index=0,index=0,media=disk,file=ReactOS.qcow2 \
    -drive if=ide,index=2,media=cdrom,file=ReactOS-0.4.14-release-15-gb6088a6.iso \
    -boot order=${BOOT} \
    -serial file:ReactOS.log \
    -net nic,model=virtio \
    \
    -device virtio-serial-pci                                             \
    -spice port=5930,disable-ticketing=on                                 \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0  \
    -chardev spicevmc,id=spicechannel0,name=vdagent                       \
    -display spice-app \
}

new-and-working
