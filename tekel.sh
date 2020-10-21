#!/bin/bash

APPDIR="/data/app/$USER"
if [ ! -d /data/app/ ] ; then
	APPDIR=$HOME/.tekelapps
	mkdir -p $APPDIR 2>/dev/null || true
fi
set -e
if [ ! -d $APPDIR ] ; then
	su -c "mkdir -p $APPDIR ; chmod 755 $APPDIR ; chown $USER -R $APPDIR" || exit 1
fi
[ "$REPO" == "" ] && export REPO="https://gitlab.com/sulinos/repositories/tekel-repo/-/raw/master/index.txt"
if [ $UID -eq 0 ] ; then
	APPDIR=/data/app/system
	if [ ! -d /data/app/ ] ; then
		APPDIR=/opt/
		mkdir -p $APPDIR 2>/dev/null || true
	fi
fi
touch $HOME/.tekel
generate_line(){
	while read line
	do
		name=$(basename $line | sed "s/\.sh$//g")
		echo "$name::$(cat repo_url)/$line"
	done
}

index(){
	find | grep ".sh$" |  generate_line | sed "s|/\./|/|g" > index.txt
}

install_common(){
	cd $APPDIR/$1
	. "$1.tekel"
	[ "$SOURCE" == "" ] || wget -c $SOURCE
	_setup
	cd $APPDIR/$1
	_build
	cd $APPDIR/$1
	_install
	if [ "$desktop_files" == "" ] ; then
		return 0
	fi
	if [ $UID -eq 0 ] ; then
		export dfile="/usr/share/applications/$NAME.tekel.desktop"
	else
		export dfile="$HOME/.local/share/applications/$NAME.desktop"
	fi
	mkdir -p "$(dirname $dfile)" 2>/dev/null || true
	touch $dfile
	chmod +x $dfile
	echo "[Desktop Entry]" > $dfile
	echo "Version=1.0" >> $dfile
	echo "Name=$NAME" >> $dfile
	echo "Comment=$COMMENT" >> $dfile
	echo "Categories=$CATEGORY" >> $dfile
	echo "Icon=$ICON" >> $dfile
	echo "Exec=$EXEC" >> $dfile
	echo "Type=Application" >> $dfile
	echo "MimeType=$MIMETYPE" >> $dfile
	echo "X-GNOME-UsesNotifications=true" >> $dfile
}

install_remote(){
	if [ -f "$APPDIR/$1/$1.tekel" ] ; then
		echo "Package $1 already installed."
		echo "You can remove $APPDIR/$1."
		exit 1
	fi 
	link=$(cat $HOME/.tekel | grep $1 | head -n 1 | sed "s/^.*:://g")
	curl $link > "/tmp/$1.tekel"
	if [ -f "/tmp/$1.tekel" ] ; then
		mkdir -p $APPDIR/$1
		mv "/tmp/$1.tekel" "$APPDIR/$1/$1.tekel"
		install_common $1
	else
		echo "Cannot get tekel file"
		exit 1
	fi
}

install_local(){
	if [ -f "$APPDIR/$1/$1.tekel" ] ; then
		echo "Package $1 already installed."
		echo "You can remove $APPDIR/$1."
		exit 1
	fi 
	if [ -f "$1" ] ; then
		name=$(sh -c "source $(realpath $1) ; echo -n \$NAME" | sed "s/ /_/g")
		mkdir -p $APPDIR/$name
		cp "$1" "$APPDIR/$name/$name.tekel"
		install_common $name
	else
		echo "Tekel file not found"
		exit 1
	fi
}

remove(){
	if [ -f "$APPDIR/$1/$1.tekel" ] ; then
		. "$APPDIR/$1/$1.tekel"
		if [ "$desktop_files" == "" ] ; then
			if [ $UID -eq 0 ] ; then
				rm -f "/usr/share/applications/$NAME.desktop"
			else
				rm -f "$HOME/.local/share/applications/$NAME.desktop"
			fi
		else
			for file in ${desktop_files[@]} ; do
				if [ $UID -eq 0 ] ; then
					rm -f "/usr/share/applications/$file.desktop"
				else
					rm -f "$HOME/.local/share/applications/$file.desktop"
				fi	
			done
		fi
		rm -rf "$APPDIR/$1"
	fi
}

update(){
	curl $REPO > $HOME/.tekel
}

list(){
	cd $APPDIR
	ls | while read line
	do
		[ -f "$APPDIR/$line/$line.tekel" ] && echo $line
	done | sort
}

look(){
	cat $HOME/.tekel | sed "s/::.*$//g" | sort | grep "$1"
}


print_help(){
	echo "tekel - Userspace package installer for SulinOS"
	if [ "$1" != "" ]; then
		echo
		echo "$@"
	fi
	echo
	echo "i/install <package-name>        - install package"
	echo "il/install-local <package-name> - install package from local"
	echo "s/show                          - list installable packages"
	echo "l/list                          - list installed packages"
	echo "u/update                        - update installable package list"
	echo "r/remove <package-name>         - remove package"
	echo "n/index                         - index repo"
}

case "$1" in
	i|install)
	if [ "$3" != "" ]; then
		print_help $1: requires only one argument
	elif [ "$2" != "" ]; then
		install_remote $2
	else
		print_help $1: requires an extra argument
	fi
	;;
	il|install-local)
	if [ "$3" != "" ]; then
		print_help $1: requires only one argument
	elif [ "$2" != "" ]; then
		install_local $2
	else
		print_help $1: requires an extra argument
	fi
	;;
	s|show)
	look $2
	;;
	l|list)
	list
	;;
	r|remove)
	if [ "$3" != "" ]; then
		print_help $1: requires only one argument
	elif [ "$2" != "" ]; then
		remove $2
	else
		print_help $1: requires an extra argument
	fi
	;;
	u|update)
	update
	;;
	n|index)
	index
	;;
	*)
	print_help
	;;
esac
