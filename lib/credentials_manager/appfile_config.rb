module CredentialsManager
  # Access the content of the app file (e.g. app identifier and Apple ID)
  class AppfileConfig

    def self.try_fetch_value(key)
      if self.default_path
        return self.new.data[key]
      end
      nil
    end

    def self.default_path
      ["./fastlane/Appfile", "./Appfile"].each do |current|
        return current if File.exists?current
      end
      nil
    end



    def initialize(path = nil)
      path ||= self.class.default_path      

      raise "Could not find Appfile at path '#{path}'".red unless File.exists?(path)

      full_path = File.expand_path(path)
      Dir.chdir(File.expand_path('..', path)) do
        eval(File.read(full_path))
      end
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