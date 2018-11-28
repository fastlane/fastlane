# This function was taken from https://github.com/Carthage/Carthage/blob/master/Source/Scripts/carthage-fish-completion
function __fish_fastlane_needs_subcommand
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'fastlane' ]
    return 0
  end
    return 1
end

if test -e "Fastfile"
  set file "Fastfile"
else if test -e "fastlane/Fastfile"
  set file "fastlane/Fastfile"
else if test -e ".fastlane/Fastfile"
  set file ".fastlane/Fastfile"
else
  exit 1
end

set commands (string match --regex '.*lane\ \:(?!private_)([^\s]*)\ do' (cat $file))

set commands_string

# Fish returns the fully matched string, plus the capture group. The actual captured value
# is every other line, starting at line 2.
set use_command false

for line in $commands
  if [ $use_command = true ]
    set commands_string "$commands_string $line"
    set use_command false
  else
    set use_command true
  end
end

set commands_string "$commands_string update_fastlane"

complete -c fastlane -n '__fish_fastlane_needs_subcommand' -a (string trim $commands_string) -f