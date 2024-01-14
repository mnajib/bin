#!/bin/bash

EVENTS="CREATE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"

sync() {
  rsync --update -alvzr --exclude '*cache*' --exclude '*.git*' /var/www/* root@secondwebserver:/var/www/

}
watch() {
  inotifywait -e "$EVENTS" -m -r --format '%:e %f' /var/www/ --exclude '/var/www/.*cache.*' 
}


watch | (
while true ; do
  read -t 1 LINE && sync
done
)
