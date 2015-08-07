module Gym
  # Responsible for building the fully working xcodebuild command
  class PackageCommandGenerator
    class << self
      def generate
        parts = ["xcodebuild -exportArchive"]
        parts += options
        parts += pipe

        parts
      end

      def options
        options = []

        options << "-archivePath '#{BuildCommandGenerator.archive_path}'"
        options << "exportFormat ipa"
        options << "-exportPath '#{ipa_path}'"

        if Gym.config[:provisioning_profile_name]
          options << "-exportProvisioningProfile '#{Gym.config[:provisioning_profile_name]}'"
        end

        if Gym.config[:codesigning_identity]
          options << "-exportSigningIdentity '#{Gym.config[:codesigning_identity]}'"
        end

        options
      end

      def pipe
        [""]
      end

      # We export it to the temporary folder and move it over to the actual output once it's finished and valid
      def ipa_path
        File.join(BuildCommandGenerator.build_path, "#{Gym.config[:output_name]}.ipa")
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.dsym"].last
      end
    end
  end
end
