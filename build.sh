#!/bin/bash
set -e

# Helper for building the images locally

branch="$1"
if [ -z "$branch" ]; then
  branch="$(git branch --no-color | grep \* | cut -d ' ' -f2)"
fi
./cp-static.sh

#for base in alpine baseimage; do
for base in baseimage; do 
  cd "py3-$base"
  docker build . -t "ambition/pypicloud:$branch-$base" -t "ambition/pypicloud:local-$base"
  cd ..
done
