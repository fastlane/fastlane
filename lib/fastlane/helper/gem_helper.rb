module Fastlane
  module Actions
    # will make sure a gem is installed. If it's not an appropriate error message is shown
    # this will *not* 'require' the gem
    def self.verify_gem!(gem_name)
      begin
        Gem::Specification.find_by_name(gem_name)
      rescue Gem::LoadError
        print_gem_error "Could not find gem '#{gem_name}'"
        print_gem_error ""
        print_gem_error "If you installed fastlane using `sudo gem install fastlane` run"
        print_gem_error "`sudo gem install #{gem_name}` to install the missing gem"
        print_gem_error ""
        print_gem_error "If you use a Gemfile add this to your Gemfile:"
        print_gem_error "gem '#{gem_name}'"
        print_gem_error "and run `bundle install`"

        raise "You have to install the `#{gem_name}`".red unless Helper.is_test?
      end
      true
    end

    def self.print_gem_error(str)
      Helper.log.error str.red
    end
  end
end
