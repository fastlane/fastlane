require 'date'

describe Fastlane do
  describe ActionSets do
    describe Amazon::Client do
      let(:app_id) { 'amzn1.devportal.mobileapp.abc' }

      def seed_environment
        ENV['AMAZON_APP_SUBMISSION_API_CLIENT_ID'] ||= 'some-client-id'
        ENV['AMAZON_APP_SUBMISSION_API_CLIENT_SECRET'] ||= 'some-client-secret'
      end

      describe '.new' do
        it 'can be initialized with defaults' do
          seed_environment

          instance = Fastlane::ActionSets::Amazon::Client.new
          expect(instance.client_id).to eq(ENV['AMAZON_APP_SUBMISSION_API_CLIENT_ID'])
          expect(instance.client_secret).to eq(ENV['AMAZON_APP_SUBMISSION_API_CLIENT_SECRET'])
        end

        it 'can be configured directly' do
          instance = Fastlane::ActionSets::Amazon::Client.new(client_id: 'other-id', client_secret: 'other-secret')
          expect(instance.client_id).to eq('other-id')
          expect(instance.client_secret).to eq('other-secret')

          instance.client_id = 'new-id'
          instance.client_secret = 'new-secret'
          expect(instance.client_id).to eq('new-id')
          expect(instance.client_secret).to eq('new-secret')
        end
      end

      describe 'authentication functionality' do
        before(:each) do
          seed_environment
          @instance = Fastlane::ActionSets::Amazon::Client.new
          stub_request(:post, 'https://api.amazon.com/auth/o2/token').
            to_return(status: 200, body: {
              access_token: 'abc123',
              expires_in: 3600,
              scope: 'appstore::apps:readwrite',
              token_type: 'bearer'
            })
        end

        describe '#authenticate_if_needed' do
          it 'kicks off a call to the Amazon API to authenticate' do
            expect(@instance.needs_authentication?).to be true
            @instance.authenticate_if_needed
            expect(@instance.needs_authentication?).to be false
          end

          it 'does not make duplicate calls' do
            @instance.authenticate_if_needed
            previous_auth_timestamp = @instance.last_authenticated
            @instance.authenticate_if_needed
            expect(@instance.last_authenticated).to eq(previous_auth_timestamp)
          end
        end

        describe '#authenticate!' do
          it 'kicks off a call to the Amazon API to authenticate' do
            expect(@instance.needs_authentication?).to be true
            response = @instance.authenticate!
            expect(response).to eq(Fastlane::ActionSets::Amazon::ClientCredentials.new({
              'access_token' => 'abc123',
              'scope' => 'appstore::apps:readwrite',
              'token_type' => 'bearer',
              'expires_in' => 3600
            }))
            expect(@instance.needs_authentication?).to be false
          end

          it 'authenticates even if needs_authentication is false' do
            @instance.authenticate!
            previous_auth_timestamp = @instance.last_authenticated
            @instance.authenticate!
            expect(@instance.last_authenticated).to be > previous_auth_timestamp
          end
        end
      end

      context 'with client credentials' do
        let(:base_url) { 'https://developer.amazon.com/api/appstore/v1/applications' }
        let(:edit_id) { 'amzn1.devportal.apprelease.9fd9ded7f16e4b1ea89dc794b6e04328' }

        before(:each) do
          seed_environment
          creds = Fastlane::ActionSets::Amazon::ClientCredentials.new({
            'access_token' => ENV['AMAZON_APP_SUBMISSION_API_JWT'] || 'jwt.jwt.jwt',
            'scope' => 'appstore::apps:readwrite',
            'token_type' => 'bearer',
            'expires_in' => 3600
          })
          @instance = Fastlane::ActionSets::Amazon::Client.new(client_credentials: creds)
        end

        describe 'edits functionality' do
          it 'fetches latest active edit' do
            stub_request(:get, "#{base_url}/edits").
              to_return(status: 200, body: {})

            result = @instance.get_active_edit(app_id: app_id)
            expect(result).to be nil
          end

          it 'creates an edit' do
            stub_request(:post, "#{base_url}/edits").
              to_return(status: 200, body: { id: app_id, status: 'IN_PROGRESS' })

            result = @instance.create_edit(app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Edit.new({
              'id' => 'amzn1.devportal.apprelease.abc',
              'status' => 'IN_PROGRESS'
            }))
          end

          it 'gets an edit' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}").
              to_return(status: 200, body: { id: app_id, status: 'IN_PROGRESS' })

            result = @instance.get_edit(edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Edit.new({
              'id' => 'amzn1.devportal.apprelease.9fd9ded7f16e4b1ea89dc794b6e04328',
              'status' => 'IN_PROGRESS'
            }))
          end

          it 'deletes an edit' do
            stub_request(:delete, "#{base_url}/edits/#{edit_id}").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            @instance.etag_cache[edit_id] = 'etag-value'
            result = @instance.delete_edit(edit_id, app_id: app_id)
            expect(result).to be nil
          end

          it 'validates an edit' do
            stub_request(:post, "#{base_url}/edits/#{edit_id}/validate").
              to_return(status: 200, body: { id: edit_id })

            result = @instance.validate_edit(edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Edit.new({
              'id' => edit_id
            }))
          end

          it 'commits changes to an edit' do
            stub_request(:post, "#{base_url}/edits/#{edit_id}/commit").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: { id: edit_id })

            @instance.etag_cache[edit_id] = 'etag-value'
            result = @instance.commit_edit(edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Edit.new({
              'id' => edit_id
            }))
          end
        end

        describe 'listing functionality' do
          let(:json_data) do
            {
              'language' => 'en-GB',
              'title' => "O'Reilly",
              'fullDescription' => 'Placeholder full description',
              'shortDescription' => 'Placeholder short description',
              'recentChanges' => 'Release notes coming soon',
              'featureBullets' => [],
              'keywords' => []
            }
          end

          it 'fetches all listings' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/listings").
              to_return(status: 200, body: {
                listings: { 'en-GB' => json_data }
              })

            listings = @instance.get_listings(edit_id: edit_id, app_id: app_id)
            expect(listings['en-GB'].language).to eq('en-GB')
          end

          it 'gets a single listing' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/listings/en-GB").
              to_return(status: 200, body: json_data)

            listing = @instance.get_listing('en-GB', edit_id: edit_id, app_id: app_id)
            expect(listing.language).to eq('en-GB')
          end

          it 'updates a listing' do
            stub_request(:put, "#{base_url}/edits/#{edit_id}/listings/en-GB").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: json_data)

            etag_key = [edit_id, 'en-GB'].join('-')
            @instance.etag_cache[etag_key] = 'etag-value'
            listing = Fastlane::ActionSets::Amazon::Listing.new(json_data)
            result = @instance.update_listing(listing, edit_id: edit_id, app_id: app_id)
            expect(result.short_description).to eq('Placeholder short description')
          end

          it 'deletes a listing' do
            stub_request(:delete, "#{base_url}/edits/#{edit_id}/listings/en-GB").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            etag_key = [edit_id, 'en-GB'].join('-')
            @instance.etag_cache[etag_key] = 'etag-value'
            result = @instance.delete_listing('en-GB', edit_id: edit_id, app_id: app_id)
            expect(result).to be nil
          end
        end

        describe 'details functionality' do
          let(:json_data) do
            {
              'defaultLanguage' => 'en-US',
              'contactWebsite' => 'https://www.oreilly.com/online-learning/support/',
              'contactEmail' => 'support@oreilly.com',
              'contactPhone' => '1-800-889-8969'
            }
          end

          it 'gets details' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/details").
              to_return(status: 200, body: json_data)

            result = @instance.get_details(edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Details.new(json_data))
          end

          it 'updates details' do
            stub_request(:put, "#{base_url}/edits/#{edit_id}/details").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: json_data)

            etag_key = [edit_id, 'details'].join('-')
            @instance.etag_cache[etag_key] = 'etag-value'
            details = Fastlane::ActionSets::Amazon::Details.new(json_data)
            result = @instance.update_details(details, edit_id: edit_id, app_id: app_id)
            expect(result.contact_email).to eq('apps@oreilly.com')
          end
        end

        describe 'APK functionality' do
          let(:apk_filepath) { File.join(__dir__, '..', '..', 'fixtures', 'mock-app.apk') }
          let(:apk_id) { 'M8FYZDFK0GJG0 ' }
          let(:json_data) do
            {
              'versionCode' => 21_040_401,
              'id' => apk_id,
              'name' => 'APK1'
            }
          end

          it 'gets apks' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/apks").
              to_return(status: 200, body: [json_data])

            result = @instance.get_apks(edit_id: edit_id, app_id: app_id)
            expect(result).to eq([
                                   Fastlane::ActionSets::Amazon::APKMetadata.new(json_data)
                                 ])
          end

          it 'gets a single apk' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/apks/#{apk_id}").
              to_return(status: 200, body: json_data)

            result = @instance.get_apk(apk_id, edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::APKMetadata.new(json_data))
          end

          it 'deletes an apk' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/apks/#{apk_id}").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            @instance.etag_cache[apk_id] = 'etag-value'
            result = @instance.delete_apk(apk_id, edit_id: edit_id, app_id: app_id)
            expect(result).to be nil
          end

          it 'replaces an apk' do
            stub_request(:put, "#{base_url}/edits/#{edit_id}/apks/#{apk_id}/replace").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: json_data)

            @instance.etag_cache[apk_id] = 'etag-value'
            result = @instance.replace_apk(apk_id, apk_filepath: apk_filepath, edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::APKMetadata.new(json_data))
          end

          it 'uploads a large apk' do
            stub_request(:post, "#{base_url}/edits/#{edit_id}/apks/large/upload").
              to_return(status: 200, body: { id: 'amzn1.devportal.fileupload.abc' })

            result = @instance.upload_large_apk(apk_filepath, edit_id: edit_id, app_id: app_id)
            expect(result).to eq('amzn1.devportal.fileupload.abc')
          end

          it 'attaches an uploaded apk' do
            file_id = 'amzn1.devportal.fileupload.abc'

            stub_request(:post, "#{base_url}/edits/#{edit_id}/apks/attach").
              to_return(status: 200, body: json_data)

            result = @instance.attach_apk(file_id, edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::APKMetadata.new(json_data))
          end

          it 'uploads and attaches an apk' do
            stub_request(:post, "#{base_url}/edits/#{edit_id}/apks/upload").
              to_return(status: 200, body: json_data)

            result = @instance.upload_apk(apk_filepath, edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::APKMetadata.new(json_data))
          end
        end

        describe 'images functionality' do
          let(:filepath) { File.join(__dir__, '..', '..', 'fixtures', 'mock-image.png') }
          let(:language) { 'en-US' }
          let(:json_data) do
            [
              { id: 'amzn1.dex.asset.f98f7b86f7674a7e9ed9192273fc9b56' },
              { id: 'amzn1.dex.asset.991a8f7d43254282842896da7bd68f5e' }
            ]
          end

          it 'gets all images' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/listings/#{language}/screenshots").
              to_return(status: 200, body: json_data)

            images = @instance.get_images('screenshots', language: language, edit_id: edit_id, app_id: app_id)
            expect(images).to eq([
                                   'amzn1.dex.asset.f98f7b86f7674a7e9ed9192273fc9b56',
                                   'amzn1.dex.asset.991a8f7d43254282842896da7bd68f5e'
                                 ])
          end

          it 'uploads an image' do
            stub_request(:post, "#{base_url}/edits/#{edit_id}/listings/#{language}/screenshots/upload").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: { id: 'amzn1.dex.asset.abc123' })

            @instance.etag_cache[[edit_id, language].join('-')] = 'etag-value'
            result = @instance.upload_image(filepath, image_type: 'screenshots', language: language, edit_id: edit_id, app_id: app_id)
            expect(result).to eq('amzn1.dex.asset.abc123')
          end

          it 'deletes an image' do
            asset_id = 'amzn1.dex.asset.abc123'

            stub_request(:delete, "#{base_url}/edits/#{edit_id}/listings/#{language}/screenshots/#{asset_id}").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            @instance.etag_cache[[edit_id, language].join('-')] = 'etag-value'
            result = @instance.delete_image(asset_id, image_type: 'screenshots', language: language, edit_id: edit_id, app_id: app_id)
            expect(result).to be nil
          end

          it 'deletes all images' do
            stub_request(:delete, "#{base_url}/edits/#{edit_id}/listings/#{language}/screenshots").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            @instance.etag_cache[[edit_id, language].join('-')] = 'etag-value'
            result = @instance.delete_all_images('screenshots', language: language, edit_id: edit_id, app_id: app_id)
            expect(result).to be nil
          end
        end

        describe 'videos functionality' do
          let(:filepath) { File.join(__dir__, '..', '..', 'fixtures', 'mock-video.mp4') }
          let(:language) { 'en-US' }
          let(:json_data) do
            [
              { id: 'amzn1.dex.asset.f98f7b86f7674a7e9ed9192273fc9b56' }
            ]
          end

          it 'gets all videos' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/listings/#{language}/videos").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: json_data)

            images = @instance.get_videos(language: language, edit_id: edit_id, app_id: app_id)
            expect(images).to eq(['amzn1.dex.asset.f98f7b86f7674a7e9ed9192273fc9b56'])
          end

          it 'uploads a video' do
            stub_request(:post, "#{base_url}/edits/#{edit_id}/listings/#{language}/videos").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: { id: 'amz1.dex.asset.video1' })

            @instance.etag_cache[[edit_id, language].join('-')] = 'etag-value'
            result = @instance.upload_video(filepath, language: language, edit_id: edit_id, app_id: app_id)
            expect(result).to eq('amz1.dex.asset.video1')
          end

          it 'deletes a video' do
            asset_id = 'amz1.dex.asset.video1'
            stub_request(:delete, "#{base_url}/edits/#{edit_id}/listings/#{language}/videos/#{asset_id}").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            @instance.etag_cache[[edit_id, language].join('-')] = 'etag-value'
            result = @instance.delete_video(asset_id, language: language, edit_id: edit_id, app_id: app_id)
            expect(result).to be nil
          end

          it 'deletes all videos' do
            stub_request(:delete, "#{base_url}/edits/#{edit_id}/listings/#{language}/videos").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 204)

            @instance.etag_cache[[edit_id, language].join('-')] = 'etag-value'
            result = @instance.delete_all_videos(language: language, edit_id: edit_id, app_id: app_id)
            expect(result).to be nil
          end
        end

        describe 'availability functionality' do
          let(:json_data) do
            {
              publishingDate: {
                dateTime: '2022-02-27T15:19:37',
                zoneId: 'US/Central'
              }
            }
          end
          it 'gets availability' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/availability").
              to_return(status: 200, body: json_data)

            result = @instance.get_availability(edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Availability.new(json_data))
          end

          it 'updates availability' do
            stub_request(:put, "#{base_url}/edits/#{edit_id}/availability").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: json_data)

            etag_key = [edit_id, 'availability'].join('-')
            @instance.etag_cache[etag_key] = 'etag-value'
            availability = Fastlane::ActionSets::Amazon::Availability.new(json_data)
            result = @instance.update_availability(availability, edit_id: edit_id, app_id: app_id)
            expect(result.publishing_date.zone_id).to eq('US/Central')
          end
        end

        describe 'targeting functionality' do
          let(:apk_id) { 'M8FYZDFK0GJG0 ' }
          let(:json_data) do
            {
              'amazonDevices' => [
                {
                  "id" => "amzn1.appstore.device.177APHJPEZKTD",
                  "name" => "Fire TV Stick 4K",
                  "reason" => {},
                  "status" => "TARGETING"
                }
              ],
              'nonAmazonDevices' => []
            }
          end

          it 'gets targeting' do
            stub_request(:get, "#{base_url}/edits/#{edit_id}/apks/#{apk_id}/targeting").
              to_return(status: 200, body: json_data)

            result = @instance.get_targeting(apk_id: apk_id, edit_id: edit_id, app_id: app_id)
            expect(result).to eq(Fastlane::ActionSets::Amazon::Targeting.new(json_data))
          end

          it 'updates targeting' do
            stub_request(:put, "#{base_url}/edits/#{edit_id}/apks/#{apk_id}/targeting").
              with(headers: { 'If-Match' => 'etag-value' }).
              to_return(status: 200, body: json_data)

            etag_key = [apk_id, 'targeting'].join('-')
            @instance.etag_cache[etag_key] = 'etag-value'
            targeting = Fastlane::ActionSets::Amazon::Targeting.new(json_data)
            result = @instance.update_targeting(targeting, apk_id: apk_id, edit_id: edit_id, app_id: app_id)
            expect(result.amazon_devices.count).to eq(1)
            expect(result.non_amazon_devices.count).to eq(0)
          end
        end
      end
    end
  end
end
