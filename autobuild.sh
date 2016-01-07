#!/usr/bin/env bash

[ -z "$1" ] && echo "Error: $1 should be a commit message" && exit 127

jekyll build 

git add .
git commit -m "$1"
git push -u origin master
