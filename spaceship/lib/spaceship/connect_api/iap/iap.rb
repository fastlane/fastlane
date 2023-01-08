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
