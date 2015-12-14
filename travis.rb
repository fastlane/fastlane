gems = %w(fastlane)

gems.each do |gem|
  Dir.chdir(gem) do
    system('bundle install')
    system('bundle exec fastlane test')
  end
end
