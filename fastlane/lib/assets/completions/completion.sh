#!/bin/sh
if [ -n "$BASH_VERSION" ]; then
  source ~/.fastlane/completions/completion.bash

elif [ -n "$ZSH_VERSION" ]; then
  source ~/.fastlane/completions/completion.zsh
fi

# Do not remove v0.0.1
