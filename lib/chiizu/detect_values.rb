module Chiizu
  class DetectValues
    # This is needed to supply default values which are based on config values determined in the initial
    # configuration pass
    def self.set_additional_default_values
      config = Chiizu.config

      # First, try loading the Chiizufile from the current directory
      config.load_configuration_file(Chiizu.chiizufile_name)

      unless config[:tests_package_name]
        config[:tests_package_name] = "#{config[:app_package_name]}.test"
      end
    end
  end
end
