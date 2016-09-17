# encoding: utf-8
# from http://stackoverflow.com/a/9857493/445598
# because of
# `incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string) (Encoding::CompatibilityError)`

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

      def manifest_path
        generator.manifest_path
      end

      def app_thinning_path
        generator.app_thinning_path
      end

      def app_thinning_size_report_path
        generator.app_thinning_size_report_path
      end

      def apps_path
        generator.apps_path
      end

      # The generator we need to use for the currently used Xcode version
      def generator
        if Gym.config[:use_legacy_build_api]
          PackageCommandGeneratorLegacy
        else
          PackageCommandGeneratorXcode7
        end
      end
    end
  end
end
