module Gym
  class XcodebuildFixes
    class << self
      # Fix PackageApplication Perl script by Xcode to create the IPA from the archive
      def patch_package_application
        require 'fileutils'

        # Initialization
        @patched_package_application_path = File.join("/tmp", "PackageApplication4Gym")
        # Remove any previous patched PackageApplication
        FileUtils.rm @patched_package_application_path if File.exist?(@patched_package_application_path)

        Dir.mktmpdir do |tmpdir|
          # Check current PackageApplication MD5
          require 'digest'

          path = File.join(Helper.gem_path("gym"), "lib/assets/package_application_patches/PackageApplication_MD5")
          expected_md5 = File.read(path)

          # If that location changes, search it using xcrun --sdk iphoneos -f PackageApplication
          package_application_path = "#{Gym.xcode_path}/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication"

          raise "Unable to patch the `PackageApplication` script bundled in XCode. This is not supported." unless expected_md5 == Digest::MD5.file(package_application_path).hexdigest

          # Duplicate PackageApplication script to PackageApplication4Gym
          FileUtils.copy_file(package_application_path, @patched_package_application_path)

          # Apply patches to PackageApplication4Gym from patches folder
          Dir[File.join(Helper.gem_path("gym"), "lib/assets/package_application_patches/*.diff")].each do |patch|
            Helper.log.info "Applying Package Application patch: #{File.basename(patch)}" if $verbose
            command = ["patch #{@patched_package_application_path} < #{patch}"]
            Runner.new.print_command(command, "Applying Package Application patch: #{File.basename(patch)}") if $verbose

            FastlaneCore::CommandExecutor.execute(command: command,
                                                print_all: false,
                                            print_command: $verbose,
                                                    error: proc do |output|
                                                      ErrorHandler.handle_package_error(output)
                                                    end)
          end
        end

        return @patched_package_application_path # Return path to the patched PackageApplication
      end

      # Remove the patched script after it was used
      def clear_patched_package_application
        if @patched_package_application_path and File.exist?(@patched_package_application_path)
          Helper.log.debug "Removing patched PackageApplication file at path '#{@patched_package_application_path}'" if $verbose
          # force in the unlikely event that the file was deleted (e.g. by a concurrent job)
          FileUtils.rm @patched_package_application_path, force: true
        end
      end
    end
  end
end
