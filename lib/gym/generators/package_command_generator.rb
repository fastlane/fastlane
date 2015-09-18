require 'shellwords'

# The concrete implementations
require 'gym/generators/package_command_generator_legacy'
require 'gym/generators/package_command_generator_xcode7'

module Gym
  class PackageCommandGenerator
    class << self
      def generate
        generator.generate
      end

      def appfile_path
        generator.appfile_path
      end

      # The path in which the ipa file will be available after executing the command
      def ipa_path
        generator.ipa_path
      end

      def dsym_path
        generator.dsym_path
      end

      private

      # The generator we need to use for the currently used Xcode version
      def generator
        Xcode.pre_7? ? PackageCommandGeneratorLegacy : PackageCommandGeneratorXcode7
      end
    end
  end
end
