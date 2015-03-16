require 'spec_helper'

describe "Create certificates" do
  regular_apple_id = "felix@sunapps.net"
  enterprise_apple_id = "felix.krause@sunapps.net"

  before :each do
    system("rm -rf /tmp/fastlane_core/")
  end

  it 'AppStore, Development and Ad Hoc' do
    # system("rm -rf /tmp/fastlane_core/")
    # Regular
    ENV["DELIVER_USER"] = regular_apple_id

    Sigh::DeveloperCenter.new.run('net.sunapps.7', Sigh::DeveloperCenter::APPSTORE)
    Sigh::DeveloperCenter.new.run('net.sunapps.7', Sigh::DeveloperCenter::DEVELOPMENT)
    Sigh::DeveloperCenter.new.run('net.sunapps.7', Sigh::DeveloperCenter::ADHOC)

    path = "/tmp/fastlane_core"
    expect(File.exists?(File.join(path, "AdHoc_net.sunapps.7.mobileprovision"))).to equal(true)
    expect(File.exists?(File.join(path, "Distribution_net.sunapps.7.mobileprovision"))).to equal(true)
    expect(File.exists?(File.join(path, "Development_net.sunapps.7.mobileprovision"))).to equal(true)


    # Enterprise
    ENV["DELIVER_USER"] = enterprise_apple_id
    Sigh::DeveloperCenter.new.run('net.sunapps.*', Sigh::DeveloperCenter::APPSTORE)
    expect(File.exists?(File.join(path, "Distribution_net.sunapps.*.mobileprovision"))).to equal(true)
  end

  it "Installs the provisioning profile in the Xcode profile path" do
    # Enterprise
    ENV["DELIVER_USER"] = enterprise_apple_id
    install_path = "~/Library/MobileDevice/Provisioning Profiles/#{ENV["SIGH_UDID"]}.mobileprovision"
    Sigh::DeveloperCenter.new.run('net.sunapps.*', Sigh::DeveloperCenter::APPSTORE)
    expect(File.exists?(install_path)).to equal(true)
  end
end