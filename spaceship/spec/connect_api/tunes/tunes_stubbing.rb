class ConnectAPIStubbing
  class Tunes
    COMPLIANCE_FORM_ACCOUNT_URL = "https://appstoreconnect.apple.com/ppm/complianceform/v1/accounts/12345678-1234-1234-1234-123456789012"
    COMPLIANCE_REQUIREMENT_ID = "87654321-4321-4321-4321-210987654321"

    class << self
      def read_fixture_file(filename)
        File.read(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'tunes', filename))
      end

      def read_binary_fixture_file(filename)
        File.binread(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'tunes', filename))
      end

      # Necessary, as we're now running this in a different context
      def stub_request(*args)
        WebMock::API.stub_request(*args)
      end

      def stub_get_app_availabilities_ready_for_distribution
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v2/appAvailabilities/123456789?include=territoryAvailabilities&limit%5BterritoryAvailabilities%5D=200").
          to_return(status: 200, body: read_fixture_file('app_availabilities_ready_for_distribution.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_get_app_availabilities_removed_from_sale
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v2/appAvailabilities/123456789?include=territoryAvailabilities&limit%5BterritoryAvailabilities%5D=200").
          to_return(status: 200, body: read_fixture_file('app_availabilities_removed_app.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_get_app_infos
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps/123456789/appInfos").
          to_return(status: 200, body: read_fixture_file('app_infos.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_app_store_version_release_request
        stub_request(:post, "https://appstoreconnect.apple.com/iris/v1/appStoreVersionReleaseRequests").
          to_return(status: 200, body: read_fixture_file('app_store_version_release_request.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_create_review_submission
        stub_request(:post, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions").
          to_return(status: 200, body: read_fixture_file('review_submission_created.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_cancel_review_submission
        stub_request(:patch, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/123456789").
          with(body: { data: WebMock::API.hash_including({ attributes: { canceled: true } }) }).
          to_return(status: 200, body: read_fixture_file('review_submission_cancelled.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_get_review_submission
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/123456789").
          to_return(status: 200, body: read_fixture_file('review_submission.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_get_review_submissions
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps/123456789-app/reviewSubmissions").
          to_return(status: 200, body: read_fixture_file('review_submissions.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_submit_review_submission
        stub_request(:patch, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/123456789").
          with(body: { data: WebMock::API.hash_including({ attributes: { submitted: true } }) }).
          to_return(status: 200, body: read_fixture_file('review_submission_submitted.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_create_review_submission_item
        stub_request(:post, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissionItems").
          to_return(status: 200, body: read_fixture_file('review_submission_item_created.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_get_review_submission_items
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/123456789/items").
          to_return(status: 200, body: read_fixture_file('review_submission_items.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_get_compliance_requirements(required: true)
        body = JSON.parse(read_fixture_file('compliance_requirements.json'))
        body["requirementData"].first["requirements"] = [] unless required
        stub_request(:get, "#{COMPLIANCE_FORM_ACCOUNT_URL}/requirements?contentId=123456789").
          to_return(status: 200, body: JSON.generate(body), headers: { 'Content-Type' => 'application/json' })
      end

      # declaration: nil stubs a form that has never been answered
      def stub_get_compliance_requirement_form(declaration: "no")
        body = JSON.parse(read_fixture_file('compliance_requirement_form.json'))
        if declaration.nil?
          body["data"].delete("medicalDeviceData")
        else
          body["data"]["medicalDeviceData"]["declaration"] = declaration
        end
        stub_request(:get, "#{COMPLIANCE_FORM_ACCOUNT_URL}/requirements/#{COMPLIANCE_REQUIREMENT_ID}/forms?contentId=123456789").
          to_return(status: 200, body: JSON.generate(body), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_post_compliance_requirement_form
        stub_request(:post, "#{COMPLIANCE_FORM_ACCOUNT_URL}/contents/123456789/requirements/#{COMPLIANCE_REQUIREMENT_ID}/forms").
          to_return(status: 200, body: read_fixture_file('compliance_requirement_form.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_webhooks
        stub_request(:get, "https://api.appstoreconnect.apple.com/v1/apps/123456789/webhooks").
          to_return(status: 200, body: read_fixture_file('webhooks.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:post, "https://api.appstoreconnect.apple.com/v1/webhooks").
          to_return(status: 200, body: read_fixture_file('webhook.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:delete, "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-123").
          to_return(status: 200, body: "", headers: {})
      end
    end
  end
end
