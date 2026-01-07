#! /bin/bash
set -e
if [ -f $1 ]; then
  echo 'Already built.'
  exit 0
fi
${@:2}
