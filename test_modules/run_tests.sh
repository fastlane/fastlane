#!/bin/sh
if `ruby test_modules/test_spaceship.rb`; then
  exit 1
else
  exit 0
fi