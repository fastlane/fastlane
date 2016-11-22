GEMS = %w(fastlane fastlane_core deliver snapshot frameit pem sigh produce cert gym pilot credentials_manager spaceship scan supply watchbuild match screengrab danger-device_grid)
RAILS = %w(boarding refresher enhancer)

SECONDS_PER_DAY = 60 * 60 * 24

#####################################################
# @!group Everything to be executed in the root folder containing all fastlane repos
#####################################################

desc 'Setup the fastlane development environment'
task :bootstrap do
  system('gem install bundler') unless system('which bundle')
  Rake::Task[:install].invoke

  box 'You are up and running'
end

desc 'Run `bundle update` for all the gems.'
task :bundle do
  GEMS.each do |repo|
    sh "cd #{repo} && bundle update"
  end
end

desc 'Run `bundle update` and `rake install` for all the gems.'
task install: :bundle do
  GEMS.each do |repo|
    sh "cd #{repo} && rake install"
  end
end

task :rubygems_admins do
  names = ["KrauseFx", "ohayon", "hemal", "asfalcone", "mpirri", "mfurtak", "milch"]
  (GEMS + ["krausefx-shenzhen"]).each do |gem_name|
    names.each do |name|
      puts `gem owner #{gem_name} -a #{name}`
    end
  end
end

task :update_dependencies do
  puts "Updating all internal fastlane dependencies"

  # This requires all version numbers to be x.x.x (3 components)
  regex = %r{spec.add_dependency .(.+).\, .\>\= (\d+\.\d+\.\d+).\, .\< \d+\.\d+\.\d+.}

  Dir["./**/*.gemspec"].each do |current_gemspec_path|
    content = File.read(current_gemspec_path)

    content.gsub!(regex) do |full_match|
      gem_name = $1
      current_version_number = Gem::Version.new($2) # used to detect if we actually changed something

      version_path = "./#{gem_name}/lib/#{gem_name}/version.rb"
      if File.exist?(version_path) && gem_name != "screengrab" # internal dependency
        version = Gem::Version.new(File.read(version_path).match(/VERSION.=..(\d+\.\d+\.\d+)./)[1])
        next_major_version = Gem::Version.new("#{version.segments[0] + 1}.0.0")

        puts "🚀  Updating #{gem_name} from #{current_version_number} to #{version} for #{gem_name}" if version != current_version_number

        "spec.add_dependency \"#{gem_name}\", \">= #{version}\", \"< #{next_major_version}\""
      else
        full_match # external dependency
      end
    end

    puts "✅   Writing to #{current_gemspec_path}"
    File.write(current_gemspec_path, content)
  end
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
