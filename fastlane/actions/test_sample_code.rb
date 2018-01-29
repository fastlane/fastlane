module Fastlane
  module Actions
    class TestSampleCodeAction < Action
      def self.run(params)
        content = File.read(params[:path])

        fill_in_env_variables

        # /m says we ignore new line
        errors = []
        content.scan(/```ruby\n([^`]*)\n```/m).each do |current_match|
          current_match = current_match.first # we only expect one match
          next if current_match.include?("sh(") # we don't want to run any shell scripts

          UI.verbose("parsing: #{current_match}")

          begin
            begin
              # rubocop:disable Security/Eval
              eval(current_match)
              # rubocop:enable Security/Eval
            rescue SyntaxError => ex
              UI.user_error!("Syntax error in code sample:\n#{current_match}\n#{ex}")
            rescue => ex
              UI.user_error!("Error found in code sample:\n#{current_match}\n#{ex}")
            end
          rescue => ex
            errors << ex
          end
        end

        UI.error("Found errors in the documentation, more information above") unless errors.empty?
        errors.each do |ex|
          UI.error(ex)
        end

        ENV.delete("CI")
        UI.user_error!("Found #{errors.count} errors in the documentation") unless errors.empty?
      end

      # Is used to look if the method is implemented as an action
      def self.method_missing(method_sym, *arguments, &_block)
        return if blacklist.include?(method_sym)

        class_ref = self.runner.class_reference_from_action_name(method_sym)
        unless class_ref
          alias_found = self.runner.find_alias(method_sym.to_s)
          if alias_found
            class_ref = self.runner.class_reference_from_action_name(alias_found.to_sym)
          end
        end

        UI.user_error!("Could not find method or action named '#{method_sym}'") if class_ref.nil?
        available_options = class_ref.available_options

        if available_options.kind_of?(Array) && available_options.first && available_options.first.kind_of?(FastlaneCore::ConfigItem)
          parameters = arguments.shift || []
          parameters.each do |current_argument, value|
            UI.verbose("Verifying '#{value}' for option '#{current_argument}' for action '#{method_sym}'")

            config_item = available_options.find { |a| a.key == current_argument }
            UI.user_error!("Unknown parameter '#{current_argument}' for action '#{method_sym}'") if config_item.nil?

            if config_item.data_type && !value.kind_of?(config_item.data_type) && !config_item.optional && !config_item.skip_type_validation
              UI.user_error!("'#{current_argument}' value must be a #{config_item.data_type}! Found #{value.class} instead.")
            end
          end
        else
          UI.verbose("Legacy parameter technique for action '#{method_sym}'")
        end

        return class_ref.sample_return_value # optional value that can be set by the action to make code samples work
      end

      # If the action name is x, don't run the verification
      # This will still verify the syntax though
      # The actions listed here are still legacy actions, so
      # they don't use the fastlane configuration system
      def self.blacklist
        [
          :import,
          :xcode_select,
          :frameit,
          :refresh_dsyms,
          :lane,
          :before_all,
          :verify_xcode,
          :error
        ]
      end

      # Metadata
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path)
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.fill_in_env_variables
        ENV["CI"] = 1.to_s
        ENV["GITHUB_TOKEN"] = "123"
      end
    end
  end
end
