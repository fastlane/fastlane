module Fastlane
  class FastlaneFolder
    FOLDER_NAME = 'fastlane'

    # Path to the fastlane folder containing the Fastfile and other configuration files
    def self.path
      value ||= "./#{FOLDER_NAME}/" if File.directory?("./#{FOLDER_NAME}/")
      value ||= "./.#{FOLDER_NAME}/" if File.directory?("./.#{FOLDER_NAME}/") # hidden folder
      value ||= "./" if File.basename(Dir.getwd) == FOLDER_NAME && File.exist?('Fastfile') # inside the folder
      value ||= "./" if File.basename(Dir.getwd) == ".#{FOLDER_NAME}" && File.exist?('Fastfile') # inside the folder and hidden

      value = nil if Helper.is_test? # this is required, as the tests would use the ./fastlane folder otherwise
      return value
    end

    # Does a fastlane configuration already exist?
    def self.setup?
      return false unless path
      File.exist?(File.join(path, "Fastfile"))
    end

    def self.create_folder!(path = nil)
      path = File.join(path || '.', FOLDER_NAME)
      FileUtils.mkdir_p(path)
      UI.success "Created new folder '#{path}'."
    end
  end
end
