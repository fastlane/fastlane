module Snapshot
  # Migrate helper files
  class Update
    # @return [Array] A list of helper files (usually just one)
    def self.find_helper
      Dir["./**/SnapshotHelper.swift"]
    end

    def update
      gem_path = Helper.gem_path("snapshot")
      paths = self.class.find_helper

      Helper.log.info "Found the following SnapshotHelper:"
      puts ''
      paths.each { |p| Helper.log.info "\t#{p}" }
      puts ''
      Helper.log.info "Are you sure you want to automatically update the helpers listed above?"
      Helper.log.info "This will overwrite all its content with the latest code."
      Helper.log.info "The underlying API will not change. You can always migrate manually by looking at"
      Helper.log.info "https://github.com/fastlane/snapshot/blob/master/lib/assets/SnapshotHelper.swift"

      return 1 unless agree("Overwrite configuration files? (y/n)".red, true)

      paths.each do |path|
        Helper.log.info "Updating '#{path}'..."
        File.write(path, File.read("#{gem_path}/lib/assets/SnapshotHelper.swift"))
      end

      Helper.log.info "Successfully updated helper files".green
    end
  end
end
