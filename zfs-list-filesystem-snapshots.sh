#!/usr/bin/env bash

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
