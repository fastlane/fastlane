module Fastlane
  module Actions
    class PodPushTrunkAction < Action
      def self.run(params)
        command = 'pod trunk push'
        if params[:path]
          command << " '#{params[:path]}'"
        end

        result = Actions.sh("#{command}")
        Helper.log.info "Successfully pushed Podspec".green
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Push a Podspec to Trunk"
      end

      def self.details
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The Podspec you want to push",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["squarefrog"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
