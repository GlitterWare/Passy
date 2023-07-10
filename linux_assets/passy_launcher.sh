#! /bin/sh
cd $(dirname $0)

if [ "$1" ] ; then
  $@
else
  ./passy
fi
