describe Pilot::TesterInstallInfo do
  let(:app) { "fake app" }
  subject(:install_info) { Pilot::TesterInstallInfo.new(app: app) }

  before(:each) do
    allow(app).to receive(:id).and_return("123456789")
  end

  def tester(attributes)
    Spaceship::ConnectAPI::BetaTester.new("1", attributes)
  end

  def device(build_version, platform: "IOS")
    { "appBuildVersion" => build_version, "platform" => platform }
  end

  def installed(devices)
    tester(state: "INSTALLED", appDevices: devices)
  end

  describe "#install_for" do
    context "with public fields" do
      it "splits a combined version and build without a build lookup" do
        expect(Spaceship::ConnectAPI::Build).not_to(receive(:all))

        install = install_info.install_for(installed([device("1.2.3 (1234)")]))

        expect(install.version).to eq("1.2.3")
        expect(install.build).to eq("1234")
        expect(install.display_version).to eq("1.2.3 (1234)")
      end

      it "picks the highest build by numeric comparison" do
        install = install_info.install_for(installed([device("1.2.3 (999)"), device("1.2.4 (1000)")]))

        expect(install.display_version).to eq("1.2.4 (1000)")
      end

      it "looks up the version of a bare build number" do
        expect(Spaceship::ConnectAPI::Build).to(receive(:all)
          .with(app_id: "123456789", build_number: "1234", platform: "IOS")
          .and_return([double("build", app_version: "1.2.3")]))

        install = install_info.install_for(installed([device("1234")]))

        expect(install.display_version).to eq("1.2.3 (1234)")
      end

      it "shows the build number alone when the lookup returns no build" do
        allow(Spaceship::ConnectAPI::Build).to(receive(:all).and_return([]))

        install = install_info.install_for(installed([device("1234")]))

        expect(install.version).to be_nil
        expect(install.display_version).to eq("1234")
      end

      it "looks up the same build and platform once per instance" do
        expect(Spaceship::ConnectAPI::Build).to(receive(:all).once.and_return([double("build", app_version: "1.2.3")]))

        first = install_info.install_for(installed([device("1234")]))
        second = install_info.install_for(installed([device("1234")]))

        expect(first.display_version).to eq("1.2.3 (1234)")
        expect(second.display_version).to eq("1.2.3 (1234)")
      end

      it "passes a nil platform to the lookup when the platform is not known" do
        expect(Spaceship::ConnectAPI::Build).to(receive(:all)
          .with(app_id: "123456789", build_number: "1234", platform: nil)
          .and_return([]))

        install_info.install_for(installed([device("1234", platform: "NEW_PLATFORM")]))
      end

      it "treats a numeric appBuildVersion as a bare build number" do
        allow(Spaceship::ConnectAPI::Build).to(receive(:all).and_return([]))

        install = install_info.install_for(installed([device(1234)]))

        expect(install.build).to eq("1234")
        expect(install.display_version).to eq("1234")
      end

      it "ignores an empty appBuildVersion" do
        expect(Spaceship::ConnectAPI::Build).not_to(receive(:all))

        install = install_info.install_for(installed([device(""), device("1.2.3 (1234)")]))

        expect(install.display_version).to eq("1.2.3 (1234)")
      end

      it "returns nil when the only appBuildVersion is empty" do
        expect(install_info.install_for(installed([device("")]))).to be_nil
      end

      it "skips the lookup without an app" do
        expect(Spaceship::ConnectAPI::Build).not_to(receive(:all))

        install = Pilot::TesterInstallInfo.new(app: nil).install_for(installed([device("1234")]))

        expect(install.display_version).to eq("1234")
      end
    end

    context "with older attributes" do
      it "reads the installed version and build from the metrics-style fields" do
        expect(Spaceship::ConnectAPI::Build).not_to(receive(:all))

        install = install_info.install_for(tester(
                                             betaTesterState: "INSTALLED",
                                             installedCfBundleShortVersionString: "1.3.300",
                                             installedCfBundleVersion: "1113",
                                             appDevices: [device("9999")]
                                           ))

        expect(install.display_version).to eq("1.3.300 (1113)")
        expect(install.build).to eq("1113")
      end

      it "formats a missing version as the metrics fields did" do
        install = install_info.install_for(tester(betaTesterState: "INSTALLED", installedCfBundleVersion: "1113"))

        expect(install.display_version).to eq(" (1113)")
        expect(install.build).to eq("1113")
      end

      it "formats a missing version and build as the metrics fields did" do
        install = install_info.install_for(tester(betaTesterState: "INSTALLED"))

        expect(install.display_version).to eq(" ()")
        expect(install.build).to be_nil
      end

      it "returns nil when the tester is not installed" do
        expect(install_info.install_for(tester(betaTesterState: "INVITED"))).to be_nil
      end
    end

    context "without an install" do
      it "returns nil with no install fields" do
        expect(install_info.install_for(tester({}))).to be_nil
      end

      %w(INVITED ACCEPTED REVOKED).each do |state|
        it "returns nil for state #{state} even with devices" do
          expect(install_info.install_for(tester(state: state, appDevices: [device("1.2.3 (1234)")]))).to be_nil
        end
      end

      it "returns nil for an installed tester with no devices" do
        expect(install_info.install_for(installed([]))).to be_nil
      end

      it "returns nil for an installed tester with appDevices absent" do
        expect(install_info.install_for(tester(state: "INSTALLED"))).to be_nil
      end

      it "returns nil when no device has a build version" do
        expect(install_info.install_for(installed([{ "platform" => "IOS" }]))).to be_nil
      end

      it "ignores devices without a build version" do
        install = install_info.install_for(installed([{ "platform" => "IOS" }, device("1.2.3 (1234)")]))

        expect(install.display_version).to eq("1.2.3 (1234)")
      end

      it "sorts a build that is not a valid version lowest without an error" do
        install = install_info.install_for(installed([device("abc"), device("1.2.3 (12)")]))

        expect(install.display_version).to eq("1.2.3 (12)")
      end
    end
  end
end
