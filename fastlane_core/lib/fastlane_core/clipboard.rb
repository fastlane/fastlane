require 'fastlane_core'
require 'open3'

module FastlaneCore
  class Clipboard
    def self.copy(content: nil)
      return UI.crash!("'pbcopy' or 'pbpaste' command not found.") unless is_supported?
      Open3.popen3('pbcopy') { |input, _, _| input << content }
    end

    def self.paste
      return UI.crash!("'pbcopy' or 'pbpaste' command not found.") unless is_supported?
      return `pbpaste`
    end

    def self.is_supported?
      return `which pbcopy`.length > 0 && `which pbpaste`.length > 0
    end
  end
end
