require 'spec_helper'

describe Spaceship::Portal::Merchant do
  let(:mock_client) { double('MockClient') }

  before do
    allow(Spaceship::Portal::Merchant).to receive(:client).and_return(mock_client)
  end

  describe ".all" do
    it "fetches all merchants" do
      mock_client_response(:merchants, with: any_args) do
        [
          {
            name: "ExampleApp Production",
            prefix: "9J57U9392R",
            identifier: "merchant.com.example.app.production",
            status: "current",
            omcId: "LM3IY56BXC"
          },
          {
            name: "ExampleApp Sandbox",
            prefix: "9J57U9392R",
            identifier: "merchant.com.example.app.sandbox",
            status: "current",
            omcId: "Z6676498T7"
          }
        ]
      end

      merchants = Spaceship::Portal::Merchant.all
      expect(merchants.count).to eq(2)
      expect(merchants.first).to be_instance_of(Spaceship::Portal::Merchant)
    end
  end

  describe ".find" do
    it "works with specific Merchant IDs" do
      mock_client_response(:merchants, with: any_args) do
        [
          {
            name: "ExampleApp Production",
            prefix: "9J57U9392R",
            identifier: "merchant.com.example.app.production",
            status: "current",
            omcId: "LM3IY56BXC"
          },
          {
            name: "ExampleApp Sandbox",
            prefix: "9J57U9392R",
            identifier: "merchant.com.example.app.sandbox",
            status: "current",
            omcId: "Z6676498T7"
          }
        ]
      end

      merchant = Spaceship::Portal::Merchant.find("merchant.com.example.app.sandbox")
      expect(merchant).to be_instance_of(Spaceship::Portal::Merchant)
      expect(merchant.merchant_id).to eq("Z6676498T7")
    end

    it "returns nil when merchant ID wasn't found" do
      mock_client_response(:merchants, with: any_args) do
        [
          {
            name: "ExampleApp Production",
            prefix: "9J57U9392R",
            identifier: "merchant.com.example.app.production",
            status: "current",
            omcId: "LM3IY56BXC"
          }
        ]
      end

      expect(Spaceship::Portal::Merchant.find("asdfasdf")).to be_nil
    end
  end

  describe ".create" do
    it 'creates a merchant' do
      allow(mock_client).to receive(:create_merchant!).with("ExampleApp Production", "merchant.com.example.app.production", mac: anything).and_return(
        JSON.parse({
          name: "ExampleApp Production",
          prefix: "9J57U9392R",
          identifier: "merchant.com.example.app.production",
          status: "current",
          omcId: "LM3IY56BXC"
        }.to_json)
      )

      merchant = Spaceship::Portal::Merchant.create!(bundle_id: "merchant.com.example.app.production", name: "ExampleApp Production", mac: false)
      expect(merchant).to be_instance_of(Spaceship::Portal::Merchant)
      expect(merchant.merchant_id).to eq("LM3IY56BXC")
      expect(merchant.bundle_id).to eq("merchant.com.example.app.production")
      expect(merchant.name).to eq("ExampleApp Production")
    end
  end

  describe ".delete" do
    it 'deletes the merchant by a given merchant_id' do
      mock_client_response(:merchants, with: any_args) do
        [
          {
            name: "ExampleApp Production",
            prefix: "9J57U9392R",
            identifier: "merchant.com.example.app.production",
            status: "current",
            omcId: "LM3IY56BXC"
          }
        ]
      end

      allow(mock_client).to receive(:delete_merchant!).with("LM3IY56BXC", mac: anything)

      subject = Spaceship::Portal::Merchant.find("merchant.com.example.app.production")
      merchant = subject.delete!
      expect(merchant.merchant_id).to eq('LM3IY56BXC')
    end
  end
end
