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
        UI.error("Your #{File.basename(path)} has had smart quotes sanitised. " \
                  'To avoid issues in the future, you should not use ' \
                  'TextEdit for editing it. If you are not using TextEdit, ' \
                  'you should turn off smart quotes in your editor of choice.')
      end

      begin
        # rubocop:disable Lint/Eval
        eval(content) # this is okay in this case
        # rubocop:enable Lint/Eval

        print_resulting_config_values(path) # only on success
      rescue SyntaxError => ex
        line = ex.to_s.match(/\(eval\):(\d+)/)[1]
        UI.user_error!("Syntax error in your configuration file '#{path}' on line #{line}: #{ex}")
      end
    end

    def print_resulting_config_values(path)
      require 'terminal-table'
      UI.success("Successfully loaded '#{File.expand_path(path)}' 📄")

      # Show message when self.modified_values is empty
      if self.modified_values.empty?
        UI.important("No values defined in '#{path}'")
        return
      end

      rows = self.modified_values.collect do |key, value|
        [key, value] if value.to_s.length > 0
      end.compact

      puts ""
      puts Terminal::Table.new(rows: rows, title: "Detected Values from '#{path}'")
      puts ""
    end

    # This is used to display only the values that have changed in the summary table
    def modified_values
      @modified_values ||= {}
    end

    def method_missing(method_sym, *arguments, &block)
      # First, check if the key is actually available
      if self.config.all_keys.include?(method_sym)
        # This silently prevents a value from having its value set more than once.
        return unless self.config._values[method_sym].to_s.empty?

        value = arguments.first
        value = yield if value.nil? && block_given?

        return if value.nil?
        self.modified_values[method_sym] = value
        self.config[method_sym] = value
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
