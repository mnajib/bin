#!/usr/bin/env bash

function sync0a(){
    local SRC=$1 #"/home/najib/_e-books"
    local DEST=$2 #"najib@mahirah:/home/najib/Documents"
    #rsync -r -t -p -o -g -x -v --progress -l -H -i -s "$SRC" "$DEST"
    rsync -r -t -p -o -g -x -v --progress -l -H -z -i -s "${SRC}" "${DEST}"
}

function sync0(){
	local SRC=""
	local DEST=""

    SRC="/home/najib/_e-books"
    DEST="najib@mahirah:/home/najib/Documents"
    sync0a "${SRC}" "${DEST}"

    SRC="/home/najib/_e-books_2"
    DEST="najib@mahirah:/home/najib/Documents"
    sync0a "${SRC}" "${DEST}"

    SRC="/home/najib/_e-books_3"
    DEST="najib@mahirah:/home/najib/Documents"
    sync0a "${SRC}" "${DEST}"

    SRC="/home/najib/_e-books_4"
    DEST="najib@mahirah:/home/najib/Documents"
    sync0a "${SRC}" "${DEST}"

    SRC="/home/najib/_e-books_5 For kids"
    DEST="najib@mahirah:/home/najib/Documents"
    sync0a "${SRC}" "${DEST}"

    SRC="/home/najib/_e-books_6"
    DEST="najib@mahirah:/home/najib/Documents"
    sync0a "${SRC}" "${DEST}"
}

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

#sync0
#sync1
#sync2
#sync3
#sync4


