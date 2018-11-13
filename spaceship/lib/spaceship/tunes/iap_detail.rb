require_relative '../du/upload_file'
require_relative 'iap_status'
require_relative 'iap_type'
require_relative 'tunes_base'

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

      # @return (Hash) Relevant only for recurring subscriptions. Holds pricing related data, such
      # as subscription pricing, intro offers, etc.
      attr_accessor :raw_pricing_data

      attr_mapping({
        'adamId' => :purchase_id,
        'referenceName.value' => :reference_name,
        'productId.value' => :product_id,
        'isNewsSubscription' => :is_news_subscription,
        'pricingDurationType.value' => :subscription_duration,
        'freeTrialDurationType.value' => :subscription_free_trial,
        'clearedForSale.value' => :cleared_for_sale
      })

      def setup
        @raw_pricing_data = @raw_data["pricingData"]
        @raw_data.delete("pricingData")

        if @raw_pricing_data
          @raw_data.set(["pricingIntervals"], @raw_pricing_data["subscriptions"])
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

      # transforms user-set versions to iTC ones
      def versions=(value = {})
        if value.kind_of?(Array)
          # input that comes from iTC api
          return
        end
        new_versions = []
        value.each do |language, current_version|
          new_versions << {
            "value" =>   {
              "name" =>  { "value" => current_version[:name] },
              "description" =>  { "value" => current_version[:description] },
              "localeCode" =>  language.to_s
            }
          }
        end

        raw_data.set(["versions"], [{ reviewNotes: { value: @review_notes }, "contentHosting" => raw_data['versions'].first['contentHosting'], "details" => { "value" => new_versions }, "id" => raw_data["versions"].first["id"], "reviewScreenshot" => { "value" => review_screenshot } }])
      end

      # transforms user-set intervals to iTC ones
      def pricing_intervals=(value = [])
        raw_pricing_intervals =
          client.transform_to_raw_pricing_intervals(application.apple_id, self.purchase_id, value)
        raw_data.set(["pricingIntervals"], raw_pricing_intervals)
        @raw_pricing_data["subscriptions"] = raw_pricing_intervals if @raw_pricing_data
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
        @pricing_intervals ||= (raw_data["pricingIntervals"] || @raw_pricing_data["subscriptions"] || []).map do |interval|
          {
            tier: interval["value"]["tierStem"].to_i,
            begin_date: interval["value"]["priceTierEffectiveDate"],
            end_date: interval["value"]["priceTierEndDate"],
            grandfathered: interval["value"]["grandfathered"],
            country: interval["value"]["country"]
          }
        end
      end

      # @return (String) Human Readable type of the purchase
      def type
        Tunes::IAPType.get_from_string(raw_data["addOnType"])
      end

      # @return (String) Human Readable status of the purchase
      def status
        Tunes::IAPStatus.get_from_string(raw_data["versions"].first["status"])
      end

      # @return (Hash) Hash containing existing review screenshot data
      def review_screenshot
        return nil unless raw_data && raw_data["versions"] && raw_data["versions"].first && raw_data["versions"].first["reviewScreenshot"] && raw_data['versions'].first["reviewScreenshot"]["value"]
        raw_data['versions'].first['reviewScreenshot']['value']
      end

      # Saves the current In-App-Purchase
      def save!
        # Transform localization versions back to original format.
        versions_array = []
        versions.each do |language, value|
          versions_array << {
                    "value" =>  {
                      "description" => { "value" => value[:description] },
                      "name" => { "value" => value[:name] },
                      "localeCode" => language.to_s
                    }
          }
        end

        raw_data.set(["versions"], [{ reviewNotes: { value: @review_notes }, contentHosting: raw_data['versions'].first['contentHosting'], "details" => { "value" => versions_array }, id: raw_data["versions"].first["id"], reviewScreenshot: { "value" => review_screenshot } }])

        # transform pricingDetails
        raw_pricing_intervals =
          client.transform_to_raw_pricing_intervals(application.apple_id,
                                                    self.purchase_id, pricing_intervals,
                                                    subscription_price_target)
        raw_data.set(["pricingIntervals"], raw_pricing_intervals)
        @raw_pricing_data["subscriptions"] = raw_pricing_intervals if @raw_pricing_data

        if @review_screenshot
          # Upload Screenshot
          upload_file = UploadFile.from_path(@review_screenshot)
          screenshot_data = client.upload_purchase_review_screenshot(application.apple_id, upload_file)
          raw_data["versions"][0]["reviewScreenshot"] = screenshot_data
        end
        # Update the Purchase
        client.update_iap!(app_id: application.apple_id, purchase_id: self.purchase_id, data: raw_data)

        # Update pricing for a recurring subscription.
        if raw_data["addOnType"] == Spaceship::Tunes::IAPType::RECURRING
          client.update_recurring_iap_pricing!(app_id: application.apple_id, purchase_id: self.purchase_id,
                                               pricing_intervals: raw_data["pricingIntervals"])
        end
      end

      # Deletes In-App-Purchase
      def delete!
        client.delete_iap!(app_id: application.apple_id, purchase_id: self.purchase_id)
      end

      # Retrieves the actual prices for an iap.
      #
      # @return ([]) An empty array
      #   if the iap is not yet cleared for sale
      # @return ([Spaceship::Tunes::PricingInfo]) An array of pricing infos from the same pricing tier
      #   if the iap uses world wide pricing
      # @return ([Spaceship::Tunes::IAPSubscriptionPricingInfo]) An array of pricing infos from multple subscription pricing tiers
      #   if the iap uses territorial pricing
      def pricing_info
        return [] unless cleared_for_sale
        return world_wide_pricing_info if world_wide_pricing?
        territorial_pricing_info
      end

      private

      # Checks wheather an iap uses world wide or territorial pricing.
      #
      # @return (true, false)
      def world_wide_pricing?
        pricing_intervals.fetch(0, {})[:country] == "WW"
      end

      # Maps a single pricing interval to pricing infos.
      #
      # @return ([Spaceship::Tunes::PricingInfo]) An array of pricing infos from the same tier
      def world_wide_pricing_info
        client
          .pricing_tiers
          .find { |p| p.tier_stem == pricing_intervals.first[:tier].to_s }
          .pricing_info
      end

      # Maps pricing intervals to their respective subscription pricing infos.
      #
      # @return ([Spaceship::Tunes::IAPSubscriptionPricingInfo]) An array of subscription pricing infos
      def territorial_pricing_info
        pricing_matrix = client.subscription_pricing_tiers(application.apple_id)
        pricing_intervals.map do |interval|
          pricing_matrix
            .find { |p| p.tier_stem == interval[:tier].to_s }
            .pricing_info
            .find { |i| i.country_code == interval[:country] }
        end
      end
    end
  end
end
