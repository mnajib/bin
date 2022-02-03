#ssh -L 5900:localhost:5900 hydra.sharcnet.ca

#wget *.iso

#qemu-img create -f qcow2 nixos.qcow2 16G

qemu-kvm --nodefaults -m 8g --smp 2 --display vnc=localhost:0 --boot d -S --monitor stdio --device virtio-tablet --device virtio-vga --device virtio-scsi,id=scsi --blockdev file,node-name=file-boot,filename=latest-nixos-minimal-x86_64-linux.iso --device scsi-hd,id=device-disk,drive=block-root --netdev user,id=net --device virtio-net,netdev=net

> c


