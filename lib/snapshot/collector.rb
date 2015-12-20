module Snapshot
  # Responsible for collecting the generated screenshots and copying them over to the output directory
  class Collector
    def self.fetch_screenshots(output, language, device_type, launch_arguments_index)
      # Documentation about how this works in the project README
      containing = File.join(TestCommandGenerator.derived_data_path, "Logs", "Test")
      attachments_path = File.join(containing, "Attachments")

      to_store = attachments(containing)
      matches = output.scan(/snapshot: (.*)/)

      if matches.count != to_store.count
        Helper.log.error "Looks like the number of screenshots (#{to_store.count}) doesn't match the number of names (#{matches.count})"
      end

      matches.each_with_index do |current, index|
        name = current[0]
        filename = to_store[index]

        language_folder = File.join(Snapshot.config[:output_directory], language)
        FileUtils.mkdir_p(language_folder)

        device_name = device_type.delete(" ")
        components = [device_name, launch_arguments_index, name].delete_if { |a| a.to_s.length == 0 }

        output_path = File.join(language_folder, components.join("-") + ".png")
        from_path = File.join(attachments_path, filename)
        if $verbose
          Helper.log.info "Copying file '#{from_path}' to '#{output_path}'...".green
        else
          Helper.log.info "Copying '#{output_path}'...".green
        end
        FileUtils.cp(from_path, output_path)
      end
    end

    def self.attachments(containing)
      Helper.log.info "Collecting screenshots..."

      plist_path = Dir[File.join(containing, "*.plist")].last # we clean the folder before each run
      Helper.log.info "Loading up '#{plist_path}'..." if $verbose
      report = Plist.parse_xml(plist_path)

      to_store = [] # contains the names of all the attachments we want to use
      report["TestableSummaries"].each do |summary|
        (summary["Tests"] || []).each do |test|
          (test["Subtests"] || []).each do |subtest|
            (subtest["Subtests"] || []).each do |subtest2|
              (subtest2["Subtests"] || []).each do |subtest3|
                (subtest3["ActivitySummaries"] || []).each do |activity|
                  # We now check if it's the rotation gesture, because that's the only thing we care about
                  if activity["Title"] == "Set device orientation to Unknown"
                    to_store << activity["Attachments"].last["FileName"]
                  end
                end
              end
            end
          end
        end
      end

      Helper.log.info "Found #{to_store.count} screenshots..."
      Helper.log.info "Found #{to_store.join(', ')}" if $verbose
      return to_store
    end
  end
end
