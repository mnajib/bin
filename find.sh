find DATA/_vnet.clients/_JPBD/_opengeo.upgrade/_ubuntu/_suite-v45-ubuntu/apt.boundlessgeo.com/suite/v45/ubuntu/pool/ -regex ".*\.deb$" -print
find . -name \*.sh -print0 | xargs -I{} -0 cp -v {} Scripts/
find . -type f -print0 | xargs -I{} -0 grep -l "font.css" {}
