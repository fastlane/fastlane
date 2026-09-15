describe Spaceship::Portal::WebsitePush do
  include_examples "common spaceship login", true
  before { Spaceship.login }
  let(:client) { Spaceship::Portal::WebsitePush.client }

  describe "successfully loads and parses all website pushes" do
    it "the number is correct" do
      expect(Spaceship::Portal::WebsitePush.all.count).to eq(2)
    end

    it "inspect works" do
      expect(Spaceship::Portal::WebsitePush.all.first.inspect).to include("Portal::WebsitePush")
    end

    it "parses website pushes correctly" do
      website_push = Spaceship::Portal::WebsitePush.all.first

      expect(website_push.bundle_id).to eq("web.com.example.one")
      expect(website_push.name).to eq("First Website Push")
      expect(website_push.status).to eq("current")
      expect(website_push.website_id).to eq("44V62UZ8L7")
      expect(website_push.app_id).to eq("44V62UZ8L7")
      expect(website_push.prefix).to eq("9J57U9392R")
    end

    it "allows modification of values and properly retrieving them" do
      website_push = Spaceship::WebsitePush.all.first
      website_push.name = "12"
      expect(website_push.name).to eq("12")
    end
  end

  describe "Filter website pushes based on group identifier" do
    it "works with specific Website Push IDs" do
      website_push = Spaceship::Portal::WebsitePush.find("web.com.example.two")
      expect(website_push.website_id).to eq("R7878HDXC3")
    end

    it "returns nil website push ID wasn't found" do
      expect(Spaceship::Portal::WebsitePush.find("asdfasdf")).to be_nil
    end
  end

  describe '#create' do
    it 'creates a website push' do
      expect(client).to receive(:create_website_push!).with('Fastlane Website Push', 'web.com.fastlane.example', mac: false).and_return({})
      website_push = Spaceship::Portal::WebsitePush.create!(bundle_id: 'web.com.fastlane.example', name: 'Fastlane Website Push')
    end
  end

  describe '#delete' do
    subject { Spaceship::Portal::WebsitePush.find("web.com.example.two") }
    it 'deletes the website push by a given website_id' do
      expect(client).to receive(:delete_website_push!).with('R7878HDXC3', mac: false)
      website_push = subject.delete!
      expect(website_push.website_id).to eq('R7878HDXC3')
    end
  end
end
