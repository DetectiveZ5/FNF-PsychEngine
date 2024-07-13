#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
#
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download/version/4.2.5
# Make sure hmm is installed (only needed once)
cd ..
haxelib --global install hmm
haxelib --global run hmm setup
hmm install
haxelib run lime setup
exit