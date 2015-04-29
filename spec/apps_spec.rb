require 'spec_helper'

describe Spaceship::Apps do
  let(:client) { Spaceship::Client.instance }
  before { Spaceship::Client.login }
  describe "successfully loads and parses all apps" do
    it "the number is correct" do
      expect(subject.count).to eq(5)
    end

    it "parses app correctly" do
      app = subject.first

      expect(app.app_id).to eq("B7JBD8LHAA")
      expect(app.name).to eq("The App Name")
      expect(app.platform).to eq("ios")
      expect(app.prefix).to eq("5A997XSHK2")
      expect(app.bundle_id).to eq("net.sunapps.151")
      expect(app.is_wildcard).to eq(false)
    end

    it "parses wildcard apps correctly" do
      app = subject.last

      expect(app.app_id).to eq("L42E9BTRAA")
      expect(app.name).to eq("SunApps")
      expect(app.platform).to eq("ios")
      expect(app.prefix).to eq("5A997XSHK2")
      expect(app.bundle_id).to eq("net.sunapps.*")
      expect(app.is_wildcard).to eq(true)
    end
  end


  describe "Filter app based on app identifier" do

    it "works with specific App IDs" do
      app = subject.find("net.sunapps.151")
      expect(app.app_id).to eq("B7JBD8LHAA")
      expect(app.is_wildcard).to eq(false)
    end

    it "works with wilcard App IDs" do
      app = subject.find("net.sunapps.*")
      expect(app.app_id).to eq("L42E9BTRAA")
      expect(app.is_wildcard).to eq(true)
    end

    it "returns nil app ID wasn't found" do
      expect(subject.find("asdfasdf")).to be_nil
    end
  end

  describe '#create' do
    it 'creates an app id with an explicit bundle_id' do
      expect(client).to receive(:create_app).with(:explicit, 'Production App', 'tools.fastlane.spaceship.some-explicit-app') {
        {'isWildCard' => true}
      }
      app = subject.create('tools.fastlane.spaceship.some-explicit-app', 'Production App')
      expect(app.is_wildcard).to eq(true)
    end

    it 'creates an app id with a wildcard bundle_id' do
      expect(client).to receive(:create_app).with(:wildcard, 'Development App', 'tools.fastlane.spaceship.*') {
        {'isWildCard' => false}
      }
      app = subject.create('tools.fastlane.spaceship.*', 'Development App')
      expect(app.is_wildcard).to eq(false)
    end
  end
end
