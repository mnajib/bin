sudo apt-get install sshfs
sudo modprobe fuse

sudo adduser najib fuse
sudo chown root:fuse /dev/fuse
sudo chmod +x /dev/fusermount

# to mount
mkdir -p ~/mnt/rt-r61/opt
#sshfs root@rt-r61:/opt/rt3 ~/mnt/rt-r61/opt
sshfs -o idmap=user root@rt-r61:/opt/rt3 ~/mnt/rt-r61/opt
cd ~/mnt/rt-r61/opt/rt3
ls -Filah

# to unmount
fusermount -u /home/najib/mnt/rt-r61/opt
