require_relative 'upload_metadata'
require_relative 'html_generator'
require_relative 'upload_screenshots'

module Deliver
  class GenerateSummary
    def run(options)
      screenshots = UploadScreenshots.new.collect_screenshots(options)
      UploadMetadata.new.load_from_filesystem(options)
      HtmlGenerator.new.render(options, screenshots, '.')
    end
  end
end
