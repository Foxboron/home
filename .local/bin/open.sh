#!/usr/bin/env bash
# Simple script to redirect url's opened from termite.

# A function containing a case list of options 


open_imv(){
    curl $1 | imv -
}

open() {
    echo $1
    case "$1" in
        *youtube.com*|*youtu.be*|*vidzi.tv*|*.webm*|*.mp4*|*.avi)  mpv "$1" --fs --title="open-float";;
        #*.png|*.jpeg|*.gif*|*.jpg) feh -B black --title open-float -. "$1";;  # feh -. = opens to fit window.
        *.png|*.jpeg|*.gif*|*.jpg) open_imv "$1" || qutebrowser "$1";;  # feh -. = opens to fit window.
        *) qutebrowser "$1";  # For everything else.;
    esac
}

# Now a for loop to iterate the list of options, 
for url; do
    case "$url" in
        *bombch.us*)
            open "$(curl -w "%{url_effective}\n" -I -L -s -S $1 -o /dev/null)"
        ;;
        *)
        open "$url"
        ;;
    esac
done
