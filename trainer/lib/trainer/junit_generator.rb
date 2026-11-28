require_relative 'module'

module Trainer
  class JunitGenerator
    attr_accessor :results

    def initialize(results)
      self.results = results
    end

    def generate
      # JUnit file documentation: http://llg.cubic.org/docs/junit/
      # And http://nelsonwells.net/2012/09/how-jenkins-ci-parses-and-displays-junit-output/
      # And http://windyroad.com.au/dl/Open%20Source/JUnit.xsd

      lib_path = Trainer::ROOT
      xml_path = File.join(lib_path, "lib/assets/junit.xml.erb")
      xml = ERB.new(File.read(xml_path), trim_mode: '<>').result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      xml = xml.gsub('system_', 'system-').delete("\e") # Jenkins cannot parse 'ESC' symbol

      # We have to manually clear empty lines
      # They may contain white spaces
      clean_xml = []
      xml.each_line do |row|
        clean_xml << row.delete("\n") if row.strip.to_s.length > 0
      end
      return clean_xml.join("\n")
    end
  end
end
