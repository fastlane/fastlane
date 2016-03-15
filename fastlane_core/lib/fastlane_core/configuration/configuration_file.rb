module FastlaneCore
  # Responsible for loading configuration files
  class ConfigurationFile
    # A reference to the actual configuration
    attr_accessor :config

    # @param config [FastlaneCore::Configuration] is stored to save the resulting values
    # @param path [String] The path to the configuration file to use
    def initialize(config, path, block_for_missing)
      self.config = config
      @block_for_missing = block_for_missing
      content = File.read(path)

      # From https://github.com/orta/danger/blob/master/lib/danger/Dangerfile.rb
      if content.tr!('“”‘’‛', %(""'''))
        Helper.log.error "Your #{File.basename(path)} has had smart quotes sanitised. " \
                    'To avoid issues in the future, you should not use ' \
                    'TextEdit for editing it. If you are not using TextEdit, ' \
                    'you should turn off smart quotes in your editor of choice.'.red
      end

      begin
        # rubocop:disable Lint/Eval
        eval(content) # this is okay in this case
        # rubocop:enable Lint/Eval
      rescue SyntaxError => ex
        line = ex.to_s.match(/\(eval\):(\d+)/)[1]
        raise "Syntax error in your configuration file '#{path}' on line #{line}: #{ex}".red
      end
    end

    def method_missing(method_sym, *arguments, &block)
      # First, check if the key is actually available
      if self.config.all_keys.include? method_sym
        # This silently prevents a value from having its value set more than once.
        return unless self.config._values[method_sym].to_s.empty?

        value = arguments.first
        value = yield if value.nil? && block_given?

        self.config[method_sym] = value unless value.nil?
      else
        # We can't set this value, maybe the tool using this configuration system has its own
        # way of handling this block, as this might be a special block (e.g. ipa block) that's only
        # executed on demand
        if @block_for_missing
          @block_for_missing.call(method_sym, arguments, block)
        else
          self.config[method_sym] = '' # important, since this will raise a good exception for free
        end
      end
    end
  end
end
