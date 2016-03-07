require 'bundler/gem_tasks'
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each(&method(:import))

task default: :spec

task :test do
  sh "../fastlane/bin/fastlane test"
end

task :push do
  sh "../fastlane/bin/fastlane release"
end
