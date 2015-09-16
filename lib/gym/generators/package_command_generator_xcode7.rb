module Gym
  # Responsible for building the fully working xcodebuild command
  class PackageCommandGeneratorXcode7
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

      def ipa_path
        File.join(BuildCommandGenerator.build_path, "#{Gym.config[:output_name]}.ipa")
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.app.dSYM"].last
      end
    end
  end
end
