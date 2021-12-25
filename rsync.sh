#!/usr/bin/env bash

function sync1 () {
    rsync -r -t -p -o -g -x -v --progress --ignore-existing -u -l -H -D -z -s \
        -e ssh \
	--exclude /mnt/home/DATA/Documents \
	--exclude Documents \
	root@192.168.123.20:/mnt/home/DATA/ \
	/home/najib/Documents
}

function sync2 () {
    #rsync -r -t -p -o -g -x -v --progress -l -H -z -s \
    rsync -r -t -p -o -g -x -v --progress --ignore-existing  -u -l -H -D -z -s \
        -e ssh \
        root@192.168.123.20:/mnt/home/DATA/Documents/ \
        /home/najib/Documents
}

function sync3 () {
    #rsync -r -t -p -o -g -x -v --progress -l -H -z -s \
    rsync -r -t -p -o -g -x -v --progress --ignore-existing -u -l -H -D -z -s \
        -e ssh \
        root@192.168.123.20:/mnt/home/najib/Downloads/ \
        /home/najib/Documents
}

function sync4 () {
    #rsync -r -t -p -o -g -x -v --progress -l -H -z -s \
    rsync -r -t -p -o -g -x -v --progress --ignore-existing -u -l -H -D -z -s \
        -e ssh \
	--exclude /mnt/home/najib/Documents \
	--exclude /mnt/home/najib/Downloads \
	--exclude Documents \
	--exclude Downloads \
	--exclude Games \
	--exclude GitRepos \
	root@192.168.123.20:/mnt/home/najib/ \
	/home/najib
}

#sync1
#sync2
#sync3
#sync4
