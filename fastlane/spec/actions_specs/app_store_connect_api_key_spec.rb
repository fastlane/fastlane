describe Fastlane do
  describe Fastlane::FastFile do
    describe "App Store Connect API Key" do
      let(:fake_api_key_p8_path) { File.absolute_path("./spaceship/spec/connect_api/fixtures/asc_key.p8") }
      let(:fake_api_key_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key.json" }
      let(:fake_api_key_in_house_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key_in_house.json" }

      let(:key_id) { "D484D98393" }
      let(:issuer_id) { "32423-234234-234324-234" }

      it "with key_filepath" do
        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api_key(
            key_id: '#{key_id}',
            issuer_id: '#{issuer_id}',
            key_filepath: '#{fake_api_key_p8_path}',
          )
        end").runner.execute(:test)

        hash = {
          key_id: key_id,
          issuer_id: issuer_id,
          key: File.binread(fake_api_key_p8_path),
          duration: nil,
          in_house: nil
        }

        expect(result).to eq(hash)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY]).to eq(hash)
      end

      it "with key_content" do
        key_content = File.binread(fake_api_key_p8_path)

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_connect_api_key(
            key_id: '#{key_id}',
            issuer_id: '#{issuer_id}',
            key_content: '#{key_content}',
            duration: 200,
            in_house: true
          )
        end").runner.execute(:test)

        hash = {
          key_id: key_id,
          issuer_id: issuer_id,
          key: key_content,
          duration: 200,
          in_house: true
        }

        expect(result).to eq(hash)
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
    end
  end
end
