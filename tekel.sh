#!/bin/bash

APPDIR="/data/app/$USER"
REPO="https://gitlab.com/sulinos/repositories/tekel-repo/-/raw/master/index.txt"
if [ $UID -eq 0 ] ; then
	echo "root not allowed"
	exit 1
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
	mkdir -p "$HOME/.local/share/applications/" &>/dev/null || true 
	export dfile="$HOME/.local/share/applications/$NAME.desktop"
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
	link=$(cat $HOME/.tekel | grep $1 | head -n 1 | sed "s/^.*:://g")
	curl $link > "/tmp/$1.tekel"
	mkdir -p $APPDIR/$1
	mv "/tmp/$1.tekel" "$APPDIR/$1/$1.tekel"
	install_common $1
}

install_local(){
	mkdir -p $APPDIR/$1
	cp "$1.tekel" "$APPDIR/$1/$1.tekel"
	install_common $1
}

remove(){
	if [ -f "$APPDIR/$1/$1.tekel" ] ; then
		. "$APPDIR/$1/$1.tekel"
		rm -f "$HOME/.local/share/applications/$NAME.desktop"
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
	cat $HOME/.tekel | sed "s/::.*$//g" | sort
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
	look
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
