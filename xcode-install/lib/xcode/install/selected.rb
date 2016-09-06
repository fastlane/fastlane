module XcodeInstall
  class Command
    class Selected < Command
      self.command = 'selected'
      self.summary = 'Show version number of currently selected Xcode.'

      def run
        puts `xcodebuild -version`
      end
    end
  end
end
