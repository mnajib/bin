EXCLUDES=""
LOCAL_DIR="/DATA/mirror-repo-epel/"

#http://ftp.tsukuba.wide.ad.jp/Linux/fedora/epel
#rsync://ftp.tsukuba.wide.ad.jp/fedora-epel

rsync -vaH --exclude-from=${EXCLUDES} --numeric-ids --delete --delete-after --delay-updates rsync://ftp.tsukuba.wide.ad.jp/fedora-epel/7/x86_64 ${LOCAL_DIR}


