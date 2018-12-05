describe Spaceship::Portal::App do
  before { Spaceship.login }
  let(:client) { Spaceship::Portal::App.client }

  describe "successfully loads and parses all apps" do
    it "the number is correct" do
      expect(Spaceship::Portal::App.all.count).to eq(5)
    end

    it "inspect works" do
      expect(Spaceship::Portal::App.all.first.inspect).to include("Portal::App")
    end

    it "parses app correctly" do
      app = Spaceship::Portal::App.all.first

      expect(app.app_id).to eq("B7JBD8LHAA")
      expect(app.name).to eq("The App Name")
      expect(app.platform).to eq("ios")
      expect(app.prefix).to eq("5A997XSHK2")
      expect(app.bundle_id).to eq("net.sunapps.151")
      expect(app.is_wildcard).to eq(false)
    end

    it "parses wildcard apps correctly" do
      app = Spaceship::Portal::App.all.last

      expect(app.app_id).to eq("L42E9BTRAA")
      expect(app.name).to eq("SunApps")
      expect(app.platform).to eq("ios")
      expect(app.prefix).to eq("5A997XSHK2")
      expect(app.bundle_id).to eq("net.sunapps.*")
      expect(app.is_wildcard).to eq(true)
    end

    it "parses app details correctly" do
      app = Spaceship::Portal::App.all.first
      app = app.details

      expect(app.app_id).to eq("B7JBD8LHAA")
      expect(app.name).to eq("The App Name")
      expect(app.platform).to eq("ios")
      expect(app.prefix).to eq("5A997XSHK2")
      expect(app.bundle_id).to eq("net.sunapps.151")
      expect(app.is_wildcard).to eq(false)

      expect(app.features).to include("push" => true)
      expect(app.enable_services).to include("push")
      expect(app.dev_push_enabled).to eq(false)
      expect(app.prod_push_enabled).to eq(true)
      expect(app.app_groups_count).to eq(0)
      expect(app.cloud_containers_count).to eq(0)
      expect(app.identifiers_count).to eq(0)
      expect(app.associated_groups.length).to eq(1)
      expect(app.associated_groups[0].group_id).to eq("group.tools.fastlane")
    end

    it "allows modification of values and properly retrieving them" do
      app = Spaceship::App.all.first
      app.name = "12"
      expect(app.name).to eq("12")
    end
  end

  describe "Filter app based on app identifier" do
    it "works with specific App IDs" do
      app = Spaceship::Portal::App.find("net.sunapps.151")
      expect(app.app_id).to eq("B7JBD8LHAA")
      expect(app.is_wildcard).to eq(false)
    end

    it "works with specific App IDs even with different case" do
      app = Spaceship::Portal::App.find("net.sunaPPs.151")
      expect(app.app_id).to eq("B7JBD8LHAA")
      expect(app.is_wildcard).to eq(false)
    end

    it "works with wilcard App IDs" do
      app = Spaceship::Portal::App.find("net.sunapps.*")
      expect(app.app_id).to eq("L42E9BTRAA")
      expect(app.is_wildcard).to eq(true)
    end

    it "returns nil app ID wasn't found" do
      expect(Spaceship::Portal::App.find("asdfasdf")).to be_nil
    end
  end

  describe '#create' do
    it 'creates an app id with an explicit bundle_id' do
      expect(client).to receive(:create_app!).with(:explicit, 'Production App', 'tools.fastlane.spaceship.some-explicit-app', mac: false, enable_services: {}) {
        { 'isWildCard' => true }
      }
      app = Spaceship::Portal::App.create!(bundle_id: 'tools.fastlane.spaceship.some-explicit-app', name: 'Production App')
      expect(app.is_wildcard).to eq(true)
    end

    it 'creates an app id with an explicit bundle_id and no push notifications' do
      expect(client).to receive(:create_app!).with(:explicit, 'Production App', 'tools.fastlane.spaceship.some-explicit-app', mac: false, enable_services: { push_notification: "off" }) {
        { 'enabledFeatures' => ["inAppPurchase"] }
      }
      app = Spaceship::Portal::App.create!(bundle_id: 'tools.fastlane.spaceship.some-explicit-app', name: 'Production App', enable_services: { push_notification: "off" })
      expect(app.enable_services).not_to(include("push"))
    end

    it 'creates an app id with a wildcard bundle_id' do
      expect(client).to receive(:create_app!).with(:wildcard, 'Development App', 'tools.fastlane.spaceship.*', mac: false, enable_services: {}) {
        { 'isWildCard' => false }
      }
      app = Spaceship::Portal::App.create!(bundle_id: 'tools.fastlane.spaceship.*', name: 'Development App')
      expect(app.is_wildcard).to eq(false)
    end
  end

  describe '#delete' do
    subject { Spaceship::Portal::App.find("net.sunapps.151") }
    it 'deletes the app by a given bundle_id' do
      expect(client).to receive(:delete_app!).with('B7JBD8LHAA', mac: false)
      app = subject.delete!
      expect(app.app_id).to eq('B7JBD8LHAA')
    end
  end

  describe '#update_name' do
    subject { Spaceship::Portal::App.find("net.sunapps.151") }
    it 'updates the name of the app by given bundle_id' do
      stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/updateAppIdName.action").
        with(body: { "appIdId" => "B7JBD8LHAA", "name" => "The New Name", "teamId" => "XXXXXXXXXX" }).
        to_return(status: 200, body: PortalStubbing.adp_read_fixture_file('updateAppIdName.action.json'), headers: { 'Content-Type' => 'application/json' })

      app = subject.update_name!('The New Name')
      expect(app.app_id).to eq('B7JBD8LHAA')
      expect(app.name).to eq('The New Name')
    end
  end
end
