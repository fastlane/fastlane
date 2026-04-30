#!/bin/bash

# running tests
TEST_MODULES=(
  "cert"
  "credentials_manager"
  "deliver"
  "fastlane"
  "fastlane_core"
  "frameit"
  "gym"
  "match"
  "pem"
  "pilot"
  "precheck"
  "produce"
  "scan"
  "screengrab"
  "sigh"
  "snapshot"
  "spaceship"
  "supply"
  "trainer"
)

for TEST_MODULE in "${TEST_MODULES[@]}"; do
  echo "Executing $TEST_MODULE module load up test"
  if ruby -e "require '$TEST_MODULE'"; then
    echo "Succeeded."
  else
    exit 2
  fi
done

exit 0
