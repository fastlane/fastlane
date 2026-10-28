require 'rubocop'

module Fastlane
  module Internal
    # The plugin template's RuboCop config: fastlane's own, minus what only exists in this repository.
    module PluginTemplateRubocopConfig
      ROOT = File.expand_path('..', __dir__)

      # `config` is fastlane's .rubocop.yml as a Hash. Its `require:` entries under ./internal/ are dropped,
      # with the configuration of every cop they define.
      def self.from(config)
        internal, external = config.fetch('require', []).partition { |path| path.start_with?('./internal/') }
        internal_files = internal.map { |path| File.expand_path(path, ROOT) }
        internal_files.each { |file| require(file) }
        internal_cops = RuboCop::Cop::Registry.global.cops.select do |cop|
          internal_files.include?(Object.const_source_location(cop.name)&.first)
        end

        config = config.reject { |key, _| key == 'inherit_from' || internal_cops.any? { |cop| cop.cop_name == key } }
        config.merge('require' => external)
      end
    end
  end
end
