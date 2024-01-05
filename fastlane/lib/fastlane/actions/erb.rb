module Fastlane
  module Actions
    class ErbAction < Action
      def self.run(params)
        template = File.read(params[:template])
        trim_mode = params[:trim_mode]

        result = Fastlane::ErbTemplateHelper.render(template, params[:placeholders], trim_mode)

        File.open(params[:destination], 'w') { |file| file.write(result) } if params[:destination]
        UI.message("Successfully parsed template: '#{params[:template]}' and rendered output to: #{params[:destination]}") if params[:destination]
        result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Allows to Generate output files based on ERB templates"
      end

      def self.details
        [
          "Renders an ERB template with `:placeholders` given as a hash via parameter.",
          "If no `:destination` is set, it returns the rendered template as string."
        ].join("\n")
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :template,
                                       short_option: "-T",
                                       env_name: "FL_ERB_SRC",
                                       description: "ERB Template File",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       short_option: "-D",
                                       env_name: "FL_ERB_DST",
                                       description: "Destination file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :placeholders,
                                       short_option: "-p",
                                       env_name: "FL_ERB_PLACEHOLDERS",
                                       description: "Placeholders given as a hash",
                                       default_value: {},
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :trim_mode,
                                       short_option: "-t",
                                       env_name: "FL_ERB_TRIM_MODE",
                                       description: "Trim mode applied to the ERB",
                                       optional: true)

        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.example_code
        [
          '# Example `erb` template:

          # Variable1 <%= var1 %>
          # Variable2 <%= var2 %>
          # <% for item in var3 %>
          #        <%= item %>
          # <% end %>

          erb(
            template: "1.erb",
            destination: "/tmp/rendered.out",
            placeholders: {
              :var1 => 123,
              :var2 => "string",
              :var3 => ["element1", "element2"]
            }
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
