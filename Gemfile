source 'https://rubygems.org'

# Specify your gem's dependencies in .gemspec
gemspec

if `cd ..; git remote -v`.include?('countdown')
  gem 'fastlane_core', path: '../fastlane_core'
  gem 'spaceship', path: '../spaceship'
end
