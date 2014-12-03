module FastLane
  class FastlaneFolder
    FOLDER_NAME = 'fastlane'
    
    def self.path
      return "./#{FOLDER_NAME}/" if File.directory?"./#{FOLDER_NAME}/"
      return "./.#{FOLDER_NAME}/" if File.directory?"./.#{FOLDER_NAME}/" # hidden folder
      return nil
    end

    def self.setup?
      return false unless self.path
      return File.exists?self.path
    end

    def self.create_folder!
      path = "./#{FOLDER_NAME}"
      FileUtils.mkdir_p path
      Helper.log.info "Created new folder '#{path}'. You can rename it to '.#{FOLDER_NAME}' to hide it.".green
    end
  end
end