require "bundler/gem_tasks"

Dir.glob('tasks/**/*.rake').each(&method(:import))

task default: :spec

task :test do
  sh "../fastlane/bin/fastlane test"
end

task :push do
  sh "../fastlane/bin/fastlane release"
end

# You can run `rake messages` to test some example outputs
task :messages do
  require 'fastlane_core'
  UI = FastlaneCore::UI

  UI.message "Neutral message"
  UI.command "ls -la"
  UI.command_output "-rw-r--r--@  1 felixkrause  staff  6148 Sep 23 20:17 .DS_Store"
  UI.command_output "drwxr-xr-x  14 felixkrause  staff   476 Dec 11 19:31 .git"
  UI.command_output "-rw-r--r--   1 felixkrause  staff   681 Sep 23 19:57 .gitignore"
  UI.success "Succesully finished processing"
  UI.error "wahaha, what's going on here!"
  UI.important "Make sure to use Windows"
  UI.header "Inputs: "

  UI.password("Your password please: ")
  name = UI.input("What's your name? ")
  if UI.confirm("Are you '#{name}'?")
    UI.success "Oh yeah"
  else
    UI.error "Wups, invalid"
  end

  project = UI.select("Select your project: ", ["Test Project", "Test Workspace"])

  UI.success("Okay #{name}, you selected '#{project}'")
end

# How does a crash look like on a CI server when a value is missing?
task :ci do
  require 'fastlane_core'
  UI = FastlaneCore::UI

  ENV["TRAVIS"] = "1"
  UI.select("Select your project: ", ["Test Project", "Test Workspace"])
end
