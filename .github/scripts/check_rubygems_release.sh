#!/bin/bash

# Usage: check_rubygems_release.sh <version> <expected sha256> [--wait]
# Exit 0: RubyGems has fastlane <version> with that sha256.
# Exit 1: it has another gem under that version, or with --wait it did not appear.
# Exit 2: it does not have that version (or could not be reached: a push then fails on "Repushing", never publishes twice).
version=$1
expected=$2
attempts=1
[ "$3" = "--wait" ] && attempts=30

if [ -z "$version" ] || [ -z "$expected" ]; then
  echo "::error::Missing version or expected sha256"
  exit 1
fi

for i in $(seq 1 "$attempts"); do
  sha=$(curl -sf "https://rubygems.org/api/v2/rubygems/fastlane/versions/$version.json" | ruby -rjson -e 'puts JSON.parse(STDIN.read)["sha"]' 2>/dev/null)
  if [ -n "$sha" ]; then
    if [ "$sha" = "$expected" ]; then
      echo "fastlane $version on RubyGems matches the built gem ($sha)"
      exit 0
    fi
    echo "::error::fastlane $version on RubyGems has sha256 $sha, the built gem $expected"
    exit 1
  fi
  [ "$i" -lt "$attempts" ] && sleep 10
done

if [ "$3" = "--wait" ]; then
  echo "::error::fastlane $version did not appear on RubyGems"
  exit 1
fi
echo "fastlane $version not found on RubyGems"
exit 2
