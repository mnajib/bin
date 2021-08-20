#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bind.dnsutils -p traceroute -p curl
# impure: needs ping
#source: https://s3.amazonaws.com/aws-cloudfront-testing/CustomerTesting.html
function _e {
    echo "> $@"
    eval "$@" 2>&1 | sed -e "s/^/    /"
    printf "Exit: %s\n\n\n" "$?"
}

function curl_test {
    curl -w "
time_namelookup:    %{time_namelookup}
time_connect:       %{time_connect}
time_appconnect:    %{time_appconnect}
time_pretransfer:   %{time_pretransfer}
time_redirect:      %{time_redirect}
time_starttransfer: %{time_starttransfer}
time_total:         %{time_total}
" -v -o /dev/null "$@"
}

function ix {
    url=$(cat | curl -F 'f:1=<-' ix.io 2> /dev/null)
    echo "Pasted at: $url"
}

(
    _e ping -c1 d3m36hgdyp4koz.cloudfront.net
    _e ping -4 -c1 d3m36hgdyp4koz.cloudfront.net
    _e ping -6 -c1 d3m36hgdyp4koz.cloudfront.net    
    _e dig -t A identity.cloudfront.net
    _e dig -t A resolver-identity.cloudfront.net
    _e traceroute -4 d3m36hgdyp4koz.cloudfront.net
    _e traceroute -6 d3m36hgdyp4koz.cloudfront.net
    _e curl_test -4 'https://d3m36hgdyp4koz.cloudfront.net/nar/0dnnfy935ihgmdrc0lmj5mir7bprsclpyh0gjxyxkcqsi3jy2l7g.nar.xz'
    _e curl_test -6 'https://d3m36hgdyp4koz.cloudfront.net/nar/0dnnfy935ihgmdrc0lmj5mir7bprsclpyh0gjxyxkcqsi3jy2l7g.nar.xz'
    _e curl -I -4 'https://cache.nixos.org/'
    _e curl -I -4 'https://cache.nixos.org/'
    _e curl -I -4 'https://cache.nixos.org/'
    _e curl -I -6 'https://cache.nixos.org/'
    _e curl -I -6 'https://cache.nixos.org/'
    _e curl -I -6 'https://cache.nixos.org/'
) | tee /dev/stderr | ix
