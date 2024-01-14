#!/bin/sh

#virsh net-list
#virsh net-list --all
virsh net-start default
virsh net-list --all

#virsh list
virsh list --all
#virsh dominfo dev.tnms.local
#virsh domstate dev.tnms.local
virsh start dev.tnms.local
virsh dominfo dev.tnms.local


