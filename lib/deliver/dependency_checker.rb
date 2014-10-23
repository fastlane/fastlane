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
    end
  end
end