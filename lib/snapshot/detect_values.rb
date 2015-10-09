module Snapshot
  class DetectValues
    # This is needed as these are more complex default values
    def self.set_additional_default_values
      config = Snapshot.config

      detect_projects

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

    def self.detect_projects
      if Snapshot.config[:workspace].to_s.length == 0
        workspace = Dir["./*.xcworkspace"]
        if workspace.count > 1
          puts "Select Workspace: "
          Snapshot.config[:workspace] = choose(*(workspace))
        else
          Snapshot.config[:workspace] = workspace.first # this will result in nil if no files were found
        end
      end

      if Snapshot.config[:workspace].to_s.length == 0 and Snapshot.config[:project].to_s.length == 0
        project = Dir["./*.xcodeproj"]
        if project.count > 1
          puts "Select Project: "
          Snapshot.config[:project] = choose(*(project))
        else
          Snapshot.config[:project] = project.first # this will result in nil if no files were found
        end
      end
    end
  end
end
