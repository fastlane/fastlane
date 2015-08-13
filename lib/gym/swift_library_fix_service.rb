module Gym
  class SwiftLibraryFixService
    class << self

      # Determine whether it is a Swift project and, eventually, include all required libraries to copy from Xcode's toolchain directory.
      # Since there's no "xcodebuild" target to do just that, it is done post-build when exporting an archived build.
      def fix
        ipa_swift_frameworks = Dir["#{appfile_path}/Frameworks/libswift*"]

        if not ipa_swift_frameworks.empty?
          Dir.mktmpdir do |tmpdir|
            # Copy all necessary Swift libraries to a temporary "SwiftSupport" directory so that we can
            # easily add it to the .ipa later.
            swift_support = File.join(tmpdir, "SwiftSupport")

            Dir.mkdir(swift_support)

            ipa_swift_frameworks.each do |path|
              framework = File.basename(path)

              sdk = Gym.config[:sdk] || 'iphoneos'
              FileUtils.copy_file("#{xcode}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/#{sdk}/#{framework}", File.join(swift_support, framework))
            end

            # Add "SwiftSupport" to the .ipa archive
            Dir.chdir(tmpdir) do
              abort unless system %{zip --recurse-paths "#{ipa_path}" "SwiftSupport" #{'> /dev/null' unless $verbose}}
            end
          end
        end
      end

      private

      def appfile_path
        Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").first
      end

      # We export it to the temporary folder and move it over to the actual output once it's finished and valid
      def ipa_path
        File.join(BuildCommandGenerator.build_path, "#{Gym.config[:output_name]}.ipa")
      end
    end
  end
end
