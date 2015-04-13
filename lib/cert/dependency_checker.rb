module Cert
  class DependencyChecker
    def self.check_dependencies
      self.check_xcode_select
    end

    def self.check_xcode_select
      return if Helper.is_test?
      unless `xcode-select -v`.include?"xcode-select version "
        Helper.log.fatal '#############################################################'
        Helper.log.fatal "# You have to install the Xcode commdand line tools to use cert"
        Helper.log.fatal "# Install the latest version of Xcode from the AppStore"
        Helper.log.fatal "# Run xcode-select --install to install the developer tools"
        Helper.log.fatal '#############################################################'
        raise "Run 'xcode-select --install' and start cert again"
      end
    end
  end
end