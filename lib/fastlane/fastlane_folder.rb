module Fastlane
  class FastlaneFolder
    FOLDER_NAME = 'fastlane'

    # Path to the fastlane folder containing the Fastfile and other configuration files
    def self.path
      return "./#{FOLDER_NAME}/" if File.directory?("./#{FOLDER_NAME}/")
      return "./.#{FOLDER_NAME}/" if File.directory?("./.#{FOLDER_NAME}/") # hidden folder
      return './' if File.basename(Dir.getwd) == FOLDER_NAME && File.exist?('Fastfile') # inside the folder
      return './' if File.basename(Dir.getwd) == ".#{FOLDER_NAME}" && File.exist?('Fastfile') # inside the folder and hidden
      nil
    end

    # Does a fastlane configuration already exist? 
    def self.setup?
      return false unless path
      File.exist?(File.join(path, "Fastfile"))
    end

    def self.create_folder!(path = nil)
      path = File.join(path || '.', FOLDER_NAME)
      FileUtils.mkdir_p(path)
      Helper.log.info "Created new folder '#{path}'.".green
    end
  end
end
