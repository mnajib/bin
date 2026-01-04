#!/usr/bin/env bash

drive="$1"

sudo smartctl --info "${drive}"
