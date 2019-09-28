source("https://rubygems.org")

gem "xcode-install", ">= 2.2.1" # needed for running xcode-install related tests

gem "danger", ">= 4.2.1", "< 5.0.0"
gem "danger-junit", ">= 0.7.3", "< 1.0.0"

gemspec(path: ".")

# temporary to test changes
gem "faraday", git: "https://github.com/bobbymcwho/faraday.git", branch: "release-0.16.2"
gem "faraday_middleware", git: "https://github.com/bobbymcwho/faraday_middleware.git", branch: "update-to-faraday-0.16.0"
# ##

plugins_path = File.join(File.expand_path("..", __FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path)
