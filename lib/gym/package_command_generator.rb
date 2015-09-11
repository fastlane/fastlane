require 'shellwords'

module Gym
  # Responsible for building the fully working xcodebuild command
  #
  # Because of a known bug in PackageApplication Perl script used by Xcode the packaging process is performed with
  # a patched version of the script.
  class PackageCommandGenerator
    class << self
      def generate
        parts = ["/usr/bin/xcrun xcodebuild -exportArchive"]
        parts += options
        parts += pipe

        parts
      end

      def options
        options = []

        options << "-exportOptionsPlist /tmp/config.plist"
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
