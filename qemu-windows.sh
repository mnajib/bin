#!/usr/bin/env bash

#qemu-img create -f qcow2 ReactOS.qcow2 80G

#qemu-system-i386 -m 1G -drive if=ide,index=0,media=disk,file=ReactOS.qcow2 -drive if=ide,index=2,media=cdrom,file=$HOME/Downloads/iso/reactos-bootcd-0.4.15-dev-2707-gd042f51-x86-gcc-lin-dbg.iso -boot order=d -serial file:ReactOS.log

#\\10.0.24\qemu

#DIR1="/mnt/nfsshare2/DATA/_iso, img, and installer/_img"
DIR1="/mnt/nfsshare2/DATA/_iso_img_and_installer/_img"
HD1="Windows10.qcow2"
HD2='win10.qcow2.img'
HD3='win10-32bits.img'
HD4='Windows10Citroen.ova'
HD5='QemuHarddiskImg.qcow2'
CD1=''

BASEDIR="$DIR1"
HARDDISK="${DIR1}/${HD1}"
CDISOIMG="${DIR1}/${CD1}"
BOOTORDER=d # 'c' to boot from first drive,  'd' to boot from cdrom/iso
LOGFILE="$HOME/qemu.log"

function new-and-testing {
  #qemu-system-i386 \
  qemu-system-x86_64 \
    #-m 4G \
    -m 1G \
    -drive if=ide,index=0,media=disk,file="$HARDDISK" \
    #-drive if=ide,index=2,media=cdrom,file=$CDISOIMG \
    -boot order="$BOOTORDER" \
    -serial file:"$LOGFILE" \
    -net nic,model=virtio \
    -net user \
    #-smb $HOME/.wine/drive_c \
    \
    #-device virtio-serial-pci                                             \
    #-spice port=5930,disable-ticketing=on                                 \
    #-device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0  \
    #-chardev spicevmc,id=spicechannel0,name=vdagent                       \
    #-display spice-app \

    #-netdev user,id=net0 -device virtio-net-pci,netdev=net0
    #-net user,smb=$HOME/Downloads \
    #-net user \
    #-net nic,model=virtio
}

#qemu-system-x86_64 \
#    -net user,smb=/absolute/path/to/folder \
#    -net nic,model=virtio \
#    ...

#qemu-system-x86_64 -m 2048 -cdrom /home/najib/Downloads/iso/Win10_Pro_1511_English_x64_july_2016.iso -hda /mnt/Windows.qcow2 -net nic -net user &

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

#old-and-working
#new-and-working
new-and-testing
