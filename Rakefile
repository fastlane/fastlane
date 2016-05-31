require 'pry'
GEMS = %w(fastlane fastlane_core deliver snapshot frameit pem sigh produce cert gym pilot credentials_manager spaceship scan supply watchbuild match screengrab)
RAILS = %w(boarding refresher enhancer)
GITHUB_TOKEN = ENV['GITHUB_SCRIPT_TOKEN'] || ENV['FL_GITHUB_RELEASE_API_TOKEN']

SECONDS_PER_DAY = 60 * 60 * 24

#####################################################
# @!group Everything to be executed in the root folder containing all fastlane repos
#####################################################

desc 'Setup the fastlane development environment'
task :bootstrap do
  system('gem install bundler') unless system('which bundle')
  Rake::Task[:clone].invoke
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
  names = ["KrauseFx", "ohayon", "samrobbins", "hemal", "asfalcone", "mpirri", "mfurtak", "i2amsam"]
  GEMS.each do |gem_name|
    names.each do |name|
      puts `gem owner #{gem_name} -a #{name}`
    end
  end
end

desc 'show repos with checked-out feature-branches'
task :features do
  (['.'] + GEMS + RAILS).each do |repo|
    branch = `cd #{repo} && git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'}`
    puts "#{repo}\n  -> #{branch}" unless branch.include?('master')
  end
end

desc 'Apply the code from the specified PR on a branch from your local working copy. Run with `rake try_out[PR#]`'
task :try_out, [:pull] do |t, args|
  pr_num = args[:pull]

  pending_changes = `git status --porcelain`
  if pending_changes.length > 0
    puts "You do not have a clean working directory".red
    puts "Please stash or commit your changes before trying out #{pr_num.blue}"
    next
  end

  require 'faraday'
  require 'faraday_middleware'
  conn = Faraday.new do |req|
    req.headers['Authorization'] = "token #{GITHUB_TOKEN}"
    req.use FaradayMiddleware::FollowRedirects
    req.adapter :net_http
  end

  pr = JSON.parse(conn.get("https://api.github.com/repos/fastlane/fastlane/pulls/#{pr_num}").body)
  puts "Getting pull request ##{pr_num}: #{pr['title']}".green
  sh "git checkout -B try_out-#{pr_num} && curl -s -L '#{pr['patch_url']}' | git apply"
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
