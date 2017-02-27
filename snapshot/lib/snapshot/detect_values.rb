module Snapshot
  class DetectValues
    # This is needed as these are more complex default values
    def self.set_additional_default_values
      config = Snapshot.config

      # First, try loading the Snapfile from the current directory
      configuration_file_path = File.expand_path(Snapshot.snapfile_name)
      config.load_configuration_file(Snapshot.snapfile_name)

      # Detect the project
      FastlaneCore::Project.detect_projects(config)
      Snapshot.project = FastlaneCore::Project.new(config)

      # Go into the project's folder, as there might be a Snapfile there
      Dir.chdir(File.expand_path("..", Snapshot.project.path)) do
        unless File.expand_path(Snapshot.snapfile_name) == configuration_file_path
          config.load_configuration_file(Snapshot.snapfile_name)
        end
      end

      Snapshot.project.select_scheme(preferred_to_include: "UITests")

      # Devices
      unless config[:devices]
        config[:devices] = []

        # We only care about a subset of the simulators
        all_simulators = FastlaneCore::Simulator.all
        all_simulators.each do |sim|
          # Filter iPads, we only want the following simulators
          # Xcode 7:
          #   ["iPad Pro", "iPad Air"]
          # Xcode 8:
          #   ["iPad Pro (9.7 Inch)", "iPad Pro (12.9 Inch)"]
          #
          # Full list: ["iPad 2", "iPad Retina", "iPad Air", "iPad Air 2", "iPad Pro"]
          next if sim.name.include?("iPad 2")
          next if sim.name.include?("iPad Retina")
          next if sim.name.include?("iPad Air 2")
          # In Xcode 8, we only need iPad Pro 9.7 inch, not the iPad Air
          next if all_simulators.any? { |a| a.name.include?("9.7 inch") } && sim.name.include?("iPad Air")

          # Filter iPhones
          # Full list: ["iPhone 4s", "iPhone 5", "iPhone 5s", "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus"]
          next if sim.name.include?("6s") # same screen resolution as iPhone 6, or iPhone 6s Plus
          next if sim.name.include?("5s") # same screen resolution as iPhone 5

          next if sim.name.include?("Apple TV")

          config[:devices] << sim.name
        end
      end
    end
  end
end
