module Fastlane
  module Actions
    class PodLibLintAction < Action
      def self.run(params)
        command = []

        if File.exist?("Gemfile") && params[:use_bundle_exec]
          command << "bundle exec"
        end

        command << "pod lib lint"

        if params[:verbose]
          command << "--verbose"
        end

        if params[:sources]
          sources = params[:sources].join(",")
          command << "--sources='#{sources}'"
        end

        if params[:allow_warnings]
          command << "--allow-warnings"
        end

        result = Actions.sh(command.join(' '))
        Helper.log.info "Pod lib lint Successfully ⬆️ ".green
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Pod lib lint"
      end

      def self.details
        "Test the syntax of your Podfile by linting the pod against the files of its directory"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                         description: "Use bundle exec when there is a Gemfile presented",
                                         is_string: false,
                                         default_value: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                         description: "Allow ouput detail in console",
                                         optional: true,
                                         is_string: false),
          FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                         description: "Allow warnings during pod lint",
                                         optional: true,
                                         is_string: false),
          FastlaneCore::ConfigItem.new(key: :sources,
                                         description: "The sources of repos you want the pod spec to lint with, separated by commas",
                                         optional: true,
                                         is_string: false,
                                         verify_block: proc do |value|
                                           raise "Sources must be an array.".red unless value.kind_of?(Array)
                                         end)
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["thierryxing"]
      end

      def self.is_supported?(platform)
        true
      end

    end
  end
end
