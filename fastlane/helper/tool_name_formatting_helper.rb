module Fastlane
  module Helper
    class ToolNameFormattingHelper
      attr_accessor :path, :is_documenting_invalid_examples

      # @param [String] path Path to the file to be checked for tool formatting
      # @param [Bool] is_documenting_invalid_examples
      #        Ignore checks if line starts with "^\s*- ❌" (i.e. if it's a line that's already been marked as incorrect)
      #        Typically used for files like `CONTRIBUTING.md`` (i.e. if it's the branding guidelines section)
      #
      def initialize(path:, is_documenting_invalid_examples: false)
        @path = path
        @is_documenting_invalid_examples = is_documenting_invalid_examples
      end

      def find_tool_name_formatting_errors
        errors = []
        File.readlines(path, mode: 'rb:BOM|UTF-8').each_with_index do |line, index|
          line_number = index + 1
          line.chomp! # Remove \n at end of line, to avoid including it in the error messages
          Fastlane::TOOLS.each do |tool|
            next if is_documenting_invalid_examples && line =~ /^\s*- ❌/

            errors << "Use _#{tool}_ instead of `#{tool}` to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("`#{tool}`")
            errors << "Use _#{tool}_ instead of `_#{tool}_` to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("`_#{tool}_`")
            errors << "Use [_#{tool}_] instead of [#{tool}] to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("[#{tool}]")
            errors << "Use _#{tool}_ instead of **#{tool}** to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("**#{tool}**")
            errors << "Use <em>#{tool}<em> instead of <code>#{tool}</code> to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("<code>#{tool}</code>")
            errors << "Use <em>#{tool}<em> or _#{tool}_ instead of <ins>#{tool}</ins> to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("<ins>#{tool}</ins>")

            " #{line} ".scan(/([A-Z_]*)([_ `"])(#{Regexp.escape(tool.to_s)})\2([A-Z_]*)/i) do |prefix, delimiter, tool_name, suffix|
              is_lowercase = tool_name == tool.to_s.downcase
              looks_like_an_env_var = (tool_name == tool_name.upcase) && delimiter == '_' && (!prefix.empty? || !suffix.empty?)
              looks_like_ruby_module = line == "module #{tool_name}"
              is_valid_case = is_lowercase || looks_like_an_env_var || looks_like_ruby_module
              errors << "fastlane tools have to be formatted in lowercase: #{tool} in '#{path}:#{line_number}': #{line}" unless is_valid_case
            end
          end
        end
        errors
      end
    end
  end
end
