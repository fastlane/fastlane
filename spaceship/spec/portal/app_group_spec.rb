describe Spaceship::Portal::AppGroup do
  before { Spaceship.login }
  let(:client) { Spaceship::Portal::AppGroup.client }

  describe "successfully loads and parses all app groups" do
    it "the number is correct" do
      expect(Spaceship::Portal::AppGroup.all.count).to eq(2)
    end

    it "inspect works" do
      expect(Spaceship::Portal::AppGroup.all.first.inspect).to include("Portal::AppGroup")
    end

    it "parses app group correctly" do
      group = Spaceship::Portal::AppGroup.all.first

      expect(group.group_id).to eq("group.com.example.one")
      expect(group.name).to eq("First group")
      expect(group.status).to eq("current")
      expect(group.app_group_id).to eq("44V62UZ8L7")
      expect(group.prefix).to eq("9J57U9392R")
    end

    it "allows modification of values and properly retrieving them" do
      group = Spaceship::AppGroup.all.first
      group.name = "12"
      expect(group.name).to eq("12")
    end
  end

  describe "Filter app group based on group identifier" do
    it "works with specific App Group IDs" do
      group = Spaceship::Portal::AppGroup.find("group.com.example.two")
      expect(group.app_group_id).to eq("2GKKV64NUG")
    end

    it "returns nil app group ID wasn't found" do
      expect(Spaceship::Portal::AppGroup.find("asdfasdf")).to be_nil
    end
  end

  describe '#create' do
    it 'creates an app group' do
      expect(client).to receive(:create_app_group!).with('Production App Group', 'group.tools.fastlane').and_return({})
      group = Spaceship::Portal::AppGroup.create!(group_id: 'group.tools.fastlane', name: 'Production App Group')
    end
  end

  describe '#delete' do
    subject { Spaceship::Portal::AppGroup.find("group.com.example.two") }
    it 'deletes the app group by a given app_group_id' do
      expect(client).to receive(:delete_app_group!).with('2GKKV64NUG')
      group = subject.delete!
      expect(group.app_group_id).to eq('2GKKV64NUG')
    end
  end
end
