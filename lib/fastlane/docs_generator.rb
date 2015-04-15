module Fastlane
  class DocsGenerator
    def self.run(output_path, ff)
      output = "fastlane actions\n"
      output += "================\n"
      
      ff.runner.description_blocks.each do |lane, description|
        output += "## #{lane}\n\n"
        output += "```\n"
        output += "fastlane #{lane}\n"
        output += "```\n\n"
        output += description + "\n"
      end
      
      File.write(output_path, output)
      Helper.log.info "Successfully generated documentation to path '#{File.expand_path(output_path)}'".green
    end
  end
end