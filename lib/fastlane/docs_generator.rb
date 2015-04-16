module Fastlane
  class DocsGenerator
    def self.run(output_path, ff)
      output = "fastlane documentation\n"
      output += "================\n"

      output += "# Installation\n"
      output += "```\n"
      output += "sudo gem install fastlane\n"
      output += "```\n\n"

      output += "# Available Actions\n"
      
      ff.runner.description_blocks.each do |lane, description|
        output += "## #{lane}\n\n"
        output += "```\n"
        output += "fastlane #{lane}\n"
        output += "```\n\n"
        output += description + "\n"
      end

      output += "\n\n----\n"
      output += "More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).\n\n"
      output += "The documentation of fastlane can be found on [GitHub](https://github.com/KrauseFx/fastlane)"

      File.write(output_path, output)
      Helper.log.info "Successfully generated documentation to path '#{File.expand_path(output_path)}'".green
    end
  end
end