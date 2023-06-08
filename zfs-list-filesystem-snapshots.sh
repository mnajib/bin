#!/usr/bin/env bash

function theList {
  watch '\
  echo "----------------------------------------------------------------------------------"; \
  echo " zfs list -t filesystem"; \
  echo "----------------------------------------------------------------------------------"; \
  zfs list -t filesystem; \
  echo ""; \
  echo "----------------------------------------------------------------------------------"; \
  echo " zfs list -t snapshot"; \
  echo "----------------------------------------------------------------------------------"; \
  echo ""; \
  echo "najibzfspool1/home"; \
  echo "------------------"; \
  echo ""; \
  zfs list -t snapshot najibzfspool1/home; \
  echo ""; \
  echo "najibzfspool1/root"; \
  echo "------------------"; \
  echo ""; \
  zfs list -t snapshot najibzfspool1/root; \
  '
}

function theUniversalList {
  watch '\
  echo "----------------------------------------------------------------------------------"; \
  echo " zfs list -t filesystem"; \
  echo "----------------------------------------------------------------------------------"; \
  zfs list -t filesystem; \
  echo ""; \
  echo "----------------------------------------------------------------------------------"; \
  echo " zfs list -t snapshot"; \
  echo "----------------------------------------------------------------------------------"; \
  echo ""; \
  zfs list -t snapshot; \
  '
}

function theUniversalList2 {
  echo "----------------------------------------------------------------------------------"
  echo " zfs list -t filesystem"
  echo "----------------------------------------------------------------------------------"
  zfs list -t filesystem
  echo ""
  echo "----------------------------------------------------------------------------------"
  echo " zfs list -t snapshot"
  echo "----------------------------------------------------------------------------------"
  echo ""
  zfs list -t snapshot
}

function listFilesystems {
  local a='\
  echo "----------------------------------------------------------------------------------"; \
  echo " zfs list -t filesystem"; \
  echo "----------------------------------------------------------------------------------"; \
  zfs list -t filesystem; \
  '
  echo $a
}

function listSnapshots {
  local a='\
  echo "----------------------------------------------------------------------------------"; \
  echo " zfs list -t snapshot"; \
  echo "----------------------------------------------------------------------------------"; \
  echo ""; \
  echo "najibzfspool1/home"; \
  echo "------------------"; \
  echo ""; \
  zfs list -t snapshot najibzfspool1/home; \
  echo ""; \
  echo "najibzfspool1/root"; \
  echo "------------------"; \
  echo ""; \
  zfs list -t snapshot najibzfspool1/root; \
  '
  echo $a
}

#theList
#theUniversalList

#listFilesystems
#listSnapshots
#watchCommand=`($listFilesystems)($listSnapshots)`
#watch $watchCommand

case "${1}" in
  'customdesktop')
     theList
     ;;
  *)
     #theUniversalList
     theUniversalList2
     ;;
esac
