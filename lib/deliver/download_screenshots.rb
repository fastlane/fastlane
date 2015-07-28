module Deliver
  class DownloadScreenshots
    def self.run(app, path)
      begin
        Helper.log.info "Downloading all existing screenshots...".green
        ItunesConnect.new.download_existing_screenshots(app, path)
        Helper.log.info "Successfully downloaded all existing screenshots".green
      rescue Exception => ex
        Helper.log.error ex
        Helper.log.error "Couldn't download already existing screenshots from iTunesConnect.".red
      end
    end
  end
end