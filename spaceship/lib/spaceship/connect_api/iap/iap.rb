require 'spaceship/connect_api/iap/client'

module Spaceship
  class ConnectAPI
    module IAP
      module API
        def iap_request_client=(iap_request_client)
          @iap_request_client = iap_request_client
        end

        def iap_request_client
          return @iap_request_client if @iap_request_client
          raise TypeError, "You need to instantiate this module with iap_request_client"
        end

        #
        # inAppPurchases
        #

        def get_in_app_purchases(app_id:, filter: nil, includes: nil, limit: nil, sort: nil)
          params = iap_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          iap_request_client.get("apps/#{app_id}/inAppPurchasesV2", params)
        end

        #
        # subscriptionGroups
        #

        def get_subscription_group(family_id:, includes: nil)
          params = iap_request_client.build_params(filter: nil, includes: includes, limit: nil, sort: nil)
          iap_request_client.get("subscriptionGroups/#{family_id}", params)
        end

        def get_subscription_groups(app_id:, filter: nil, includes: nil, limit: nil, sort: nil)
          params = iap_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          iap_request_client.get("apps/#{app_id}/subscriptionGroups", params)
        end

        def create_subscription_group(reference_name:, app_id:)
          params = {
            data: {
              type: 'subscriptionGroups', # Hard coded value
              attributes: {
                referenceName: reference_name
              },
              relationships: {
                app: {
                  data: {
                    id: app_id,
                    type: 'apps' # Hard coded value
                  }
                }
              },
            }
          }

          iap_request_client.post('subscriptionGroups', params)
        end

        #
        # subscriptionGroupLocalizations
        #

        def get_subscription_group_localization(localization_id:, includes: nil)
          params = iap_request_client.build_params(filter: nil, includes: includes, limit: nil, sort: nil)
          iap_request_client.get("subscriptionGroupLocalizations/#{localization_id}", params)
        end

        def get_subscription_group_localizations(family_id:, includes: nil, limit: nil)
          params = iap_request_client.build_params(filter: nil, includes: includes, limit: limit, sort: nil)
          iap_request_client.get("subscriptionGroups/#{family_id}/subscriptionGroupLocalizations", params)
        end

        def create_subscription_group_localization(custom_app_name:, locale:, name:, family_id:)
          params = {
            data: {
              type: 'subscriptionGroupLocalizations',
              attributes: {
                customAppName: custom_app_name,
                locale: locale,
                name: name
              },
              relationships: {
                subscriptionGroup: {
                  data: {
                    id: family_id,
                    type: 'subscriptionGroups'
                  }
                }
              }
            }
          }

          iap_request_client.post('subscriptionGroupLocalizations', params)
        end

        def update_subscription_group_localization(custom_app_name:, name:, localization_id:)
          params = {
            data: {
              id: localization_id,
              type: 'subscriptionGroupLocalizations',
              attributes: {
                customAppName: custom_app_name,
                name: name
              }
            }
          }

          iap_request_client.patch("subscriptionGroupLocalizations/#{localization_id}", params)
        end

        #
        # subscriptionIntroductoryOffers
        #

        def get_subscription_introductory_offers(app_id:, filter: nil, includes: nil, limit: nil, sort: nil)
          params = iap_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          iap_request_client.get("subscriptions/#{app_id}/introductoryOffers", params)
        end

        #
        # subscriptionPrices
        #

        def get_subscription_prices(app_id:, filter: nil, includes: nil, limit: nil, sort: nil)
          params = iap_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          iap_request_client.get("subscriptions/#{app_id}/prices", params)
        end

        # def patch_age_rating_declaration(age_rating_declaration_id: nil, attributes: nil)
        #   body = {
        #     data: {
        #       type: "ageRatingDeclarations",
        #       id: age_rating_declaration_id,
        #       attributes: attributes
        #     }
        #   }

        #   iap_request_client.patch("ageRatingDeclarations/#{age_rating_declaration_id}", body)
        # end

      end
    end
  end
end
