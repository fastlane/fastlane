require "bundler/gem_tasks"

GEMS = %w(fastlane danger-device_grid)

SECONDS_PER_DAY = 60 * 60 * 24

task(:rubygems_admins) do
  names = ["KrauseFx", "ohayon", "mpirri", "taquitos"]
  (GEMS + ["krausefx-shenzhen", "commander-fastlane"]).each do |gem_name|
    names.each do |name|
      puts(`gem owner #{gem_name} -a #{name}`)
    end
  end
end

task(:test_all) do
  formatter = "--format progress"
  formatter += " -r rspec_junit_formatter --format RspecJunitFormatter -o #{ENV['CIRCLE_TEST_REPORTS']}/rspec/fastlane-junit-results.xml" if ENV["CIRCLE_TEST_REPORTS"]
  sh("rspec --pattern ./**/*_spec.rb #{formatter}")
end

# Overwrite the default rake task
# since we use fastlane to deploy fastlane
task(:push) do
  sh("bundle exec fastlane release")
end

task(:generate_team_table) do
  require 'json'
  content = ["<table id='team'>"]

  contributors = JSON.parse(File.read("team.json"))
  counter = 0
  number_of_rows = 5

  contributors.keys.shuffle.each do |github_user|
    user_content = contributors[github_user]
    github_user_name = user_content['name']
    github_user_id = github_user_name.downcase.gsub(' ', '-')
    github_profile_url = "https://github.com/#{github_user}"

    content << "<tr>" if counter % number_of_rows == 0
    content << "<td id='#{github_user_id}'>"
    content << "<a href='#{github_profile_url}'>"
    content << "<img src='#{github_profile_url}.png?size=140'>"
    content << "</a>"
    if user_content['twitter']
      content << "<h4 align='center'><a href='https://twitter.com/#{user_content['twitter']}'>#{github_user_name}</a></h4>"
    else
      content << "<h4 align='center'>#{github_user_name}</h4>"
    end
    # content << "<p align='center'>#{user_content['slogan']}</p>" if user_content['slogan'].to_s.length > 0

    content << "</td>"
    content << "</tr>" if counter % number_of_rows == number_of_rows - 1

    counter += 1
  end
  content << "</table>"

  readme = File.read("README.md")
  readme.gsub!(%r{\<table id='team'\>.*\<\/table\>}m, content.join("\n"))
  File.write("README.md", readme)
  puts("All done")
end

task(:update_gem_spec_authors) do
  require 'json'
  contributors = JSON.parse(File.read("team.json"))

  names = contributors.values.collect do |current|
    current["name"]
  end.shuffle

  gemspec = File.read("fastlane.gemspec")
  gemspec.gsub!(/spec.authors\s+\=\s.*/, "spec.authors       = [\"#{names.join('", "')}\"]")
  File.write("fastlane.gemspec", gemspec)
end

#####################################################
# @!group Helper Methods
#####################################################

def box(str)
  l = str.length + 4
  puts('')
  puts('=' * l)
  puts('| ' + str + ' |')
  puts('=' * l)
end

task(default: :test_all)
