require "bundler/gem_tasks"
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each(&method(:import))

task default: :spec

task :test do
  sh "../fastlane/bin/fastlane test"
end

task :beta do
  require 'spaceship'
  Spaceship::Tunes.login('flapple@krausefx.com')
  app = Spaceship::Application.find("tools.fastlane.app")
  require 'pry'

  app.edit_version
  binding.pry
  # binding.pry
  # puts app.live_version
  # binding.pry
end