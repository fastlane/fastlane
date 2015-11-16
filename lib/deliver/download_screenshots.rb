module Deliver
  class DownloadScreenshots
    def self.run(options, path)
      Helper.log.info "Downloading all existing screenshots...".green
      download(options, path)
      Helper.log.info "Successfully downloaded all existing screenshots".green
    rescue => ex
      Helper.log.error ex
      Helper.log.error "Couldn't download already existing screenshots from iTunesConnect.".red
    end

    def self.download(options, folder_path)
      v = options[:app].latest_version

      v.screenshots.each do |language, screenshots|
        screenshots.each do |screenshot|
          file_name = [screenshot.sort_order, screenshot.device_type, screenshot.sort_order].join("_")
          original_file_extension = File.basename(screenshot.original_file_name)
          file_name += "." + original_file_extension

          Helper.log.info "Downloading existing screenshot '#{file_name}'"

          containing_folder = File.join(folder_path, screenshot.language)
          begin
            FileUtils.mkdir_p(containing_folder)
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
