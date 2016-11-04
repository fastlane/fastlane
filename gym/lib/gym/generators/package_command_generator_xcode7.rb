# encoding: utf-8
# from http://stackoverflow.com/a/9857493/445598
# because of
# `incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string) (Encoding::CompatibilityError)`

require 'tempfile'

module Gym
  # Responsible for building the fully working xcodebuild command
  class PackageCommandGeneratorXcode7
    class << self
      def generate
        print_legacy_information

        parts = ["/usr/bin/xcrun #{XcodebuildFixes.wrap_xcodebuild.shellescape} -exportArchive"]
        parts += options
        parts += pipe

        File.write(config_path, config_content) # overwrite everytime. Could be optimized

        parts
      end

      def options
        config = Gym.config

        options = []
        options << "-exportOptionsPlist '#{config_path}'"
        options << "-archivePath #{BuildCommandGenerator.archive_path.shellescape}"
        options << "-exportPath '#{temporary_output_path}'"
        options << "-toolchain '#{config[:toolchain]}'" if config[:toolchain]
        options << config[:export_xcargs] if config[:export_xcargs]

        options
      end

      def pipe
        [""]
      end

      # We export the ipa into this directory, as we can't specify the ipa file directly
      def temporary_output_path
        Gym.cache[:temporary_output_path] ||= Dir.mktmpdir('gym_output')
      end

      def ipa_path
        unless Gym.cache[:ipa_path]
          path = Dir[File.join(temporary_output_path, "*.ipa")].last
          # We need to process generic IPA
          if path
            # Try to find IPA file in the output directory, used when app thinning was not set
            Gym.cache[:ipa_path] = File.join(temporary_output_path, "#{Gym.config[:output_name]}.ipa")
            FileUtils.mv(path, Gym.cache[:ipa_path]) unless File.expand_path(path).casecmp(File.expand_path(Gym.cache[:ipa_path]).downcase).zero?
          elsif Dir.exist?(apps_path)
            # Try to find "generic" IPA file inside "Apps" folder, used when app thinning was set
            files = Dir[File.join(apps_path, "*.ipa")]
            # Generic IPA file doesn't have suffix so its name is the shortest
            path = files.min_by(&:length)
            Gym.cache[:ipa_path] = File.join(temporary_output_path, "#{Gym.config[:output_name]}.ipa")
            FileUtils.cp(path, Gym.cache[:ipa_path]) unless File.expand_path(path).casecmp(File.expand_path(Gym.cache[:ipa_path]).downcase).zero?
          else
            ErrorHandler.handle_empty_archive unless path
          end
        end
        Gym.cache[:ipa_path]
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.app.dSYM"].last
      end

      # The path the config file we use to sign our app
      def config_path
        Gym.cache[:config_path] ||= "#{Tempfile.new('gym_config').path}.plist"
        return Gym.cache[:config_path]
      end

      # The path to the manifest plist file
      def manifest_path
        Gym.cache[:manifest_path] ||= File.join(temporary_output_path, "manifest.plist")
      end

      # The path to the app-thinning plist file
      def app_thinning_path
        Gym.cache[:app_thinning] ||= File.join(temporary_output_path, "app-thinning.plist")
      end

      # The path to the App Thinning Size Report file
      def app_thinning_size_report_path
        Gym.cache[:app_thinning_size_report] ||= File.join(temporary_output_path, "App Thinning Size Report.txt")
      end

      # The path to the Apps folder
      def apps_path
        Gym.cache[:apps_path] ||= File.join(temporary_output_path, "Apps")
      end

      private

      def normalize_export_options(hash)
        # Normalize some values
        hash[:onDemandResourcesAssetPacksBaseURL] = URI.escape(hash[:onDemandResourcesAssetPacksBaseURL]) if hash[:onDemandResourcesAssetPacksBaseURL]
        if hash[:manifest]
          hash[:manifest][:appURL] = URI.escape(hash[:manifest][:appURL]) if hash[:manifest][:appURL]
          hash[:manifest][:displayImageURL] = URI.escape(hash[:manifest][:displayImageURL]) if hash[:manifest][:displayImageURL]
          hash[:manifest][:fullSizeImageURL] = URI.escape(hash[:manifest][:fullSizeImageURL]) if hash[:manifest][:fullSizeImageURL]
          hash[:manifest][:assetPackManifestURL] = URI.escape(hash[:manifest][:assetPackManifestURL]) if hash[:manifest][:assetPackManifestURL]
        end
        hash
      end

      def keys_to_symbols(hash)
        # Convert keys to symbols
        hash = hash.each_with_object({}) do |(k, v), memo|
          memo[k.to_sym] = v
          memo
        end
        hash
      end

      def read_export_options
        # Reads export options
        if Gym.config[:export_options]
          if Gym.config[:export_options].kind_of?(Hash)
            # Reads options from hash
            hash = normalize_export_options(Gym.config[:export_options])
          else
            # Reads options from file
            hash = Plist.parse_xml(Gym.config[:export_options])
            # Convert keys to symbols
            hash = keys_to_symbols(hash)
          end

          # Saves configuration for later use
          Gym.config[:export_method] ||= hash[:method]
          Gym.config[:include_symbols] = hash[:uploadSymbols] if Gym.config[:include_symbols].nil?
          Gym.config[:include_bitcode] = hash[:uploadBitcode] if Gym.config[:include_bitcode].nil?
          Gym.config[:export_team_id] ||= hash[:teamID]
        else
          hash = {}
          # Sets default values
          Gym.config[:export_method] ||= "app-store"
          Gym.config[:include_symbols] = true if Gym.config[:include_symbols].nil?
          Gym.config[:include_bitcode] = false if Gym.config[:include_bitcode].nil?
        end
        hash
      end

      def config_content
        require 'plist'

        hash = read_export_options

        # Overrides export options if needed
        hash[:method] = Gym.config[:export_method]
        if Gym.config[:export_method] == 'app-store'
          hash[:uploadSymbols] = (Gym.config[:include_symbols] ? true : false) unless Gym.config[:include_symbols].nil?
          hash[:uploadBitcode] = (Gym.config[:include_bitcode] ? true : false) unless Gym.config[:include_bitcode].nil?
        end
        hash[:teamID] = Gym.config[:export_team_id] if Gym.config[:export_team_id]

        UI.important("Generated plist file with the following values:")
        UI.command_output("-----------------------------------------")
        UI.command_output(JSON.pretty_generate(hash))
        UI.command_output("-----------------------------------------")
        if $verbose
          UI.message("This results in the following plist file:")
          UI.command_output("-----------------------------------------")
          UI.command_output(to_plist(hash))
          UI.command_output("-----------------------------------------")
        end

        to_plist(hash)
      end

      # Avoids a Hash#to_plist conflict between CFPropertyList and plist gems
      def to_plist(hash)
        Plist::Emit.dump(hash, true)
      end

      def print_legacy_information
        return if Gym.config[:provisioning_profile_path].to_s.length == 0

        UI.error "You're using Xcode 7 or above, the `provisioning_profile_path` value will be ignored"
        UI.error "Please follow the Code Signing Guide: https://codesigning.guide (for match) or https://docs.fastlane.tools/codesigning/GettingStarted/"
        UI.error "This is just a warning, gym will continue running just as expected, but the parameter will be ignored"
      end
    end
  end
end
