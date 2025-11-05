#!/usr/bin/env bash


sudo dmidecode -t memory | grep -E "Locator|Size|Type|Speed|Manufacturer|Part Number"
