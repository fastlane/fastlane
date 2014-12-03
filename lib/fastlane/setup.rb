module FastLane
  class Setup
    def run
      raise "Fastlane already set up at path #{folder}".yellow if FastlaneFolder.setup?

      FastlaneFolder.create_folder!
      copy_existing_files
      generate_fastfile
    end

    def copy_existing_files
      files = ['Deliverfile', 'Snapfile']
      files.each do |current|
        if File.exists?current
          file_name = File.basename(current)
          to_path = File.join(folder, file_name)
          Helper.log.info "Moving '#{current}' to '#{to_path}'".green
          FileUtils.cp(current, to_path)
        end
      end
    end

    def generate_fastfile
      template = File.read("#{gem_path}/lib/assets/FastfileTemplate")
      # TODO: modify code based on existing files
      path = File.join(folder, FastlaneFolder::FOLDER_NAME)
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your own deployment lanes."
    end

    def folder
      FastlaneFolder.path
    end

    private
      def gem_path
        if not Helper.is_test? and Gem::Specification::find_all_by_name('fastlane').any?
          return Gem::Specification.find_by_name('fastlane').gem_dir
        else
          return './'
        end
      end
  end
end