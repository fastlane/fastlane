module Gym
  # Responsible for building the fully working xcodebuild command
  #
  # Because of a known bug in PackageApplication Perl script used by Xcode the packaging process is performed with
  # a patched version of the script.
  class PackageCommandGenerator
    class << self
      def generate
        @patched_package_application = patch_package_application

        parts = ["/usr/bin/xcrun #{@patched_package_application} -v"]
        parts += options
        parts += pipe
        parts += postfix

        parts
      end

      def options
        options = []

        options << "'#{appfile_path}'"
        options << "-o '#{ipa_path}'"
        options << "exportFormat ipa"

        if Gym.config[:provisioning_profile_name]
          options << "--embed '#{Gym.config[:provisioning_profile_name]}'"
        end

        if Gym.config[:codesigning_identity]
          options << "--sign '#{Gym.config[:codesigning_identity]}'"
        end

        options
      end

      def pipe
        [""]
      end

      def postfix
        # Remove the patched PackageApplication file after the export is finished
        ["; rm -rf #{@patched_package_application}"]
      end

      def appfile_path
        Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").first
      end

      # We export it to the temporary folder and move it over to the actual output once it's finished and valid
      def ipa_path
        File.join(BuildCommandGenerator.build_path, "#{Gym.config[:output_name]}.ipa")
      end

      # The path the the dsym file for this app. Might be nil
      def dsym_path
        Dir[BuildCommandGenerator.archive_path + "/**/*.dsym"].last
      end

      private

      # Fix PackageApplication Perl script by Xcode to create the IPA from the archive
      def patch_package_application
        require 'fileutils'

        # Initialization
        developer_dir = `xcode-select --print-path`.strip

        # Remove any previous patched PackageApplication
        FileUtils.rm Dir.glob("/tmp/PackageApplication4Gym")


        Dir.mktmpdir do |tmpdir|
          # Duplicate PackageApplication script to PackageApplication4Gym
          FileUtils.copy_file("#{developer_dir}/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication", File.join(tmpdir, "PackageApplication4Gym"))

          # Apply patches to PackageApplication4Gym from patches folder
          Dir["lib/assets/package_application_patches/*"].each do |patch|
            puts "Applying Package Application patch: #{File.basename(patch)}"
            command = "patch #{File.join(tmpdir, "PackageApplication4Gym")} < #{patch}"
            print_command(command, "Applying Package Application patch: #{File.basename(patch)}") if $verbose

            system(command)
          end

          # Move patched PackageApplication to Xcode directory
          FileUtils.copy_file(File.join(tmpdir, "PackageApplication4Gym"), File.join("/tmp", "PackageApplication4Gym"))
        end

        # Return path to the patched PackageApplication
        File.join("/tmp", "PackageApplication4Gym")
      end
    end
  end
end
