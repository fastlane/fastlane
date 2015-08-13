module Gym
  class XcodeFix
    class << self
      # Fix PackageApplication Perl script by Xcode to create the IPA from the archive
      def patch_package_application
        require 'fileutils'

        # Initialization
        developer_dir = `xcode-select --print-path`.strip
        patched_package_application_path = File.join("/tmp", "PackageApplication4Gym")
        # Remove any previous patched PackageApplication
        FileUtils.rm patched_package_application_path if File.exist?(patched_package_application_path)

        Dir.mktmpdir do |tmpdir|
          # Check current PackageApplication MD5
          require 'digest'

          path = File.join(Helper.gem_path("gym"), "lib/assets/package_application_patches/PackageApplication_MD5")
          expected_md5 = File.read(path)

          # If that location changes, search it using xcrun --sdk iphoneos -f PackageApplication
          package_application_path = "#{developer_dir}/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication"

          raise "Unable to patch the `PackageApplication` script bundled in XCode. This is not supported." unless expected_md5 == Digest::MD5.file(package_application_path).hexdigest

          # Duplicate PackageApplication script to PackageApplication4Gym
          FileUtils.copy_file(package_application_path, patched_package_application_path)

          # Apply patches to PackageApplication4Gym from patches folder
          Dir[File.join(Helper.gem_path("gym"), "lib/assets/package_application_patches/*.diff")].each do |patch|
            Helper.log.info "Applying Package Application patch: #{File.basename(patch)}" unless Gym.config[:silent]
            command = ["patch #{patched_package_application_path} < #{patch}"]
            print_command(command, "Applying Package Application patch: #{File.basename(patch)}") if $verbose

            FastlaneCore::CommandExecutor.execute(command: command, 
                                                print_all: false, 
                                            print_command: !Gym.config[:silent], 
                                                    error: proc do |output|
              ErrorHandler.handle_package_error(output)
            end
          end
        end

        return patched_package_application_path # Return path to the patched PackageApplication
      end
    end
  end
end
