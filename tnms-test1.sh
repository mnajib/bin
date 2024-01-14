#!/bin/bash

COUNTER=0
while true; do
#while [  $COUNTER -lt 10 ]; do
#  let COUNTER=COUNTER+1 
  #echo The counter is $COUNTER

  #date +%s%N
  #date +%T
  #time snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835 | wc -l
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835 >> tnms-test.log

  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.$COUNTER | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.$COUNTER >> tnms-test.log &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.$COUNTER >> tnms-test.log
  ##snmpbulkget -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.$COUNTER >> tnms-test.log

  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.2 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.3 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.4 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.5 | wc -l &
  ##snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.6 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.7 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.8 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.9 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 | wc -l &
  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 1.3.6.1.4.1.22835.9 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.7 1.3.6.1.4.1.22835.6 1.3.6.1.4.1.22835.5 1.3.6.1.4.1.22835.4 1.3.6.1.4.1.22835.3 1.3.6.1.4.1.22835.2 1.3.6.1.4.1.22835.1 >> tnms-test.log &

  #echo -e "`date` `snmpbulkget -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 1.3.6.1.4.1.22835.9 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.7 1.3.6.1.4.1.22835.6 1.3.6.1.4.1.22835.5 1.3.6.1.4.1.22835.4 1.3.6.1.4.1.22835.3 1.3.6.1.4.1.22835.2 1.3.6.1.4.1.22835.1`" >> tnms-test.log &
  #snmpbulkget -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 1.3.6.1.4.1.22835.9 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.7 1.3.6.1.4.1.22835.6 1.3.6.1.4.1.22835.5 1.3.6.1.4.1.22835.4 1.3.6.1.4.1.22835.3 1.3.6.1.4.1.22835.2 1.3.6.1.4.1.22835.1 >> tnms-test.log &
i=(`snmpbulkget -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 1.3.6.1.4.1.22835.9 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.7 1.3.6.1.4.1.22835.6 1.3.6.1.4.1.22835.5 1.3.6.1.4.1.22835.4 1.3.6.1.4.1.22835.3 1.3.6.1.4.1.22835.2 1.3.6.1.4.1.22835.1`)
  OIFS="$IFS"
  IFS="\n\n"
  time=`date`
  #i="`tr $i`"
  IFS='\n' read -a ia <<< "${i}"
  #for t in "${i/\ //g}"
  #for t in "${i[@]}"
  for t in "${ia}"
  do
    echo "${time} ${t}" >> tnms-test.log
  done
  IFS="$OIFS"
  


  #snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 >> tnms-test.log &
  #time snmpbulkwalk -v2c -Cn0 -Cr500 -c public 192.168.122.128 1.3.6.1.4.1.22835.10 1.3.6.1.4.1.22835.9 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.8 1.3.6.1.4.1.22835.7 1.3.6.1.4.1.22835.6 1.3.6.1.4.1.22835.5 1.3.6.1.4.1.22835.4 1.3.6.1.4.1.22835.3 1.3.6.1.4.1.22835.2 1.3.6.1.4.1.22835.1 >> tnms-test.log &
  #echo ---
  #sleep 1
done

exit 0
