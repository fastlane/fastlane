require 'credentials_manager/appfile_config'

describe CredentialsManager do
  describe CredentialsManager::AppfileConfig do
    describe "#load_for_lane_configuration" do
      it "overrides Appfile configuration with current driven lane." do
        ENV["FASTLANE_LANE_NAME"] = :beta.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1.beta')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('3ECBP458CC')

        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('enterprise.com')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :something.to_s
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('platform.com')
      end
    end

    describe "#load_for_platform_configuration" do
      it "overrides Appfile configuration with current platform." do
        ENV["FASTLANE_LANE_NAME"] = nil
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile2').data[:app_identifier]).to eq('net.sunapps.ios')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile2').data[:apple_id]).to eq('fabio@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile2').data[:team_id]).to eq('3ECBP458AA')

        ENV["FASTLANE_PLATFORM_NAME"] = :osx.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile2').data[:app_identifier]).to eq('net.sunapps.osx')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile2').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile2').data[:team_id]).to eq('Q2CBPJ58AA')
      end
    end

    describe "#load_for_platform_for_lane_configuration" do
      it "overrides Appfile configuration with current platform and specified lane." do
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile3').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile3').data[:app_identifier]).to eq('net.sunapps.enterprise')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile3').data[:team_id]).to eq('Q2CBPJ58AA')
      end
    end

    describe "#load_for_platform_configurations_same_name_lane" do
      it "overrides Appfile configuration with two different specified platforms name and lanes with same name." do
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile4').data[:apple_id]).to eq('fabio@sunapps.ios.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile4').data[:app_identifier]).to eq('net.sunapps.ios.enterprise')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile4').data[:team_id]).to eq('Q2CBPJ58AA')

        ENV["FASTLANE_PLATFORM_NAME"] = :osx.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile4').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile4').data[:app_identifier]).to eq('net.sunapps.osx.enterprise')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile4').data[:team_id]).to eq('3ECBP458AA')
      end
    end

    describe "#load_using_blocks" do
      it "can load Appfile configurations if the setters are passed blocks instead of values." do
        ENV["FASTLANE_PLATFORM_NAME"] = nil
        ENV["FASTLANE_LANE_NAME"] = nil

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile5').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile5').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile5').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile5').data[:apple_id]).to eq('fabio@sunapps.ios.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile5').data[:app_identifier]).to eq('net.sunapps.ios.enterprise')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile5').data[:team_id]).to eq('Q2CBPJ58AA')
      end
    end

    describe "#load_default_configuration_no_lane_or_configuration_found" do
      it "loads Appfile default values for current platform and lane if no override is found" do
        ENV["FASTLANE_LANE_NAME"] = :this_is_not_something_you_find_in_the_app_file.to_s
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = :this_is_not_something_you_find_in_the_app_file.to_s
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end

    describe "#load_default_configuration" do
      it "loads Appfile default values if any lane or platform is found" do
        ENV["FASTLANE_LANE_NAME"] = nil
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = nil
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('net.sunapps.1')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end

    describe "#load_lane_configuration_if_platform_specifier_is_blank" do
      it "ignores the platform specifier if it is blank" do
        ENV["FASTLANE_LANE_NAME"] = "enterprise"
        ENV["FASTLANE_PLATFORM_NAME"] = ""
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('enterprise.com')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = "    "
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:app_identifier]).to eq('enterprise.com')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile1').data[:team_id]).to eq('Q2CBPJ58CC')
      end
    end

    describe "#load_for_lane_configuration_with_specified_platform" do
      it "overrides Appfile configuration with current platform and specified lane." do
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :beta.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile6').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile6').data[:app_identifier]).to eq('com.app.beta')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile6').data[:team_id]).to eq('Q2CBPJ58CC')

        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :enterprise.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile6').data[:apple_id]).to eq('felix@sunapps.net')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile6').data[:app_identifier]).to eq('enterprise.com')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile6').data[:team_id]).to eq('Q2CBPJ58AA')
      end
    end

    describe "Appfile7" do
      it "supports the old syntax too" do
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s
        ENV["FASTLANE_LANE_NAME"] = :beta.to_s
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile7').data[:app_identifier]).to eq('abc.xyz')
      end

      it "doesn't return empty strings but nil instead" do
        ENV.delete("FASTLANE_USER")
        ENV.delete("DELIVER_USER")
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile7').data[:apple_id]).to eq(nil)
      end
    end

    describe "Appfile8" do
      it "allows dynamic creation of for_lane blocks" do
        ENV["FASTLANE_LANE_NAME"] = nil
        ENV["FASTLANE_PLATFORM_NAME"] = :ios.to_s

        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile8').data[:app_identifier]).to eq('*')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile8').data[:apple_id]).to eq('myAppleId@mail.com')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile8').data[:team_id]).to eq(nil)

        ENV["FASTLANE_LANE_NAME"] = :lane_name1.to_s
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile8').data[:app_identifier]).to eq('lane_name1.*')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile8').data[:apple_id]).to eq('otherAppleId@mail.com')
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile8').data[:team_id]).to eq('TEAMID')
      end
    end

    describe "Appfile9" do
      it "falls back to environment variable `FASTLANE_USER` for the username" do
        env_name = "User@#{Time.now.to_i}"
        ENV["FASTLANE_USER"] = env_name
        ENV["DELIVER_USER"] = "This shouldn't be the value, as fastlane is more important"
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile9').data[:apple_id]).to eq(env_name)
        ENV.delete("FASTLANE_USER")
        ENV.delete("DELIVER_USER")
      end

      it "falls back to environment variable `DELIVER_USER` for the username" do
        env_name = "User@#{Time.now.to_i}"
        ENV["FASTLANE_USER"] = env_name
        expect(CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile9').data[:apple_id]).to eq(env_name)
        ENV.delete("DELIVER_USER")
      end
    end

    describe "No Appfile" do
      it "prefills information from the environment variable" do
        env_name = "User@#{Time.now.to_i}"
        ENV["DELIVER_USER"] = env_name
        expect(CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)).to eq(env_name)
        ENV.delete("DELIVER_USER")
      end
    end

    describe "'smart quotes' handling" do
      it "still gets the needed information from the Appfile" do
        config = CredentialsManager::AppfileConfig.new('credentials_manager/spec/fixtures/Appfile_smart_quotes')

        expect(config.data[:apple_id]).to eq('appfile@krausefx.com')
        expect(config.data[:app_identifier]).to eq('such.app')
      end
    end
  end

  after(:each) do
    ENV.delete("FASTLANE_USER")
    ENV.delete("DELIVER_USER")
  end
end
