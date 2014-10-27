module Deliver
  class DependencyChecker
    def self.check_for_brew
      if `which phantomjs`.length == 0
        # Missing brew dependency
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to install phantomjs to use deliver"
        Helper.log.fatal "# phantomjs is used to control the iTunesConnect frontend"
        Helper.log.fatal "# Install Homebrew using http://brew.sh/" if `which brew`.length == 0
        Helper.log.fatal "# Run 'brew install phantomjs' and start deliver again"
        Helper.log.fatal '#############################################################'
        raise "Run 'brew install phantomjs' and start deliver again"
      end

      unless `xcode-select -v`.include?"xcode-select version "
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to install the Xcode commdand line tools to use deliver"
        Helper.log.fatal "# Install the latest version of Xcode from the AppStore"
        Helper.log.fatal "# Run xcode-select --install to install the developer tools"
        Helper.log.fatal '#############################################################'
        raise "Run 'xcode-select --install' and start deliver again"
      end
    end
  end
end