#!/bin/bash

#inputfile="tnms_data.sql"
#DBNAME=$2
#PASSWORD='tnms111111'
#
INPUTFILE=$1
DBNAME='tnms'
USERNAME='root'
PASSWORD='root123'

#mysql> drop database tnms;
#mysql> create database tnms;
#mysql -uroot -p
#tnms111111
#mysql> show databases;
#mysql> use tnms;
#mysql> show tables;

# Do backup
/root/bin/backup-tnms.sh

mysql -u $USERNAME -p $PASSWORD drop database $DBNAME
mysql -u $USERNAME -p $PASSWORD create database $DBNAME
mysql -u $USERNAME -p $PASSWORD $DBNAME  < $INPUTFILE
