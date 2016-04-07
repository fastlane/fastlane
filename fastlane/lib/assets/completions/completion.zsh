_fastlane_complete() {
  read -l; local cl="$REPLY"; read -ln; local cp="$REPLY"; reply=(`COMP_SHELL=zsh COMP_LINE="$cl" COMP_POINT="$cp" ~/.fastlane/completions/_fastlane_complete.rb`)
}

compctl -K _fastlane_complete fastlane
