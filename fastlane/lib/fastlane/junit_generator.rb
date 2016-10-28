module Fastlane
  class JUnitGenerator
    def self.generate(results)
      # JUnit file documentation: http://llg.cubic.org/docs/junit/
      # And http://nelsonwells.net/2012/09/how-jenkins-ci-parses-and-displays-junit-output/
      # And http://windyroad.com.au/dl/Open%20Source/JUnit.xsd

      containing_folder = ENV['FL_REPORT_PATH'] || FastlaneCore::FastlaneFolder.path || Dir.pwd
      path = File.join(containing_folder, 'report.xml')

      @steps = results
      xml_path = File.join(Fastlane::ROOT, "lib/assets/report_template.xml.erb")
      xml = ERB.new(File.read(xml_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      xml = xml.gsub('system_', 'system-').delete("\e") # Jenkins can not parse 'ESC' symbol

      File.write(path, xml)

      return path
    end
  end
end
