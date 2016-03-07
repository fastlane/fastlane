module Fastlane
  module Actions
    class PemAction < Action
      def self.run(params)
        require 'pem'
        require 'pem/options'
        require 'pem/manager'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('pem') unless Helper.is_test?

          success_block = params[:new_profile]

          PEM.config = params

          if Helper.is_test?
            profile_path = './test.pem'
          else
            profile_path = PEM::Manager.start
          end

          if success_block and profile_path
            success_block.call(File.expand_path(profile_path)) if success_block
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('pem', PEM::VERSION)
        end
      end

      def self.description
        "Makes sure a valid push profile is active and creates a new one if needed"
      end

      def self.author
        "KrauseFx"
      end

      def self.details
        [
          "Additionally to the available options, you can also specify a block that only gets executed if a new",
          "profile was created. You can use it to upload the new profile to your server.",
          "Use it like this: ",
          "pem(",
          "  new_profile: proc do ",
          "    # your upload code",
          "  end",
          ")"
        ].join("\n")
      end

      def self.available_options
        require 'pem'
        require 'pem/options'

        unless @options
          @options = PEM::Options.available_options
          @options << FastlaneCore::ConfigItem.new(key: :new_profile,
                                       description: "Block that is called if there is a new profile",
                                       optional: true,
                                       is_string: false)
        end
        @options
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
