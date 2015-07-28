module Deliver
  class Testflight

    # Uploads a new build to Apple TestFlight
    # @param ipa_path (String) a path to the IPA to upload
    # @param app_id (String) optional, the app ID
    # @param skip_deploy (boolean) Should the submission be skipped? 
    def self.upload!(ipa_path, app_id, skip_deploy)
      ItunesTransporter.hide_transporter_output

      app_identifier = IpaFileAnalyser.fetch_app_identifier(ipa_path)
      app_identifier ||= ENV["TESTFLIGHT_APP_IDENTITIFER"] || ask("Could not automatically find the app identifier, please enter the app's bundle identifier: ")
      app_id ||= (FastlaneCore::ItunesSearchApi.fetch_by_identifier(app_identifier)['trackId'] rescue nil)
      app_id ||= (FastlaneCore::ItunesConnect.new.find_apple_id(app_identifier) rescue nil)
      app_id ||= ENV["TESTFLIGHT_APPLE_ID"] || ask("Could not automatically find the app ID, please enter it here (e.g. 956814360): ")
      strategy = (skip_deploy ? Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD : Deliver::IPA_UPLOAD_STRATEGY_BETA_BUILD)

      Helper.log.info "Ready to upload new build to TestFlight (#{app_identifier} - #{app_id})".green

      # Got everything to ready to deploy
      app = App.new(app_identifier: app_identifier, apple_id: app_id)
      ipa = IpaUploader.new(app, '/tmp/', ipa_path, strategy)
      result = ipa.upload!
      raise "Error distributing new beta version!".red unless result == true
    end
  end
end