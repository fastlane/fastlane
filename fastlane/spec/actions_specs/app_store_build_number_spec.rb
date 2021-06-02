require 'ostruct'

describe Fastlane do
  describe Fastlane::FastFile do
    describe "app_store_build_number" do
      it "orders versions array of integers" do
        versions = [3, 5, 1, 0, 4]
        result = Fastlane::Actions::AppStoreBuildNumberAction.order_versions(versions)

        expect(result).to eq(['0', '1', '3', '4', '5'])
      end

      it "orders versions array of integers and string integers" do
        versions = [3, 5, '1', 0, '4']
        result = Fastlane::Actions::AppStoreBuildNumberAction.order_versions(versions)

        expect(result).to eq(['0', '1', '3', '4', '5'])
      end

      it "orders versions array of integers, string integers, floats, and semantic versions string" do
        versions = [3, '1', '2.3', 9, '6.5.4', '11.4.6', 5.6]
        result = Fastlane::Actions::AppStoreBuildNumberAction.order_versions(versions)

        expect(result).to eq(['1', '2.3', '3', '5.6', '6.5.4', '9', '11.4.6'])
      end

      it "returns value as string (with build number as version string)" do
        allow(Fastlane::Actions::AppStoreBuildNumberAction).to receive(:get_build_number).and_return(OpenStruct.new({ build_nr: "1.2.3", build_v: "foo" }))

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_build_number(username: 'name@example.com', app_identifier: 'x.y.z')
        end").runner.execute(:test)

        expect(result).to eq("1.2.3")
      end

      it "returns value as integer (with build number as version number)" do
        allow(Fastlane::Actions::AppStoreBuildNumberAction).to receive(:get_build_number).and_return(OpenStruct.new({ build_nr: "3", build_v: "foo" }))

        result = Fastlane::FastFile.new.parse("lane :test do
          app_store_build_number(username: 'name@example.com', app_identifier: 'x.y.z')
        end").runner.execute(:test)

        expect(result).to eq(3)
      end
    end

    describe "#get_build_number" do
      let(:fake_api_key_json_path) do
        "./spaceship/spec/connect_api/fixtures/asc_key.json"
      end

      let(:platform) do
        "ios"
      end

      let(:app_identifier) do
        "com.fastlane.tools"
      end

      let(:app_version) do
        "1.0.0"
      end

      let(:build_number) do
        "1234"
      end

      let(:app_id) do
        "TXX1234XX"
      end

      let(:app) do
        { platform: platform, app_identifier: app_identifier, id: app_id }
      end

      let(:build) do
        { version: build_number }
      end

      let(:live_version) do
        { build: build, version_string: app_version }
      end

      let(:options) do
        { platform: platform, app_identifier: app_identifier }
      end

      before(:each) do
        allow(Spaceship::ConnectAPI::Platform)
          .to receive(:map)
          .with(platform)
          .and_return(platform)

        allow(Spaceship::ConnectAPI::App)
          .to receive(:find)
          .with(app_identifier)
          .and_return(app)
      end

      describe "what happens when fetching the 'live-version' build number" do
        before(:each) do
          allow(app)
            .to receive(:get_live_app_store_version)
            .with(platform: platform)
            .and_return(live_version)

          allow(live_version)
            .to receive(:build)
            .and_return(build)

          allow(build)
            .to receive(:version)
            .and_return(build_number)

          allow(live_version)
            .to receive(:version_string)
            .and_return(app_version)

          options[:live] = true
        end

        context "when using app store connect api token" do
          before(:each) do
            allow(Spaceship::ConnectAPI)
              .to receive(:token)
              .and_return(Spaceship::ConnectAPI::Token.from(filepath: fake_api_key_json_path))
          end

          it "uses the existing API token if found and fetches the latest build number for live-version" do
            expect(Spaceship::ConnectAPI::Token).to receive(:from).with(hash: nil, filepath: nil).and_return(false)
            expect(UI).to receive(:message).with("Using existing authorization token for App Store Connect API")
            expect(UI).to receive(:message).with("Fetching the latest build number for live-version")
            expect(UI).to receive(:message).with("Latest upload for live-version #{app_version} is build: #{build_number}")

            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end

          it "creates and sets new API token using config api_key and api_key_path and fetches the latest build number for live-version" do
            expect(Spaceship::ConnectAPI::Token).to receive(:from).with(hash: "api_key", filepath: "api_key_path").and_return(true)
            expect(UI).to receive(:message).with("Creating authorization token for App Store Connect API")
            expect(Spaceship::ConnectAPI).to receive(:token=)
            expect(UI).to receive(:message).with("Fetching the latest build number for live-version")
            expect(UI).to receive(:message).with("Latest upload for live-version #{app_version} is build: #{build_number}")

            options[:api_key] = "api_key"
            options[:api_key_path] = "api_key_path"
            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end
        end

        context "when using web session" do
          before(:each) do
            allow(Spaceship::ConnectAPI)
              .to receive(:token)
              .and_return(nil)
          end

          it "performs the login using username and password and fetches the latest build number for live-version" do
            expect(options).to receive(:fetch).with(:username, force_ask: true)
            expect(UI).to receive(:message).with("Login to App Store Connect (username)")
            expect(Spaceship::ConnectAPI).to receive(:login)
            expect(UI).to receive(:message).with("Login successful")
            expect(UI).to receive(:message).with("Fetching the latest build number for live-version")
            expect(UI).to receive(:message).with("Latest upload for live-version #{app_version} is build: #{build_number}")

            options[:username] = "username"
            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end
        end
      end

      describe "what happens when fetching the 'testflight' build number" do
        before(:each) do
          allow(Spaceship::ConnectAPI)
            .to receive(:token)
            .and_return(Spaceship::ConnectAPI::Token.from(filepath: fake_api_key_json_path))

          allow(app)
            .to receive(:id)
            .and_return(app_id)

          allow(build)
            .to receive(:version)
            .and_return(build_number)

          allow(build)
            .to receive(:app_version)
            .and_return(app_version)

          options[:live] = false
          expect(UI).to receive(:message).with("Using existing authorization token for App Store Connect API")
        end

        context "when 'version' and 'platform' both params are NOT given in input options" do
          before(:each) do
            options[:version] = nil
            options[:platform] = nil
          end

          it "sets the correct filters and fetches the latest testflight build number with any platform" do
            expected_filter = { app: app_id }
            expect(Spaceship::ConnectAPI::Platform).to receive(:map).with(nil).and_return(nil)
            expect(UI).to receive(:message).with("Fetching the latest build number for any version")
            expect(Spaceship::ConnectAPI).to receive(:get_builds).with(filter: expected_filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1).and_return([build])
            expect(UI).to receive(:message).with("Latest upload for version #{app_version} on any platform is build: #{build_number}")

            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end
        end

        context "when 'version' is NOT given but 'platform' is given in input options" do
          before(:each) do
            options[:version] = nil
            options[:platform] = platform
          end

          it "sets the correct filters and fetches the latest testflight build number with correct platform" do
            expected_filter = { :app => app_id, "preReleaseVersion.platform" => platform }
            expect(UI).to receive(:message).with("Fetching the latest build number for any version")
            expect(Spaceship::ConnectAPI).to receive(:get_builds).with(filter: expected_filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1).and_return([build])
            expect(UI).to receive(:message).with("Latest upload for version #{app_version} on #{platform} platform is build: #{build_number}")

            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end
        end

        context "when 'version' is given but 'platform' is NOT given in input options" do
          before(:each) do
            options[:version] = app_version
            options[:platform] = nil
          end

          it "sets the correct filters and fetches the latest testflight build number with any platform of given version" do
            expected_filter = { :app => app_id, "preReleaseVersion.version" => app_version }
            expect(Spaceship::ConnectAPI::Platform).to receive(:map).with(nil).and_return(nil)
            expect(UI).to receive(:message).with("Fetching the latest build number for version #{app_version}")
            expect(Spaceship::ConnectAPI).to receive(:get_builds).with(filter: expected_filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1).and_return([build])
            expect(UI).to receive(:message).with("Latest upload for version #{app_version} on any platform is build: #{build_number}")

            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end
        end

        context "when 'version' and 'platform' both params are given in input options" do
          before(:each) do
            options[:version] = app_version
            options[:platform] = platform
          end

          it "sets the correct filters and fetches the latest testflight build number with correct platform of given version" do
            expected_filter = { :app => app_id, "preReleaseVersion.platform" => platform, "preReleaseVersion.version" => app_version }
            expect(UI).to receive(:message).with("Fetching the latest build number for version #{app_version}")
            expect(Spaceship::ConnectAPI).to receive(:get_builds).with(filter: expected_filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1).and_return([build])
            expect(UI).to receive(:message).with("Latest upload for version #{app_version} on #{platform} platform is build: #{build_number}")

            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(build_number)
            expect(result.build_v).to eq(app_version)
          end
        end

        context "when could not found the build and 'initial_build_number' is NOT given in input options" do
          before(:each) do
            expected_filter = { :app => app_id, "preReleaseVersion.platform" => platform, "preReleaseVersion.version" => app_version }
            allow(Spaceship::ConnectAPI)
              .to receive(:get_builds)
              .with(filter: expected_filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1)
              .and_return([nil])

            options[:version] = app_version
            options[:platform] = platform
            options[:initial_build_number] = nil
          end

          it "raises an exception" do
            expect(UI).to receive(:message).with("Fetching the latest build number for version #{app_version}")
            expect(UI).to receive(:important).with("Could not find a build for version #{app_version} on #{platform} platform on App Store Connect")
            expect(UI).to receive(:user_error!).with("Could not find a build on App Store Connect - and 'initial_build_number' option is not set")

            Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
          end
        end

        context "when could not found the build but 'initial_build_number' is given in input options" do
          before(:each) do
            expected_filter = { :app => app_id, "preReleaseVersion.platform" => platform, "preReleaseVersion.version" => app_version }
            allow(Spaceship::ConnectAPI)
              .to receive(:get_builds)
              .with(filter: expected_filter, sort: "-uploadedDate", includes: "preReleaseVersion", limit: 1)
              .and_return([nil])

            options[:version] = app_version
            options[:platform] = platform
            options[:initial_build_number] = 5678
          end

          it "fallbacks to 'initial_build_number' input param" do
            expect(UI).to receive(:message).with("Fetching the latest build number for version #{app_version}")
            expect(UI).to receive(:important).with("Could not find a build for version #{app_version} on #{platform} platform on App Store Connect")
            expect(UI).to receive(:message).with("Using initial build number of 5678")

            result = Fastlane::Actions::AppStoreBuildNumberAction.get_build_number(options)
            expect(result.build_nr).to eq(5678)
            expect(result.build_v).to eq(app_version)
          end
        end
      end
    end
  end
end
