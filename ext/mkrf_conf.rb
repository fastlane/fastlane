require 'rubygems/dependency_installer'

di = Gem::DependencyInstaller.new

begin
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.4.0')
    di.install 'json', ['>= 2.0.1', '< 3.0.0']
  else
    di.install 'json', '< 3.0.0'
  end
rescue => e
  warn "#{$0}: #{e}"
  exit!
end

# Write fake Rakefile for rake since Makefile isn't used
File.open(File.join(File.dirname(__FILE__), 'Rakefile'), 'w') do |f|
  f.write("task :default" + $/)
end
