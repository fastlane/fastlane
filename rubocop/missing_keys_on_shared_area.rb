require 'rubocop'

module RuboCop
  module Lint
    class MissingKeysOnSharedArea < RuboCop::Cop::Cop
      MISSING_KEYS_MSG = "There are missing keys on the shared area. Check constants provided in 'SharedValues' or keys provided in 'output' method in the action's code".freeze
      MISSING_OUTPUT_METHOD_MSG = "There are declared keys on the shared area 'SharedValues', but 'output' method has not been found".freeze

      attr_writer :shared_values_constants
      def shared_values_constants
        @shared_values_constants ||= []
      end

      def on_module(node)
        name, body = *node
        return unless name.source == 'SharedValues'
        return if body.nil?

        body.children.compact.each do |child|
          next unless child.respond_to?('casgn_type?')

          if child.or_asgn_type? # Multiple constant values
            lhs, _value = *child
            _scope, const_name = *lhs
          else # Single constant value
            _scope, const_name, _value = *child
            self.shared_values_constants << const_name.to_s if const_name
          end

          _scope, const_name, _value = *body unless const_name
          self.shared_values_constants << const_name.to_s if const_name
        end
      end

      def on_defs(node)
        return if self.shared_values_constants.empty?

        _definee, method_name, _args, body = *node
        return unless method_name.to_s == 'output'

        if body.nil?
          add_offense(node, :expression, MISSING_KEYS_MSG)
          return
        end

        unless body.array_type?
          add_offense(node, :expression, MISSING_KEYS_MSG)
          return
        end

        children = body.children.select(&:array_type?)
        keys = children.map { |child| child.children.first.source.to_s.gsub(/\s|"|'/, '') }
        add_offense(node, :expression, MISSING_KEYS_MSG) unless self.shared_values_constants.to_set == keys.to_set
      end

      def on_class(node)
        name, _superclass, body = *node
        add_offense(node, :expression, MISSING_OUTPUT_METHOD_MSG) if body.nil? && self.shared_values_constants.any?
        return if body.nil?

        check(name, body)
      end

      def check(_name, node)
        return if node.nil?
        return if self.shared_values_constants.empty?

        if node.defs_type? # A single method
          add_offense(node, :expression, MISSING_OUTPUT_METHOD_MSG) unless contains_output?(node)
        elsif node.begin_type? # Multiple methods
          outputs = node.each_child_node(:defs).select { |n| contains_output?(n) }
          add_offense(node, :expression, MISSING_OUTPUT_METHOD_MSG) if outputs.empty?
        end
      end

      def contains_output?(node)
        _definee, method_name, _args, _body = *node
        method_name.to_s == 'output'
      end
    end
  end
end
