#!/bin/sh
# This is a comment!
echo Hello World
rm -rf ./docs
mdbook build
mv book docs
git add .
git commit -m "update"
git push -origin master
