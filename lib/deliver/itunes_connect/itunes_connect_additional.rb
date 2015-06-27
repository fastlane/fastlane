module Deliver
  class ItunesConnect < FastlaneCore::ItunesConnect
    # This file sets additional information like copyright and age rating

    def set_copyright!(app, text)
      verify_app(app)
      open_app_page(app)

      Helper.log.info "Setting copyright to '#{text}'".green

      first("input[ng-model='versionInfo.copyright.value']").set text
      
      (click_on "Save" rescue nil) # if nothing has changed, there is no back button and we don't care
    rescue => ex
      error_occured(ex)
    end

    def set_app_review_information!(app, hash)
      verify_app(app)
      open_app_page(app)

      Helper.log.info "Setting review information: #{hash}"

      first("input[ng-model='versionInfo.appReviewInfo.firstName.value']").set                     hash[:first_name]
      first("input[ng-model='versionInfo.appReviewInfo.lastName.value']").set                      hash[:last_name]
      first("input[ng-model='versionInfo.appReviewInfo.phoneNumber.value']").set                   hash[:phone_number]
      first("input[ng-model='versionInfo.appReviewInfo.emailAddress.value']").set                  hash[:email_address]
      first("input[ng-model='versionInfo.appReviewInfo.userName.value']").set                      hash[:demo_user]
      first("input[ng-model='versionInfo.appReviewInfo.password.value']").set                      hash[:demo_password]
      first("span[ng-show='versionInfo.appReviewInfo.reviewNotes.isEditable'] > * > textarea").set hash[:notes]

      (click_on "Save" rescue nil) # if nothing has changed, there is no back button and we don't care

      Helper.log.info "Successfully saved review information".green
    rescue => ex
      error_occured(ex)
    end

    def set_release_after_approval!(app, automatic_release)
      verify_app(app)
      open_app_page(app)

      Helper.log.info "Setting automatic release to '#{automatic_release}'".green

      radio_value = automatic_release ? "true" : "false"

      # Find the correct radio button
      first("div[itc-radio='versionInfo.releaseOnApproval.value'][radio-value='#{radio_value}'] > * > a").click

      (click_on "Save" rescue nil) # if nothing has changed, there is no back button and we don't care
    rescue => ex
      error_occured(ex)
    end

    def set_categories!(app, primary, secondary, primarySubs, secondarySubs)
      verify_app(app)
      open_app_page(app)

      Helper.log.info "Setting primary/secondary category.'".green

      set_category_dropdown(primary, "primaryCategory")

      set_category_dropdown(secondary, "secondaryCategory")

      if primarySubs
        if primarySubs.length > 0
          set_category_dropdown(primarySubs[0], "primaryFirstSubCategory")
        end
        if primarySubs.length > 1
          set_category_dropdown(primarySubs[1], "primarySecondSubCategory")
        end
      end

      if secondarySubs
        if secondarySubs.length > 0
          set_category_dropdown(secondarySubs[0], "secondaryFirstSubCategory")
        end
        if secondarySubs.length > 1
          set_category_dropdown(secondarySubs[1], "secondarySecondSubCategory")
        end
      end

      (click_on "Save" rescue nil) # if nothing has changed, there is no back button and we don't care
    rescue => ex
      error_occured(ex)
    end

    private

    def set_category_dropdown(value, catId)
      if value
        all("select[ng-model='versionInfo.#{catId}.value'] > option").each do |category|
          if category.text.to_s == value.to_s
            category.select_option
            value = nil
            break
          end
        end
        if value
          Helper.log.info "Could not find #{catId} '#{value}'. Make sure it's available on iTC".red
        end
      end
    end
  end
end