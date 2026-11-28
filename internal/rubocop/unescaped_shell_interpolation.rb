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
      # Separate arguments cannot express a pipe, a redirect or `&&`; for those the
      # message points at the Open3 equivalent.
      #
      # A local variable is followed to its assignments in the same method, `+=` and `<<` included:
      # it is accepted when every assignment is escaped, and a command string
      # built in a variable is checked where it is built.
      # A command joined from a list checks each element of the list.
      # Not followed: pieces returned by other methods, as in gym's and scan's command generators, which build
      # arrays joined elsewhere; such pieces are only reported, if at all, where the array is joined.
      class UnescapedShellInterpolation < Base
        MSG = 'Escape `%<source>s` (`.shellescape`), or pass the command as separate arguments.'.freeze
        MSG_SHELL_SYNTAX = 'Escape `%<source>s` (`.shellescape`), or run it without a shell: %<hints>s.'.freeze
        # Matched against the command's literal text, quoted parts removed.
        SHELL_SYNTAX_HINTS = {
          /(?<!\|)\|(?!\|)/ => 'for the pipe, `Open3.pipeline_r`, or filter the output in Ruby',
          /[<>]/ => 'for the redirect, Open3 with `out:`/`err:` (`err: File::NULL`), or `Open3.capture2e` for `2>&1`',
          /&&|\|\||;/ => 'for `&&`/`;`, one call per command (`chdir:` replaces `cd … &&`)'
        }.freeze

        COMMAND_METHODS = %i[sh sh_control_output sh_no_action backticks system exec spawn capture2 capture2e capture3 popen popen2 popen2e popen3].to_set.freeze
        SAFE_METHODS = %i[shellescape shelljoin to_i to_f].to_set.freeze

        def on_send(node)
          command = command_argument(node)
          command = command.children.first if command&.type == :splat
          check_command(command, node) if command
        end
        alias on_csend on_send

        def on_xstr(node)
          command = sole_variable(node)
          if command && !assignments(command, node).empty?
            check_command(command, node)
          else
            check_string(node, node)
          end
        end

        private

        # The first argument of a command method, or the `command:` of `CommandExecutor.execute`.
        def command_argument(node)
          return node.first_argument if COMMAND_METHODS.include?(node.method_name)
          return unless node.method_name == :execute && node.receiver&.const_type? && node.receiver.short_name == :CommandExecutor

          options = node.last_argument
          return unless options&.hash_type?

          options.pairs.find { |pair| pair.key.sym_type? && pair.key.value == :command }&.value
        end

        # `` `#{command}` ``: the variable, followed like `sh(command)`.
        def sole_variable(string)
          return unless string.children.size == 1 && string.children.first.begin_type?

          value = string.children.first.children
          value.first if value.size == 1 && value.first.lvar_type?
        end

        # The command argument: an interpolated string, a joined list, or a local variable holding one.
        def check_command(command, at)
          if command.dstr_type?
            check_string(command, at)
          elsif join?(command)
            check_join(command, at)
          elsif command.lvar_type?
            assignments(command, at).each { |value| check_command(value, at) unless value.lvar_type? }
          end
        end

        def check_string(string, at, hints = shell_syntax_hints(literal_text(string.children)))
          interpolations(string).each do |interpolation|
            value = interpolation.children.last
            next if value.nil? || safe?(value, at)

            report(interpolation, value, hints)
          end
        end

        # `[a, b].join(' ')`, or a list variable: each element is checked, the list itself when its elements are unknown.
        def check_join(join, at)
          return if escaped_each?(join.receiver)

          elements = list_elements(join.receiver, at)
          return report(join, join, []) unless elements

          hints = shell_syntax_hints(literal_text(elements, ' '))
          elements.each { |element| check_element(element, at, hints) }
        end

        def check_element(element, at, hints)
          if element.dstr_type?
            check_string(element, at, hints)
          elsif element.if_type? && element.if_branch && element.else_branch
            [element.if_branch, element.else_branch].each { |branch| check_element(branch, at, hints) }
          elsif !safe?(element, at)
            report(element, element, hints)
          end
        end

        def report(node, value, hints)
          message = hints.empty? ? format(MSG, source: value.source) : format(MSG_SHELL_SYNTAX, source: value.source, hints: hints.join('; '))
          add_offense(node, message: message)
        end

        # A string continued with `\` is a dstr of dstrs.
        def interpolations(string)
          string.each_child_node(:begin, :dstr).flat_map { |part| part.dstr_type? ? interpolations(part) : [part] }
        end

        def shell_syntax_hints(text)
          text = text.gsub(/'[^']*'|"[^"]*"/, '')
          SHELL_SYNTAX_HINTS.filter_map { |pattern, hint| hint if text.match?(pattern) }
        end

        # The literal parts of a string or a list, an interpolation or a value counting as one character.
        def literal_text(parts, separator = '')
          parts.map do |part|
            if part.str_type? then part.value
            elsif part.dstr_type? then literal_text(part.children)
            else 'x'
            end
          end.join(separator)
        end

        def join?(node)
          node.send_type? && node.method_name == :join
        end

        # The elements of a list literal, or of a variable only assigned list literals; nil when unknown.
        def list_elements(list, at)
          return list_literal(list) unless list&.lvar_type?

          elements = assignments(list, at).map { |value| value.parent.send_type? ? [value] : list_literal(value) } # `<<` adds one element
          elements.reduce(:+) unless elements.empty? || elements.include?(nil)
        end

        # `[a, b]` or `[a, b].compact`
        def list_literal(node)
          node = node.receiver if node&.send_type? && node.method_name == :compact
          node.children if node&.array_type?
        end

        def safe?(value, at, seen = Set.new)
          return true if value.int_type? || value.float_type? || value.str_type? || value.sym_type? || value.nil_type?
          return true if value.send_type? && SAFE_METHODS.include?(value.method_name)
          return true if value.send_type? && %i[escape shellescape].include?(value.method_name) && value.receiver&.const_name == 'Shellwords'
          return safe_join?(value, at, seen) if join?(value)
          return interpolations(value).all? { |part| part.children.last.nil? || safe?(part.children.last, at, seen) } if value.dstr_type?
          return [value.if_branch, value.else_branch].all? { |branch| branch && safe?(branch, at, seen) } if value.if_type?
          return false unless value.lvar_type?
          return false if seen.include?(value.children.first)

          values = assignments(value, at)
          !values.empty? && values.all? { |assigned| safe?(assigned, at, seen | [value.children.first]) }
        end

        def safe_join?(join, at, seen)
          escaped_each?(join.receiver) || list_elements(join.receiver, at)&.all? { |element| safe?(element, at, seen) } || false
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

        # The values assigned to the local variable in the method around `at` (blocks share its variables),
        # with what `+=` and `<<` add to it.
        # Empty when it is a method argument or assigned in a way this does not follow.
        def assignments(lvar, at)
          name = lvar.children.first
          scope = at.each_ancestor(:def, :defs).first || at.each_ancestor.to_a.last
          return [] unless scope

          values = scope.each_descendant(:lvasgn, :op_asgn, :or_asgn, :and_asgn, :send).filter_map do |node|
            if node.send_type?
              node.first_argument if node.method_name == :<< && node.receiver&.lvar_type? && node.receiver.children.first == name
            elsif !(node.lvasgn_type? && %i[op_asgn or_asgn and_asgn].include?(node.parent&.type)) # read with its +=
              target = node.lvasgn_type? ? node : node.children.first
              next unless target.lvasgn_type? && target.children.first == name

              if node.lvasgn_type?
                node.children.size == 2 ? node.children.last : :unknown # `a, b = list` is not followed
              elsif node.op_asgn_type? && node.children[1] == :+
                node.children.last
              else
                :unknown # ||=, &&= and other operators are not followed
              end
            end
          end
          return [] if values.include?(:unknown) || values.none? { |value| value.parent.lvasgn_type? }

          values
        end
      end
    end
  end
end
