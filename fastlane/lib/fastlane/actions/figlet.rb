module Fastlane
  module Actions
    module SharedValues
      FIGLET_CUSTOM_VALUE = :FIGLET_CUSTOM_VALUE
    end

    class FigletAction < Action
      def self.run(params)
        text = params[:text]
        font = params[:font]
        output = `figlet  -f #{font}  #{text.upcase}`
        puts output
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "figlet wraps around the figlet command to create big ASCII ART"
      end

      def self.details
        ["This action requires that you have figlet installed.  On a mac you can",
         " do this with the command:       brew install figlet",
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :text,
                                       env_name: "FL_FIGLET_TEXT",
                                       description: "Text to ASCII-ify",
                                       verify_block: proc do |value|
                                         raise "No text given, pass using `text: 'STRING'`".red unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :font,
                                       env_name: "FL_FIGLET_FONT",
                                       description: "custom figlet font",
                                       is_string: true,
                                       default_value: "standard")
        ]
      end

      def self.authors
        ["Jeeftor"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
