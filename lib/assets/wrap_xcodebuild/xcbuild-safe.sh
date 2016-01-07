#!/bin/bash --login

# Cf. http://stackoverflow.com/questions/33041109
#
# Xcode 7 (incl. 7.0.1) seems to have a dependency on the system ruby.
# xcodebuild is screwed up by using rvm to map to another non-system
# ruby†. This script is a fix that allows you call xcodebuild in a
# "safe" rvm environment, but will not (AFAIK) affect the "external"
# rvm setting.
#
# The script is a drop in replacement for your xcodebuild call.
#
#   xcodebuild arg1 ... argn
#
# would become
#
#   path/to/xcbuild-safe.sh arg1 ... argn
#
# -----
# † Because, you know, that *never* happens when you are building
# Xcode projects, say with abstruse tools like Rake or CocoaPods.

# This allows you to use rvm in a script. Otherwise you get a BS
# error along the lines of "cannot use rvm as function". Jeez.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Cause rvm to use system ruby. AFAIK, this is effective only for
# the scope of this script.
which rvm && rvm use system
set -x          # echoes commands
unset RUBYLIB
unset RUBYOPT
unset BUNDLE_BIN_PATH
unset _ORIGINAL_GEM_PATH
unset BUNDLE_GEMFILE
#env | sort > /tmp/env.wrapper
#rvm info >> /tmp/env.wrapper
xcodebuild "$@" # calls xcodebuild with all the arguments passed to this
