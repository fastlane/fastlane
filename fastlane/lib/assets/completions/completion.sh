#!/bin/sh
# shellcheck disable=SC2155
# shellcheck disable=SC1090
# shellcheck disable=SC2039

if [ -n "$BASH_VERSION" ]; then
  . ~/.fastlane/completions/completion.bash
elif [ -n "$ZSH_VERSION" ]; then
  . ~/.fastlane/completions/completion.zsh
fi

# Do not remove v0.0.1
