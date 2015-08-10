module Gym
  # Responsible for building the fully working xcodebuild command
  #
  # See: http://stackoverflow.com/a/23683125
  class PackageCommandGenerator
    class << self
      def generate
        parts = ["/usr/bin/xcrun -sdk iphoneos PackageApplication -v"]
        parts += options
        parts += pipe

        parts
      end

      def options
        options = []

        options << "#{app_file_name}"
        options << "-o"
        options << "#{ipa_path}"

        if Gym.config[:provisioning_profile_name]
          options << "--embed '#{Gym.config[:provisioning_profile_name]}'"
        end

        if Gym.config[:codesigning_identity]
          options << "--sign '#{Gym.config[:codesigning_identity]}'"
        end

        options
      end

      def pipe
        [""]
      end

      # The app file name defined in the `Products/Applications` path.
      def app_file_name
        Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").first
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
