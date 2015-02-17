require 'fastlane_core/developer_center/developer_center'

module FastlaneCore
  class DeveloperCenter
    APPS_URL = "https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action"
    CREATE_APP_URL = "https://developer.apple.com/account/ios/identifiers/bundle/bundleCreate.action"

    def run
      create_new_app
    rescue => ex
      error_occured(ex)
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{@config[:app_name]}' already exists, nothing to do on the Dev Center".green
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{@config[:app_name]}' on the Apple Dev Center".green
        visit CREATE_APP_URL
        wait_for_elements("*[name='appIdName']").first.set @config[:app_name]
        wait_for_elements("*[name='explicitIdentifier']").first.set @config[:bundle_identifier]
        click_next

        sleep 3 # sometimes this takes a while and we don't want to timeout

        wait_for_elements("form[name='bundleSubmit']") # this will show the summary of the given information
        click_next

        sleep 3 # sometimes this takes a while and we don't want to timeout

        wait_for_elements(".ios.bundles.confirmForm.complete")
        click_on "Done"

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        ENV["CREATED_NEW_APP_ID"] = Time.now.to_s

        Helper.log.info "Finished creating new app '#{@config[:app_name]}' on the Dev Center".green
      end

      return true
    end


    private
      def app_exists?
        visit APPS_URL

        wait_for_elements("td[aria-describedby='grid-table_identifier']").each do |app|
          identifier = app['title']

          return true if identifier.to_s == @config[:bundle_identifier].to_s
        end

        false
      end

      def click_next
        wait_for_elements('.button.small.blue.right.submit').last.click
      end
  end
end
