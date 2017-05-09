module Fastlane
  module Actions
    class ShieldAction < Action
      def self.run(params)
        subject = escape_text_param(params[:subject])
        status = escape_text_param(params[:status])
        color = params[:color]
        format = params[:format]
        style = params[:style]

        begin
          Actions.sh("wget -O \"#{params[:output_path]}\" \"https://img.shields.io/badge/#{subject}-#{status}-#{color}.#{format}?style=#{style}\"")
        rescue FastlaneCore::Interface::FastlaneError => e
          if params[:fail_on_error]
            raise e
          end
        end
      end

      def self.escape_text_param(text)
        text.gsub("_", "__").gsub("-", "--")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Downloads a customized status badge from shields.io"
      end

      def self.details
        "See http://shields.io/#your-badge for examples"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :output_path,
            description: "The path the badge will be saved to",
            is_string: true,
            optional: false),
          FastlaneCore::ConfigItem.new(
            key: :format,
            description: "The file format of the badge (svg, json, png, etc)",
            is_string: true,
            default_value: "svg"),
          FastlaneCore::ConfigItem.new(
            key: :subject,
            description: "The label for the left-hand side of the badge",
            is_string: true,
            optional: false),
          FastlaneCore::ConfigItem.new(
            key: :status,
            description: "The label for the right-hand side of the badge",
            is_string: true,
            optional: false),
          FastlaneCore::ConfigItem.new(
            key: :color,
            description: "The color (name or hexcode) of the right-hand side of the badge (ex: green, yellow, red, ff69b4)",
            is_string: true,
            default_value: "green"),
          FastlaneCore::ConfigItem.new(
            key: :style,
            description: "The style of the badge (plastic, flat, flat-square, social)",
            is_string: true,
            default_value: "flat"),
          FastlaneCore::ConfigItem.new(
            key: :fail_on_error,
            description: "If false, suppresses any errors that occur. Convenient if you don't want your builds to fail if shields.io goes down",
            is_string: false,
            default_value: true)
        ]
      end

      def self.authors
        ["dwhitlow"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
