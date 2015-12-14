module Fastlane
  module Actions
    class FrameitAction < Action
      def self.run(config)
        return if Helper.test?

        require 'frameit'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('frameit') unless Helper.is_test?
          color = Frameit::Color::BLACK
          color = Frameit::Color::SILVER if config[:white] || config[:silver]

          Helper.log.info "Framing screenshots at path #{config[:path]}"

          Dir.chdir(config[:path]) do
            ENV["FRAMEIT_FORCE_DEVICE_TYPE"] = config[:force_device_type] if config[:force_device_type]
            Frameit::Runner.new.run('.', color)
            ENV.delete("FRAMEIT_FORCE_DEVICE_TYPE") if config[:force_device_type]
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('frameit', Frameit::VERSION)
        end
      end

      def self.description
        "Adds device frames around the screenshots using frameit"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :white,
                                         env_name: "FRAMEIT_WHITE_FRAME",
                                         description: "Use white device frames",
                                         optional: true,
                                         is_string: false),
          FastlaneCore::ConfigItem.new(key: :silver,
                                       description: "Use white device frames. Alias for :white",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FRAMEIT_SCREENSHOTS_PATH",
                                       description: "The path to the directory containing the screenshots",
                                       default_value: Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] || FastlaneFolder.path),
          FastlaneCore::ConfigItem.new(key: :force_device_type,
                                       env_name: "FRAMEIT_FORCE_DEVICE_TYPE",
                                       description: "Forces a given device type, useful for Mac screenshots, as their sizes vary",
                                       optional: true,
                                       verify_block: proc do |value|
                                         available = ['iPhone_6_Plus', 'iPhone_5s', 'iPhone_4', 'iPad_mini', 'Mac']
                                         unless available.include? value
                                           raise "Invalid device type '#{value}'. Available values: #{available}".red
                                         end
                                       end)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
