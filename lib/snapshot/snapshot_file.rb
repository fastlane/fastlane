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
          raise "Devices has to be an array" unless value.kind_of?Array
          value.each do |current|
            unless SnapshotFile.available_devices.include?current
              raise "Device '#{current}' not found. Available device types: #{available_devices}"
            end
          end
          @config.devices = value
        when :languages
          raise "Languages has to be an array" unless value.kind_of?Array
          value.each do |current|
            unless Languages::ALL_LANGUAGES.include?current
              raise "Language '#{current}' not found. Available languages: #{Languages::ALL_LANGUAGES}"
            end
          end
          @config.languages = value
        when :ios_version
          raise "ios_version has to be an String" unless value.kind_of?String
          @config.ios_version = value
        when :project_path
          raise "project_path has to be an String" unless value.kind_of?String
          @config.project_path = value
        end
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