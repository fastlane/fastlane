require_relative 'ui/ui'

module FastlaneCore
  class FastlaneFolder
    FOLDER_NAME = 'fastlane'

    # Path to the fastlane folder containing the Fastfile and other configuration files
    def self.path
      puts("DEBUG: Dir.getwd = '#{Dir.getwd}'")
      puts("all files in current wd = '#{Dir.glob("*")}'")
      puts("all files in current wd/fastlane = '#{Dir.glob("#{FOLDER_NAME}/*")}'")
      puts("fastlane_folder: 1")
      fastlane_folder_is_directory = File.directory?("./#{FOLDER_NAME}/")
      puts("DEBUG: fastlane_folder_is_directory = '#{fastlane_folder_is_directory}' (File.directory?(./FOLDER_NAME/))")
      
      fastlane_folder_exists_no_trailing_slash = File.directory?("./#{FOLDER_NAME}")
      puts("DEBUG: fastlane_folder_exists_no_trailing_slash = '#{fastlane_folder_exists_no_trailing_slash}' (File.directory?(./FOLDER_NAME))")
      fastlane_folder_exists_no_slashes_at_all = File.directory?("#{FOLDER_NAME}")
      puts("DEBUG: fastlane_folder_exists_no_slashes_at_all = '#{fastlane_folder_exists_no_slashes_at_all}' (File.directory?(FOLDER_NAME))")
      fastlane_folder_is_a_file = File.file?("./#{FOLDER_NAME}/")
      puts("DEBUG: fastlane_folder_is_a_file = '#{fastlane_folder_is_a_file}' (File.file?(./FOLDER_NAME/))")
      fastlane_folder_exists = File.exist?('./#{FOLDER_NAME}/')
      puts("DEBUG: fastlane_folder_exists = '#{fastlane_folder_exists}' (File.exist?(./FOLDER_NAME/))")
      fastfile_exists_in_fastlane_folder = File.exist?('./#{FOLDER_NAME}/Fastfile')
      puts("DEBUG: fastfile_exists_in_fastlane_folder = '#{fastfile_exists_in_fastlane_folder}' (File.exist?(./FOLDER_NAME/Fastfile))")
      
      value ||= "./#{FOLDER_NAME}/" if fastlane_folder_is_directory
      puts("fastlane_folder: 2: '#{value}'")
      value ||= "./.#{FOLDER_NAME}/" if File.directory?("./.#{FOLDER_NAME}/") # hidden folder
      puts("fastlane_folder: 3: '#{value}'")
      value ||= "./" if File.basename(Dir.getwd) == FOLDER_NAME && File.exist?('Fastfile.swift') # inside the folder
      puts("fastlane_folder: 4: '#{value}'")
      value ||= "./" if File.basename(Dir.getwd) == ".#{FOLDER_NAME}" && File.exist?('Fastfile.swift') # inside the folder and hidden
      puts("fastlane_folder: 5: '#{value}'")
      value ||= "./" if File.basename(Dir.getwd) == FOLDER_NAME && File.exist?('Fastfile') # inside the folder
      puts("fastlane_folder: 6: '#{value}'")
      value ||= "./" if File.basename(Dir.getwd) == ".#{FOLDER_NAME}" && File.exist?('Fastfile') # inside the folder and hidden
      puts("fastlane_folder: 7: '#{value}'")
      puts("DEBUG: self.path = '#{value}', Dir.getwd = '#{Dir.getwd}'")
      return value
    end

    # path to the Swift runner executable if it has been built
    def self.swift_runner_path
      return File.join(self.path, 'FastlaneRunner')
    end

    def self.swift?
      return false unless self.fastfile_path
      return self.fastfile_path.downcase.end_with?(".swift")
    end

    def self.swift_folder_path
      return File.join(self.path, 'swift')
    end

    def self.swift_runner_project_path
      return File.join(self.swift_folder_path, 'FastlaneSwiftRunner', 'FastlaneSwiftRunner.xcodeproj')
    end

    def self.swift_runner_built?
      swift_runner_path = self.swift_runner_path
      if swift_runner_path.nil?
        return false
      end

      return File.exist?(swift_runner_path)
    end

    # Path to the Fastfile inside the fastlane folder. This is nil when none is available
    def self.fastfile_path
      puts("fastfile_path 0: Dir.getwd = '#{Dir.getwd}'")
      
      return nil if self.path.nil?

      puts("fastfile_path 1: Fastfile.swift: Dir.getwd = '#{Dir.getwd}'")
      
      # Check for Swift first, because Swift is #1
      path = File.join(self.path, 'Fastfile.swift')
      return path if File.exist?(path)

      puts("fastfile_path 2: Fastfile: Dir.getwd = '#{Dir.getwd}'")
      
      path = File.join(self.path, 'Fastfile')
      return path if File.exist?(path)
      
      puts("fastfile_path 3: nil")
      return nil
    end

    # Does a fastlane configuration already exist?
    def self.setup?
      return false unless self.fastfile_path
      File.exist?(self.fastfile_path)
    end

    def self.create_folder!(path = nil)
      path = File.join(path || '.', FOLDER_NAME)
      return if File.directory?(path) # directory is already there
      UI.user_error!("Found a file called 'fastlane' at path '#{path}', please delete it") if File.exist?(path)
      FileUtils.mkdir_p(path)
      UI.success("Created new folder '#{path}'.")
    end
  end
end
