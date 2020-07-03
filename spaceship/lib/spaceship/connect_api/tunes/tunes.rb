require 'spaceship/connect_api/tunes/client'

module Spaceship
  class ConnectAPI
    module Tunes
      #
      # ageRatingDeclarations
      #

      def get_age_rating_declaration(app_store_version_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appStoreVersions/#{app_store_version_id}/ageRatingDeclaration", params)
      end

      def patch_age_rating_declaration(age_rating_declaration_id: nil, attributes: nil)
        body = {
          data: {
            type: "ageRatingDeclarations",
            id: age_rating_declaration_id,
            attributes: attributes
          }
        }

        Client.instance.patch("ageRatingDeclarations/#{age_rating_declaration_id}", body)
      end

      #
      # app
      #

      def post_app(name: nil, version_string: nil, sku: nil, primary_locale: nil, bundle_id: nil, platforms: nil, company_name: nil)
        included = []
        included << {
          type: "appInfos",
          id: "${new-appInfo-id}",
          relationships: {
            appInfoLocalizations: {
              data: [
                {
                  type: "appInfoLocalizations",
                  id: "${new-appInfoLocalization-id}"
                }
              ]
            }
          }
        }
        included << {
          type: "appInfoLocalizations",
          id: "${new-appInfoLocalization-id}",
          attributes: {
            locale: primary_locale,
            name: name
          }
        }

        platforms.each do |platform|
          included << {
            type: "appStoreVersions",
            id: "${store-version-#{platform}}",
            attributes: {
              platform: platform,
              versionString: version_string
            },
            relationships: {
              appStoreVersionLocalizations: {
                data: [
                  {
                    type: "appStoreVersionLocalizations",
                    id: "${new-#{platform}VersionLocalization-id}"
                  }
                ]
              }
            }
          }

          included << {
            type: "appStoreVersionLocalizations",
            id: "${new-#{platform}VersionLocalization-id}",
            attributes: {
              locale: primary_locale
            }
          }
        end

        app_store_verions_data = platforms.map do |platform|
          {
            type: "appStoreVersions",
            id: "${store-version-#{platform}}"
          }
        end

        relationships = {
          appStoreVersions: {
            data: app_store_verions_data
          },
          appInfos: {
            data: [
              {
                type: "appInfos",
                id: "${new-appInfo-id}"
              }
            ]
          }
        }

        app_attributes = {
          sku: sku,
          primaryLocale: primary_locale,
          bundleId: bundle_id
        }
        app_attributes[:companyName] = company_name if company_name

        body = {
          data: {
            type: "apps",
            attributes: app_attributes,
            relationships: relationships
          },
          included: included
        }

        Client.instance.post("apps", body)
      end

      def patch_app(app_id: nil, attributes: {}, app_price_tier_id: nil, territory_ids: nil)
        relationships = {}
        included = []

        # Price tier
        unless app_price_tier_id.nil?
          relationships[:prices] = {
            data: [
              {
                type: "appPrices",
                id: "${price1}"
              }
            ]
          }

          included << {
            type: "appPrices",
            id: "${price1}",
            attributes: {
              startDate: nil
            },
            relationships: {
              app: {
                data: {
                  type: "apps",
                  id: app_id
                }
              },
              priceTier: {
                data: {
                  type: "appPriceTiers",
                  id: app_price_tier_id.to_s
                }
              }
            }
          }
        end

        # Territories
        territories_data = (territory_ids || []).map do |id|
          { type: "territories", id: id }
        end
        unless territories_data.empty?
          relationships[:availableTerritories] = {
            data: territories_data
          }
        end

        # Data
        data = {
          type: "apps",
          id: app_id
        }
        data[:attributes] = attributes unless attributes.empty?
        data[:relationships] = relationships unless relationships.empty?

        # Body
        body = {
          data: data
        }
        body[:included] = included unless included.empty?

        Client.instance.patch("apps/#{app_id}", body)
      end

      #
      # appPreview
      #

      def get_app_preview(app_preview_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appPreviews/#{app_preview_id}", params)
      end

      def post_app_preview(app_preview_set_id: nil, attributes: {})
        body = {
          data: {
            type: "appPreviews",
            attributes: attributes,
            relationships: {
              appPreviewSet: {
                data: {
                  type: "appPreviewSets",
                  id: app_preview_set_id
                }
              }
            }
          }
        }

        Client.instance.post("appPreviews", body)
      end

      def patch_app_preview(app_preview_id: nil, attributes: {})
        body = {
          data: {
            type: "appPreviews",
            id: app_preview_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appPreviews/#{app_preview_id}", body)
      end

      def delete_app_preview(app_preview_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appPreviews/#{app_preview_id}", params)
      end

      #
      # appPreviewSets
      #

      def get_app_preview_sets(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appPreviewSets", params)
      end

      def post_app_preview_set(app_store_version_localization_id: nil, attributes: {})
        body = {
          data: {
            type: "appPreviewSets",
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

        Client.instance.post("appPreviewSets", body)
      end

      #
      # appPrices
      #

      def get_app_prices(app_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appPrices", params)
      end

      #
      # appReviewAttachments
      #

      def post_app_store_review_attachment(app_store_review_detail_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreReviewAttachments",
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

        Client.instance.post("appStoreReviewAttachments", body)
      end

      def patch_app_store_review_attachment(app_store_review_attachment_id: nil, attributes: {})
        body = {
          data: {
            type: "appStoreReviewAttachments",
            id: app_store_review_attachment_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appStoreReviewAttachments/#{app_store_review_attachment_id}", body)
      end

      def delete_app_store_review_attachment(app_store_review_attachment_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("appStoreReviewAttachments/#{app_store_review_attachment_id}", params)
      end

      #
      # appScreenshotSets
      #

      def get_app_screenshot_sets(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appScreenshotSets", params)
      end

      def get_app_screenshot_set(app_screenshot_set_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appScreenshotSets/#{app_screenshot_set_id}", params)
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

      def patch_app_screenshot_set_screenshots(app_screenshot_set_id: nil, app_screenshot_ids: nil)
        app_screenshot_ids ||= []

        body = {
          data: app_screenshot_ids.map do |app_screenshot_id|
            {
              type: "appScreenshots",
              id: app_screenshot_id
            }
          end
        }

        Client.instance.patch("appScreenshotSets/#{app_screenshot_set_id}/relationships/appScreenshots", body)
      end

      #
      # appScreenshots
      #

      def get_app_screenshot(app_screenshot_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("appScreenshots/#{app_screenshot_id}", params)
      end

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

      def get_app_infos(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appInfos", params)
      end

      def patch_app_info(app_info_id: nil, attributes: {})
        attributes ||= {}

        data = {
          type: "appInfos",
          id: app_info_id
        }
        data[:attributes] = attributes unless attributes.empty?

        body = {
          data: data
        }

        Client.instance.patch("appInfos/#{app_info_id}", body)
      end

      #
      # Adding the key will create/update (if value) or delete if nil
      # Not including a key will leave as is
      # category_id_map: {
      #   primary_category_id: "GAMES",
      #   primary_subcategory_one_id: "PUZZLE",
      #   primary_subcategory_two_id: "STRATEGY",
      #   secondary_category_id: nil,
      #   secondary_subcategory_one_id: nil,
      #   secondary_subcategory_two_id: nil
      # }
      #
      def patch_app_info_categories(app_info_id: nil, category_id_map: nil)
        category_id_map ||= {}
        primary_category_id = category_id_map[:primary_category_id]
        primary_subcategory_one_id = category_id_map[:primary_subcategory_one_id]
        primary_subcategory_two_id = category_id_map[:primary_subcategory_two_id]
        secondary_category_id = category_id_map[:secondary_category_id]
        secondary_subcategory_one_id = category_id_map[:secondary_subcategory_one_id]
        secondary_subcategory_two_id = category_id_map[:secondary_subcategory_two_id]

        relationships = {}

        # Only update if key is included (otherwise category will be removed)
        if category_id_map.include?(:primary_category_id)
          relationships[:primaryCategory] = {
            data: primary_category_id ? { type: "appCategories", id: primary_category_id } : nil
          }
        end

        # Only update if key is included (otherwise category will be removed)
        if category_id_map.include?(:primary_subcategory_one_id)
          relationships[:primarySubcategoryOne] = {
            data: primary_subcategory_one_id ? { type: "appCategories", id: primary_subcategory_one_id } : nil
          }
        end

        # Only update if key is included (otherwise category will be removed)
        if category_id_map.include?(:primary_subcategory_two_id)
          relationships[:primarySubcategoryTwo] = {
            data: primary_subcategory_two_id ? { type: "appCategories", id: primary_subcategory_two_id } : nil
          }
        end

        # Only update if key is included (otherwise category will be removed)
        if category_id_map.include?(:secondary_category_id)
          relationships[:secondaryCategory] = {
            data: secondary_category_id ? { type: "appCategories", id: secondary_category_id } : nil
          }
        end

        # Only update if key is included (otherwise category will be removed)
        if category_id_map.include?(:secondary_subcategory_one_id)
          relationships[:secondarySubcategoryOne] = {
            data: secondary_subcategory_one_id ? { type: "appCategories", id: secondary_subcategory_one_id } : nil
          }
        end

        # Only update if key is included (otherwise category will be removed)
        if category_id_map.include?(:secondary_subcategory_two_id)
          relationships[:secondarySubcategoryTwo] = {
            data: secondary_subcategory_two_id ? { type: "appCategories", id: secondary_subcategory_two_id } : nil
          }
        end

        data = {
          type: "appInfos",
          id: app_info_id
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
      # appInfoLocalizations
      #

      def get_app_info_localizations(app_info_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("appInfos/#{app_info_id}/appInfoLocalizations", params)
      end

      def post_app_info_localization(app_info_id: nil, attributes: {})
        body = {
          data: {
            type: "appInfoLocalizations",
            attributes: attributes,
            relationships: {
              appStoreVersion: {
                data: {
                  type: "appStoreVersions",
                  id: app_info_id
                }
              }
            }
          }
        }

        Client.instance.post("appInfoLocalizations", body)
      end

      def patch_app_info_localization(app_info_localization_id: nil, attributes: {})
        body = {
          data: {
            type: "appInfoLocalizations",
            id: app_info_localization_id,
            attributes: attributes
          }
        }

        Client.instance.patch("appInfoLocalizations/#{app_info_localization_id}", body)
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
        if build_id
          data = {
            type: "builds",
            id: build_id
          }
        end

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

      #
      # sandboxTesters
      #

      def get_sandbox_testers(filter: nil, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("sandboxTesters", params)
      end

      def post_sandbox_tester(attributes: {})
        body = {
          data: {
            type: "sandboxTesters",
            attributes: attributes
          }
        }

        Client.instance.post("sandboxTesters", body)
      end

      def delete_sandbox_tester(sandbox_tester_id: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.delete("sandboxTesters/#{sandbox_tester_id}", params)
      end

      #
      # territories
      #

      def get_territories(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: nil, includes: nil, limit: nil, sort: nil)
        Client.instance.get("territories", params)
      end
    end
  end
end
