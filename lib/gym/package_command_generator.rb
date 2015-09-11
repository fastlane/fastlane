require 'shellwords'

module Gym
  class PackageCommandGenerator
    class << self
      def generate
        generator.generate
      end

      def appfile_path
        generator.appfile_path
      end

      def ipa_path
        generator.ipa_path
      end

      def dsym_path
        generator.dsym_path
      end

      private

      def generator
        Gym.pre_7? ? PackageCommandGeneratorPre7 : PackageCommandGeneratorV7
      end
    end
  end

  # Responsible for building the fully working xcodebuild command on xcode < 7
  #
  # Because of a known bug in PackageApplication Perl script used by Xcode the packaging process is performed with
  # a patched version of the script.
  class PackageCommandGeneratorPre7
    class << self
      def generate
        parts = ["/usr/bin/xcrun #{XcodebuildFixes.patch_package_application} -v"]
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
          options << "--sign '#{Gym.config[:codesigning_identity]}'"
        end

        options
      end

      def pipe
        [""]
      end

      def appfile_path
        path = Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").first
        path ||= Dir[BuildCommandGenerator.archive_path + "/**/*.app"].last

        return path
      end

      # We export it to the temporary folder and move it over to the actual output once it's finished and valid
      def ipa_path
        File.join(BuildCommandGenerator.build_path, "#{Gym.config[:output_name]}.ipa")
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.app.dSYM"].last
      end
    end
  end

  # Responsible for building the fully working xcodebuild command
  class PackageCommandGeneratorV7
    @config_content = %(<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>uploadSymbols</key>
  <true/>
  <key>uploadBitcode</key>
  <false/>
</dict>
</plist>
)
    @config_path = '/tmp/config.plist'

    class << self
      def generate
        parts = ["/usr/bin/xcrun xcodebuild -exportArchive"]
        parts += options
        parts += pipe

        File.write(@config_path, @config_content) # overwrite everytime. Could be optimized

        parts
      end

      def options
        options = []

        options << "-exportOptionsPlist #{@config_path}"
        options << "-archivePath '#{BuildCommandGenerator.archive_path}'"
        options << "-exportPath '#{BuildCommandGenerator.build_path}'" # we move it once the binary is finished

        options
      end

      def pipe
        [""]
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.app.dSYM"].last
      end
    end
  end
end
