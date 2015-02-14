require 'nokogiri'

module Fastlane
  class JUnitGenerator
    def self.generate(results)
      # JUnit file documentation: http://llg.cubic.org/docs/junit/
      # And http://nelsonwells.net/2012/09/how-jenkins-ci-parses-and-displays-junit-output/

      containing_folder = Fastlane::FastlaneFolder.path || Dir.pwd
      path = File.join(containing_folder, 'report.xml')

      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.testsuites(name: 'fastlane') do
          xml.testsuite(name: 'deploy') do
            results.each_with_index do |current, index|
              xml.testcase(name: [index, current[:name]].join(': '), time: current[:time]) do
                xml.failure(message: current[:error]) if current[:error]
                xml.system_out current[:output] if current[:output]
              end
            end
          end
        end
      end
      result = builder.to_xml.gsub('system_', 'system-').gsub("", ' ') # Jenkins can not parse 'ESC' symbol

      File.write(path, result)

      path
    end
  end
end
