#!/bin/bash

date=`/root/bin/date.sh`

mysqldump -u root -p tnms > tnms-$date.sql
