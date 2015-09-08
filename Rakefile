
GEMS = %w[fastlane fastlane_core deliver snapshot frameit pem sigh produce cert codes gym pilot credentials_manager spaceship]
RAILS = %w[boarding refresher enhancer]

#####################################################
# @!group Everything to be executed in the root folder containing all fastlane repos
#####################################################

desc "Setup the fastlane development environment"
task :bootstrap do	
	if system('which bundle')
    Rake::Task[:clone].invoke
    Rake::Task[:install].invoke
  else
    raise "Please install bundler using `sudo gem install bundler`"
  end

  box "You are up and running"
end

desc "Clones all the repositories. Use `bootstrap` if you want to clone + install all gems"
task :clone do
	(GEMS + RAILS).each do |repo|
		if File.directory?repo
			sh "cd #{repo} && git pull"
		else
			sh "git clone https://github.com/krausefx/#{repo}"
		end
	end
end

desc "Run `bundle install` for all the gems."
task :bundle do
	GEMS.each do |repo|
		sh "cd #{repo} && bundle install"
	end
end

desc "Run `bundle install` and `rake install` for all the gems."
task :install => :bundle do
	GEMS.each do |repo|
		sh "cd #{repo} && rake install"
	end
end


desc "Show the un-commited changes from all repos"
task :diff do
	(GEMS + RAILS).each do |repo|
		output = `cd #{repo} && git diff --stat` # not using `sh` as it gets you into its own view
		if (output || "").length > 0
			box repo
			puts output
		end
	end
end

desc "Pulls the latest changes from all the gems repos"
task :pull do
	sh "git pull" # the countdown repo itself
	
	(GEMS + RAILS).each do |repo|
		sh "cd #{repo} && git pull"
	end		
end

desc "Fetches the latest rubocop config from the fastlane main repo"
task :fetch_rubocop do
	fl_path = "./fastlane/.rubocop_general.yml"
	raise "Could not find rubocop configuration in fastlane repository" unless File.exist?(fl_path)
	rubocop_file = File.read(fl_path)

	GEMS.each do |repo|
		next if repo == 'fastlane' # we don't want to overwrite the main repo's config

		path = File.join(repo, ".rubocop_general.yml")
		if File.exist?(path)
			# we only want to store the file for repos we use rubocop in
			if File.read(path) != rubocop_file
				File.write(path, rubocop_file)
				puts "+ Updated rubocop file #{path}"
			else
				puts "- File #{path} unchanged"
			end
		end
	end
end

desc "Fetch the latest rubocop config and apply&test it for all gems"
task :rubocop => :fetch_rubocop do
	GEMS.each do |repo|
		path = File.join(repo, ".rubocop_general.yml")
		if File.exist?(path)
			begin
				sh "cd #{repo} && rubocop"
			rescue => ex
				box "Validation for #{repo} failed"
			end
		end
	end
end

desc "Print out the # of unreleased commits"
task :unreleased do
	GEMS.each do |repo|
		Dir.chdir(repo) do
			`git pull --tags`

			last_tag = `git describe --abbrev=0 --tags`.strip
			output = `git log #{last_tag}..HEAD --oneline`.strip

			if output.length > 0
				box "#{repo}: #{output.split("\n").count} Commits"
				output.split("\n").each do |line|
					puts "\t" + line.split(" ", 1).last # we don't care about the commit ID
				end

				puts "\nhttps://github.com/KrauseFx/#{repo}/compare/#{last_tag}...master"
			end
		end
	end
end

#####################################################
# @!group Helper Methods
#####################################################

def box(str)
	l = str.length + 4
	puts ""
	puts "=" * l
	puts "| " + str + " |"
	puts "=" * l
end
