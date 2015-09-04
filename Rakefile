
GEMS = %w[fastlane fastlane_core deliver snapshot frameit pem sigh produce cert codes gym pilot credentials_manager spaceship]
RAILS = %w[boarding refresher enhancer]

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

task :clone do
	(GEMS + RAILS).each do |repo|
		if File.directory?repo
			sh "cd #{repo} && git pull"
		else
			sh "git clone https://github.com/krausefx/#{repo}"
		end
	end
end

task :bundle do
	GEMS.each do |repo|
		sh "cd #{repo} && bundle install"
	end
end

task :pull do
	(GEMS + RAILS).each do |repo|
		sh "cd #{repo} && git pull"
	end		
end

task :install => :bundle do
	GEMS.each do |repo|
		sh "cd #{repo} && rake install"
	end		
end

def box(str)
	l = str.length + 4
	puts "\n=" * l
	puts "| " + str + " |"
	puts "=" * l
end
