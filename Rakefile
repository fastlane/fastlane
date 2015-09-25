require "bundler/gem_tasks"
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each(&method(:import))

task default: :spec

task :test do
  sh "../fastlane/bin/fastlane test"
end

task :beta do
  require 'spaceship'
  puts "Login..."
  Spaceship::Tunes.login('flapple@krausefx.com')
  app = Spaceship::Application.find("tools.fastlane.app")
  require 'pry'

  # puts app.name["en-US"]
  # puts app.privacy_url["en-US"]
  
  details = app.details
  details.name['en-US'] = "Updated by fastlane"
  details.privacy_url['en-US'] = "https://fastlane.tools"
  details.primary_category = 'Sports'
  details.secondary_category = 'Family'
  details.save!

  # v = app.edit_version

  # puts v.marketing_url['de-DE']
  # v.marketing_url['en-US'] = "https://neu.com"
  # v.marketing_url['de-DE'] = "https://suchdeutsch.com"

end