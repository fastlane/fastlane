module Snapshot
  class SnapshotFile

    # @return (String) The path to the used Deliverfile.
    attr_accessor :path

    # @param path (String) the path to the config file to use (including the file name)
    def initialize(path, config)
      raise "Config file not found at path '#{path}'".red unless File.exists?(path.to_s)

      self.path = path

      @config = config

      eval(File.read(self.path))
    end

    def method_missing(method_sym, *arguments, &block)
      value = arguments.first || (block.call if block_given?)

      case method_sym
        when :devices
          self.verify_devices(value)
        when :languages
          self.verify_languages(value)
        when :ios_version
          raise "ios_version has to be an String".red unless value.kind_of?String
          @config.ios_version = value
        when :scheme
          raise "scheme has to be an String".red unless value.kind_of?String
          @config.manual_scheme = value
        when :js_file
          raise "js_file has to be an String".red unless value.kind_of?String
          raise "js_file at path '#{value}' not found".red unless File.exists?value
          @config.manual_js_file = value.gsub("~", ENV['HOME'])
        when :screenshots_path
          raise "screenshots_path has to be an String".red unless value.kind_of?String
          @config.screenshots_path = value.gsub("~", ENV['HOME'])
        when :html_path
          raise "html_path has to be an String".red unless value.kind_of?String
          @config.html_path = value.gsub("~", ENV['HOME'])
          @config.html_path = @config.html_path + "/screenshots.html" unless @config.html_path.include?".html"
        when :build_command
          raise "build_command has to be an String".red unless value.kind_of?String
          @config.build_command = value
        when :project_path
          raise "project_path has to be an String".red unless value.kind_of?String

          if File.exists?value and (value.end_with?".xcworkspace" or value.end_with?".xcodeproj")
            @config.project_path = value.gsub("~", ENV['HOME'])
          else
            raise "The given project_path '#{value}' could not be found. Make sure to include the extension as well.".red
          end
        else
          Helper.log.error "Unknown method #{method_sym}"
        end
    end

    def verify_devices(value)
      raise "Devices has to be an array".red unless value.kind_of?Array
      @config.devices = []
      value.each do |current|
        current += " (#{@config.ios_version} Simulator)" unless current.include?"Simulator"

        unless SnapshotFile.available_devices.include?current
          raise "Device '#{current}' not found. Available device types: #{SnapshotFile.available_devices}".red
        else
          @config.devices << current
        end
      end
    end

    def verify_languages(value)
      raise "Languages has to be an array".red unless value.kind_of?Array
      value.each do |current|
        unless Languages::ALL_LANGUAGES.include?current
          raise "Language '#{current}' not found. Available languages: #{Languages::ALL_LANGUAGES}".red
        end
      end
      @config.languages = value
    end

    def self.available_devices
      if not @result
        @result = []
        `instruments -s`.split("\n").each do |current|
          # Example: "iPhone 5 (8.1 Simulator) [C49ECC4A-5A3D-44B6-B9BF-4E25BC326400]"
          @result << current.split(' [').first if current.include?"Simulator"
        end
      end
      return @result
    end
  end
end