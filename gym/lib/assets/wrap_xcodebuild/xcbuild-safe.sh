#!/bin/bash --login
# shellcheck disable=SC2155
# shellcheck disable=SC1090

# Originally from, https://stackoverflow.com/questions/33041109
# Modified to work in RVM and non RVM environments
#
# Xcode 7 (incl. 7.0.1) seems to have a dependency on the system ruby.
# xcodebuild has issues by using rvm to map to another non-system
# ruby. This script is a fix that allows you call xcodebuild in a
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
# More information available here: https://github.com/fastlane/fastlane/issues/6495
# -----

which rvm > /dev/null
# shellcheck disable=SC2181
if [[ $? -eq 0 ]]; then
  echo "RVM detected, forcing to use system ruby"
  # This allows you to use rvm in a script. Otherwise you get a BS
  # error along the lines of "cannot use rvm as function". Jeez.
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

  # Cause rvm to use system ruby. AFAIK, this is effective only for
  # the scope of this script.
  rvm use system
fi

if which rbenv > /dev/null; then
  echo "rbenv detected, removing env variables"

  # Cause rbenv to use system ruby. Lasts only for the scope of this
  # session which will normally just be this script.
  rbenv shell system
fi

# Since Xcode has a dependency to 2 external gems: sqlite and CFPropertyList
# More information https://github.com/fastlane/fastlane/issues/6495
# We have to unset those variables for rbenv, rvm and when the user uses bundler
unset RUBYLIB
unset RUBYOPT
unset BUNDLE_BIN_PATH
unset _ORIGINAL_GEM_PATH
unset BUNDLE_GEMFILE
# Even if we do not use rbenv in some environments such as CircleCI,
# We also need to unset GEM_HOME and GEM_PATH explicitly.
# More information https://github.com/fastlane/fastlane/issues/6277
unset GEM_HOME
unset GEM_PATH

set -x          # echoes commands
xcodebuild "$@" # calls xcodebuild with all the arguments passed to this
