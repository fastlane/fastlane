# encoding: utf-8

# from https://stackoverflow.com/a/9857493/445598
# because of
# `incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string) (Encoding::CompatibilityError)`

require 'tempfile'
require 'xcodeproj'

require 'fastlane_core/core_ext/cfpropertylist'
require_relative '../module'
require_relative '../error_handler'
require_relative 'build_command_generator'

module Gym
  # Responsible for building the fully working xcodebuild command
  class PackageCommandGeneratorXcode7
    class << self
      DEFAULT_EXPORT_METHOD = 'app-store'

      def generate
        parts = ["/usr/bin/xcrun #{wrap_xcodebuild.shellescape} -exportArchive"]
        parts += options
        parts += pipe

        File.write(config_path, config_content) # overwrite everytime. Could be optimized

        parts
      end

      def options
        config = Gym.config

        options = []
        options << "-exportOptionsPlist '#{config_path}'"
        options <<
          "-archivePath #{BuildCommandGenerator.archive_path.shellescape}"
        options << "-exportPath '#{temporary_output_path}'"
        options << "-toolchain '#{config[:toolchain]}'" if config[:toolchain]
        options << config[:export_xcargs] if config[:export_xcargs]
        options << config[:xcargs] if config[:xcargs]

        options
      end

      def pipe
        ['']
      end

      # We export the ipa into this directory, as we can't specify the ipa file directly
      def temporary_output_path
        Gym.cache[:temporary_output_path] ||= Dir.mktmpdir('gym_output')
      end

      # Wrap xcodebuild to work-around ipatool dependency to system ruby
      def wrap_xcodebuild
        require 'fileutils'
        @wrapped_xcodebuild_path ||=
          File.join(Gym::ROOT, 'lib/assets/wrap_xcodebuild/xcbuild-safe.sh')
      end

      def ipa_path
        unless Gym.cache[:ipa_path]
          path = Dir[File.join(temporary_output_path, '*.ipa')].last
          # We need to process generic IPA
          if path
            # Try to find IPA file in the output directory, used when app thinning was not set
            Gym.cache[:ipa_path] =
              File.join(
                temporary_output_path,
                "#{Gym.config[:output_name]}.ipa"
              )
            unless File.expand_path(path).casecmp(
                   File.expand_path(Gym.cache[:ipa_path]).downcase
                 )
                   .zero?
              FileUtils.mv(path, Gym.cache[:ipa_path])
            end
          elsif Dir.exist?(apps_path)
            # Try to find "generic" IPA file inside "Apps" folder, used when app thinning was set
            files = Dir[File.join(apps_path, '*.ipa')]
            # Generic IPA file doesn't have suffix so its name is the shortest
            path = files.min_by(&:length)
            Gym.cache[:ipa_path] =
              File.join(
                temporary_output_path,
                "#{Gym.config[:output_name]}.ipa"
              )
            unless File.expand_path(path).casecmp(
                   File.expand_path(Gym.cache[:ipa_path]).downcase
                 )
                   .zero?
              FileUtils.cp(path, Gym.cache[:ipa_path])
            end
          else
            ErrorHandler.handle_empty_archive unless path
          end
        end
        Gym.cache[:ipa_path]
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + '/**/*.app.dSYM'].last
      end

      # The path the config file we use to sign our app
      def config_path
        Gym.cache[:config_path] ||= "#{Tempfile.new('gym_config').path}.plist"
        return Gym.cache[:config_path]
      end

      # The path to the manifest plist file
      def manifest_path
        Gym.cache[:manifest_path] ||=
          File.join(temporary_output_path, 'manifest.plist')
      end

      # The path to the app-thinning plist file
      def app_thinning_path
        Gym.cache[:app_thinning] ||=
          File.join(temporary_output_path, 'app-thinning.plist')
      end

      # The path to the App Thinning Size Report file
      def app_thinning_size_report_path
        Gym.cache[:app_thinning_size_report] ||=
          File.join(temporary_output_path, 'App Thinning Size Report.txt')
      end

      # The path to the Apps folder
      def apps_path
        Gym.cache[:apps_path] ||= File.join(temporary_output_path, 'Apps')
      end

      private

      def normalize_export_options(hash)
        # Normalize some values
        if hash[:onDemandResourcesAssetPacksBaseURL]
          hash[:onDemandResourcesAssetPacksBaseURL] =
            URI.escape(hash[:onDemandResourcesAssetPacksBaseURL])
        end
        if hash[:manifest]
          if hash[:manifest][:appURL]
            hash[:manifest][:appURL] = URI.escape(hash[:manifest][:appURL])
          end
          if hash[:manifest][:displayImageURL]
            hash[:manifest][:displayImageURL] =
              URI.escape(hash[:manifest][:displayImageURL])
          end
          if hash[:manifest][:fullSizeImageURL]
            hash[:manifest][:fullSizeImageURL] =
              URI.escape(hash[:manifest][:fullSizeImageURL])
          end
          if hash[:manifest][:assetPackManifestURL]
            hash[:manifest][:assetPackManifestURL] =
              URI.escape(hash[:manifest][:assetPackManifestURL])
          end
        end
        hash
      end

      def read_export_options
        # Reads export options
        if Gym.config[:export_options]
          hash = normalize_export_options(Gym.config[:export_options])

          # Saves configuration for later use
          Gym.config[:export_method] ||= hash[:method] || DEFAULT_EXPORT_METHOD
          if Gym.config[:include_symbols].nil?
            Gym.config[:include_symbols] = hash[:uploadSymbols]
          end
          if Gym.config[:include_bitcode].nil?
            Gym.config[:include_bitcode] = hash[:uploadBitcode]
          end
          Gym.config[:export_team_id] ||= hash[:teamID]
        else
          hash = {}
          # Sets default values
          Gym.config[:export_method] ||= DEFAULT_EXPORT_METHOD
          if Gym.config[:include_symbols].nil?
            Gym.config[:include_symbols] = true
          end
          if Gym.config[:include_bitcode].nil?
            Gym.config[:include_bitcode] = false
          end
        end
        hash
      end

      def config_content
        hash = read_export_options

        # Overrides export options if needed
        hash[:method] = Gym.config[:export_method]
        if Gym.config[:export_method] == 'app-store'
          unless Gym.config[:include_symbols].nil?
            hash[:uploadSymbols] = (Gym.config[:include_symbols] ? true : false)
          end
          unless Gym.config[:include_bitcode].nil?
            hash[:uploadBitcode] = (Gym.config[:include_bitcode] ? true : false)
          end
        end

        # xcodebuild will not use provisioning profiles
        # if we don't specify signingStyle as manual
        if Helper.xcode_at_least?('9.0') && hash[:provisioningProfiles]
          hash[:signingStyle] = 'manual'
        end

        if Gym.config[:export_team_id]
          hash[:teamID] = Gym.config[:export_team_id]
        end

        UI.important('Generated plist file with the following values:')
        UI.command_output('-----------------------------------------')
        UI.command_output(JSON.pretty_generate(hash))
        UI.command_output('-----------------------------------------')
        if FastlaneCore::Globals.verbose?
          UI.message('This results in the following plist file:')
          UI.command_output('-----------------------------------------')
          UI.command_output(hash.to_plist)
          UI.command_output('-----------------------------------------')
        end

        hash.to_plist
      end

      def signing_style
        projects = Gym.project.project_paths
        project = projects.first
        xcodeproj = Xcodeproj::Project.open(project)
        xcodeproj.root_object.attributes['TargetAttributes']
          .each do |target, sett|
          return sett['ProvisioningStyle'].to_s.downcase
        end
      rescue => e
        UI.verbose(e.to_s)
        UI.error('Unable to read provisioning style from .pbxproj file.')
        return 'automatic'
      end
    end
  end
end
