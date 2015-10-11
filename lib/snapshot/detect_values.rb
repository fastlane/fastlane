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
        config[:devices] = Simulator.all.collect(&:name)
      end
    end
  end
end
