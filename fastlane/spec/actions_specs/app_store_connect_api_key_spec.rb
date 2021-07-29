describe Fastlane do
  describe Fastlane::FastFile do
    describe "App Store Connect API Key" do
      let(:fake_api_key_p8_path) { File.absolute_path("./spaceship/spec/connect_api/fixtures/asc_key.p8") }
      let(:fake_api_key_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key.json" }
      let(:fake_api_key_in_house_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key_in_house.json" }

      let(:key_id) { "D484D98393" }
      let(:issuer_id) { "32423-234234-234324-234" }

      it "with key_filepath" do
        hash = {
          key_id: key_id,
          issuer_id: issuer_id,
          key: File.binread(fake_api_key_p8_path),
          is_key_content_base64: false,
          duration: 1200,
          in_house: false
        }

        expect(Spaceship::ConnectAPI::Token).to receive(:create).with(hash).and_return("some fake token")
        expect(Spaceship::ConnectAPI).to receive(:token=).with("some fake token")

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api_key(
            key_id: '#{key_id}',
            issuer_id: '#{issuer_id}',
            key_filepath: '#{fake_api_key_p8_path}',
          )
        end").runner.execute(:test)

        expect(result).to eq(hash)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY]).to eq(hash)
      end

      describe "with key_content" do
        let(:key_content) { File.binread(fake_api_key_p8_path).gsub("\r", '') }

        it "with plain text" do
          hash = {
            key_id: key_id,
            issuer_id: issuer_id,
            key: key_content,
            is_key_content_base64: false,
            duration: 200,
            in_house: true
          }

          expect(Spaceship::ConnectAPI::Token).to receive(:create).with(hash).and_return("some fake token")
          expect(Spaceship::ConnectAPI).to receive(:token=).with("some fake token")

          result = Fastlane::FastFile.new.parse("lane :test do
            app_store_connect_api_key(
              key_id: '#{key_id}',
              issuer_id: '#{issuer_id}',
              key_content: '#{key_content}',
              duration: 200,
              in_house: true
            )
          end").runner.execute(:test)

          expect(result).to eq(hash)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY]).to eq(hash)
        end

        it "with base64 encoded" do
          hash = {
            key_id: key_id,
            issuer_id: issuer_id,
            key: key_content,
            is_key_content_base64: true,
            duration: 200,
            in_house: true
          }

          expect(Spaceship::ConnectAPI::Token).to receive(:create).with(hash).and_return("some fake token")
          expect(Spaceship::ConnectAPI).to receive(:token=).with("some fake token")

          result = Fastlane::FastFile.new.parse("lane :test do
            app_store_connect_api_key(
              key_id: '#{key_id}',
              issuer_id: '#{issuer_id}',
              key_content: '#{key_content}',
              is_key_content_base64: true,
              duration: 200,
              in_house: true
            )
          end").runner.execute(:test)

          expect(result).to eq(hash)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY]).to eq(hash)
        end
      end

      it "raise error when no key_filepath or key_content" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            app_store_connect_api_key(
              key_id: '#{key_id}',
              issuer_id: '#{issuer_id}'
            )
          end").runner.execute(:test)
        end.to raise_error(/:key_content or :key_filepath is required/)
      end

      it "raise error when duration is higher than 20 minutes" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            app_store_connect_api_key(
              key_id: 'foo',
              issuer_id: 'bar',
              key_content: 'derp',
              duration: 1300
            )
          end").runner.execute(:test)
        end.to raise_error("The duration can't be more than 1200 (20 minutes) and the value entered was '1300'")
      end

      it "doesn't create and set api token if 'set_spaceship_token' input option is FALSE" do
        expect(Spaceship::ConnectAPI::Token).not_to receive(:create)
        expect(Spaceship::ConnectAPI).not_to receive(:token=)

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api_key(
            key_id: '#{key_id}',
            issuer_id: '#{issuer_id}',
            key_filepath: '#{fake_api_key_p8_path}',
            set_spaceship_token: false
          )
        end").runner.execute(:test)

        hash = {
          key_id: key_id,
          issuer_id: issuer_id,
          key: File.binread(fake_api_key_p8_path),
          is_key_content_base64: false,
          duration: 500,
          in_house: false
        }

        expect(result).to eq(hash)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY]).to eq(hash)
      end
    end
  end
end
