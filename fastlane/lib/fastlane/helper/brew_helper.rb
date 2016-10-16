module Fastlane
  module Actions
    # will make sure a binary is installed via brew. If it's not, an appropriate error message is shown
    #
    # @param [String] formula_name
    #        Name of the brew formula to check
    #
    # @param [String, Gem::Requirement, Gem::Requirement] version_requirement
    #        An optional version requirement
    #
    def self.verify_brew_formula!(formula_name, version_requirement = nil)
      verify_homebrew!(formula_name)

      result = `brew ls --versions #{formula_name}`
      found = !result.empty?
      unless version_requirement.nil?
        req = Gem::Requirement.new(version_requirement)
        installed_versions = result.split(' ').drop(1).reverse
        found = installed_versions.any? do |v|
          req.satisfied_by?(Gem::Version.new(v))
        end
      end

      unless found
        UI.error("Could not find the homebrew formula '#{formula_name}'")
        UI.error("")
        UI.error("Install it first using:")
        UI.command("brew install #{formula_name}")
        UI.error("")

        UI.user_error!("You have to install the `#{formula_name}` binary on this machine") unless Helper.is_test?
      end
      true
    end

    # will check if homebrew is installed
    #
    # @param [String] formula_name
    #        Name of the brew formula we want to check the homebrew installation for.
    #        This name is only used to provide more context in the error message if brew isn't installed.
    #
    def self.verify_homebrew!(formula_name = nil)
      `which brew`
      unless $?.success?
        unless formula_name.nil?
          UI.error("Homebrew Formula '#{formula_name}'' not found")
          UI.error("")
        end
        UI.error("Homebrew doesn't even seem to be installed")
        UI.error("Install Homebrew by following the instructions at")
        UI.important("http://brew.sh")
        UI.error("")
        if formula_name.nil?
          UI.user_error!("You have to install homebrew on this machine") unless Helper.is_test?
        else
          UI.error("Then install the formula #{formula_name} using:")
          UI.command("brew install #{formula_name}")

          UI.user_error!("You have to install #{formula_name} on this machine") unless Helper.is_test?
        end
      end
    end
  end
end
