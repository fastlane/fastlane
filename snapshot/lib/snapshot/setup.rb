require_relative 'module'

module Snapshot
  class Setup
    # This method will take care of creating a Snapfile and other necessary files
    def self.create(path, is_swift_fastfile: false, print_instructions_on_failure: false)
      # First generate all the names & paths
      if is_swift_fastfile
        template_path = "#{Snapshot::ROOT}/lib/assets/SnapfileTemplate.swift"
        snapfile_path = File.join(path, 'Snapfile.swift')
      else
        template_path = "#{Snapshot::ROOT}/lib/assets/SnapfileTemplate"
        snapfile_path = File.join(path, 'Snapfile')
      end
      snapshot_helper_filename = "SnapshotHelperXcode8.swift"
      if Helper.xcode_at_least?("9.0")
        snapshot_helper_filename = "SnapshotHelper.swift"
      end

      if File.exist?(snapfile_path)
        if print_instructions_on_failure
          print_instructions(snapshot_helper_filename: snapshot_helper_filename)
          return
        else
          UI.user_error!("Snapfile already exists at path '#{snapfile_path}'. Run 'fastlane snapshot' to generate screenshots.")
        end
      end

      File.write(snapfile_path, File.read(template_path))

      # ensure that upgrade is cause when going from 8 to 9
      File.write(File.join(path, snapshot_helper_filename), File.read("#{Snapshot::ROOT}/lib/assets/#{snapshot_helper_filename}"))

      puts("✅  Successfully created #{snapshot_helper_filename} '#{File.join(path, snapshot_helper_filename)}'".green)
      puts("✅  Successfully created new Snapfile at '#{snapfile_path}'".green)
      puts("-------------------------------------------------------".yellow)
      print_instructions(snapshot_helper_filename: snapshot_helper_filename)
    end

    def self.print_instructions(snapshot_helper_filename: nil)
      puts("Open your Xcode project and make sure to do the following:".yellow)
      puts("1) Add a new UI Test target to your project".yellow)
      puts("2) Add the ./fastlane/#{snapshot_helper_filename} to your UI Test target".yellow)
      puts("   You can move the file anywhere you want".yellow)
      puts("3) Call `setupSnapshot(app)` when launching your app".yellow)
      puts("")
      puts("  let app = XCUIApplication()")
      puts("  setupSnapshot(app)")
      puts("  app.launch()")
      puts("")
      puts("4) Add `snapshot(\"0Launch\")` to wherever you want to trigger screenshots".yellow)
      puts("5) Add a new Xcode scheme for the newly created UITest target".yellow)
      puts("6) Add a Check to enable the `Shared` box of the newly created scheme".yellow)
      puts("")
      puts("More information: https://docs.fastlane.tools/getting-started/ios/screenshots/".green)
    end
  end
end
