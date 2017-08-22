module Snapshot
  class Setup
    # This method will take care of creating a Snapfile and other necessary files
    def self.create(path)
      snapfile_path = File.join(path, 'Snapfile')

      if File.exist?(snapfile_path)
        UI.user_error!("Snapfile already exists at path '#{snapfile_path}'. Run 'fastlane snapshot' to generate screenshots.")
      end

      File.write(snapfile_path, File.read("#{Snapshot::ROOT}/lib/assets/SnapfileTemplate"))
      snapshot_helper_filename = "SnapshotHelperXcode8.swift"
      if Helper.xcode_at_least?("9.0")
        snapshot_helper_filename = "SnapshotHelper.swift"
      end

      # ensure that upgrade is cause when going from 8 to 9
      File.write(File.join(path, snapshot_helper_filename), File.read("#{Snapshot::ROOT}/lib/assets/#{snapshot_helper_filename}"))

      puts "✅  Successfully created #{snapshot_helper_filename} '#{File.join(path, snapshot_helper_filename)}'".green
      puts "✅  Successfully created new Snapfile at '#{snapfile_path}'".green

      puts "-------------------------------------------------------".yellow
      puts "Open your Xcode project and make sure to do the following:".yellow
      puts "1) Add a new UI Test target to your project".yellow
      puts "2) Add the ./fastlane/#{snapshot_helper_filename} to your UI Test target".yellow
      puts "   You can move the file anywhere you want".yellow
      puts "3) Call `setupSnapshot(app)` when launching your app".yellow
      puts ""
      puts "  let app = XCUIApplication()"
      puts "  setupSnapshot(app)"
      puts "  app.launch()"
      puts ""
      puts "4) Add `snapshot(\"0Launch\")` to wherever you want to create the screenshots".yellow
      puts ""
      puts "More information on GitHub: https://github.com/fastlane/fastlane/tree/master/snapshot".green
    end
  end
end
