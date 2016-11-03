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

    # Path to the Fastfile inside the fastlane folder. This is nil when none is available
    def self.fastfile_path
      path = File.join(self.path || '.', 'Fastfile')
      return path if File.exist?(path)
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
      UI.success "Created new folder '#{path}'."
    end

    # Returns an array of symbols for the available lanes for the Fastfile
    # This doesn't actually use the Fastfile parser, but only
    # the available lanes. This way it's much faster
    # Use this only if performance is :key:
    def self.available_lanes
      return [] if fastfile_path.nil?
      output = `cat #{fastfile_path.shellescape} | grep \"^\s*lane \:\" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}'`
      return output.strip.split(" ").collect(&:to_sym)
    end
  end
end
