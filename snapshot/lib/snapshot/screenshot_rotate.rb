require_relative 'module'
require 'fastlane_core/fastlane_pty'

module Snapshot
  # This class takes care of rotating images
  class ScreenshotRotate
    require 'shellwords'

    # @param (String) The path in which the screenshots are located in
    def run(path)
      UI.verbose("Rotating the screenshots (if necessary)")
      rotate(path)
    end

    def rotate(path)
      Dir.glob([path, '/**/*.png'].join('/')).each do |file|
        UI.verbose("Rotating '#{file}'")

        command = nil
        if file.end_with?("landscapeleft.png")
          command = "sips -r -90 '#{file}'"
        elsif file.end_with?("landscaperight.png")
          command = "sips -r 90 '#{file}'"
        elsif file.end_with?("portrait_upsidedown.png")
          command = "sips -r 180 '#{file}'"
        end

        next unless command

        # Only rotate if we need to
        FastlaneCore::FastlanePty.spawn(command) do |command_stdout, command_stdin, pid|
          command_stdout.sync
          command_stdout.each do |line|
            # We need to read this otherwise things hang
          end
          ::Process.wait(pid)
        end
      end
    end
  end
end
