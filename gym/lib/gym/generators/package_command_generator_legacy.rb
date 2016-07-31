# encoding: utf-8
# from http://stackoverflow.com/a/9857493/445598
# because of
# `incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string) (Encoding::CompatibilityError)`

module Gym
  # Responsible for building the fully working xcodebuild command on Xcode < 7
  #
  # Because of a known bug in PackageApplication Perl script used by Xcode the packaging process is performed with
  # a patched version of the script.
  class PackageCommandGeneratorLegacy
    class << self
      def generate
        print_legacy_information

        parts = ["/usr/bin/xcrun #{XcodebuildFixes.patch_package_application.shellescape} -v"]
        parts += options
        parts += pipe

        parts
      end

      def options
        options = []

        options << Shellwords.escape(appfile_path)
        options << "-o '#{ipa_path}'"
        options << "exportFormat ipa"

        if Gym.config[:provisioning_profile_path]
          options << "--embed '#{Gym.config[:provisioning_profile_path]}'"
        end

        if Gym.config[:codesigning_identity]
          options << "--sign #{Gym.config[:codesigning_identity].shellescape}"
        end

        options
      end

      def pipe
        [""]
      end

      # Place where the IPA file will be created, so it can be safely moved to the destination folder
      def temporary_output_path
        Gym.cache[:temporary_output_path] ||= Dir.mktmpdir('gym_output')
      end

      def appfile_path
        path = Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").first
        path ||= Dir[BuildCommandGenerator.archive_path + "/**/*.app"].first

        return path
      end

      # We export it to the temporary folder and move it over to the actual output once it's finished and valid
      def ipa_path
        File.join(temporary_output_path, "#{Gym.config[:output_name]}.ipa")
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.app.dSYM"].last
      end

      def manifest_path
        ""
      end

      def app_thinning_path
        ""
      end

      def app_thinning_size_report_path
        ""
      end

      def apps_path
        ""
      end

      def print_legacy_information
        if Gym.config[:include_bitcode]
          UI.important "Legacy build api is enabled, the `include_bitcode` value will be ignored"
        end

        if Gym.config[:include_symbols]
          UI.important "Legacy build api is enabled, the `include_symbols` value will be ignored"
        end

        if Gym.config[:export_team_id].to_s.length > 0
          UI.important "Legacy build api is enabled, the `export_team_id` value will be ignored"
        end

        if Gym.config[:export_method].to_s.length > 0
          UI.important "Legacy build api is enabled, the `export_method` value will be ignored"
        end
      end
    end
  end
end
