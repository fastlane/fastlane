#!/bin/bash
# Runs a lane through the Swift Package Manager runner built from this checkout, in the situations the runner
# has to handle, and checks which fastlane ran or that the runner stopped. macOS only (lsof, ::1).
# Usage: Tests/spm-runner/run.sh   (needs swift, bundle and python3)
set -u
here=$(cd "$(dirname "$0")" && pwd)
repository=$(cd "$here/../.." && pwd)
work=$(mktemp -d)
# Reuse the gems installed for this repository, then drop what `bundle exec` exported: the runner must find the project's Gemfile itself
bundle_path=$(cd "$repository" && bundle config get path --parseable 2>/dev/null | sed -n 's/^path=//p')
[ -n "$bundle_path" ] && export BUNDLE_PATH="$bundle_path"
unset BUNDLE_GEMFILE BUNDLE_BIN_PATH BUNDLER_SETUP BUNDLER_VERSION RUBYOPT RUBYLIB
trap 'rm -rf "$work"' EXIT
failures=0

(cd "$here" && swift build --build-path "$work/build" > "$work/build.log" 2>&1) || { cat "$work/build.log"; exit 1; }
runner="$work/build/debug/Runner"

# A project using fastlane from this checkout through Bundler
mkdir -p "$work/project/sub/deeper" "$work/elsewhere" "$work/dir with space"
printf 'source "https://rubygems.org"\ngem "fastlane", path: "%s"\n' "$repository" > "$work/project/Gemfile"
(cd "$work/project" && bundle install --quiet > "$work/bundle.log" 2>&1) || { cat "$work/bundle.log"; exit 1; }
printf '#!/bin/sh\nBUNDLE_GEMFILE="%s/project/Gemfile" exec bundle exec fastlane "$@"\n' "$work" > "$work/dir with space/fastlane"
chmod +x "$work/dir with space/fastlane"

free_port() {
  python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])'
}

# scenario <name> <expected: bundler|stopped> <directory> [VAR=value...]
scenario() {
  local name=$1 expected=$2 directory=$3 port=${PORT:-$(free_port)}
  shift 3
  rm -f "$work/marker"
  (cd "$directory" && env SPM_RUNNER_MARKER="$work/marker" "$@" perl -e 'alarm 30; exec @ARGV' "$runner" lane record swiftServerPort "$port" > "$work/run.log" 2>&1)
  local status=$? result
  if [ -f "$work/marker" ]; then
    result=$(sed 's#=/.*#=set#' "$work/marker")
  elif [ $status -eq 1 ] && grep -q "already in use" "$work/run.log"; then
    result="stopped"
  else
    result="no lane, exit $status"
  fi
  case "$expected:$result" in
    bundler:bundler=set | stopped:stopped) echo "PASS  $name: $result" ;;
    *) echo "FAIL  $name: $result, expected $expected"; sed 's/^/      /' "$work/run.log"; failures=$((failures + 1)) ;;
  esac
}

# Holds the port on one address, the way an unrelated program would
hold_port() {
  python3 -c '
import socket, sys, time
family = socket.AF_INET6 if ":" in sys.argv[1] else socket.AF_INET
s = socket.socket(family)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((sys.argv[1], int(sys.argv[2])))
s.listen()
print("listening", flush=True)
time.sleep(60)' "$1" "$2" > "$work/holder.log" 2>&1 &
  holder=$!
  until grep -q listening "$work/holder.log" 2>/dev/null; do sleep 0.1; done
}

scenario "from the project directory" bundler "$work/project"
scenario "from a subdirectory" bundler "$work/project/sub/deeper"
scenario "with BUNDLE_GEMFILE, from elsewhere" bundler "$work/elsewhere" BUNDLE_GEMFILE="$work/project/Gemfile"
scenario "with FASTLANE_SPM_BIN containing a space" bundler "$work/elsewhere" FASTLANE_SPM_BIN="'$work/dir with space/fastlane'"
for address in 127.0.0.1 ::1; do
  PORT=$(free_port)
  hold_port "$address" "$PORT"
  PORT=$PORT scenario "with the port held on $address" stopped "$work/project"
  kill $holder
  wait $holder 2>/dev/null
done

exit $failures
