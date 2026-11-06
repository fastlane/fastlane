describe Fastlane::Actions::DownloadAppPrivacyDetailsFromAppStoreAction do
  def config
    FastlaneCore::Configuration.create(described_class.available_options, {})
  end

  it "reads its own environment variables" do
    FastlaneCore::Helper.with_env_values("DOWNLOAD_APP_PRIVACY_DETAILS_FROM_APP_STORE_APP_IDENTIFIER" => "com.example.download",
                                         "DOWNLOAD_APP_PRIVACY_DETAILS_FROM_APP_STORE_OUTPUT_JSON_PATH" => "download.json") do
      expect(config[:app_identifier]).to eq("com.example.download")
      expect(config[:output_json_path]).to eq("download.json")
    end
  end

  it "still reads the upload action's environment variables" do
    FastlaneCore::Helper.with_env_values("UPLOAD_APP_PRIVACY_DETAILS_TO_APP_STORE_APP_IDENTIFIER" => "com.example.upload",
                                         "UPLOAD_APP_PRIVACY_DETAILS_TO_APP_STORE_OUTPUT_JSON_PATH" => "upload.json") do
      expect(config[:app_identifier]).to eq("com.example.upload")
      expect(config[:output_json_path]).to eq("upload.json")
    end
  end
end
