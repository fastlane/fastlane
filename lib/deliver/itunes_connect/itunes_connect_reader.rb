module Deliver
  # For all the information reading (e.g. version number)
  class ItunesConnect < FastlaneCore::ItunesConnect
    # This method will fetch the current status ({Deliver::App::AppStatus})
    # of your app and return it.
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_app_status(app)
      begin
        verify_app(app)

        status = (get_app_information(app)['status'] rescue nil)

        return Deliver::App::AppStatus::PREPARE_FOR_SUBMISSION if status == 'prepareForUpload'
        return Deliver::App::AppStatus::PREPARE_FOR_SUBMISSION if status == 'devRejected' # that's the same thing
        return Deliver::App::AppStatus::WAITING_FOR_REVIEW if status == 'waitingForReview'
        return Deliver::App::AppStatus::READY_FOR_SALE if status == 'readyForSale'
        return Deliver::App::AppStatus::PENDING_DEVELOPER_RELEASE if status == 'pendingDeveloperRelease'

        Helper.log.info "App Status '#{status}' not yet implemented, please submit an issue on GitHub"
        return nil
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # This method will fetch the version number of the currently live version
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_live_version(app)
      begin
        verify_app(app)

        return (get_app_information(app)['version']['value'] rescue nil)
      rescue => ex
        error_occured(ex)
      end
    end
  end
end