describe Spaceship::Portal::Merchant do
  before { Spaceship.login }
  let(:client) { Spaceship::Portal::Merchant.client }

  describe "successfully loads and parses all merchants" do
    it "the number is correct" do
      expect(Spaceship::Portal::Merchant.all.count).to eq(2)
    end

    it "inspect works" do
      expect(Spaceship::Portal::Merchant.all.first.inspect).to include("Portal::Merchant")
    end

    it "parses merchant correctly" do
      merchant = Spaceship::Portal::Merchant.all.first

      expect(merchant.merchant_id).to eq("LM3IY56BXC")
      expect(merchant.name).to eq("ExampleApp Production")
      expect(merchant.status).to eq("current")
      expect(merchant.bundle_id).to eq("merchant.com.example.app.production")
      expect(merchant.prefix).to eq("9J57U9392R")
    end

    it "allows modification of values and properly retrieving them" do
      merchant = Spaceship::Merchant.all.first
      merchant.name = "New name"
      expect(merchant.name).to eq("New name")
    end
  end

  describe "Filter merchant based on merchant identifier" do
    it "works with specific Merchant IDs" do
      merchant = Spaceship::Portal::Merchant.find("merchant.com.example.app.sandbox")
      expect(merchant.merchant_id).to eq("Z6676498T7")
    end

    it "returns nil when merchant ID wasn't found" do
      expect(Spaceship::Portal::Merchant.find("asdfasdf")).to be_nil
    end
  end

  describe '#create' do
    it 'creates a merchant' do
      expect(client).to receive(:create_merchant!).with('ExampleApp Production', 'merchant.com.example.app.production', mac: false).and_return({})
      merchant = Spaceship::Portal::Merchant.create!(bundle_id: 'merchant.com.example.app.production', name: 'ExampleApp Production')
    end
  end

  describe '#delete' do
    subject { Spaceship::Portal::Merchant.find("merchant.com.example.app.production") }
    it 'deletes the merchant by a given merchant_id' do
      expect(client).to receive(:delete_merchant!).with('LM3IY56BXC', mac: false)
      merchant = subject.delete!
      expect(merchant.merchant_id).to eq('LM3IY56BXC')
    end
  end
end
