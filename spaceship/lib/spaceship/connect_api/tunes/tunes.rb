require 'spaceship/connect_api/tunes/client'

module Spaceship
  class ConnectAPI
    module Tunes

      #
      # app
      #

      def patch_app(app_id: nil, attributes: {})
        body = {
          data: {
            type: "apps",
            id: app_id,
            attributes: attributes
          }
        }

        Client.instance.patch("apps/#{app_id}", body)
      end

      #
      # appReviewAttachments
      #

      def get_app_review_attachments(app_store_review_detail_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appStoreReviewDetails/#{app_store_review_detail_id}/appReviewAttachments", params)
      end

      def post_app_review_attachment(app_store_review_detail_id: nil, attributes: {})
        body = {
          data: {
            type: "appReviewAttachments",
            attributes: attributes,
            relationships: {
              appStoreReviewDetail: {
                data: {
                  type: "appStoreReviewDetails",
                  id: app_store_review_detail_id
                }
              }
            }
          }
        }

        Client.instance.post("appReviewAttachments", body)
      end

      def patch_app_review_attachment(app_review_attachment_id: nil, attributes: {})
        body = {
          data: {
            type: "appReviewAttachments",
            id: app_review_attachment_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appReviewAttachments/#{app_review_attachment_id}", body)
      end

      def delete_app_review_attachment(app_review_attachment_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appReviewAttachments/#{app_review_attachment_id}", params)
      end

      #
      # appScreenshotSets
      #

      def get_app_screenshot_sets(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appScreenshotSets", params)
      end

      def post_app_screenshot_set(app_store_version_localization_id: nil, attributes: {})
        body = {
          data: {
            type: "appScreenshotSets",
            attributes: attributes,
            relationships: {
              appStoreVersionLocalization: {
                data: {
                  type: "appStoreVersionLocalizations",
                  id: app_store_version_localization_id
                }
              }
            }
          }
        }

        Client.instance.post("appScreenshotSets", body)
      end

      #
      # appScreenshots
      #

      def post_app_screenshot(app_screenshot_set_id: nil, attributes: {})
        body = {
          data: {
            type: "appScreenshots",
            attributes: attributes,
            relationships: {
              appScreenshotSet: {
                data: {
                  type: "appScreenshotSets",
                  id: app_screenshot_set_id
                }
              }
            }
          }
        }

        Client.instance.post("appScreenshots", body)
      end

      def patch_app_screenshot(app_screenshot_id: nil, attributes: {})
        body = {
          data: {
            type: "appScreenshots",
            id: app_screenshot_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appScreenshots/#{app_screenshot_id}", body)
      end

      def delete_app_screenshot(app_screenshot_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appScreenshots/#{app_screenshot_id}", params)
      end

      #
      # appInfos
      #

      def get_app_infos(app_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("apps/#{app_id}/appInfos", params)
      end

      def patch_app_info(app_info_id: nil, attributes: {})
        attributes ||= {}

        data = {
          type: "appInfos",
          id: app_info_id,
        }
        data[:attributes] = attributes unless attributes.empty?

        body = {
          data: data
        }

        Client.instance.patch("appInfos/#{app_info_id}", body)
      end

      def patch_app_info_categories(app_info_id: nil, primary_category_id: nil, secondary_category_id: nil, primary_subcategory_one_id: nil, primary_subcategory_two_id: nil, secondary_subcategory_one_id: nil, secondary_subcategory_two_id: nil)
        relationships = {
          primaryCategory: {
            data: primary_category_id ? { "type": "appCategories", "id": primary_category_id } : nil
          },
          secondaryCategory: {
            data: secondary_category_id ? { "type": "appCategories", "id": secondary_category_id } : nil
          },
          primarySubcategoryOne: {
            data: primary_subcategory_one_id ? { "type": "appCategories", "id": primary_subcategory_one_id } : nil
          },
          primarySubcategoryTwo: {
            data: primary_subcategory_two_id ? { "type": "appCategories", "id": primary_subcategory_two_id } : nil
          },
          secondarySubcategoryOne: {
            data: secondary_subcategory_one_id ? { "type": "appCategories", "id": secondary_subcategory_one_id } : nil
          },
          secondarySubcategoryTwo: {
            data: secondary_subcategory_two_id ? { "type": "appCategories", "id": secondary_subcategory_two_id } : nil
          }
        }

        data = {
          type: "appInfos",
          id: app_info_id,
        }
        data[:relationships] = relationships unless relationships.empty?

        body = {
          data: data
        }

        Client.instance.patch("appInfos/#{app_info_id}", body)
      end

      def delete_app_info(app_info_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appInfos/#{app_info_id}", params)
      end

      #
      # appStoreReviewDetails
      #

      def get_app_store_review_detail(app_store_version_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appStoreVersions/#{app_store_version_id}/appStoreReviewDetail", params)
      end

      def post_app_store_review_detail(app_store_version_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreReviewDetails",
            attributes: attributes,
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_store_version_id
                }
              }
            }
          }
        }

        Client.instance.post("appStoreReviewDetails", body)
      end

      def patch_app_store_review_detail(app_store_review_detail_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreReviewDetails",
            id: app_store_review_detail_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appStoreReviewDetails/#{app_store_review_detail_id}", body)
      end

      #
      # appStoreVersionLocalizations
      #

      def get_app_store_version_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appStoreVersionLocalizations", params)
      end

      def post_app_store_version_localization(app_store_version_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreVersionLocalizations",
            attributes: attributes,
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_store_version_id
                }
              }
            }
          }
        }

        Client.instance.post("appStoreVersionLocalizations", body)
      end

      def patch_app_store_version_localization(app_store_version_localization_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreVersionLocalizations",
            id: app_store_version_localization_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appStoreVersionLocalizations/#{app_store_version_localization_id}", body)
      end

      def delete_app_store_version_localization(app_store_version_localization_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appStoreVersionLocalizations/#{app_store_version_localization_id}", params)
      end

      #
      # appStoreVersionPhasedReleases
      #

      def get_app_store_version_phased_release(app_store_version_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appStoreVersions/#{app_store_version_id}/appStoreVersionPhasedRelease", params)
      end

      def post_app_store_version_phased_release(app_store_version_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreVersionPhasedReleases",
            attributes: attributes,
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_store_version_id
                }
              }
            }
          }
        }

        Client.instance.post("appStoreVersionPhasedReleases", body)
      end

      def delete_app_store_version_phased_release(app_store_version_phased_release_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appStoreVersionPhasedReleases/#{app_store_version_phased_release_id}", params)
      end

      #
      # appStoreVersions
      #

      def get_app_store_versions(app_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("apps/#{app_id}/appStoreVersions", params)
      end

      def get_app_store_version(app_store_version_id: nil, includes: nil)
        params = Client.instance.build_params(filter: nil, includes: includes, limit: nil, sort: nil)
        Client.instance.get("appStoreVersions/#{app_store_version_id}", params)
      end

      def post_app_store_version(app_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreVersions",
            attributes: attributes,
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

        Client.instance.post("appStoreVersions", body)
      end

      def patch_app_store_version(app_store_version_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreVersions",
            id: app_store_version_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appStoreVersions/#{app_store_version_id}", body)
      end

      def patch_app_store_version_with_build(app_store_version_id: nil, build_id: nil)
        data = nil
        data = {
          "type": "builds",
          "id": build_id
        } if build_id

        body = {
          data: {
            type: "appStoreVersions",
            id: app_store_version_id,
            relationships: {
              build: {
                data: data
              }
            }
          }
        }

        Client.instance.patch("appStoreVersions/#{app_store_version_id}", body)
      end

      #
      # appStoreVersionPhasedReleases
      #

      def get_reset_ratings_request(app_store_version_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appStoreVersions/#{app_store_version_id}/resetRatingsRequest", params)
      end

      def post_reset_ratings_request(app_store_version_id: nil)
        body = {
          data: {
            type: "resetRatingsRequests",
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_store_version_id
                }
              }
            }
          }
        }

        Client.instance.post("resetRatingsRequests", body)
      end

      def delete_reset_ratings_request(reset_ratings_request_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("resetRatingsRequests/#{reset_ratings_request_id}", params)
      end

      #
      # appStoreVersionSubmissions
      #

      def get_app_store_version_submission(app_store_version_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appStoreVersions/#{app_store_version_id}/appStoreVersionSubmission", params)
      end

      def post_app_store_version_submission(app_store_version_id: nil)
        body = {
          data: {
            type: "appStoreVersionSubmissions",
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_store_version_id
                }
              }
            }
          }
        }

        Client.instance.post("appStoreVersionSubmissions", body)
      end

      def delete_app_store_version_submission(app_store_version_submission_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appStoreVersionSubmissions/#{app_store_version_submission_id}", params)
      end

      #
      # idfaDeclarations
      #

      def get_idfa_declaration(app_store_version_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appStoreVersions/#{app_store_version_id}/idfaDeclaration", params)
      end

      def post_idfa_declaration(app_store_version_id: nil, attributes: nil)
        body = {
          data: {
            type: "idfaDeclarations",
            attributes: attributes,
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_store_version_id
                }
              }
            }
          }
        }

        Client.instance.post("idfaDeclarations", body)
      end

      def patch_idfa_declaration(idfa_declaration_id: nil, attributes: nil)
        body = {
          data: {
            type: "idfaDeclarations",
            id: idfa_declaration_id,
            attributes: attributes
          }
        }

        Client.instance.patch("idfaDeclarations/#{idfa_declaration_id}", body)
      end

      def delete_idfa_declaration(idfa_declaration_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("idfaDeclarations/#{idfa_declaration_id}", params)
      end

    end
  end
end
