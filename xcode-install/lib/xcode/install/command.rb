require 'claide'
require 'xcode/install/version'

module XcodeInstall
  class PlainInformative < StandardError
    include CLAide::InformativeError
  end

  class Informative < PlainInformative
    def message
      "[!] #{super}".ansi.red
    end
  end

  class Command < CLAide::Command
    require 'xcode/install/cleanup'
    require 'xcode/install/cli'
    require 'xcode/install/install'
    require 'xcode/install/installed'
    require 'xcode/install/list'
    require 'xcode/install/select'
    require 'xcode/install/selected'
    require 'xcode/install/uninstall'
    require 'xcode/install/update'
    require 'xcode/install/simulators'

    self.abstract_command = true
    self.command = 'xcversion'
    self.version = VERSION
    self.description = 'Xcode installation manager.'
  end
end
