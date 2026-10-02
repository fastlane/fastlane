require 'rubocop'

module RuboCop
  module Cop
    module Fastlane
      # Flags values interpolated into a shell command string without escaping.
      #
      #   sh("git tag #{tag}")              # bad
      #   sh("git tag #{tag.shellescape}")  # good
      #   sh("git", "tag", tag)             # good: no shell
      #
      # A local variable is followed to its assignments in the same method:
      # it is accepted when every assignment is escaped, and a command string
      # built in a variable is checked where it is built.
      class UnescapedShellInterpolation < Base
        MSG = 'Escape `%<source>s` (`.shellescape`), or pass the command as separate arguments.'.freeze

        COMMAND_METHODS = %i[sh backticks system exec spawn capture2 capture2e capture3 popen popen2 popen2e popen3].to_set.freeze
        SAFE_METHODS = %i[shellescape shelljoin to_i to_f].to_set.freeze

        def on_send(node)
          return unless COMMAND_METHODS.include?(node.method_name)

          command = node.first_argument
          command = command.children.first if command&.type == :splat
          check_command(command, node) if command
        end
        alias on_csend on_send

        def on_xstr(node)
          check_string(node, node)
        end

        private

        # The command argument: an interpolated string, or a local variable holding one.
        def check_command(command, at)
          if command.dstr_type?
            check_string(command, at)
          elsif command.lvar_type?
            assignments(command, at).each { |value| check_string(value, at) if value.dstr_type? }
          end
        end

        def check_string(string, at)
          string.each_child_node(:begin) do |interpolation|
            value = interpolation.children.last
            next if value.nil? || safe?(value, at)

            add_offense(interpolation, message: format(MSG, source: value.source))
          end
        end

        def safe?(value, at, seen = Set.new)
          return true if value.int_type? || value.float_type? || value.str_type? || value.sym_type?
          return true if value.send_type? && SAFE_METHODS.include?(value.method_name)
          return true if value.send_type? && %i[escape shellescape].include?(value.method_name) && value.receiver&.const_name == 'Shellwords'
          return true if value.send_type? && value.method_name == :join && escaped_each?(value.receiver)
          return false unless value.lvar_type?
          return false if seen.include?(value.children.first)

          values = assignments(value, at)
          !values.empty? && values.all? { |assigned| safe?(assigned, at, seen | [value.children.first]) }
        end

        # `list.map(&:shellescape)` or `list.map { |x| x.shellescape }`
        def escaped_each?(node)
          return false unless node
          if node.send_type? && node.method_name == :map
            node.first_argument&.block_pass_type? && node.first_argument.children.first&.value == :shellescape
          elsif node.block_type? && node.method_name == :map
            body = node.body
            body&.send_type? && body.method_name == :shellescape
          else
            false
          end
        end

        # The values assigned to the local variable in the method around `at` (blocks share its variables).
        # Empty when it is a method argument or assigned in a way this does not follow.
        def assignments(lvar, at)
          name = lvar.children.first
          scope = at.each_ancestor(:def, :defs).first || at.each_ancestor.to_a.last
          return [] unless scope

          values = scope.each_descendant(:lvasgn, :op_asgn, :or_asgn, :and_asgn).filter_map do |asgn|
            target = asgn.lvasgn_type? ? asgn : asgn.children.first
            next unless target.lvasgn_type? && target.children.first == name

            asgn.lvasgn_type? ? asgn.children.last : :unknown # +=, ||= and &&= are not followed
          end
          values.include?(:unknown) ? [] : values
        end
      end
    end
  end
end
