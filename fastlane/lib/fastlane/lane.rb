module Fastlane
  # Represents a lane
  class Lane
    attr_accessor :platform

    attr_accessor :name

    # @return [Array] An array containing the description of this lane
    #   Each item of the array is one line
    attr_accessor :description

    attr_accessor :block

    # @return [Boolean] Is that a private lane that can't be called from the CLI?
    attr_accessor :is_private

    def initialize(platform: nil, name: nil, description: nil, block: nil, is_private: false)
      UI.user_error!("description must be an array") unless description.kind_of?(Array)
      UI.user_error!("lane name must not contain any spaces") if name.to_s.include?(" ")
      UI.user_error!("lane name must start with :") unless name.kind_of?(Symbol)

      self.class.verify_lane_name(name)

      self.platform = platform
      self.name = name
      self.description = description
      # We want to support _both_ lanes expecting a `Hash` (like `lane :foo do |options|`), and lanes expecting
      # keyword parameters (like `lane :foo do |param1:, param2:, param3: 'default value'|`)
      block_expects_keywords = !block.nil? && block.parameters.any? { |type, _| [:key, :keyreq].include?(type) }
      # Conversion of the `Hash` parameters (passed by `Lane#call`) into keywords has to be explicit in Ruby 3
      # https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/
      self.block = block_expects_keywords ? proc { |options| block.call(**options) } : block
      self.is_private = is_private
    end

    # Execute this lane
    #
    # @param [Hash] parameters The Hash of parameters to pass to the lane
    #
    def call(parameters)
      block.call(parameters || {})
    end

    # @return [String] The lane + name of the lane. If there is no platform, it will only be the lane name
    def pretty_name
      [platform, name].reject(&:nil?).join(' ')
    end

    class << self
      # Makes sure the lane name is valid
      def verify_lane_name(name)
        if self.deny_list.include?(name.to_s)
          UI.error("Lane name '#{name}' is invalid! Invalid names are #{self.deny_list.join(', ')}.")
          UI.user_error!("Lane name '#{name}' is invalid")
        end

        if self.gray_list.include?(name.to_sym)
          UI.error("------------------------------------------------")
          UI.error("Lane name '#{name}' should not be used because it is the name of a fastlane tool")
          UI.error("It is recommended to not use '#{name}' as the name of your lane")
          UI.error("------------------------------------------------")
          # We still allow it, because we're nice
          # Otherwise we might break existing setups
          return
        end

        self.ensure_name_not_conflicts(name.to_s)
      end

      def deny_list
        %w(
          run
          init
          new_action
          lanes
          list
          docs
          action
          actions
          enable_auto_complete
          new_plugin
          add_plugin
          install_plugins
          update_plugins
          search_plugins
          help
          env
          update_fastlane
        )
      end

      def gray_list
        Fastlane::TOOLS
      end

      def ensure_name_not_conflicts(name)
        # First, check if there is a predefined method in the actions folder
        return unless Actions.action_class_ref(name)
        UI.error("------------------------------------------------")
        UI.error("Name of the lane '#{name}' is already taken by the action named '#{name}'")
        UI.error("------------------------------------------------")
      end
    end
  end
end
