module Snapshot
  class DetectValues
    # This is needed as these are more complex default values
    def self.set_additional_default_values
      config = Snapshot.config

      FastlaneCore::Project.detect_projects(config)

      Snapshot.project = FastlaneCore::Project.new(config)

      # Go into the project's folder
      Dir.chdir(File.expand_path("..", Snapshot.project.path)) do
        config.load_configuration_file(Snapshot.snapfile_name)
      end

      Snapshot.project.select_scheme

      # Devices
      unless config[:devices]
        config[:devices] = []

        # We only care about a subset of the simulators
        FastlaneCore::Simulator.all.each do |sim|
          next if sim.name.include?("iPad") and !sim.name.include?("Retina") # we only need one iPad
          next if sim.name.include?("6s") # same screen resolution
          next if sim.name.include?("5s") # same screen resolution

          config[:devices] << sim.name
        end
      end
    end
  end
end
