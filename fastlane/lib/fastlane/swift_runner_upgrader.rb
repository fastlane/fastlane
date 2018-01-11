require 'xcodeproj'
require 'fileutils'

module Fastlane
  # current logic:
  # - find all groups in existing project
  # -- if a group is missing, add it
  # --- add all files for group into new group, build target, and compile phase
  # - iterate through existing groups
  # -- update all files needing updating
  # - iterate through existing groups
  # -- if a file from the manifest is new, add it to group, build target, and compile phase
  # - Save and return true if any action was taken to modify any file (project included)

  # build project
  class SwiftRunnerUpgrader
    attr_accessor :target_project # project we'll be updating
    attr_accessor :fastlane_runner_target # FastlaneRunner xcodeproj target
    attr_accessor :manifest_hash # hash of file names to group names they belong to
    attr_accessor :manifest_groups # unique list of group names that came from the manifest
    attr_accessor :target_swift_code_file_folder_path # location in filesystem where all swift files should exist when we're done
    attr_accessor :source_swift_code_file_folder_path # source location of where we're copying file from during the upgrade process

    RELATIVE_SOURCE_FILE_PATH = "../"

    def initialize
      @source_swift_code_file_folder_path = File.expand_path(File.join(Fastlane::ROOT, "/swift"))
      @target_swift_code_file_folder_path = FastlaneCore::FastlaneFolder.swift_folder_path

      manifest_file = File.join(@source_swift_code_file_folder_path, "/upgrade_manifest.json")
      UI.success("loading manifest: #{manifest_file}")
      @manifest_hash = JSON.parse(File.read(manifest_file))
      @manifest_groups = @manifest_hash.values.uniq

      runner_project_path = FastlaneCore::FastlaneFolder.swift_runner_project_path
      @target_project = Xcodeproj::Project.open(runner_project_path)

      @root_group = @target_project.groups.select { |group| group.name == "Fastlane Runner" }.first

      @fastlane_runner_target = @target_project.targets.select { |target| target.name == "FastlaneRunner" }.first
    end

    def upgrade_if_needed!(dry_run: false)
      upgraded = add_missing_groups_and_files!(dry_run: dry_run)
      upgraded = upgrade_files!(dry_run: dry_run) || upgraded
      upgraded = add_new_files_to_groups! || upgraded

      UI.verbose("FastlaneRunner project has been updated and can be written back to disk") if upgraded
      unless dry_run
        UI.verbose("FastlaneRunner project changes have been stored") if upgraded
        target_project.save if upgraded
      end

      return upgraded
    end

    def upgrade_files!(dry_run: false)
      upgraded_anything = false
      self.manifest_hash.each do |filename, group|
        upgraded_anything = copy_file_if_needed!(filename: filename, dry_run: dry_run) || upgraded_anything
      end
      return upgraded_anything
    end

    def find_missing_groups
      missing_groups = []

      existing_group_names_set = @root_group.groups.map { |group| group.name.downcase }.to_set
      self.manifest_groups.each do |group_name|
        unless existing_group_names_set.include?(group_name.downcase)
          missing_groups << group_name
        end
      end
      return missing_groups
    end

    # currently just copies file, even if not needed.
    def copy_file_if_needed!(filename: nil, dry_run: false)
      # TODO: implement dry_run (DIFFING [ugh])
      return true if dry_run

      source = File.join(self.source_swift_code_file_folder_path, "/#{filename}")
      target = File.join(self.target_swift_code_file_folder_path, "/#{filename}")

      FileUtils.cp(source, target)
      UI.verbose("Copied #{source} to #{target}")
      return true
    end

    def add_new_files_to_groups!
      inverted_hash = {}

      # need {group => [file1, file2, etc..]} instead of: {file1 => group, file2 => group, etc...}
      self.manifest_hash.each do |filename, group_name|
        group_name = group_name.downcase

        files_in_group = inverted_hash[group_name]
        if files_in_group.nil?
          files_in_group = []
          inverted_hash[group_name] = files_in_group
        end
        files_in_group << filename
      end

      # this helps us signal to the user that we made changes
      updated_project = false
      # iterate through the groups and collect all the swift files in each
      @root_group.groups.each do |group|
        # current group's filenames
        existing_group_files_set = group.files
                                        .select { |file| !file.name.nil? && file.name.end_with?(".swift") }
                                        .map(&:name)
                                        .to_set

        group_name = group.name.downcase
        manifest_group_filenames = inverted_hash[group_name]

        # compare the current group files to what the manifest says should minially be there
        manifest_group_filenames.each do |filename|
          # current group is missing a file from the manifest, need to add it
          next if existing_group_files_set.include?(filename)

          UI.verbose("Adding new file #{filename} to group: `#{group.name}`")
          new_file_reference = group.new_file("#{RELATIVE_SOURCE_FILE_PATH}#{filename}")

          # add references to the target, and make sure they are added to the build phase to
          self.fastlane_runner_target.add_resources([new_file_reference])
          self.fastlane_runner_target.source_build_phase.add_file_reference(new_file_reference)

          updated_project = true
        end
      end

      return updated_project
    end

    def add_missing_groups_and_files!(dry_run: false)
      missing_groups = self.find_missing_groups.to_set
      unless missing_groups.length >= 0
        return false
      end

      # well, we know we have some changes to make, so if this is a dry run,
      # don't bother doing anything and just return true
      return true if dry_run

      missing_groups.each do |missing_group_name|
        new_group = @root_group.new_group(missing_group_name)

        # find every file in the manifest that belongs to the new group, and add it to the new group
        self.manifest_hash.each do |filename, group|
          next unless group.casecmp(missing_group_name.downcase).zero?
          # assumes this is a new file, we don't handle moving files between groups
          new_file_reference = new_group.new_file("#{RELATIVE_SOURCE_FILE_PATH}#{filename}")

          # add references to the target, and make sure they are added to the build phase to
          self.fastlane_runner_target.add_resources([new_file_reference])
          self.fastlane_runner_target.source_build_phase.add_file_reference(new_file_reference)
        end
      end

      return true # yup, we definitely updated groups
    end
  end
end
