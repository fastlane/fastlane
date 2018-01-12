require 'rubocop'

module RuboCop
  module Require
    class PreferRelative < RuboCop::Cop::Cop
      MSG = '`%<tool>s` required directly, prefer `require_relative %<require_statement>s`'.freeze

      def_node_matcher :extract_required_file, <<-PATTERN
        (send nil :require (str $_))
      PATTERN

      def tool_dirs
        return @tool_dirs if @tool_dirs

        base_fastlane_dir = File.expand_path("../", File.dirname(__FILE__))
        tool_dirs = Dir["#{base_fastlane_dir}/**/lib/*.rb"]
        @tool_dirs = tool_dirs.map { |t| File.basename(t, ".rb") }
      end

      attr_writer :corrected_statements
      def corrected_statements
        @corrected_statements ||= {}
      end

      def on_send(node)
        return unless (required = extract_required_file(node))
        parts = required.split("/")
        head = parts.shift
        tail = parts.join("/")
        return unless self.tool_dirs.include?(head)

        self.corrected_statements[node] = "internal('#{required}')"

        message = format(MSG, tool: head, require_statement: require_statement)
        add_offense(node, :expression, message)
      end

      def autocorrect(node)
        lambda do |corrector|
          corrector.replace(node.loc.expression, "require_relative #{self.corrected_statements[node]}")
        end
      end
    end
  end
end
