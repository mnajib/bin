#!/bin/bash

for file in * ; do [ -f ../images/$file ] && echo $file ; done
