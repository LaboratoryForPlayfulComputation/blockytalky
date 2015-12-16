#!/usr/bin/env bash

query=`dpkg-query -l | grep inotify-tools`

if  ! [ -n "$query" ]; then
  echo "installing inotify-tools"
  apt-get install -y inotify-tools
fi

queryssl=`dpkg-query -l | grep libssl-dev`

if  ! [ -n "$queryssl" ]; then
  echo "installing libssl-dev for python/pip's requests[secure]"
  apt-get install -y libffi-dev libssl-dev
fi
