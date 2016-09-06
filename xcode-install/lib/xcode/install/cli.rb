module XcodeInstall
  class Command
    class InstallCLITools < Command
      self.command = 'install-cli-tools'
      self.summary = 'Installs Xcode Command Line Tools.'

      def run
        raise Informative, 'Xcode CLI Tools are already installed.' if installed?
        install
      end

      def installed?
        File.exist?('/Library/Developer/CommandLineTools/usr/lib/libxcrun.dylib')
      end

      def install
        cli_placeholder_file = '/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress'
        # create the placeholder file that's checked by CLI updates' .dist code in Apple's SUS catalog
        FileUtils.touch(cli_placeholder_file)
        # find the CLI Tools update
        product = `softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n'`
        `softwareupdate -i "#{product}" -v`
        FileUtils.rm(cli_placeholder_file)
      end
    end
  end
end
