require 'credentials_manager/appfile_config'

describe CredentialsManager do
  describe CredentialsManager::AppfileConfig do
    describe "#load_for_lane_configuration" do
      it "overrides Appfile configuration with current driven lane: beta" do
        ENV["FASTLANE_LANE_NAME"] = :beta.to_s

        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1.beta')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('3ECBP458CC')

        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('enterprise.com')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end

    describe "#load_default_configuration_no_lane_found" do
      it "loads Appfile default values for current driven lane if no override is found" do
        ENV["FASTLANE_LANE_NAME"] = :this_is_not_something_you_find_in_the_app_file.to_s
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end

    describe "#load_default_configuration" do
      it "loads Appfile default values if no any lane is found" do
        ENV["FASTLANE_LANE_NAME"] = nil
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end
  end
end