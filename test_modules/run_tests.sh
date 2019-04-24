#!/bin/sh

# set -o nounset
# set -o errexit
# set -o xtrace

# installing fastlane gem
gem build fastlane.gemspec
gem install fastlane-2.121.1.gem

# running tests
ruby test_modules/test_spaceship.rb
