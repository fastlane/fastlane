module Fastlane
  module Actions
    module SharedValues
    end

    class DotgpgEnvironmentAction < Action
      def self.run(options)
        require 'dotgpg/environment'

        if options[:dotgpg_file]
          dotgpg_file = options[:dotgpg_file]
        end

        raise "Dotgpg file '#{File.expand_path(dotgpg_file)}' not found".red if dotgpg_file && !File.exist?(dotgpg_file)

        Helper.log.info "Reading secrets from #{dotgpg_file}"
        Dotgpg::Environment.new(dotgpg_file).apply
      end

      def self.description
        "Reads in production secrets set in a dotgpg file and puts them in ENV."
      end

      def self.details
        "More information about dotgpg can be found at https://github.com/ConradIrwin/dotgpg"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dotgpg_file,
                                       env_name: "DOTGPG_FILE",
                                       description: "Path to your DSYM file",
                                       default_value: Dir["dotgpg/*.gpg"].last,
                                       optional: false,
                                       verify_block: proc do |value|
                                         # validation is done in the action
                                       end)
        ]
      end

      def self.authors
        ["simonlevy5"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
