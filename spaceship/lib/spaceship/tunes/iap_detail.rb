module Spaceship
  module Tunes
    class IAPDetail < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # @return (Integer) the IAP id
      attr_accessor :purchase_id

      # @return (Bool) if it is a news subscription
      attr_accessor :is_news_subscription

      # @return (String) the IAP Referencename
      attr_accessor :reference_name

      # @return (String) the IAP Product-Id
      attr_accessor :product_id

      # @return (String) free trial period
      attr_accessor :subscription_free_trial

      # @return (String) subscription duration
      attr_accessor :subscription_duration

      # @return (Bool) Cleared for sale flag
      attr_accessor :cleared_for_sale

      attr_accessor :review_screenshot

      # @return (String) the notes for the review team
      attr_accessor :review_notes

      # @return (Hash) subscription pricing target
      attr_accessor :subscription_price_target

      attr_mapping({
        'adamId' => :purchase_id,
        'referenceName.value' => :reference_name,
        'productId.value' => :product_id,
        'isNewsSubscription' => :is_news_subscription,
        'pricingDurationType.value' => :subscription_duration,
        'freeTrialDurationType.value' => :subscription_free_trial,
        'clearedForSale.value' => :cleared_for_sale
      })

      class << self
        def factory(attrs)
          return self.new(attrs)
        end
      end

      # @return (Hash) Hash of languages
      # @example: {
      #   'de-DE': {
      #     name: "Name shown in AppStore",
      #     description: "Description of the In app Purchase"
      #
      #   }
      # }
      def versions
        parsed_versions = {}
        raw_versions = raw_data["versions"].first["details"]["value"]
        raw_versions.each do |localized_version|
          language = localized_version["value"]["localeCode"]
          parsed_versions[language.to_sym] = {
            name: localized_version["value"]["name"]["value"],
            description: localized_version["value"]["description"]["value"]
          }
        end
        return parsed_versions
      end

      # @return (Array) pricing intervals
      # @example:
      #  [
      #    {
      #      country: "WW",
      #      begin_date: nil,
      #      end_date: nil,
      #      tier: 1
      #    }
      #  ]
      def pricing_intervals
        parsed_intervals = []
        raw_data["pricingIntervals"].each do |interval|
          parsed_intervals << {
            tier: interval["value"]["tierStem"].to_i,
            begin_date: interval["value"]["priceTierEffectiveDate"],
            end_date: interval["value"]["priceTierEndDate"],
            grandfathered: interval["value"]["grandfathered"],
            country: interval["value"]["country"]
          }
        end
        return parsed_intervals
      end

      # @return (String) Human Readable type of the purchase
      def type
        Tunes::IAPType.get_from_string(raw_data["addOnType"])
      end

      # @return (String) Human Readable status of the purchase
      def status
        Tunes::IAPStatus.get_from_string(raw_data["versions"].first["status"])
      end

      # Saves the current In-App-Purchase
      def save!
        # Transform localization versions back to original format.
        versions_array = []
        versions.each do |language, value|
          versions_array << {
                    value: {
                      description: { value: value[:description] },
                      name: { value: value[:name] },
                      localeCode: language.to_s
                    }
          }
        end

        raw_data.set(["versions"], [{ reviewNotes: @review_notes, details: { value: versions_array } }])

        # transform pricingDetails
        intervals_array = []
        pricing_intervals.each do |interval|
          intervals_array << {
            value: {
              tierStem: interval[:tier],
              priceTierEffectiveDate: interval[:begin_date],
              priceTierEndDate: interval[:end_date],
              country: interval[:country] || "WW",
              grandfathered: interval[:grandfathered]
            }
          }
        end

        if subscription_price_target
          intervals_array = []
          pricing_calculator = client.iap_subscription_pricing_target(app_id: application.apple_id, purchase_id: purchase_id, currency: subscription_price_target[:currency], tier: subscription_price_target[:tier])
          pricing_calculator.each do |language_code, value|
            intervals_array << {
              value: {
                tierStem: value["tierStem"],
                priceTierEffectiveDate: value["priceTierEffectiveDate"],
                priceTierEndDate: value["priceTierEndDate"],
                country: language_code,
                grandfathered: { value: "FUTURE_NONE" }
              }
            }
          end

        end

        raw_data.set(["pricingIntervals"], intervals_array)

        if @review_screenshot
          # Upload Screenshot
          upload_file = UploadFile.from_path @review_screenshot
          screenshot_data = client.upload_purchase_review_screenshot(application.apple_id, upload_file)
          new_screenshot = {
            "value" => {
              "assetToken" => screenshot_data["token"],
              "sortOrder" => 0,
              "type" => "SortedScreenShot",
              "originalFileName" => upload_file.file_name,
              "size" => screenshot_data["length"],
              "height" => screenshot_data["height"],
              "width" => screenshot_data["width"],
              "checksum" => screenshot_data["md5"]
            }
          }

          raw_data["versions"][0]["reviewScreenshot"] = new_screenshot
        end
        # Update the Purchase
        client.update_iap!(app_id: application.apple_id, purchase_id: self.purchase_id, data: raw_data)
      end

      # Deletes In-App-Purchase
      def delete!
        client.delete_iap!(app_id: application.apple_id, purchase_id: self.purchase_id)
      end
    end
  end
end
