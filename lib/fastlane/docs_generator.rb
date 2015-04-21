module Fastlane
  class DocsGenerator
    def self.run(output_path, ff)
      output = ["fastlane documentation"]
      output << "================"

      output << "# Installation"
      output << "```"
      output << "sudo gem install fastlane"
      output << "```"

      output << "# Available Actions"

      all_keys = ff.runner.description_blocks.keys.reject(&:nil?)
      all_keys.unshift(nil) # because we want root elements on top.. always! They have key nil

      all_keys.each do |platform|
        output << "## #{platform}" if platform

        value = ff.runner.description_blocks[platform]

        value.each do |lane, description|
          output << render(platform, lane, description)
        end

        output << "----"
      end

      output << "More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools)."
      output << "The documentation of fastlane can be found on [GitHub](https://github.com/KrauseFx/fastlane)"

      File.write(output_path, output.join("\n"))
      Helper.log.info "Successfully generated documentation to path '#{File.expand_path(output_path)}'".green
    end

    private

    def self.render(platform, lane, description)
      full_name = [platform, lane].reject(&:nil?).join(" ")

      output = []
      output << "### #{full_name}"
      output << "```"
      output << "fastlane #{full_name}"
      output << "```"
      output << description
      output
    end
  end
end
