module Gym
  # Responsible for building the fully working xcodebuild command
  class PackageCommandGeneratorXcode7
    class << self
      def generate
        parts = ["/usr/bin/xcrun xcodebuild -exportArchive"]
        parts += options
        parts += pipe

        File.write(config_path, config_content) # overwrite everytime. Could be optimized

        parts
      end

      def options
        options = []

        options << "-exportOptionsPlist #{config_path}"
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

      private

      def config_path
        @config_path ||= "/tmp/gym_config_#{Time.now.to_i}.plist"
        return @config_path
      end

      def config_content
        require 'plist'
        symbols = (Gym.config[:skip_symbols] ? false : true)
        bitcode = (Gym.config[:upload_bitcode] ? true : false)

        {
          method: 'app-store',
          uploadSymbols: symbols,
          uploadBitcode: bitcode
        }.to_plist
      end
    end
  end
end
