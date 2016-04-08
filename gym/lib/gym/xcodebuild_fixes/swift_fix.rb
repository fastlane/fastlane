# encoding: utf-8
# from http://stackoverflow.com/a/9857493/445598
# because of
# `incompatible encoding regexp match (UTF-8 regexp with ASCII-8BIT string) (Encoding::CompatibilityError)`
require 'zip'

module Gym
  class XcodebuildFixes
    class << self
      # Determine whether it is a Swift project and, eventually, include all required libraries to copy from Xcode's toolchain directory.
      # Since there's no "xcodebuild" target to do just that, it is done post-build when exporting an archived build.
      def swift_library_fix
        require 'fileutils'

        return if check_for_swift PackageCommandGenerator

        UI.verbose "Packaging up the Swift Framework as the current app is a Swift app"
        ipa_swift_frameworks = Dir["#{PackageCommandGenerator.appfile_path}/Frameworks/libswift*"]

        Dir.mktmpdir do |tmpdir|
          # Copy all necessary Swift libraries to a temporary "SwiftSupport" directory so that we can
          # easily add it to the .ipa later.
          swift_support = File.join(tmpdir, "SwiftSupport")

          Dir.mkdir(swift_support)

          ipa_swift_frameworks.each do |path|
            framework = File.basename(path)

            FileUtils.copy_file("#{Xcode.xcode_path}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos/#{framework}", File.join(swift_support, framework))
          end

          # Add "SwiftSupport" to the .ipa archive
          Dir.chdir(tmpdir) do
            command_parts = ["zip --recurse-paths '#{PackageCommandGenerator.ipa_path}' SwiftSupport"]
            command_parts << "> /dev/null" unless $verbose
            Runner.new.print_command(command_parts, "Fix Swift embedded code if needed") if $verbose

            FastlaneCore::CommandExecutor.execute(command: command_parts,
                                                print_all: false,
                                            print_command: !Gym.config[:silent],
                                                    error: proc do |output|
                                                      ErrorHandler.handle_package_error(output)
                                                    end)
          end
        end
      end

      # @param the PackageCommandGenerator
      # @return true if swift
      def check_for_swift(pcg)
        UI.verbose "Checking for Swift framework"
        default_swift_libs = "#{pcg.appfile_path}/Frameworks/libswift.*" # note the extra ., this is a string representation of a regexp
        zip_entries_matching(pcg.ipa_path, /#{default_swift_libs}/).count > 0
      end

      # return the entries (files or directories) in the zip matching the pattern
      # @param zipfile a zipfile
      # @return the files or directories matching the pattern
      def zip_entries_matching(zipfile, file_pattern)
        files = []
        Zip::File.open(zipfile) do |zip_file|
          zip_file.each do |entry|
            files << entry.name if entry.name.force_encoding("utf-8").match file_pattern
          end
        end
        files
      end
    end
  end
end
