# rubocop:disable Metrics/AbcSize
module Fastlane
  module Actions
    # Commits the current changes in the repo as a version bump, checking to make sure only files which contain version information have been changed.
    class CommitVersionBumpAction < Action
      def self.run(params)
        require 'xcodeproj'
        require 'pathname'
        require 'set'
        require 'shellwords'

        xcodeproj_path = params[:xcodeproj] ? File.expand_path(File.join('.', params[:xcodeproj])) : nil

        # find the repo root path
        repo_path = Actions.sh('git rev-parse --show-toplevel').strip
        repo_pathname = Pathname.new(repo_path)

        if xcodeproj_path
          # ensure that the xcodeproj passed in was OK
          raise "Could not find the specified xcodeproj: #{xcodeproj_path}" unless File.directory?(xcodeproj_path)
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

        # find the pbxproj path, relative to git directory
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

        # create our list of files that we expect to have changed, they should all be relative to the project root, which should be equal to the git workdir root
        expected_changed_files = []
        expected_changed_files << pbxproj_path
        expected_changed_files << info_plist_files
        expected_changed_files.flatten!.uniq!

        # get the list of files that have actually changed in our git workdir
        git_dirty_files = Actions.sh('git diff --name-only HEAD').split("\n") + Actions.sh('git ls-files --other --exclude-standard').split("\n")

        # little user hint
        raise 'No file changes picked up. Make sure you run the `increment_build_number` action first.'.red if git_dirty_files.empty?

        # check if the files changed are the ones we expected to change (these should be only the files that have version info in them)
        changed_files_as_expected = (Set.new(git_dirty_files.map(&:downcase)).subset? Set.new(expected_changed_files.map(&:downcase)))
        unless changed_files_as_expected
          unless params[:force]
            error = [
              "Found unexpected uncommited changes in the working directory. Expected these files to have ",
              "changed: \n#{expected_changed_files.join("\n")}.\nBut found these actual changes: ",
              "#{git_dirty_files.join("\n")}.\nMake sure you have cleaned up the build artifacts and ",
              "are only left with the changed version files at this stage in your lane, and don't touch the ",
              "working directory while your lane is running. You can also use the :force option to bypass this ",
              "check, and always commit a version bump regardless of the state of the working directory."
            ].join("\n")
            raise error.red
          end
        end

        if params[:settings]
          expected_changed_files << 'Settings.bundle/Root.plist'
        end

        # get the absolute paths to the files
        git_add_paths = expected_changed_files.map do |path|
          File.expand_path(File.join(repo_pathname, path))
        end

        # then create a commit with a message
        Actions.sh("git add #{git_add_paths.map(&:shellescape).join(' ')}")

        begin
          build_number = Actions.lane_context[Actions::SharedValues::BUILD_NUMBER]

          params[:message] ||= (build_number ? "Version Bump to #{build_number}" : "Version Bump")

          Actions.sh("git commit -m '#{params[:message]}'")

          Helper.log.info "Committed \"#{params[:message]}\" 💾.".green
        rescue => ex
          Helper.log.error ex
          Helper.log.info "Didn't commit any changes.".yellow
        end
      end

      def self.description
        "Creates a 'Version Bump' commit. Run after `increment_build_number`"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_COMMIT_BUMP_MESSAGE",
                                       description: "The commit message when committing the version bump",
                                       optional: true),
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
          FastlaneCore::ConfigItem.new(key: :settings,
                                       env_name: "FL_COMMIT_INCLUDE_SETTINGS",
                                       description: "Include Settings.bundle/Root.plist with version bump",
                                       optional: true,
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
