#!/bin/bash
# cat /etc/http/http.conf | remove-commented-lines.sh | less
grep -v "^#" | grep -v "^\ *$" | grep -v "\t*#"
