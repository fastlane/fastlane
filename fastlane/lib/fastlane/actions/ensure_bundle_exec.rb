module Fastlane
  module Actions
    module SharedValues
    end

    # Raises an exception and stop the lane execution if the repo is not on a specific branch
    class EnsureBundleExecAction < Action
      def self.run(params)

        # gemfile_path = PluginManager.new.gemfile_path
        # if gemfile_path

          if !FastlaneCore::Helper.bundler?
            UI.user_error!("Not using bundled fastlane")
          end
        
        #   # The user has a Gemfile, but forgot to use `bundle exec`
        #   # Let's tell the user how to use `bundle exec`
        #   # We show this warning no matter if the command is slow or not
        #   UI.important("fastlane detected a Gemfile in the current directory")
        #   UI.important("however it seems like you don't use `bundle exec`")
        #   UI.important("to launch fastlane faster, please use")
        #   UI.message("")
        #   UI.command "bundle exec fastlane #{ARGV.join(' ')}"
        #   UI.message("")
        # end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Raises an exception if not on a using bundler"
      end

      def self.details
        [
          "This action will check if you are using bundler."
        ].join("\n")
      end

      def self.available_options
        [
        ]
      end

      def self.output
        []
      end

      def self.author
        ['rishabhtayal']
      end

      def self.example_code
        [
          "ensure_bundle_exec"
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
