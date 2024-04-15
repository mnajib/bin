#!/usr/bin/env bash

#
# Usate example:
#   hotSpareAsPermanentReplacement $zfspoolName $deviName
#   hotSpareAsPermanentReplacement najibzfspool1 wwn-0x5000cca8e7c7d82e
#
hotSpareAsPermanentReplacement() {
  # When hot-space device is activated, as not-permanent replacement fo faulted device.
  # Then, instead of a new replacement device, we can use the hot-spare device as a permanent replacement

  local zfspoolName="$1"
  local deviceName="$2"

  # Detach faulty device,
  sudo zpool detach $zfspoolName $deviceName
  # with this, the faulty device will detached
  # and the hot-spare will replace the faulty device permanently.
}
