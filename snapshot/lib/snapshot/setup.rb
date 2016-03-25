module Snapshot
  class Setup
    # This method will take care of creating a Snapfile and other necessary files
    def self.create(path)
      snapfile_path = File.join(path, 'Snapfile')

      if File.exist?(snapfile_path)
        UI.user_error!("Snapfile already exists at path '#{snapfile_path}'. Run 'snapshot' to use snapshot.")
      end

      gem_path = Helper.gem_path("snapshot")
      File.write(snapfile_path, File.read("#{gem_path}/lib/assets/SnapfileTemplate"))
      File.write(File.join(path, 'SnapshotHelper.swift'), File.read("#{gem_path}/lib/assets/SnapshotHelper.swift"))

      puts "Successfully created SnapshotHelper.swift '#{File.join(path, 'SnapshotHelper.swift')}'".green
      puts "Successfully created new Snapfile at '#{snapfile_path}'".green

      puts "-------------------------------------------------------".yellow
      puts "Open your Xcode project and make sure to do the following:".yellow
      puts "1) Add the ./fastlane/SnapshotHelper.swift to your UI Test target".yellow
      puts "   You can move the file anywhere you want".yellow
      puts "2) Call `setupSnapshot(app)` when launching your app".yellow
      puts ""
      puts "  let app = XCUIApplication()"
      puts "  setupSnapshot(app)"
      puts "  app.launch()"
      puts ""
      puts "3) Add `snapshot(\"0Launch\")` to wherever you want to create the screenshots".yellow
      puts ""
      puts "More information on GitHub: https://github.com/fastlane/fastlane/tree/master/snapshot".green
    end
  end
end
