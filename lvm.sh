# 
pvscan
vgscan
lvscan

#
vgchange -ay  # vgchange --available y

# shrink filesystem
resize2fs ... /dev/VolGroup00/backup

# shrink lv
lvresize -L -20G /dev/VolGroup00/backup

# shrink vg

# shrink pv


