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

        if Helper.test?
          xcodeproj_path = "/tmp/Test.xcodeproj"
        end

        # get the repo root path
        repo_path = Helper.test? ? '/tmp/repo' : Actions.sh('hg root').strip
        repo_pathname = Pathname.new(repo_path)

        if xcodeproj_path
          # ensure that the xcodeproj passed in was OK
          unless Helper.test?
            UI.user_error!("Could not find the specified xcodeproj: #{xcodeproj_path}") unless File.directory?(xcodeproj_path)
          end
        else
          # find an xcodeproj (ignoring dependencies)
          xcodeproj_paths = Fastlane::Helper::XcodeprojHelper.find(repo_path)

          # no projects found: error
          UI.user_error!('Could not find a .xcodeproj in the current repository\'s working directory.') if xcodeproj_paths.count == 0

          # too many projects found: error
          if xcodeproj_paths.count > 1
            relative_projects = xcodeproj_paths.map { |e| Pathname.new(e).relative_path_from(repo_pathname).to_s }.join("\n")
            UI.user_error!("Found multiple .xcodeproj projects in the current repository's working directory. Please specify your app's main project: \n#{relative_projects}")
          end

          # one project found: great
          xcodeproj_path = xcodeproj_paths.first
        end

        # find the pbxproj path, relative to hg directory
        if Helper.test?
          hg_dirty_files = params[:test_dirty_files].split(",")
          expected_changed_files = params[:test_expected_files].split(",")
        else
          pbxproj_pathname = Pathname.new(File.join(xcodeproj_path, 'project.pbxproj'))
          pbxproj_path = pbxproj_pathname.relative_path_from(repo_pathname).to_s

          # find the info_plist files
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

          # create our list of files that we expect to have changed, they should all be relative to the project root, which should be equal to the hg workdir root
          expected_changed_files = []
          expected_changed_files << pbxproj_path
          expected_changed_files << info_plist_files
          expected_changed_files.flatten!.uniq!

          # get the list of files that have actually changed in our hg workdir
          hg_dirty_files = Actions.sh('hg status -n').split("\n")
        end

        # little user hint
        UI.user_error!("No file changes picked up. Make sure you run the `increment_build_number` action first.") if hg_dirty_files.empty?

        # check if the files changed are the ones we expected to change (these should be only the files that have version info in them)
        dirty_set = Set.new(hg_dirty_files.map(&:downcase))
        expected_set = Set.new(expected_changed_files.map(&:downcase))
        changed_files_as_expected = dirty_set.subset?(expected_set)
        unless changed_files_as_expected
          unless params[:force]
            str = ["Found unexpected uncommitted changes in the working directory. Expected these files to have changed:",
                   "#{expected_changed_files.join("\n")}.",
                   "But found these actual changes: \n#{hg_dirty_files.join("\n")}.",
                   "Make sure you have cleaned up the build artifacts and are only left with the changed version files at this",
                   "stage in your lane, and don't touch the working directory while your lane is running. You can also use the :force option to ",
                   "bypass this check, and always commit a version bump regardless of the state of the working directory."].join("\n")
            UI.user_error!(str)
          end
        end

        # create a commit with a message
        command = "hg commit -m '#{params[:message]}'"
        return command if Helper.test?
        begin
          Actions.sh(command)

          UI.success("Committed \"#{params[:message]}\" 💾.")
        rescue => ex
          UI.error(ex)
          UI.important("Didn't commit any changes. 😐")
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
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project") unless File.exist?(value)
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
                                       description: "A list of expected changed files passed in for testing",
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

      def self.details
        list = <<-LIST.markdown_list
          All `.plist` files
          The `.xcodeproj/project.pbxproj` file
        LIST
        [
          "The mercurial equivalent of the [commit_version_bump](https://docs.fastlane.tools/actions/commit_version_bump/) git action. Like the git version, it is useful in conjunction with [`increment_build_number`](https://docs.fastlane.tools/actions/increment_build_number/).",
          "It checks the repo to make sure that only the relevant files have changed, these are the files that `increment_build_number` (`agvtool`) touches:".markdown_preserve_newlines,
          list,
          "Then commits those files to the repo.",
          "Customize the message with the `:message` option, defaults to 'Version Bump'",
          "If you have other uncommitted changes in your repo, this action will fail. If you started off in a clean repo, and used the _ipa_ and or _sigh_ actions, then you can use the [clean_build_artifacts](https://docs.fastlane.tools/actions/clean_build_artifacts/) action to clean those temporary files up before running this action."
        ].join("\n")
      end

      def self.example_code
        [
          'hg_commit_version_bump',
          'hg_commit_version_bump(
            message: "Version Bump",                 # create a commit with a custom message
            xcodeproj: "./path/MyProject.xcodeproj", # optional, if you have multiple Xcode project files, you must specify your main project here
          )'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
