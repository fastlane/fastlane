require 'fastlane_core/appfile_config'

describe FastlaneCore do
  describe FastlaneCore::AppfileConfig do
    describe "#load_for_lane_configuration" do
      it "overrides Appfile configuration with current driven lane." do
        ENV["FASTLANE_LANE_NAME"] = :beta.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1.beta')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('3ECBP458CC')

        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('enterprise.com')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_LANE_NAME"] = "ios something"
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('platform.com')
      end
    end

    describe "#load_for_platform_configuration" do
      it "overrides Appfile configuration with current platform." do
        ENV["FASTLANE_LANE_NAME"] = nil
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile2').data[:app_identifier]).to eq('net.sunapps.ios')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile2').data[:apple_id]).to eq('fabio@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile2').data[:team_id]).to eq('3ECBP458AA')

        ENV["FASTLANE_PLATFORM_NAME"] = :osx.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile2').data[:app_identifier]).to eq('net.sunapps.osx')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile2').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile2').data[:team_id]).to eq('Q2CBPJ58AA')
      end
    end

    describe "#load_for_platform_for_lane_configuration" do
      it "overrides Appfile configuration with current platform and specified lane." do
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile3').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile3').data[:app_identifier]).to eq('net.sunapps.enterprise')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile3').data[:team_id]).to eq('Q2CBPJ58AA')
      end
    end

    describe "#load_for_platform_configurations_same_name_lane" do
      it "overrides Appfile configuration with two different specified platforms name and lanes with same name." do
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile4').data[:apple_id]).to eq('fabio@sunapps.ios.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile4').data[:app_identifier]).to eq('net.sunapps.ios.enterprise')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile4').data[:team_id]).to eq('Q2CBPJ58AA')

        ENV["FASTLANE_PLATFORM_NAME"] = :osx.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile4').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile4').data[:app_identifier]).to eq('net.sunapps.osx.enterprise')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile4').data[:team_id]).to eq('3ECBP458AA')
      end
    end


    describe "#load_default_configuration_no_lane_or_configuration_found" do
      it "loads Appfile default values for current platform and lane if no override is found" do
        ENV["FASTLANE_LANE_NAME"] = :this_is_not_something_you_find_in_the_app_file.to_s
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = :this_is_not_something_you_find_in_the_app_file.to_s
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end

    describe "#load_default_configuration" do
      it "loads Appfile default values if any lane or platform is found" do
        ENV["FASTLANE_LANE_NAME"] = nil
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = nil
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(FastlaneCore::AppfileConfig.new('spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end
  end
end