source "https://rubygems.org"

gemspec path: "fastlane"

gem "danger", "~> 0.10"

if ENV["FASTLANE_LOCAL_DEV"]
  require "fastlane/tools.rb"
  local_deps = Fastlane::TOOLS + [:fastlane_core, :credentials_manager]
  local_deps.each do |dep|
    next if dep == :fastlane    
    gem dep.to_s, path: dep.to_s
  end

end
