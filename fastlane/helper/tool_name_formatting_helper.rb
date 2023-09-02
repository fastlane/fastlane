module Fastlane
  module Helper
    class ToolNameFormattingHelper
      attr_accessor :content, :path

      def initialize(content:, path:)
        @content = content
        @path = path
      end

      def find_tool_name_formatting_errors
        errors = []
        Fastlane::TOOLS.each do |tool|
          lines = content.split("\n")
          lines.each_with_index do |line, index|
            line_number = index + 1
            # Ignore checks if line starts with "^\s*- ❌" (i.e. if it's a line that's already been marked as incorrect)
            # and if the file is CONTRIBUTING.md (i.e. if it's the branding guidelines section)
            next if line =~ /^\s*- ❌/ && path == "CONTRIBUTING.md"
            errors << "Use _#{tool}_ instead of `#{tool}` to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("`#{tool}`")
            errors << "Use _#{tool}_ instead of `_#{tool}_` to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("`_#{tool}_`")
            errors << "Use [_#{tool}_] instead of [#{tool}] to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("[#{tool}]")
            errors << "Use _#{tool}_ instead of **#{tool}** to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("**#{tool}**")
            errors << "Use <em>#{tool}<em> instead of <code>#{tool}</code> to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("<code>#{tool}</code>")
            errors << "Use <em>#{tool}<em> or _#{tool}_ instead of <ins>#{tool}</ins> to mention a tool in the docs in '#{path}:#{line_number}': #{line}" if line.include?("<ins>#{tool}</ins>")

            line.scan(/([A-Z_]*)([_ `"])(#{Regexp.escape(tool.to_s)})\2([A-Z_]*)/i) do |prefix, delimiter, tool_name, suffix|
              wrong_case = tool_name != tool.to_s.downcase
              looks_like_an_env_var = (tool_name == tool_name.upcase) && delimiter == '_' && (!prefix.empty? || !suffix.empty?)
              errors << "fastlane tools have to be formatted in lowercase: #{tool} in '#{path}:#{line_number}': #{line}" if !looks_like_an_env_var && wrong_case
            end
          end
        end
        errors
      end
    end
  end
end
