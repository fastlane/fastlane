module Chiizu
  class DependencyChecker
    def self.check_dependencies
      return if Helper.test?

      self.check_adb
    end

    def self.check_adb
      unless `adb version`.include? "Android Debug Bridge"
        Helper.log.fatal '#############################################################'
        Helper.log.fatal '# TODO Helpful error message'
        Helper.log.fatal '#############################################################'
        raise 'TODO Helpful error message'
      end
    end
  end
end
