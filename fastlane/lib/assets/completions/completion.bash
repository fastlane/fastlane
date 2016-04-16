_fastlane_complete() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"
  local completions=""

  # look for Fastfile either in this directory or fastlane/ then grab the lane names
  if [[ -e "Fastfile" ]]; then
    file="Fastfile"
  elif [[ -e "fastlane/Fastfile" ]]; then
    file="fastlane/Fastfile"
  elif [[ -e ".fastlane/Fastfile" ]] then
    file=".fastlane/Fastfile"
  fi

  # parse 'beta' out of 'lane :beta do', etc
  completions=`cat $file | grep "^\s*lane \:" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}'`

  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}

complete -F _fastlane_complete fastlane
