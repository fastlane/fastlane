module Fastlane
  module Actions
    class ImportFromGemAction < Action
      def self.run(params)
        # in fast_file.rb
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Import Fastfiles from an installed gem to use their lanes"
      end

      def self.details
        [
          "Like `import_from_git`, this is useful if you share lanes across multiple apps, here by packaging the Fastfiles in a gem. The project's `Gemfile.lock` then pins the version of the shared lanes and of what they depend on, and the fastlane plugins the gem depends on are loaded when its Fastfiles are imported.",
          "The gem must be in the project's Gemfile. By default every `fastlane/Fastfile*` in the gem is imported, so lanes can be split into files by purpose; an `actions` folder next to them is imported too."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :gem_name,
                                       optional: false,
                                       type: String,
                                       description: "The gem to import the Fastfiles and actions from"),
          FastlaneCore::ConfigItem.new(key: :paths,
                                       description: "The path(s) of the Fastfiles in the gem, as glob patterns",
                                       type: Array,
                                       default_value: ['fastlane/Fastfile*'],
                                       optional: true)
        ]
      end

      def self.category
        :misc
      end

      def self.output
        [
        ]
      end

      def self.return_value
      end

      def self.authors
        ["lacostej"]
      end

      def self.example_code
        [
          'import_from_gem(
            gem_name: "my_company_lanes" # The gem to import the Fastfiles from, listed in your Gemfile
          )',
          'import_from_gem(
            gem_name: "my_company_lanes",
            paths: ["fastlane/Fastfile", "fastlane/Fastfile.release"] # The Fastfiles to import, relative to the gem
          )'
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
