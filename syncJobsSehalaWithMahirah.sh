#!/usr/bin/env bash

#DIR1=/home/najib/Documents/_jobs/a/
#DIR2=najib@mahirah:/home/najib/Documents/_jobs/a/
DIR1=/home/najib/Documents/_jobs/
DIR2=najib@mahirah:/home/najib/Documents/_jobs/
#srcDir=$1
#desDir=$2

#rsync -h --progress --stats -r -tgo -p -l -D --update --protect-args -e "ssh -p 22" /home/najib/Documents/_jobs/a/ najib@mahirah:/home/najib/Documents/_jobs/a/

function printUsage {
    echo ""
    echo "Description:"
    echo "    Sync ~/Documents/_jobs in this $HOSTNAME and in mahirah."
    echo ""
    echo "Usage:"
    echo "    syncJobsSehalaWithMahirah,sh --toMahirah"
    echo "    syncJobsSehalaWithMahirah,sh --toMahirahWithDelDes"
    echo "    syncJobsSehalaWithMahirah,sh --fromMahirah"
    echo "    syncJobsSehalaWithMahirah,sh --fromMahirahWithDelDes"
    echo ""
}

function doSync {
	local srcDir=$1
	local desDir=$2
	rsync -h --progress --stats -r -tgo -p -l -D --update --protect-args -e "ssh -p 22" $srcDir $desDir
}

function doSyncWithDelete { # XXX: with delete extraneous files from destination directories {
	local srcDir=$1
	local desDir=$2
	rsync -h --progress --stats -r -tgo -p -l -D --update --delete --protect-args -e "ssh -p 22" $srcDir $desDir
}

# XXX: Not in use
#function syncToMahirah {
#    doSync $1 $2
#}

# XXX: Not in use
#function syncFromMahirah {
#    doSync $2 $1
#}

case $1 in
    --toMahirah|--toMahirahWithDelDes)
	#syncToMahirah $DIR1 $DIR2
	#doSync $DIR1 $DIR2
	doSyncWithDelete $DIR1 $DIR2
        ;;
    --fromMahirah)
        #syncFromMahirah $DIR1 $DIR2
        doSync $DIR2 $DIR1
        ;;
    --fromMahirahWithDelDes)
	doSyncWithDelete $DIR2 $DIR1
	;;
    *)
        printUsage
        ;;
esac
