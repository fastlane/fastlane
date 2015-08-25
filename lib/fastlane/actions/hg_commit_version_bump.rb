# rubocop:disable Metrics/AbcSize
module Fastlane
  module Actions
    # Commits version bump.
    class HgCommitVersionBumpAction < Action
      def self.run(params)
        require 'xcodeproj'
        require 'pathname'
        require 'set'
        require 'shellwords'

        xcodeproj_path = params[:xcodeproj] ? File.expand_path(File.join('.', params[:xcodeproj])) : nil

        if Helper.is_test?
          xcodeproj_path = "/tmp/Test.xcodeproj"
        end

        # get the repo root path
        repo_path = Helper.is_test? ? '/tmp/repo' : Actions.sh('hg root').strip
        repo_pathname = Pathname.new(repo_path)

        if xcodeproj_path
          # ensure that the xcodeproj passed in was OK
          unless Helper.is_test?
            raise "Could not find the specified xcodeproj: #{xcodeproj_path}" unless File.directory?(xcodeproj_path)
          end
        else
          # find an xcodeproj (ignoring the Cocoapods one)
          xcodeproj_paths = Dir[File.expand_path(File.join(repo_path, '**/*.xcodeproj'))].reject { |path| %r{Pods\/.*.xcodeproj} =~ path }

          # no projects found: error
          raise 'Could not find a .xcodeproj in the current repository\'s working directory.'.red if xcodeproj_paths.count == 0

          # too many projects found: error
          if xcodeproj_paths.count > 1
            relative_projects = xcodeproj_paths.map { |e| Pathname.new(e).relative_path_from(repo_pathname).to_s }.join("\n")
            raise "Found multiple .xcodeproj projects in the current repository's working directory. Please specify your app's main project: \n#{relative_projects}".red
          end

          # one project found: great
          xcodeproj_path = xcodeproj_paths.first
        end

        # find the pbxproj path, relative to hg directory
        if Helper.is_test?
          hg_dirty_files = params[:test_dirty_files].split(",")
          expected_changed_files = params[:test_expected_files].split(",")
        else
          pbxproj_pathname = Pathname.new(File.join(xcodeproj_path, 'project.pbxproj'))
          pbxproj_path = pbxproj_pathname.relative_path_from(repo_pathname).to_s

          # find the info_plist files
          # rubocop:disable Style/MultilineBlockChain
          project = Xcodeproj::Project.open(xcodeproj_path)
          info_plist_files = project.objects.select do |object|
            object.isa == 'XCBuildConfiguration'
          end.map(&:to_hash).map do |object_hash|
            object_hash['buildSettings']
          end.select do |build_settings|
            build_settings.key?('INFOPLIST_FILE')
          end.map do |build_settings|
            build_settings['INFOPLIST_FILE']
          end.uniq.map do |info_plist_path|
            Pathname.new(File.expand_path(File.join(xcodeproj_path, '..', info_plist_path))).relative_path_from(repo_pathname).to_s
          end
          # rubocop:enable Style/MultilineBlockChain

          # create our list of files that we expect to have changed, they should all be relative to the project root, which should be equal to the hg workdir root
          expected_changed_files = []
          expected_changed_files << pbxproj_path
          expected_changed_files << info_plist_files
          expected_changed_files.flatten!.uniq!

          # get the list of files that have actually changed in our hg workdir
          hg_dirty_files = Actions.sh('hg status -n').split("\n")
        end

        # little user hint
        raise 'No file changes picked up. Make sure you run the `increment_build_number` action first.'.red if hg_dirty_files.empty?

        # check if the files changed are the ones we expected to change (these should be only the files that have version info in them)
        dirty_set = Set.new(hg_dirty_files.map(&:downcase))
        expected_set = Set.new(expected_changed_files.map(&:downcase))
        changed_files_as_expected = dirty_set.subset? expected_set
        unless changed_files_as_expected
          unless params[:force]
            str = ["Found unexpected uncommited changes in the working directory. Expected these files to have changed:",
                   "#{expected_changed_files.join("\n")}.",
                   "But found these actual changes: \n#{hg_dirty_files.join("\n")}.",
                   "Make sure you have cleaned up the build artifacts and are only left with the changed version files at this",
                   "stage in your lane, and don't touch the working directory while your lane is running. You can also use the :force option to ",
                   "bypass this check, and always commit a version bump regardless of the state of the working directory."
                  ].join("\n")
            raise str.red
          end
        end

        # create a commit with a message
        command = "hg commit -m '#{params[:message]}'"
        return command if Helper.is_test?
        begin
          Actions.sh(command)

          Helper.log.info "Committed \"#{params[:message]}\" 💾.".green
        rescue => ex
          Helper.log.error ex
          Helper.log.info "Didn't commit any changes. 😐".yellow
        end
      end

      def self.description
        "This will commit a version bump to the hg repo"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_COMMIT_BUMP_MESSAGE",
                                       description: "The commit message when committing the version bump",
                                       default_value: "Version Bump"),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_BUILD_NUMBER_PROJECT",
                                       description: "The path to your project file (Not the workspace). If you have only one, this is optional",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass the path to the project, not the workspace".red if value.include? "workspace"
                                         raise "Could not find Xcode project".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_FORCE_COMMIT",
                                       description: "Forces the commit, even if other files than the ones containing the version number have been modified",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :test_dirty_files,
                                       env_name: "FL_HG_COMMIT_TEST_DIRTY_FILES",
                                       description: "A list of dirty files passed in for testing",
                                       optional: true,
                                       default_value: "file1, file2"),
          FastlaneCore::ConfigItem.new(key: :test_expected_files,
                                       env_name: "FL_HG_COMMIT_TEST_EXP_FILES",
                                       description: "A list of expected changed files passed in for testin",
                                       optional: true,
                                       default_value: "file1, file2")
        ]
      end

      def self.author
        # credits to lmirosevic for original git version
        "sjrmanning"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
