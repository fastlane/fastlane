require 'pty'
require 'shellwords'
require 'plist'

module Snapshot
  class Runner
    attr_accessor :errors

    def work
      self.errors = []

      Helper.log.info "Building and running project - this might take some time...".green

      errors = []
      Snapshot.config[:devices].each do |device|
        Snapshot.config[:languages].each do |language|
          begin
            launch(language, device)
          rescue => ex
            Helper.log.error ex # we should to show right here as well
            errors << ex
          end
        end
      end

      raise errors.join('; ') if errors.count > 0
    end

    def launch(language, device_type)
      screenshots_path = TestCommandGenerator.derived_data_path
      FileUtils.rm_rf(screenshots_path)
      FileUtils.mkdir_p(screenshots_path)

      File.write("/tmp/language.txt", language)

      command = TestCommandGenerator.generate(device_type: device_type)

      Helper.log_alert("#{device_type.name} - #{language}")

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: {
                                                "Touching" => "Running Tests: "
                                              },
                                              error: proc do |output, return_code|
                                                Helper.log.info "cought error... #{return_code}".red
                                                ErrorHandler.handle_test_error(output, return_code)
                                                # no exception raised... that means we need to retry
                                                launch(language, device_type)
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path)
      fetch_screenshots(raw_output, language, device_type)
    end

    def fetch_screenshots(output, language, device_type)
      # The way this works:
      # When the user calls `snapshot` in the UI Tests it actually just does a 
      # long press on the Application (!) which you usually wouldn't do probably
      # We go through all test events and check where we do a long press
      # 
      # Xcode generates a plist file that contains all the events and test results
      # 
      # Once we have all events that apply and the file name of the snapshot we now have to 
      # match them to the actual file name
      # we make use of the test run output we have in the `output` variable
      # This includes something like
      # 
      #   snapshot: [some random text here]
      # 
      # We find all these entries using a regex. The number of events and snapshot output
      # should be the same
      # 
      # We now go ahead and use this information to copy over the screenshot with a meaningful
      # name to the current directory

      Helper.log.info "Collecting screenshots..."
      containing = File.join(TestCommandGenerator.derived_data_path, "Logs", "Test")
      attachments_path = File.join(containing, "Attachments")

      plist_path = Dir[File.join(containing, "*.plist")].last # we clean the folder before each run
      Helper.log.info "Loading up '#{plist_path}'..." #if $verbose
      report = Plist::parse_xml(plist_path)

      activities = []
      report["TestableSummaries"].each do |summary|
        summary["Tests"].each do |test|
          test["Subtests"].each do |subtest|
            subtest["Subtests"].each do |subtest2|
              subtest2["Subtests"].each do |subtest3|
                subtest3["ActivitySummaries"].each do |activity|
                  activities << activity if activity["Title"].include?("Long press Target Application")
                end
              end
            end
          end
        end
      end

      Helper.log.info "Found #{activities.count} screenshots..."

      to_store = [] # contains the names of all the attachments we want to use
      activities.each do |activity|
        # We do care about this, all "Long press Target" events mean screenshots
        attachment_entry = activity["SubActivities"].last # the latest event is fine
        to_store << attachment_entry["Attachments"].last["FileName"]
      end

      Helper.log.info "Found #{to_store.join(', ')}" #if $verbose

      matches = output.scan(/snapshot: (.*)/)
      
      if matches.count != to_store.count
        Helper.log.error "Looks like the number of screenshots (#{to_store.count}) doesn't match the number of names (#{matches.count})"
      end

      matches.each_with_index do |current, index|
        name = current[0]
        filename = to_store[index]

        output_path = "./#{name} - #{language} - #{device_type.name}.png"
        from_path = File.join(attachments_path, filename)
        Helper.log.info "Copying file '#{from_path}' to '#{output_path}'...".green
        FileUtils.cp(from_path, output_path)
      end
    end
  end
end
