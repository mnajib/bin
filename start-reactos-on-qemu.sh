#!/usr/bin/env bash

BOOT=c  # boot from first drive
#BOOT=d  # boot from cdrom/iso

qemu-system-i386 \
  -m 1G \
  -drive if=ide,index=0,index=0,media=disk,file=ReactOS.qcow2 \
  -drive if=ide,index=2,media=cdrom,file=ReactOS-0.4.14-release-15-gb6088a6.iso \
  -boot order=${BOOT} \
  -serial file:ReactOS.log
  -tftp="${HOME}/.wine/drive_c"
  -net user,smb=${HOME}/.wine/drive_c
