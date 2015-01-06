module Fastlane
  class FastlaneFolder
    FOLDER_NAME = 'fastlane'
    
    def self.path
      return "./#{FOLDER_NAME}/" if File.directory?"./#{FOLDER_NAME}/"
      return "./.#{FOLDER_NAME}/" if File.directory?"./.#{FOLDER_NAME}/" # hidden folder
      return "./" if File.basename(Dir.getwd) == FOLDER_NAME and File.directory?"../#{FOLDER_NAME}/" # inside the folder
      return "./" if File.basename(Dir.getwd) == FOLDER_NAME and File.directory?"../.#{FOLDER_NAME}/" # inside the folder and hidden
      return nil
    end

    def self.setup?
      return false unless self.path
      return File.exists?self.path
    end

    def self.create_folder!
      path = "./#{FOLDER_NAME}"
      FileUtils.mkdir_p path
      Helper.log.info "Created new folder '#{path}'.".green
    end
  end
end