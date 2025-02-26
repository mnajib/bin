#!/usr/bin/env bash

#
# NOTE:
#   Done test run with success
#

# You should set readonly=on for MyTank/backups/offsite if:
#   You want all datasets under MyTank/backups/offsite/ to be protected from accidental modifications.
#   You want to prevent accidental file edits or deletions that could break your backup integrity.
#   You use Syncoid for one-way sync, and you don't plan to manually change anything inside MyTank/backups/offsite.
#
# This will make all sub-datasets (MyTank/backups/offsite/*) read-only, unless overridden.
# Future Syncoid syncs will still work because Syncoid uses zfs send and zfs receive, which bypass the read-only restriction.
#sudo zfs set readonly=on MyTank/backups/offsite
#
#sudo zfs set readonly=on MyTank/backups/offsite/najibzfspool1

sudo syncoid root@customdesktop.localdomain:najibzfspool1/home MyTank/backups/offsite/najibzfspool1
