From: <Saved by Blink>
Snapshot-Content-Location: https://git.zx2c4.com/password-store/plain/contrib/dmenu/passmenu
Subject: 
Date: Fri, 30 Jul 2021 00:24:07 -0000
MIME-Version: 1.0
Content-Type: multipart/related;
	type="text/html";
	boundary="----MultipartBoundary--H2N4XNUGziGDjFrCEemQUvOumSPzfMRHuqmNercBmX----"


------MultipartBoundary--H2N4XNUGziGDjFrCEemQUvOumSPzfMRHuqmNercBmX----
Content-Type: text/html
Content-ID: <frame-FFDDC2B3BFD43695CA16488A6CA9C060@mhtml.blink>
Content-Transfer-Encoding: quoted-printable
Content-Location: https://git.zx2c4.com/password-store/plain/contrib/dmenu/passmenu

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; charset=
=3DUTF-8"></head><body><pre style=3D"word-wrap: break-word; white-space: pr=
e-wrap;">#!/usr/bin/env bash

shopt -s nullglob globstar

typeit=3D0
if [[ $1 =3D=3D "--type" ]]; then
	typeit=3D1
	shift
fi

if [[ -n $WAYLAND_DISPLAY ]]; then
	dmenu=3Ddmenu-wl
	xdotool=3D"ydotool type --file -"
elif [[ -n $DISPLAY ]]; then
	dmenu=3Ddmenu
	xdotool=3D"xdotool type --clearmodifiers --file -"
else
	echo "Error: No Wayland or X11 display detected" &gt;&amp;2
	exit 1
fi

prefix=3D${PASSWORD_STORE_DIR-~/.password-store}
password_files=3D( "$prefix"/**/*.gpg )
password_files=3D( "${password_files[@]#"$prefix"/}" )
password_files=3D( "${password_files[@]%.gpg}" )

password=3D$(printf '%s\n' "${password_files[@]}" | "$dmenu" "$@")

[[ -n $password ]] || exit

if [[ $typeit -eq 0 ]]; then
	pass show -c "$password" 2&gt;/dev/null
else
	pass show "$password" | { IFS=3D read -r pass; printf %s "$pass"; } | $xdo=
tool
fi
</pre></body></html>
------MultipartBoundary--H2N4XNUGziGDjFrCEemQUvOumSPzfMRHuqmNercBmX------
