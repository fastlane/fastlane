module Fastlane
  class JUnitGenerator
    def self.generate(results)
      # JUnit file documentation: http://llg.cubic.org/docs/junit/
      # And http://nelsonwells.net/2012/09/how-jenkins-ci-parses-and-displays-junit-output/

      containing_folder = Fastlane::FastlaneFolder.path || Dir.pwd
      path = File.join(containing_folder, 'report.xml')

      @steps = results
      xml_path = File.join(lib_path, "assets/report_template.xml.erb")
      xml = ERB.new(File.read(xml_path)).result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      xml = xml.gsub('system_', 'system-').delete("\e") # Jenkins can not parse 'ESC' symbol

      File.write(path, xml)

      return path
    end

    def self.lib_path
      if !Helper.is_test? and Gem::Specification.find_all_by_name('fastlane').any?
        return [Gem::Specification.find_by_name('fastlane').gem_dir, 'lib'].join('/')
      else
        return './lib'
      end
    end
  end
end
