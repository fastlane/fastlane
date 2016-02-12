module Fastlane
  module Actions
    class ErbAction < Action
      def self.run(params)
        template = File.read(params[:template])
        result =   ERB.new(template).result(OpenStruct.new(params[:placeholders]).instance_eval { binding })
        File.open(params[:destination], 'w') { |file| file.write(result) } if params[:destination]
        Helper.log.info "Successfully parsed template: '#{params[:template]}' and rendered output to: #{params[:destination]}" if params[:destination]
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Allows to Generate output files based on ERB templates"
      end

      def self.details
        "Renders an ERB template with `placeholders` given as a hash via parameter, if no :destination is set, returns rendered template as string"
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :template,
                                       short_option: "-T",
                                       env_name: "FL_ERB_SRC",
                                       description: "ERB Template File",
                                       optional: false,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       short_option: "-D",
                                       env_name: "FL_ERB_DST",
                                       description: "Destination file",
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :placeholders,
                                       short_option: "-p",
                                       env_name: "FL_ERB_PLACEHOLDERS",
                                       description: "Placeholders given as a hash",
                                       default_value: {},
                                       is_string: false,
                                       type: Hash
                                      )

        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
