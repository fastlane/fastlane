module Deliver
  class DownloadScreenshots
    def self.run(options, path)
      Helper.log.info "Downloading all existing screenshots...".green
      download(options, path)
      Helper.log.info "Successfully downloaded all existing screenshots".green
    rescue Exception => ex
      Helper.log.error ex
      Helper.log.error "Couldn't download already existing screenshots from iTunesConnect.".red
    end

    def self.download(options, folder_path)
      languages = JSON.parse(File.read(File.join(Helper.gem_path('spaceship'), "lib", "assets", "languageMapping.json")))
      v = options[:app].latest_version

      v.screenshots.each do |language, screenshots|
        screenshots.each do |screenshot|
          file_name = [screenshot.sort_order, screenshot.device_type, screenshot.original_file_name].join("_")
          Helper.log.info "Downloading existing screenshot '#{file_name}' of device type: '#{screenshot.device_type}'"

          containing_folder = File.join(folder_path, "screenshots", screenshot.language.to_language_code)
          begin
            FileUtils.mkdir_p containing_folder
          rescue
            # if it's already there
          end
          path = File.join(containing_folder, file_name)
          File.write(path, open(screenshot.url).read)
        end
      end
    end
  end
end
