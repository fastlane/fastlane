module Snapshot
  # Migrate helper files
  class Update
    # @return [Array] A list of helper files (usually just one)
    def self.find_helper
      Dir["./**/SnapshotHelper.swift"]
    end

    def update
      paths = self.class.find_helper

      UI.message "Found the following SnapshotHelper:"
      paths.each { |p| UI.message "\t#{p}" }
      UI.important "Are you sure you want to automatically update the helpers listed above?"
      UI.message "This will overwrite all its content with the latest code."
      UI.message "The underlying API will not change. You can always migrate manually by looking at"
      UI.message "https://github.com/fastlane/fastlane/blob/master/snapshot/lib/assets/SnapshotHelper.swift"

      return 1 unless UI.confirm("Overwrite configuration files?")

      paths.each do |path|
        UI.message "Updating '#{path}'..."
        File.write(path, File.read("#{Snapshot::ROOT}/lib/assets/SnapshotHelper.swift"))
      end

      UI.success "Successfully updated helper files"
    end
  end
end
