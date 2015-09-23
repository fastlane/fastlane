module Fastlane
  module Actions
    # will make sure a gem is installed. If it's not an appropriate error message is shown
    # this will *not* 'require' the gem
    def self.verify_gem!(gem_name)
      begin
        Gem::Specification.find_by_name(gem_name)
      rescue Gem::LoadError
        raise "You have to install the `#{gem_name}` using `sudo gem install #{gem_name}` to use this action. If you use a `Gemfile` add '#{gem_name}' to it".red
      end
      true
    end
  end
end
