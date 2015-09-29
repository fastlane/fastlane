module Deliver
  class DetectValues
    def run!(options)
      find_app_identifier(options)
      find_app(options)
      find_folders(options)
    end

    def find_app_identifier(options)
      return if options[:app_identifier]

      if options[:ipa]
        identifier = FastlaneCore::IpaFileAnalyser.fetch_app_identifier(options[:ipa])
        options[:app_identifier] = identifier if identifier.to_s.length > 0
      end

      options[:app_identifier] ||= ask("The Bundle Identifier of your App: ")
    end

    def find_app(options)
      search_by = options[:app_identifier]
      search_by = options[:app] if search_by.to_s.length == 0
      options[:app] = Spaceship::Application.find(search_by)
    end

    def find_folders(options)
      containing = Helper.fastlane_enabled? ? './fastlane' : '.'
      options[:screenshots_path] ||= File.join(containing, 'screenshots')
      options[:metadata_path] ||= File.join(containing, 'metadata')

      FileUtils.mkdir_p(options[:screenshots_path])
      FileUtils.mkdir_p(options[:metadata_path])
    end
  end
end
