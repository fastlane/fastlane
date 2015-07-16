module FastlaneCore
  # Responsible for loading configuration files
  class ConfigurationFile
    # A reference to the actual configuration
    attr_accessor :config

    # @param config [FastlaneCore::Configuration] is stored to save the resulting values
    # @param path [String] The path to the configuration file to use
    def initialize(config, path)
      self.config = config
      eval(File.read(path))
    end

    def method_missing(method_sym, *arguments, &block)
      value = arguments.first || (block.call if block_given?) # this is either a block or a value
      if value
        self.config[method_sym] = value
      end
    end
  end
end