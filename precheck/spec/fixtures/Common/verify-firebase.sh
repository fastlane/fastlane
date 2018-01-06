#!/usr/bin/env bash

# Xcode scripting does not invoke rvm. To get the correct ruby,
# we must invoke rvm manually. This requires loading the rvm
# *shell function*, which can manipulate the active shell-script
# environment. See: http://rvm.io/workflow/scripting

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"

elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
  exit 128
fi

# Actually run fastlane from the fastlane root directory.
cd ../../../
FASTLANE_HIDE_CHANGELOG=1 FASTLANE_HIDE_TIMESTAMP=1 FASTLANE_ENV_PRINTER=1 FASTLANE_SKIP_UPDATE_CHECK=1 bundle exec fastlane verify_firebase
