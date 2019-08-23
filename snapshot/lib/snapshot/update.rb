require_relative 'module'
require_relative 'runner'

module Snapshot
  # Migrate helper files
  class Update
    # @return [Array] A list of helper files (usually just one)
    def self.find_helper
      paths = Dir["./**/SnapshotHelper.swift"] + Dir["./**/SnapshotHelperXcode8.swift"]
      # exclude assets in gym
      paths.reject { |p| p.include?("snapshot/lib/assets/") }
    end

    def update(force: false)
      paths = self.class.find_helper
      UI.user_error!("Couldn't find any SnapshotHelper files in current directory") if paths.count == 0

      UI.message("Found the following SnapshotHelper:")
      paths.each { |p| UI.message("\t#{p}") }
      UI.important("Are you sure you want to automatically update the helpers listed above?")
      UI.message("This will overwrite all its content with the latest code.")
      UI.message("The underlying API will not change. You can always migrate manually by looking at")
      UI.message("https://github.com/fastlane/fastlane/blob/master/snapshot/lib/assets/SnapshotHelper.swift")

      if !force && !UI.confirm("Overwrite configuration files?")
        return 1
      end

      paths.each do |path|
        UI.message("Updating '#{path}'...")
        input_path = Snapshot::Runner.path_to_helper_file_from_gem
        File.write(path, File.read(input_path))
      end

      UI.success("Successfully updated helper files")
    end
  end
end
