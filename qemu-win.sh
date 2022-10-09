#!/usr/bin/env bash

# Wrapper script for launching a qemu instance for Windows 10.
#
# This script is used in a Dell XPS 13 host.
#
# Usage: win [custom_qemu_options]
#
# Example:
# Assigning host USB device to guest VM
# qemu-win.sh -usb -device usb-host,hostbus=2,hostaddr=2

set -xe

export QEMU_AUDIO_DRV=alsa
#export SDL_VIDEODRIVER=wayland

#vm_path=$(systemd-path user-shared)/libvirt/images/win10.img
vm_path=/mnt/external-data/home/najib/VirtualBox\ VMs/Windows10Citroen\ Clone/Windows10Citroen\ Clone.vdi
smb_path="$HOME"/qemu

	#-nic user,model=e1000,smb="$smb_path" \
	#-soundhw hda \
	#-drive file="$vm_path",format=raw,if=virtio,cache=none,aio=native,cache.direct=on \
	#-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
qemu-system-x86_64 \
	-m 5G \
	-drive file="$vm_path" \
	-enable-kvm \
	-machine type=pc,accel=kvm \
	-smp 4,sockets=1,cores=2,threads=2 \
	#-cpu host \
	-vga virtio -display sdl,gl=on \
	#-nic user,model=e1000 \
	#-usb \
	#-device usb-tablet \
	#-device nec-usb-xhci,id=xhci \
	"$@"
