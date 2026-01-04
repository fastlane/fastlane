require "bundler/gem_tasks"

task(:test_all) do
  formatter = "--format progress"
  formatter += " -r rspec_junit_formatter --format RspecJunitFormatter -o #{ENV['CIRCLE_TEST_REPORTS']}/rspec/fastlane-junit-results.xml" if ENV["CIRCLE_TEST_REPORTS"]
  command = "rspec --pattern spec/**/*_spec.rb,*/spec/**/*_spec.rb #{formatter} #{ENV['RSPEC_ARGS']}"

  run_rspec(command)
end

def run_rspec(command)
  # To move Ruby 3.0 or next major version migration going forward, we want to keep monitoring deprecation warnings
  if Gem.win_platform?
    # Windows would not work with /bin/bash so skip collecting warnings
    sh(command)
  else
    # Mix stderr into stdout to let handle `tee` it and then collect warnings by filtering stdout out
    command += " 2>&1 | tee >(grep 'warning:' > #{File.join(ENV['CIRCLE_TEST_REPORTS'], 'ruby_warnings.txt')})" if ENV["CIRCLE_TEST_REPORTS"]
    # tee >(...) occurs syntax error with `sh` helper which uses /bin/sh by default.
    sh("/bin/bash -o pipefail -c \"#{command}\"")
  end
end

# run, displays and saves the list of tests that do not work standalone
task(:test_all_individually) do
  files = Dir.glob("./**/*_spec.rb")

  failed = files.select do |file|
    formatter = "--format progress"
    command = "rspec #{formatter} #{ENV['RSPEC_ARGS']} #{file}"
    run_rspec(command)
    false
  rescue => _
    true
  end

  unless failed.empty?
    puts("Individual tests failing: #{failed.join(' ')}")
    file = "failed_tests"
    File.write(file, failed.join("\n"))
    raise "Some tests are failing when ran on their own. See #{file}"
  end
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
    content << "<img src='#{github_profile_url}.png' width='140px;'>"
    content << "</a>"
    if user_content['twitter']
      content << "<h4 align='center'><a href='https://twitter.com/#{user_content['twitter']}'>#{github_user_name}</a></h4>"
    else
      content << "<h4 align='center'>#{github_user_name}</h4>"
    end

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
  names = names.join("\",\n                        \"")
  gemspec.gsub!(/spec.authors\s+\=\s.*?\]/m, "spec.authors       = [\"#{names}\"]")
  File.write("fastlane.gemspec", gemspec)
end

task(default: :test_all)

# Prepare the plugin template RuboCop config before building/installing the gem
desc "Prepare .rubocop.yml for plugin template"
task(:prepare_rubocop_config) do
  require 'yaml'
  require 'fileutils'

  lib = File.expand_path('fastlane/lib', __dir__)
  rubocop_config = File.expand_path('.rubocop.yml', __dir__)

  next unless File.exist?(rubocop_config)

  config = YAML.safe_load(File.read(rubocop_config), aliases: true)
  config['require'] = %w[rubocop/require_tools rubocop-performance]
  config.delete('inherit_from')
  config.delete('CrossPlatform/ForkUsage')
  config.delete('Lint/IsStringUsage')

  target = File.join(lib, 'fastlane/plugins/template/.rubocop.yml')
  FileUtils.mkdir_p(File.dirname(target))
  File.write(target, YAML.dump(config))
end

%w(build install release).each do |t|
  Rake::Task[t].enhance([:prepare_rubocop_config]) if Rake::Task.task_defined?(t)
end
