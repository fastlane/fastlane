#!/bin/sh

# installing current version of fastlane gem
BUILD_LOG=$(eval gem build fastlane.gemspec)
if [ $? -ne 0 ]
then
  exit 1
fi
GEM_FILE=$(eval echo $BUILD_LOG | sed 's/.*File: //')
gem install $GEM_FILE

# running tests
TEST_FILES=(
  "test_modules/test_spaceship.rb"
  "test_modules/test_scan.rb"
)
for TEST_FILE in ${TEST_FILES[*]} 
do
  ruby $TEST_FILE
done
