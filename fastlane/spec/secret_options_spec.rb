describe "Options holding secrets" do
  json_key_data = '{"type": "service_account", "private_key": "-----BEGIN PRIVATE KEY-----\nAAAA\n-----END PRIVATE KEY-----\n"}'

  {
    "supply json_key_data" => [-> { Supply::Options.available_options }, :json_key_data, json_key_data],
    "get_managed_play_store_publishing_rights json_key_data" => [-> { Fastlane::Actions::GetManagedPlayStorePublishingRightsAction.available_options }, :json_key_data, json_key_data],
    "match private_token" => [-> { Match::Options.available_options }, :private_token, "glpat-example-1234"],
    "match job_token" => [-> { Match::Options.available_options }, :job_token, "job-token-example-1234"],
    "match s3_access_key" => [-> { Match::Options.available_options }, :s3_access_key, "AKIAEXAMPLE1234"],
    "zip password" => [-> { Fastlane::Actions::ZipAction.available_options }, :password, "zip-password-1234"]
  }.each do |name, (options, key, value)|
    it "masks #{name} in output" do
      FastlaneCore::Configuration.create(options.call, { key => value })

      expect(FastlaneCore::Secrets.mask("value: #{value}")).to eq("value: #{key.upcase}_REDACTED")
    end
  end
end
