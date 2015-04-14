require 'spec_helper'

describe "Create certificates" do
  regular_apple_id = "felix@sunapps.net"
  enterprise_apple_id = "felix.krause@sunapps.net"

  profile_install_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles"
  backup_profile_install_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles Old"

  before :all do
    # move existing folder to backup folder so we can test
    if File.directory?(profile_install_path)
      FileUtils.mv(profile_install_path, backup_profile_install_path)
    end
  end

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

  it "Creates the install path if it does not exist yet" do
    expect(File.directory?(profile_install_path)).to equal(false)

    random_file_name = "test_#{Random.rand(1..10000000000000)}"
    ENV["SIGH_UDID"] = random_file_name

    file_name = "/tmp/#{random_file_name}.mobileprovision"
    FileUtils.touch(file_name)

    Sigh::Manager.install_profile(file_name)

    expect(File.exists?(File.expand_path("~" + "/Library/MobileDevice/Provisioning Profiles/#{random_file_name}.mobileprovision"))).to equal(true)
  end

  it "Installs the provisioning profile in the Xcode profile path" do
    # Enterprise
    ENV["DELIVER_USER"] = enterprise_apple_id
    install_path = "~/Library/MobileDevice/Provisioning Profiles/#{ENV["SIGH_UDID"]}.mobileprovision"
    Sigh::DeveloperCenter.new.run('net.sunapps.*', Sigh::DeveloperCenter::APPSTORE)
    expect(File.exists?(install_path)).to equal(true)
  end

  after :all do
    FileUtils.remove_dir(profile_install_path)
    File.rename(backup_profile_install_path, profile_install_path)
  end
end