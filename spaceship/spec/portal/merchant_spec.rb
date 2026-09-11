require 'spec_helper'

describe Spaceship::Portal::Merchant do
  let(:mock_client) { double('MockClient') }

  let(:merchant) do
    Spaceship::Portal::Merchant.new(JSON.parse({
      name: "ExampleApp Production",
      prefix: "9J57U9392R",
      identifier: "merchant.com.example.app.production",
      status: "current",
      omcId: "LM3IY56BXC"
    }.to_json))
  end

  let(:domain_list) do
    JSON.parse([
      {
        displayId: "5Y57MLHP2K",
        name: "payments.example.com",
        status: "verified",
        path: "https://payments.example.com/.well-known/apple-developer-merchantid-domain-association.txt",
        canVerify: true,
        expirationDate: "2026-10-11",
        expirationDateString: "Oct 11, 2026"
      },
      {
        displayId: "UFVN6788YA",
        name: "www.example.com",
        status: "pending",
        path: "https://www.example.com/.well-known/apple-developer-merchantid-domain-association.txt",
        canVerify: true
      }
    ].to_json)
  end

  before do
    allow(Spaceship::Portal::Merchant).to receive(:client).and_return(mock_client)
    allow(Spaceship::Portal::Merchant::Domain).to receive(:client).and_return(mock_client)
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

  describe "the Mac platform" do
    let(:mac_merchant) do
      {
        name: "ExampleApp Production",
        prefix: "9J57U9392R",
        identifier: "merchant.com.example.app.production",
        status: "current",
        omcId: "LM3IY56BXC"
      }
    end

    it "records the platform a merchant was fetched with" do
      mock_client_response(:merchants, with: { mac: true }) { [mac_merchant] }

      merchant = Spaceship::Portal::Merchant.find("merchant.com.example.app.production", mac: true)
      expect(merchant.mac?).to be(true)
    end

    it "records the platform a merchant was created with" do
      allow(mock_client).to receive(:create_merchant!)
        .with("ExampleApp Production", "merchant.com.example.app.production", mac: true)
        .and_return(JSON.parse(mac_merchant.to_json))

      merchant = Spaceship::Portal::Merchant.create!(bundle_id: "merchant.com.example.app.production", name: "ExampleApp Production", mac: true)
      expect(merchant.mac?).to be(true)
    end

    it "deletes a Mac merchant against the Mac endpoint" do
      mock_client_response(:merchants, with: { mac: true }) { [mac_merchant] }
      expect(mock_client).to receive(:delete_merchant!).with("LM3IY56BXC", mac: true)

      Spaceship::Portal::Merchant.find("merchant.com.example.app.production", mac: true).delete!
    end

    it "leaves an iOS merchant on the iOS endpoint" do
      mock_client_response(:merchants, with: { mac: false }) { [mac_merchant] }
      expect(mock_client).to receive(:delete_merchant!).with("LM3IY56BXC", mac: false)

      merchant = Spaceship::Portal::Merchant.find("merchant.com.example.app.production")
      expect(merchant.mac?).to be(false)
      merchant.delete!
    end
  end

  describe "#domains" do
    it 'fetches the domains registered to this merchant' do
      expect(mock_client).to receive(:merchant_domains).with("LM3IY56BXC", mac: false).and_return(domain_list)

      domains = merchant.domains
      expect(domains.count).to eq(2)
      expect(domains.first).to be_instance_of(Spaceship::Portal::Merchant::Domain)
      expect(domains.first.name).to eq("payments.example.com")
    end

    it 'gives each domain a reference back to this merchant' do
      allow(mock_client).to receive(:merchant_domains).with(any_args).and_return(domain_list)

      expect(merchant.domains.first.merchant).to eq(merchant)
    end

    it 'only fetches the domains once' do
      expect(mock_client).to receive(:merchant_domains).once.with(any_args).and_return(domain_list)

      merchant.domains
      merchant.domains
    end
  end

  describe Spaceship::Portal::Merchant::Domain do
    let(:domain) do
      Spaceship::Portal::Merchant::Domain.new(domain_list.first).tap { |d| d.merchant = merchant }
    end

    let(:mac_domain) do
      mac_merchant = Spaceship::Portal::Merchant.new(JSON.parse({
        omcId: "LM3IY56BXC",
        platform: "mac"
      }.to_json))

      Spaceship::Portal::Merchant::Domain.new(domain_list.first).tap { |d| d.merchant = mac_merchant }
    end

    describe ".all" do
      it "fetches all domains of the given merchant" do
        expect(mock_client).to receive(:merchant_domains).with("LM3IY56BXC", mac: false).and_return(domain_list)

        domains = Spaceship::Portal::Merchant::Domain.all(merchant)
        expect(domains.count).to eq(2)
        expect(domains.first).to be_instance_of(Spaceship::Portal::Merchant::Domain)
        expect(domains.first.merchant).to eq(merchant)
      end

      it "fetches the Mac domains for a Mac merchant" do
        mac_merchant = Spaceship::Portal::Merchant.new(JSON.parse({
          omcId: "LM3IY56BXC",
          platform: "mac"
        }.to_json))

        expect(mock_client).to receive(:merchant_domains).with("LM3IY56BXC", mac: true).and_return(domain_list)

        Spaceship::Portal::Merchant::Domain.all(mac_merchant)
      end

      it "maps all attributes of a domain" do
        allow(mock_client).to receive(:merchant_domains).with(any_args).and_return(domain_list)

        domain = Spaceship::Portal::Merchant::Domain.all(merchant).first
        expect(domain.domain_id).to eq("5Y57MLHP2K")
        expect(domain.name).to eq("payments.example.com")
        expect(domain.status).to eq("verified")
        expect(domain.path).to eq("https://payments.example.com/.well-known/apple-developer-merchantid-domain-association.txt")
        expect(domain.can_verify).to eq(true)
        expect(domain.expiration_date).to eq("2026-10-11")
        expect(domain.expiration_date_string).to eq("Oct 11, 2026")
      end
    end

    describe ".find" do
      it "works with specific domain names" do
        allow(mock_client).to receive(:merchant_domains).with(any_args).and_return(domain_list)

        domain = Spaceship::Portal::Merchant::Domain.find(merchant, "www.example.com")
        expect(domain).to be_instance_of(Spaceship::Portal::Merchant::Domain)
        expect(domain.domain_id).to eq("UFVN6788YA")
      end

      it "returns nil when the domain name wasn't found" do
        allow(mock_client).to receive(:merchant_domains).with(any_args).and_return(domain_list)

        expect(Spaceship::Portal::Merchant::Domain.find(merchant, "asdfasdf")).to be_nil
      end
    end

    describe ".create" do
      it 'registers a domain for the given merchant' do
        expect(mock_client).to receive(:create_merchant_domain!).with("LM3IY56BXC", "payments.example.com", mac: false).and_return(domain_list.first)

        domain = Spaceship::Portal::Merchant::Domain.create!(merchant: merchant, domain_name: "payments.example.com")
        expect(domain).to be_instance_of(Spaceship::Portal::Merchant::Domain)
        expect(domain.domain_id).to eq("5Y57MLHP2K")
        expect(domain.name).to eq("payments.example.com")
        expect(domain.merchant).to eq(merchant)
      end
    end

    describe ".delete" do
      it 'deletes the domain by a given domain_id and merchant_id' do
        allow(mock_client).to receive(:merchant_domains).with(any_args).and_return(domain_list)
        expect(mock_client).to receive(:delete_merchant_domain!).with("5Y57MLHP2K", "LM3IY56BXC", mac: false)

        subject = Spaceship::Portal::Merchant::Domain.find(merchant, "payments.example.com")
        domain = subject.delete!
        expect(domain.domain_id).to eq("5Y57MLHP2K")
      end
    end

    describe "#verification_file" do
      it 'downloads the domain association file' do
        expect(mock_client).to receive(:merchant_domain_get_verification_file).with("5Y57MLHP2K", mac: false).and_return("A-AAeyJ0ZWFtSWQiOiJYWFhYWFhYWFhYIg")

        expect(domain.verification_file).to eq("A-AAeyJ0ZWFtSWQiOiJYWFhYWFhYWFhYIg")
      end

      it 'downloads from the Mac endpoint for a Mac merchant' do
        expect(mock_client).to receive(:merchant_domain_get_verification_file).with("5Y57MLHP2K", mac: true)

        mac_domain.verification_file
      end
    end

    describe "#verify" do
      it 'asks Apple to verify the domain' do
        expect(mock_client).to receive(:merchant_domain_verify).with("5Y57MLHP2K", mac: false).and_return({ "resultCode" => 0 })

        expect(domain.verify).to eq({ "resultCode" => 0 })
      end

      it 'verifies against the Mac endpoint for a Mac merchant' do
        expect(mock_client).to receive(:merchant_domain_verify).with("5Y57MLHP2K", mac: true)

        mac_domain.verify
      end
    end
  end
end
