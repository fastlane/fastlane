require "bundler/gem_tasks"

GEMS = %w(fastlane danger-device_grid)
RAILS = %w(boarding refresher enhancer)

SECONDS_PER_DAY = 60 * 60 * 24

task :rubygems_admins do
  names = ["KrauseFx", "ohayon", "hemal", "asfalcone", "mpirri", "mfurtak", "milch"]
  (GEMS + ["krausefx-shenzhen"]).each do |gem_name|
    names.each do |name|
      puts `gem owner #{gem_name} -a #{name}`
    end
  end
end

task :test_all do
  formatter = "--format progress"
  formatter += " -r rspec_junit_formatter --format RspecJunitFormatter -o $CIRCLE_TEST_REPORTS/rspec/fastlane-junit-results.xml" if ENV["CIRCLE_TEST_REPORTS"]
  sh "rspec -t now --pattern ./**/*_spec.rb #{formatter}"
end

# Overwrite the default rake task
# since we use fastlane to deploy fastlane
task :push do
  sh "bundle exec fastlane release"
end

#####################################################
# @!group Helper Methods
#####################################################

def box(str)
  l = str.length + 4
  puts ''
  puts '=' * l
  puts '| ' + str + ' |'
  puts '=' * l
end

task default: :test_all
