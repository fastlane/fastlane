describe Supply do
  describe Supply::Client do
    let(:service_account_file) { File.read(fixture_file("sample-service-account.json")) }
    before do
      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token").
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      stub_request(:post, "https://www.googleapis.com/androidpublisher/v2/applications/test-app/edits").
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
    end

    it "displays error messages from the API" do
      stub_request(:post, "https://www.googleapis.com/upload/androidpublisher/v2/applications/test-app/edits//listings/en-US/icon").
        to_return(status: 403, body: '{"error":{"message":"Ensure project settings are enabled."}}', headers: { 'Content-Type' => 'application/json' })

      expect(UI).to receive(:user_error!).with("Google Api Error: Invalid request - Ensure project settings are enabled.")
      client = Supply::Client.new(service_account_json: StringIO.new(service_account_file), params: { timeout: 1 })
      client.begin_edit(package_name: 'test-app')
      client.upload_image(image_path: fixture_file("playstore-icon.png"),
                          image_type: "icon",
                            language: "en-US")
    end

    describe "AndroidPublisher" do
      let(:subject) { Androidpublisher::AndroidPublisherService.new }

      # Verify that the Google API client has all the expected methods we use.
      it "has all the expected Google API methods" do
        expect(subject.class.method_defined?(:commit_edit)).to eq(true)
        expect(subject.class.method_defined?(:delete_edit)).to eq(true)
        expect(subject.class.method_defined?(:delete_all_images)).to eq(true)
        expect(subject.class.method_defined?(:get_listing)).to eq(true)
        expect(subject.class.method_defined?(:get_track)).to eq(true)
        expect(subject.class.method_defined?(:insert_edit)).to eq(true)
        expect(subject.class.method_defined?(:list_apk_listings)).to eq(true)
        expect(subject.class.method_defined?(:list_apks)).to eq(true)
        expect(subject.class.method_defined?(:list_edit_bundles)).to eq(true)
        expect(subject.class.method_defined?(:list_images)).to eq(true)
        expect(subject.class.method_defined?(:list_listings)).to eq(true)
        expect(subject.class.method_defined?(:update_apk_listing)).to eq(true)
        expect(subject.class.method_defined?(:update_listing)).to eq(true)
        expect(subject.class.method_defined?(:update_track)).to eq(true)
        expect(subject.class.method_defined?(:upload_apk)).to eq(true)
        expect(subject.class.method_defined?(:upload_edit_bundle)).to eq(true)
        expect(subject.class.method_defined?(:upload_edit_deobfuscationfile)).to eq(true)
        expect(subject.class.method_defined?(:upload_expansion_file)).to eq(true)
        expect(subject.class.method_defined?(:upload_image)).to eq(true)
        expect(subject.class.method_defined?(:validate_edit)).to eq(true)
      end
    end
  end
end
