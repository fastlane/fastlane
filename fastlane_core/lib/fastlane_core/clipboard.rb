require 'open3'

module FastlaneCore
  class Clipboard
    def self.copy(content: nil)
      return UI.error!("Clipboard.copy is only supported in macOS environment.") if !Helper.mac?
      Open3.popen3('pbcopy') { |input, _, _| input << content }
    end

    def self.paste
      return UI.error!("Clipboard.paste is only supported in macOS environment.") if !Helper.mac?
      return `pbpaste`
    end
  end
end
