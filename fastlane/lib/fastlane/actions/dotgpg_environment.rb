module Fastlane
  module Actions
    module SharedValues
    end

    class DotgpgEnvironmentAction < Action
      def self.run(options)
        Actions.verify_gem!('dotgpg')
        require 'dotgpg/environment'

        UI.message("Reading secrets from #{options[:dotgpg_file]}")
        Dotgpg::Environment.new(options[:dotgpg_file]).apply
      end

      def self.description
        "Reads in production secrets set in a dotgpg file and puts them in ENV"
      end

      def self.details
        "More information about dotgpg can be found at https://github.com/ConradIrwin/dotgpg"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dotgpg_file,
                                       env_name: "DOTGPG_FILE",
                                       description: "Path to your gpg file",
                                       code_gen_sensitive: true,
                                       default_value: Dir["dotgpg/*.gpg"].last,
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Dotgpg file '#{File.expand_path(value)}' not found") unless File.exist?(value)
                                       end)
        ]
      end

      def self.authors
        ["simonlevy5"]
      end

      def self.example_code
        [
          "dotgpg_environment(dotgpg_file: './path/to/gpgfile')"
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
