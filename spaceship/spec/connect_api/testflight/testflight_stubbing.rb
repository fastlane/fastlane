class ConnectAPIStubbing
  class TestFlight
    class << self
      def read_fixture_file(filename)
        File.read(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'testflight', filename))
      end

      def read_binary_fixture_file(filename)
        File.binread(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'testflight', filename))
      end

      # Necessary, as we're now running this in a different context
      def stub_request(*args)
        WebMock::API.stub_request(*args)
      end

      def stub_apps
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps").
          to_return(status: 200, body: read_fixture_file('apps.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps?include=appStoreVersions").
          to_return(status: 200, body: read_fixture_file('apps.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps?filter%5BbundleId%5D=com.joshholtz.FastlaneTest&include=appStoreVersions").
          to_return(status: 200, body: read_fixture_file('apps.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps/123456789").
          to_return(status: 200, body: read_fixture_file('app.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_app_localizations
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaAppLocalizations").
          to_return(status: 200, body: read_fixture_file('beta_app_localizations.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_app_review_details
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaAppReviewDetails").
          to_return(status: 200, body: read_fixture_file('beta_app_review_details.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_app_review_submissions
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaAppReviewSubmissions").
          to_return(status: 200, body: read_fixture_file('beta_app_review_submissions.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_build_localizations
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaBuildLocalizations").
          to_return(status: 200, body: read_fixture_file('beta_build_localizations.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_build_metrics
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaBuildMetrics").
          to_return(status: 200, body: read_fixture_file('beta_build_metrics.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_feedbacks
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaFeedbacks").
          to_return(status: 200, body: read_fixture_file('beta_feedbacks.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_feedbacks_delete
        stub_request(:delete, "https://appstoreconnect.apple.com/iris/v1/betaFeedbacks/987654321").
          to_return(status: 200, body: "", headers: {})
      end

      def stub_beta_groups
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaGroups").
          to_return(status: 200, body: read_fixture_file('beta_groups.json'), headers: { 'Content-Type' => 'application/json' })

        created_beta_group = JSON.parse(read_fixture_file('beta_create_group.json'))
        stub_request(:post, "https://appstoreconnect.apple.com/iris/v1/betaGroups").
          to_return { |request|
            request_body = JSON.parse(request.body)
            response_body = created_beta_group.dup
            %w{isInternalGroup hasAccessToAllBuilds}.each do |attribute|
              response_body["data"]["attributes"][attribute] = request_body["data"]["attributes"][attribute]
            end
            { status: 200, body: JSON.dump(response_body), headers: { 'Content-Type' => 'application/json' } }
          }

        stub_request(:delete, "https://appstoreconnect.apple.com/iris/v1/betaGroups/123456789").
          to_return(status: 200, body: "", headers: {})
      end

      def stub_beta_testers
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaTesters").
          to_return(status: 200, body: read_fixture_file('beta_testers.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_beta_tester_metrics
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/betaTesterMetrics").
          to_return(status: 200, body: read_fixture_file('beta_tester_metrics.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_build_beta_details
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/buildBetaDetails").
          to_return(status: 200, body: read_fixture_file('build_beta_details.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_build_bundles
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/buildBundles/48a9bb1f-5f0f-4133-8c72-3fb93e92603a/buildBundleFileSizes").
          to_return(status: 200, body: read_fixture_file('build_bundles_build_bundle_file_sizes.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_build_deliveries
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/apps/1234/buildDeliveries").
          to_return(status: 200, body: read_fixture_file('build_deliveries.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_builds
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/builds?include=buildBetaDetail,betaBuildMetrics&limit=10&sort=uploadedDate").
          to_return(status: 200, body: read_fixture_file('builds.json'), headers: { 'Content-Type' => 'application/json' })
      end

      def stub_pre_release_versions
        stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/preReleaseVersions").
          to_return(status: 200, body: read_fixture_file('pre_release_versions.json'), headers: { 'Content-Type' => 'application/json' })
      end
    end
  end
end
