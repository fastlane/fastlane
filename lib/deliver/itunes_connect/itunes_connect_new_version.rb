module Deliver
  class ItunesConnect < FastlaneCore::ItunesConnect
    # This method creates a new version of your app using the
    # iTunesConnect frontend. This will happen directly after calling
    # this method. 
    # @param app (Deliver::App) the app you want to modify
    # @param version_number (String) the version number as string for 
    # the new version that should be created
    def create_new_version!(app, version_number)
      begin
        current_version = get_live_version(app)

        verify_app(app)
        open_app_page(app)

        if page.has_content?BUTTON_STRING_NEW_VERSION

          if current_version == version_number
            # This means, this version is already live on the App Store
            raise "Version #{version_number} is already created, submitted and released on iTC. Please verify you're using a new version number."
          end

          click_on BUTTON_STRING_NEW_VERSION

          Helper.log.info "Creating a new version (#{version_number})"
          
          all(".fullWidth.nobottom.ng-isolate-scope.ng-pristine").last.set(version_number.to_s)
          click_on "Create"

          while not page.has_content?"Prepare for Submission"
            sleep 1
            Helper.log.debug("Waiting for 'Prepare for Submission'")
          end
        else
          Helper.log.warn "Can not create version #{version_number} on iTunesConnect. Maybe it was already created."

          begin
            created_version = wait_for_elements("input[ng-model='versionInfo.version.value']").first.value
            if created_version != version_number
              update_existing_version_number!(app, version_number)
            end
          rescue => ex
            # Can not fetch the version number of the new version (this happens, when it's e.g. 'Developer Rejected')
            Helper.log.error ex
            unless page.has_content?version_number
              raise "Some other version was created instead of the one you defined ('#{version_number}')."
            end
          end
        end

        true
      rescue => ex
        error_occured(ex)
      end
    end

    def update_existing_version_number!(app, version_number)
      Helper.log.warn "There is already a new version created, which does not match the current version: '#{version_number}'"

      version_input = wait_for_elements("input[ng-model='versionInfo.version.value']").first
      version_input.set version_number
      click_on "Save"

      Helper.log.warn "Changed the version number of the latest version to '#{version_number}'".green
    end
  end
end