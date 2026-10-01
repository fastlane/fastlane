require "bundler/gem_tasks"

Dir.glob("internal/rakelib/*.rake").each { |r| load r }

task(:test_all) do
  formatter = "--format progress"
  # On GitHub Actions - automatically write out the rspec logs to be parsed later.
  formatter += " --format json --out rspec_logs.json" if ENV["GITHUB_ACTIONS"]
  command = "rspec --pattern spec/**/*_spec.rb,*/spec/**/*_spec.rb #{formatter} #{ENV['RSPEC_ARGS']}"

  sh(command)
end

# run, displays and saves the list of tests that do not work standalone
task(:test_all_individually) do
  files = Dir.glob("./**/*_spec.rb")

  failed = files.select do |file|
    formatter = "--format progress"
    command = "rspec #{formatter} #{ENV['RSPEC_ARGS']} #{file}"
    sh(command)
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
  require_relative 'fastlane/lib/fastlane/documentation/markdown_docs_generator'

  readme = File.read("README.md")
  readme.sub!(/(?<=<!-- team:start -->\n).*(?=<!-- team:end -->)/m) { Fastlane::MarkdownDocsGenerator.render_team("team.json") }
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

# test_all and test_parallel as well as the packaging tasks. The template's
# .rubocop.yml is generated and gitignored, so a working copy can be left
# holding one from an older fastlane, and plugin_generator_spec then generates a
# plugin whose gemspec and rubocop config disagree about the Ruby version. That
# surfaces as `expected 0, got 1` with the rubocop output thrown away, which is
# a poor thing to debug: it looks like an environment problem and is a stale
# file. Regenerating first is cheap and makes the run say the same thing on any
# machine. See fastlane#30184.
%w(build install release test_all test_parallel).each do |t|
  Rake::Task[t].enhance([:prepare_rubocop_config]) if Rake::Task.task_defined?(t)
end
