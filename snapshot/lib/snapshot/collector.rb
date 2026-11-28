require 'plist'
require 'json'
require 'tmpdir'

require_relative 'module'
require_relative 'test_command_generator'

module Snapshot
  # Responsible for collecting the generated screenshots and copying them over to the output directory
  class Collector
    # Returns true if it succeeds
    def self.fetch_screenshots(output, dir_name, device_type, launch_arguments_index)
      language_folder = File.join(Snapshot.config[:output_directory], dir_name)
      FileUtils.mkdir_p(language_folder)

      return collect_screenshots_for_language_folder(language_folder)
    end

    # Returns true if it succeeds
    def self.collect_screenshots_for_language_folder(destination)
      screenshots = Dir["#{SCREENSHOTS_DIR}/*.png"]
      return false if screenshots.empty?
      screenshots.each do |screenshot|
        filename = File.basename(screenshot)
        to_path = File.join(destination, filename)
        copy(screenshot, to_path)
      end
      FileUtils.rm_rf(SCREENSHOTS_DIR)
      return true
    end

    # On macOS the UI test runner is sandboxed and can't write to SCREENSHOTS_DIR: SnapshotHelper attaches
    # each screenshot to the test results instead. Export them into SCREENSHOTS_DIR under their names.
    def self.import_screenshots_from_result_bundle(result_bundle_path)
      Dir.mktmpdir("snapshot_attachments") do |dir|
        FastlaneCore::CommandExecutor.execute(command: ["xcrun", "xcresulttool", "export", "attachments", "--path", result_bundle_path, "--output-path", dir])
        manifest = JSON.parse(File.read(File.join(dir, "manifest.json")))
        FileUtils.mkdir_p(SCREENSHOTS_DIR)
        manifest.flat_map { |test| test["attachments"] }.each do |attachment|
          # xcresulttool suggests "<attachment name>_<index>_<UUID>.png"
          name = attachment["suggestedHumanReadableName"][/\A(.+)_\d+_\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\.png\z/, 1]
          next unless name
          FileUtils.cp(File.join(dir, attachment["exportedFileName"]), File.join(SCREENSHOTS_DIR, "#{name}.png"))
        end
      end
    end

    def self.copy(from_path, to_path)
      if FastlaneCore::Globals.verbose?
        UI.success("Copying file '#{from_path}' to '#{to_path}'...")
      else
        UI.success("Copying '#{to_path}'...")
      end
      FileUtils.cp(from_path, to_path)
    end
  end
end
