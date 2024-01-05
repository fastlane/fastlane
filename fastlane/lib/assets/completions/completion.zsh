#!/bin/zsh

_fastlane_complete() {
  local word completions file
  word="$1"

  # look for Fastfile either in this directory or fastlane/ then grab the lane names
  if [[ -e "Fastfile" ]] then
    file="Fastfile"
  elif [[ -e "fastlane/Fastfile" ]] then
    file="fastlane/Fastfile"
  elif [[ -e ".fastlane/Fastfile" ]] then
    file=".fastlane/Fastfile"
  else
    return 1
  fi

  # parse 'beta' out of 'lane :beta do', etc
  completions="$(sed -En 's/^[ 	]*lane +:([^ 	]+).*$/\1/p' "$file")"
  completions="$completions update_fastlane"

  reply=( "${=completions}" )
}

