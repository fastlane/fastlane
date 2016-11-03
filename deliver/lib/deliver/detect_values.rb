module Deliver
  class DetectValues
    def run!(options, skip_params = {})
      find_app_identifier(options)
      find_app(options)
      find_folders(options)
      find_version(options) unless skip_params[:skip_version]
    end

    def find_app_identifier(options)
      return if options[:app_identifier]

      if options[:ipa]
        identifier = FastlaneCore::IpaFileAnalyser.fetch_app_identifier(options[:ipa])
      elsif options[:pkg]
        identifier = FastlaneCore::PkgFileAnalyser.fetch_app_identifier(options[:pkg])
      end

      options[:app_identifier] = identifier if identifier.to_s.length > 0
      options[:app_identifier] ||= UI.input("The Bundle Identifier of your App: ")
    rescue
      UI.user_error!("Could not infer your App's Bundle Identifier")
    end

    def find_app(options)
      search_by = options[:app_identifier]
      search_by = options[:app] if search_by.to_s.length == 0
      app = Spaceship::Application.find(search_by)
      if app
        options[:app] = app
      else
        UI.user_error!("Could not find app with app identifier '#{options[:app_identifier]}' in your iTunes Connect account (#{options[:username]} - Team: #{Spaceship::Tunes.client.team_id})")
      end
    end

    def find_folders(options)
      containing = Helper.fastlane_enabled? ? './fastlane' : '.'
      options[:screenshots_path] ||= File.join(containing, 'screenshots')
      options[:metadata_path] ||= File.join(containing, 'metadata')

      FileUtils.mkdir_p(options[:screenshots_path])
      FileUtils.mkdir_p(options[:metadata_path])
    end

    def find_version(options)
      return if options[:app_version]

      if options[:ipa]
        options[:app_version] ||= FastlaneCore::IpaFileAnalyser.fetch_app_version(options[:ipa])
      elsif options[:pkg]
        options[:app_version] ||= FastlaneCore::PkgFileAnalyser.fetch_app_version(options[:pkg])
      end
    rescue
      UI.user_error!("Could not infer your app's version")
    end
  end
end
