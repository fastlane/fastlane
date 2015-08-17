module Gym
  class XcodebuildFixes
    class << self
      # Determine whether it is a Swift project and, eventually, include all required libraries to copy from Xcode's toolchain directory.
      # Since there's no "xcodebuild" target to do just that, it is done post-build when exporting an archived build.
      def swift_library_fix
        require 'fileutils'

        ipa_swift_frameworks = Dir["#{PackageCommandGenerator.appfile_path}/Frameworks/libswift*"]
        Helper.log.info "Checking for Swift framework" if $verbose

        return if ipa_swift_frameworks.empty?
        Helper.log.info "Packaging up the Swift Framework as the current app is a Swift app" if $verbose

        Dir.mktmpdir do |tmpdir|
          # Copy all necessary Swift libraries to a temporary "SwiftSupport" directory so that we can
          # easily add it to the .ipa later.
          swift_support = File.join(tmpdir, "SwiftSupport")

          Dir.mkdir(swift_support)

          ipa_swift_frameworks.each do |path|
            framework = File.basename(path)

            FileUtils.copy_file("#{Gym.xcode_path}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos/#{framework}", File.join(swift_support, framework))
          end

          # Add "SwiftSupport" to the .ipa archive
          Dir.chdir(tmpdir) do
            command_parts = ["zip --recurse-paths #{PackageCommandGenerator.ipa_path} SwiftSupport"]
            command_parts << "> /dev/null" unless $verbose
            print_command(command_parts, "Fix Swift embedded code if needed") if $verbose

            FastlaneCore::CommandExecutor.execute(command: command_parts,
                                                print_all: false,
                                            print_command: !Gym.config[:silent],
                                                    error: proc do |output|
                                                      ErrorHandler.handle_package_error(output)
                                                    end)
          end
        end
      end
    end
  end
end
