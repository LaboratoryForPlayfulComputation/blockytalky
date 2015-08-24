#!/bin/bash
pushd /home/pi/blockytalky_elixir/blockytalky 
elixir --detached -S mix phoenix.server
popd
