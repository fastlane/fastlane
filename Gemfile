source 'https://rubygems.org'

# Specify your gem's dependencies in .gemspec
gemspec

if `cd ..; git remote -v`.include?("countdown")
  gem "fastlane_core", path: "../fastlane_core"
  gem "credentials_manager", path: "../credentials_manager"
  gem "spaceship", path: "../spaceship"
  gem "deliver", path: "../deliver"
  gem "snapshot", path: "../snapshot"
  gem "frameit", path: "../frameit"
  gem "pem", path: "../pem"
  gem "cert", path: "../cert"
  gem "sigh", path: "../sigh"
  gem "produce", path: "../produce"
  gem "gym", path: "../gym"
  gem "pilot", path: "../pilot"
  gem "supply", path: "../supply"
  gem "scan", path: "../scan"
end
