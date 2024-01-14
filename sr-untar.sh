#!/bin/bash

IFILE="."
desdir="../_PM2011Q1-extracted"

tarfile=(
  `find ${IFILE} -name "*.tar"`
)

for afile in "${tarfile[@]}"
do 
  echo "Processing ${afile} ..."
  tar -xf ${afile} && rm -f ${afile} && mv ./root ${desdir}/${afile}
done
