#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export XAUTHORITY="$HOME/.Xauthority"

session="${1:-plasma}"
case "$session" in
    i3)
        export DESKTOP_SESSION=i3
        exec i3
        ;;
    awesome)
        export DESKTOP_SESSION=awesome
        exec awesome
        ;;
    plasma)
        export DESKTOP_SESSION=plasma
        exec startplasma-x11
        ;;
    *)
        exec "$session"
        ;;
esac
