gem = ENV['GEM']

Dir.chdir(gem) do
  system('bundle install')
  system('bundle exec fastlane test')
end
