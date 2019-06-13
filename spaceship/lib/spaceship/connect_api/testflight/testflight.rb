require 'spaceship/connect_api/testflight/client'

module Spaceship
  class ConnectAPI
    module TestFlight
      #
      # apps
      #

      def get_apps(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/apps
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("apps", params)
      end

      def get_app(app_id: nil, includes: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>
        params = Client.instance.build_params(filter: nil, includes: includes, limit: nil, sort: nil)
        Client.instance.get("apps/#{app_id}", params)
      end

      #
      # betaAppLocalizations
      #

      def get_beta_app_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaAppLocalizations?filter[app]=<app_id>
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("betaAppLocalizations", params)
      end

      def post_beta_app_localizations(app_id: nil, attributes: {})
        # POST
        # https://appstoreconnect.apple.com/iris/v1/betaAppLocalizations
        path = "betaAppLocalizations"

        body = {
          data: {
            attributes: attributes,
            type: "betaAppLocalizations",
            relationships: {
              app: {
                data: {
                  type: "apps",
                  id: app_id
                }
              }
            }
          }
        }

        Client.instance.post(path, body)
      end

      def patch_beta_app_localizations(localization_id: nil, attributes: {})
        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>/betaAppLocalizations/<localization_id>
        path = "betaAppLocalizations/#{localization_id}"

        body = {
          data: {
            attributes: attributes,
            id: localization_id,
            type: "betaAppLocalizations"
          }
        }

        Client.instance.patch(path, body)
      end

      #
      # betaAppReviewDetails
      #

      def get_beta_app_review_detail(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaAppReviewDetails?filter[app]=<app_id>
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("betaAppReviewDetails", params)
      end

      def patch_beta_app_review_detail(app_id: nil, attributes: {})
        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>/betaAppReviewDetails
        path = "betaAppReviewDetails/#{app_id}"

        body = {
          data: {
            attributes: attributes,
            id: app_id,
            type: "betaAppReviewDetails"
          }
        }

        Client.instance.patch(path, body)
      end

      #
      # betaAppReviewSubmissions
      #

      def get_beta_app_review_submissions(filter: {}, includes: nil, limit: nil, sort: nil, cursor: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaAppReviewSubmissions
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort, cursor: cursor)
        Client.instance.get("betaAppReviewSubmissions", params)
      end

      def post_beta_app_review_submissions(build_id: nil)
        # POST
        # https://appstoreconnect.apple.com/iris/v1/betaAppReviewSubmissions
        path = "betaAppReviewSubmissions"
        body = {
          data: {
            type: "betaAppReviewSubmissions",
            relationships: {
              build: {
                data: {
                  type: "builds",
                  id: build_id
                }
              }
            }
          }
        }

        Client.instance.post(path, body)
      end

      def delete_beta_app_review_submission(beta_app_review_submission_id: nil)
        # DELETE
        # https://appstoreconnect.apple.com/iris/v1/betaAppReviewSubmissions/<beta_app_review_submission_id>
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil, cursor: nil)
        Client.instance.delete("betaAppReviewSubmissions/#{beta_app_review_submission_id}", params)
      end

      #
      # betaBuildLocalizations
      #

      def get_beta_build_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaBuildLocalizations
        path = "betaBuildLocalizations"
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get(path, params)
      end

      def post_beta_build_localizations(build_id: nil, attributes: {})
        # POST
        # https://appstoreconnect.apple.com/iris/v1/betaBuildLocalizations
        path = "betaBuildLocalizations"

        body = {
          data: {
            attributes: attributes,
            type: "betaBuildLocalizations",
            relationships: {
              build: {
                data: {
                  type: "builds",
                  id: build_id
                }
              }
            }
          }
        }

        Client.instance.post(path, body)
      end

      def patch_beta_build_localizations(localization_id: nil, feedbackEmail: nil, attributes: {})
        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/apps/<app_id>/betaBuildLocalizations
        path = "betaBuildLocalizations/#{localization_id}"

        body = {
          data: {
            attributes: attributes,
            id: localization_id,
            type: "betaBuildLocalizations"
          }
        }

        Client.instance.patch(path, body)
      end

      #
      # betaBuildMetrics
      #

      def get_beta_build_metrics(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaBuildMetrics
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("betaBuildMetrics", params)
      end

      #
      # betaGroups
      #

      def get_beta_groups(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaGroups
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("betaGroups", params)
      end

      def add_beta_groups_to_build(build_id: nil, beta_group_ids: [])
        # POST
        # https://appstoreconnect.apple.com/iris/v1/builds/<build_id>/relationships/betaGroups
        path = "builds/#{build_id}/relationships/betaGroups"
        body = {
          data: beta_group_ids.map do |id|
            {
              type: "betaGroups",
              id: id
            }
          end
        }

        Client.instance.post(path, body)
      end

      #
      # betaTesters
      #

      def get_beta_testers(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaTesters
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("betaTesters", params)
      end

      # beta_testers - [{email: "", firstName: "", lastName: ""}]
      def post_bulk_beta_tester_assignments(beta_group_id: nil, beta_testers: nil)
        # POST
        # https://appstoreconnect.apple.com/iris/v1/bulkBetaTesterAssignments
        beta_testers || []

        beta_testers.map do |tester|
          tester[:errors] = []
        end

        body = {
          data: {
            attributes: {
              betaTesters: beta_testers
            },
            relationships: {
              betaGroup: {
                data: {
                  type: "betaGroups",
                  id: beta_group_id
                }
              }
            },
            type: "bulkBetaTesterAssignments"
          }
        }

        Client.instance.post("bulkBetaTesterAssignments", body)
      end

      def delete_beta_tester_from_apps(beta_tester_id: nil, app_ids: [])
        # DELETE
        # https://appstoreconnect.apple.com/iris/v1/betaTesters/<beta_tester_id>/relationships/apps
        path = "betaTesters/#{beta_tester_id}/relationships/apps"
        body = {
          data: app_ids.map do |id|
            {
              type: "apps",
              id: id
            }
          end
        }

        delete(path, nil, body)
      end

      def delete_beta_tester_from_beta_groups(beta_tester_id: nil, beta_group_ids: [])
        # DELETE
        # https://appstoreconnect.apple.com/iris/v1/betaTesters/<beta_tester_id>/relationships/betaGroups
        path = "betaTesters/#{beta_tester_id}/relationships/betaGroups"
        body = {
          data: beta_group_ids.map do |id|
            {
              type: "betaGroups",
              id: id
            }
          end
        }

        delete(path, nil, body)
      end

      #
      # betaTesterMetrics
      #

      def get_beta_tester_metrics(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/betaTesterMetrics
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("betaTesterMetrics", params)
      end

      #
      # builds
      #

      def get_builds(filter: {}, includes: "buildBetaDetail,betaBuildMetrics", limit: 10, sort: "uploadedDate", cursor: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/builds
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort, cursor: cursor)
        Client.instance.get("builds", params)
      end

      def get_build(build_id: nil, includes: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/builds/<build_id>?
        params = Client.instance.build_params(filter: nil, includes: includes, limit: nil, sort: nil, cursor: nil)
        Client.instance.get("builds/#{build_id}", params)
      end

      def patch_builds(build_id: nil, attributes: {})
        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/builds/<build_id>
        path = "builds/#{build_id}"

        body = {
          data: {
            attributes: attributes,
            id: build_id,
            type: "builds"
          }
        }

        Client.instance.patch(path, body)
      end

      #
      # buildBetaDetails
      #

      def get_build_beta_details(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/buildBetaDetails
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("buildBetaDetails", params)
      end

      def patch_build_beta_details(build_beta_details_id: nil, attributes: {})
        # PATCH
        # https://appstoreconnect.apple.com/iris/v1/buildBetaDetails/<build_beta_details_id>
        path = "buildBetaDetails/#{build_beta_details_id}"

        body = {
          data: {
            attributes: attributes,
            id: build_beta_details_id,
            type: "buildBetaDetails"
          }
        }

        Client.instance.patch(path, body)
      end

      #
      # buildDeliveries
      #

      def get_build_deliveries(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/buildDeliveries
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("buildDeliveries", params)
      end

      #
      # preReleaseVersions
      #

      def get_pre_release_versions(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/preReleaseVersions
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("preReleaseVersions", params)
      end
    end
  end
end
