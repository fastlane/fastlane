module Fastlane
  module Actions
    # Commits the current changes in the repo as a version bump, checking to make sure only files which contain version information have been changed.
    class CommitVersionBumpAction
      def self.run(params)
        require 'xcodeproj'
        require 'pathname'
        require 'set'
        require 'shellwords'

        params = params.first

        commit_message = (params && params[:message]) || 'Version Bump'

        # find the repo root path
        repo_path = `git rev-parse --show-toplevel`.strip

        # find an xcodeproj (ignoreing the Cocoapods one)
        xcodeproj_paths = Dir[File.expand_path(File.join(repo_path, '**/*.xcodeproj'))].reject { |path| /Pods\/.*.xcodeproj/ =~ path }

        raise 'Could not find a .xcodeproj in the current repository\'s working directory.'.red if xcodeproj_paths.count == 0
        raise 'Found multiple .xcodeproj projects in the current repository\'s working directory. This tool only support project folders with a single .xcodeproj.'.red if xcodeproj_paths.count > 1
        xcodeproj_path = xcodeproj_paths.first

        # find the pbxproj path, relative to git directory
        git_pathname = Pathname.new(repo_path)
        pbxproj_pathname = Pathname.new(File.join(xcodeproj_path, 'project.pbxproj'))
        pbxproj_path = pbxproj_pathname.relative_path_from(git_pathname).to_s

        # find the info_plist files
        project = Xcodeproj::Project.open(xcodeproj_path)
        info_plist_files = project.objects.select { |object| object.isa == 'XCBuildConfiguration' }.map(&:to_hash).map { |object_hash| object_hash['buildSettings'] }.select { |build_settings| build_settings.has_key?('INFOPLIST_FILE') }.map { |build_settings| build_settings['INFOPLIST_FILE'] }.uniq

        # create our list of files that we expect to have changed, they should all be relative to the project root, which should be equal to the git workdir root
        expected_changed_files = []
        expected_changed_files << pbxproj_path
        expected_changed_files << info_plist_files
        expected_changed_files.flatten!.uniq!

        # get the list of files that have actually changed in our git workdir
        git_dirty_files = `git diff --name-only HEAD`.split("\n") + `git ls-files --other --exclude-standard`.split("\n")

        # little user hint
        raise 'No file changes picked up. Make sure you run the `increment_build_number` action first.'.red if git_dirty_files.empty?

        # check if the files changed are the ones we expected to change (these should be only the files that have version info in them)
        changed_files_as_expected = (Set.new(git_dirty_files) == Set.new(expected_changed_files))
        raise "Found unexpected uncommited changes in the working directory. Expected these files to have changed: #{expected_changed_files}. But found these actual changes: #{git_dirty_files}. Make sure you have cleaned up the build artifacts and are only left with the changed version files at this stage in your lane, and don't touch the working directory while your lane is running.".red unless changed_files_as_expected

        # get the absolute paths to the files
        git_add_paths = expected_changed_files.map { |path| File.expand_path(File.join(git_pathname, path)) }

        # then create a commit with a message
        Actions.sh("git add #{git_add_paths.map(&:shellescape).join(' ')}")
        Actions.sh("git commit -m '#{commit_message}'")

        Helper.log.info "Committed \"#{commit_message}\" 💾.".green
      end
    end
  end
end
