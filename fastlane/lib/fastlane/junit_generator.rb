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
      xml = ERB.new(File.read(xml_path)).result(binding) # https://web.archive.org/web/20160430190141/www.rrn.dk/rubys-erb-templating-system

      xml = xml.gsub('system_', 'system-').delete("\e") # Jenkins cannot parse 'ESC' symbol

      begin
        File.write(path, xml)
      rescue => ex
        UI.error(ex)
        UI.error("Couldn't save report.xml at path '#{File.expand_path(path)}', make sure you have write access to the containing directory.")
      end

      return path
    end
  end
end
