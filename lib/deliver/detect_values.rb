module Deliver
  class DetectValues
    def run!(options)
      find_app(options)
      find_folders(options)
    end

    def find_app(options)
      search_by = options[:app_identifier]
      search_by = options[:app] if search_by.to_s.length == 0
      options[:app] = Spaceship::Application.find(search_by)
    end

    def find_folders(options)
      containing = Helper.fastlane_enabled? ? './fastlane' : '.'
      options[:screenshots_folder] ||= File.join(containing, 'screenshots')
      options[:metadata_folder] ||= File.join(containing, 'metadata')
    end
  end
end
