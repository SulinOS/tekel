#!/bin/bash
[ $UID -eq 0 ] && echo "root not allowed" && exit 1
PATH=$PATH:/usr/libexec/tekel/cli
mkdir -p $HOME/.tekel/
if [ "$1" == "install" ] ; then
 	b_it $*
elif [ "$1" == "remove" ] ; then 
 	b_rm $*
elif [ "$1" == "info" ] ; then 
 	b_inf $*
elif [ "$1" == "update" ] ; then 
 	b_up $*
elif [ "$1" == "index" ] ; then 
 	b_ix $*
elif [ "$1" == "list" ] ; then 
 	b_li $*
elif [ "$1" == "look" ] ; then 
 	b_la $*
 else
 	echo "Usage: $0 [install/remove/info/update/index/list/look]"
 fi
 echo -ne
