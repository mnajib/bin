#!/usr/bin/env bash

#mount ...
cd /mnt/external-data/home/najib/VirtualBox\ VMs/Windows10Citroen\ Clone
qemu-system-x86_64 -rtc base="2002-01-01",clock=vm -m 2G  -hda Windows10Citroen\ Clone.vdi

#password: bismillah


