describe Fastlane do
  describe Fastlane::FastFile do
    APPALOOSA_SERVER = Fastlane::Actions::AppaloosaAction::APPALOOSA_SERVER

    describe 'Appaloosa Integration' do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end
      let(:appaloosa_lane) do
        "lane :test do appaloosa(
          {
            binary:      './fastlane/spec/fixtures/fastfiles/Fastfile1',
            api_token:   'xxx',
            store_id:    '556',
            screenshots: ''
          }
        ) end"
      end

      context 'without ipa or apk' do
        let(:appaloosa_lane) { "lane :test do appaloosa({ api_token: 'xxx', store_id:  'xxx' }) end" }

        it 'raises a Fastlane error' do
          expect { Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Couldn't find ipa/)
            end
          )
        end
      end

      context 'without api_token' do
        let(:appaloosa_lane) do
          "lane :test do appaloosa(
            {
                store_id: 'xxx',
                binary: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            }
          ) end"
        end

        it 'raises a Fastlane error for missing api_token' do
          expect { Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/No value found for 'api_token'/)
            end
          )
        end
      end

      context 'without store_id' do
        let(:appaloosa_lane) do
          "lane :test do appaloosa(
            {
                api_token: 'xxx',
                binary: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            }
          ) end"
        end

        it 'raises a Fastlane error for missing store_id' do
          expect { Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match("No value found for 'store_id'")
            end
          )
        end
      end

      context 'when upload_service returns an error' do
        before do
          stub_request(:get, "#{APPALOOSA_SERVER}/upload_services/presign_form?api_key=xxx&file=Fastfile1&group_ids=&store_id=556").
            to_return(status: 200, body: '{ "errors": "A group id is incorrect" }', headers: {})
        end

        it 'returns group_id errors' do
          expect { Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match('ERROR: A group id is incorrect')
            end
          )
        end
      end

      context 'when get_s3_url return a 404' do
        let(:presign_s3_key) { Base64.encode64('https://appaloosa.com/test') }
        let(:presign_payload) { { s3_sign: presign_s3_key, path: 'https://appaloosa.com/file.apk' }.to_json }
        let(:expect_error) { 'ERROR: A problem occurred with your API token and your store id. Please try again.' }

        before do
          stub_request(:get, "#{APPALOOSA_SERVER}/upload_services/presign_form?api_key=xxx&file=Fastfile1&group_ids=&store_id=556").
            to_return(status: 200, body: presign_payload)
          stub_request(:put, "http://appaloosa.com/test").
            to_return(status: 200)
          stub_request(:get, "#{APPALOOSA_SERVER}/556/upload_services/url_for_download?api_key=xxx&key=https://appaloosa.com/file.apk&store_id=556").
            to_return(status: 404)
        end

        it 'raises a Fastlane error for problem with API token or store id' do
          expect { Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to eq(expect_error)
            end
          )
        end
      end

      context 'when get_s3_url return a 403' do
        let(:presign_s3_key) { Base64.encode64('https://appaloosa.com/test') }
        let(:presign_payload) { { s3_sign: presign_s3_key, path: 'https://appaloosa.com/file.apk' }.to_json }
        let(:expect_error) { 'ERROR: A problem occurred with your API token and your store id. Please try again.' }

        before do
          stub_request(:get, "#{APPALOOSA_SERVER}/upload_services/presign_form?api_key=xxx&file=Fastfile1&group_ids=&store_id=556").
            to_return(status: 200, body: presign_payload)
          stub_request(:put, "http://appaloosa.com/test").
            to_return(status: 200)
          stub_request(:get, "#{APPALOOSA_SERVER}/556/upload_services/url_for_download?api_key=xxx&key=https://appaloosa.com/file.apk&store_id=556").
            to_return(status: 403)
        end

        it 'raises a Fastlane error for problem with API token or store id' do
          expect { Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to eq(expect_error)
            end
          )
        end
      end

      context 'with valid parameters' do
        let(:presign_s3_key) { Base64.encode64('https://appaloosa.com/test') }
        let(:presign_payload) { { s3_sign: presign_s3_key, path: 'https://appaloosa.com/file.apk' }.to_json }
        let(:upload_services_payload) do
          {
            store_id: '673',
            api_key: '80d982459eac288245c9',
            key: 'https://appaloosa.com/fastlane/mqkaoev2/iphone6-screenshot2.png'
          }.to_json
        end

        before do
          stub_request(:get, "#{APPALOOSA_SERVER}/upload_services/presign_form?api_key=xxx&file=Fastfile1&group_ids=&store_id=556").
            to_return(status: 200, body: presign_payload, headers: {})
          stub_request(:put, "http://appaloosa.com/test").
            to_return(status: 200, body: '', headers: {})
          stub_request(:get, "#{APPALOOSA_SERVER}/556/upload_services/url_for_download?api_key=xxx&key=https://appaloosa.com/file.apk&store_id=556").
            to_return(status: 200, body: upload_services_payload, headers: {})
        end

        it 'works with valid parameters' do
          Fastlane::FastFile.new.parse(appaloosa_lane).runner.execute(:test)
        end
      end
    end
  end
end
