#!/usr/bin/env bash

# Usage:
#   sekolah-tugasan-init "01 Pendidikan Islam"

#if not exist ...
#mkdir $1
#mkdir "${1}/01 Tugasan"
#mkdir "${1}/02 Bukti daftar kehadiran"
#mkdir "${1}/03 Hasil tugasan"
#mkdir "${1}/04 Bukti handar hasil tugasan"

#umask 0022
umask 0002

mkdir "01 Tugasan"
mkdir "02 Bukti daftar kehadiran"
mkdir "03 Hasil tugasan"
mkdir "04 Bukti handar hasil tugasan"
