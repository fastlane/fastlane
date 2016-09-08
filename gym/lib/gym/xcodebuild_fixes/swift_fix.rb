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

        return if check_for_swift(PackageCommandGenerator)

        UI.verbose "Packaging up the Swift Framework as the current app is a Swift app"
        ipa_swift_frameworks = Dir["#{PackageCommandGenerator.appfile_path}/Frameworks/libswift*"]

        # Decides which Swift toolchain we will use
        toolchain = Gym.config[:toolchain]
        unless toolchain
          if is_swift_23
            toolchain = "Swift_2.3.xctoolchain"
          else
            toolchain = "XcodeDefault.xctoolchain"
          end
        end
        UI.verbose "Using Swift toolchain: #{toolchain}"

        Dir.mktmpdir do |tmpdir|
          # Copy all necessary Swift libraries to a temporary "SwiftSupport" directory so that we can
          # easily add it to the .ipa later.
          swift_support = File.join(tmpdir, "SwiftSupport")

          Dir.mkdir(swift_support)

          ipa_swift_frameworks.each do |path|
            framework = File.basename(path)

            begin
              from = File.join(Xcode.xcode_path, "Toolchains/#{toolchain}/usr/lib/swift/iphoneos/#{framework}")
              FileUtils.copy_file(from, File.join(swift_support, framework))
            rescue => ex
              UI.error("Error copying over framework file. Please try running gym without the legacy build API enabled")
              UI.error("For more information visit https://github.com/fastlane/fastlane/issues/5863")
              UI.error("Missing file #{path} inside #{Xcode.xcode_path}")
              UI.error(ex)
            end
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

      # Returns true if all build settings are configured as 2.3
      # Note: this probably should check the exact build configuration
      # at some point
      # @return true if all build settings are configured as 2.3
      def is_swift_23

        project = Gym.project
        xcodeproj_path = project.is_workspace ? project.path.gsub('xcworkspace', 'xcodeproj') : project.path

        project = Xcodeproj::Project.open(xcodeproj_path)

        # Get array of unique swift versions
        swift_versions = project.objects.select do |object|
          object.isa == 'XCBuildConfiguration'
        end.map(&:to_hash).map do |object_hash|
          object_hash['buildSettings']
        end.select do |build_settings|
          build_settings.key?('SWIFT_VERSION')
        end.map do |build_settings|
          build_settings['SWIFT_VERSION']
        end.uniq

        # Warning and return false if multiple settings
        # This probably shouldn't ever happen so didn't want to spend a lot of
        # time to work around this problem
        #
        # Developer can use the "toolchain" config to get something super specific setup
        # if (s)he wants :)
        if swift_versions.count > 1
          UI.warning "Build settings don't have SWIFT_VERSION set to 2.3 for all configurations. Cannot determine which toolchaint to use."
          return false
        end

        return swift_versions.first == "2.3"
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
