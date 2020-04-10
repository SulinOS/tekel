#!/bin/bash
[ $UID -eq 0 ] && echo "root not allowed" && exit 1
PATH=$PATH:/usr/libexec/bakkal/cli
mkdir -p $HOME/.bakkal/{tmp,packages}
[ "$1" == "install" ] && b_it $*
[ "$1" == "remove" ] && b_rm $*
[ "$1" == "info" ] && b_inf $*
[ "$1" == "update" ] && b_up $*
[ "$1" == "index" ] && b_ix $*

