module Fastlane
  class DocsGenerator
    def self.run(ff, output_path = nil)
      output_path ||= File.join(FastlaneCore::FastlaneFolder.path || '.', 'README.md')

      output = ["fastlane documentation"]
      output << "----"
      output << ""

      output << "# Installation"
      output << ""
      output << "Make sure you have the latest version of the Xcode command line tools installed:"
      output << ""
      output << "```sh"
      output << "xcode-select --install"
      output << "```"
      output << ""
      output << "For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)"
      output << ""
      output << "# Available Actions"

      all_keys = ff.runner.lanes.keys.reject(&:nil?)
      all_keys.unshift(nil) # because we want root elements on top. always! They have key nil

      all_keys.each do |platform|
        lanes = ff.runner.lanes[platform]

        if lanes.nil? || lanes.empty? || lanes.all? { |_, lane| lane.is_private }
          next
        end

        if platform
          output << ""
          output << "## #{formatted_platform(platform)}"
        end

        lanes.each do |lane_name, lane|
          next if lane.is_private
          output << render(platform, lane_name, lane.description.join("\n\n"))
        end

        output << ""
        output << "----"
        output << ""
      end

      output << "This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run."
      output << ""
      output << "More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools)."
      output << ""
      output << "The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools)."
      output << ""

      begin
        File.write(output_path, output.join("\n"))
        UI.success("Successfully generated documentation at path '#{File.expand_path(output_path)}'") if FastlaneCore::Globals.verbose?
      rescue => ex
        UI.error(ex)
        UI.error("Couldn't save fastlane documentation at path '#{File.expand_path(output_path)}', make sure you have write access to the containing directory.")
      end
    end

    #####################################################
    # @!group Helper
    #####################################################

    def self.formatted_platform(pl)
      pl = pl.to_s
      return "iOS" if pl == 'ios'
      return "Mac" if pl == 'mac'
      return "Android" if pl == 'android'

      return pl
    end

    # @param platform [String]
    # @param lane [Fastlane::Lane]
    # @param description [String]
    def self.render(platform, lane, description)
      full_name = [platform, lane].reject(&:nil?).join(' ')

      output = []
      output << ""
      output << "### #{full_name}"
      output << ""
      output << "```sh"
      output << "[bundle exec] fastlane #{full_name}"
      output << "```"
      output << ""
      output << description
      output
    end
  end
end
