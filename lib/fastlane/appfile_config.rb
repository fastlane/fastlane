module Fastlane
  # Access the content of the app file (e.g. app identifier and Apple ID)
  class AppfileConfig
    def self.default_path
      "./fastlane/Appfile"
    end

    def self.try_fetch_value(key)
      if File.exists?(self.default_path)
        return self.new.data[key]
      end
      nil
    end

    def initialize(path = nil)
      path ||= AppfileConfig.default_path

      raise "Could not find Appfile at path '#{path}'".red unless File.exists?(path)

      eval(File.read(path))
    end

    def data
      @data ||= {}
    end

    def app_identifier(value)
      value ||= yield if block_given?
      data[:app_identifier] = value if value
    end

    def apple_id(value)
      value ||= yield if block_given?
      data[:apple_id] = value if value
    end
  end
end