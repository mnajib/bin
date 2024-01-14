#!/bin/bash


awk -F, '/^\(/ { print $1 }'  snmpsimulator-realalarm-data.test.tmp.sql
