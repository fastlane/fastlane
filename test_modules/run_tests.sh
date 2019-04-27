#!/bin/sh

# running tests
TEST_MODULES=(
  "spaceship"
  "scan"
)
EXIT_CODE=0
for TEST_MODULE in ${TEST_MODULES[*]}
do
  echo "Executing $TEST_MODULE module load up test"
  ruby -e "require '$TEST_MODULE'"
  if [ $? -eq 0 ]
  then
    echo "Succeed."
  else
    EXIT_CODE=2
  fi
done

exit $EXIT_CODE
