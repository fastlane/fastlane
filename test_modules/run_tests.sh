#!/bin/sh

# running tests
TEST_FILES=(
  "test_modules/test_spaceship.rb"
  "test_modules/test_scan.rb"
)
EXIT_CODE=0
for TEST_FILE in ${TEST_FILES[*]} 
do
  ruby $TEST_FILE
  if [ $? -ne 0 ]
  then
    EXIT_CODE=2
  fi
done

exit $EXIT_CODE
