module Snapshot
  class SnapshotFile

    # @return (String) The path to the used Deliverfile.
    attr_accessor :path

    # @param path (String) the path to the config file to use (including the file name)
    def initialize(path, config)
      raise "Config file not found at path '#{path}'".red unless File.exists?(path.to_s)

      self.path = path

      @config = config

      eval(File.read(self.path))
    end

    def method_missing(method_sym, *arguments, &block)
      if ["setup", "teardown"].any?{|a| method_sym.to_s.include?a }
        value = nil # this is a block
      else
        value = arguments.first || (block.call if block_given?) # this is either a block or a value
      end

      case method_sym
        when :devices
          raise "Devices has to be an array".red unless value.kind_of?Array
          @config.devices = value
        when :languages
          @config.languages = value
        when :ios_version
          raise "ios_version has to be an String".red unless value.kind_of?String
          @config.ios_version = value
        when :scheme
          raise "scheme has to be an String".red unless value.kind_of?String
          @config.manual_scheme = value
        when :js_file
          raise "js_file has to be an String".red unless value.kind_of?String
          raise "js_file at path '#{value}' not found".red unless File.exists?value
          @config.manual_js_file = File.expand_path(value)
        when :screenshots_path
          raise "screenshots_path has to be an String".red unless value.kind_of?String
          @config.screenshots_path = File.expand_path(value)
        when :build_command
          raise "build_command has to be an String".red unless value.kind_of?String
          @config.build_command = value
        when :build_dir
          raise "build_dir has to be an String".red unless value.kind_of?String
          @config.build_dir = File.expand_path(value)
        when :custom_args
          raise "custom_args has to be an String".red unless value.kind_of?String
          @config.custom_args = value
        when :custom_build_args
          raise "custom_build_args has to be an String".red unless value.kind_of?String
          @config.custom_build_args = value
        when :custom_run_args
          raise "custom_run_args has to be an String".red unless value.kind_of?String
          @config.custom_run_args = value
        when :skip_alpha_removal
          @config.skip_alpha_removal = true
        when :clear_previous_screenshots
          @config.clear_previous_screenshots = true
        when :project_path
          raise "project_path has to be an String".red unless value.kind_of?String

          path = File.expand_path(value)
          if File.exists?path and (path.end_with?".xcworkspace" or path.end_with?".xcodeproj")
            @config.project_path = path
          else
            raise "The given project_path '#{path}' could not be found. Make sure to include the extension as well.".red
          end
        when :html_path
          raise "The `html_path` options was removed from snapshot. The default location is now the screenshots path. Please remove this line from your 'Snapfile'.".red
        # Blocks
        when :setup_for_device_change, :teardown_device, :setup_for_language_change, :teardown_language
          raise "#{method_sym} needs to have a block provided." unless block_given?
          Helper.log.warn("'setup_for_language_change' and 'teardown_language' are deprecated.".yellow) if [:setup_for_language_change, :teardown_language].include?method_sym
          @config.blocks[method_sym] = block
        when :html_title 
          raise "html_title has to be an String".red unless value.kind_of?String
          @config.html_title = value
        else
          Helper.log.error "Unknown method #{method_sym}"
        end
    end
  end
end