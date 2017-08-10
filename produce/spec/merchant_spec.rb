require "produce/merchant"

describe Produce::Merchant do
  describe ".detect_merchant_identifier" do
    it "accesses merchant identifier from produce config" do
      config = { merchant_identifier: "merchant.com.example.app" }

      result = Produce::Merchant.detect_merchant_identifier(config)

      expect(result).to eql("merchant.com.example.app")
    end

    it "accesses merchant identifier from produce config and prepends with merchant." do
      config = { merchant_identifier: "com.example.app" }

      result = Produce::Merchant.detect_merchant_identifier(config)

      expect(result).to eql("merchant.com.example.app")
    end

    it "falls back to UI.input when in interactive mode" do
      config = {}
      allow(UI).to receive(:interactive?).and_return(true)
      allow(UI).to receive(:input).and_return("merchant.com.example.app")

      result = Produce::Merchant.detect_merchant_identifier(config)

      expect(result).to eql("merchant.com.example.app")
    end

    it "raises error when not in interactive mode and no :merchant_identifier is provided" do
      config = {}
      allow(UI).to receive(:interactive?).and_return(false)

      expect { Produce::Merchant.detect_merchant_identifier(config) }.to raise_error(FastlaneCore::Interface::FastlaneError)
    end
  end

  describe ".prepare_identifier" do
    it "doesn't prepend merchant. when it already begins with merchant." do
      result = Produce::Merchant.prepare_identifier("merchant.com.example.app")

      expect(result).to eql("merchant.com.example.app")
    end

    it "prepends merchant. when identifier doesn't start with merchant." do
      result = Produce::Merchant.prepare_identifier("com.example.app")

      expect(result).to eql("merchant.com.example.app")
    end
  end

  describe ".input" do
    it "falls back to UI.input when in interactive mode" do
      config = {}
      allow(UI).to receive(:interactive?).and_return(true)
      allow(UI).to receive(:input)

      result = Produce::Merchant.input("Some instruction", "whatever")

      expect(UI).to have_received(:input).with("Some instruction")
    end

    it "raises error when not in interactive mode and no :merchant_identifier is provided" do
      allow(UI).to receive(:interactive?).and_return(false)
      allow(UI).to receive(:user_error!)

      Produce::Merchant.input("whatever", "error message")

      expect(UI).to have_received(:user_error!).with("error message")
    end
  end

  describe ".find_merchant" do
    it "checking cache stores found merchant" do
      merchant_0 = Object.new
      merchant_repo = Object.new
      allow(Produce::Merchant).to receive(:mac?).and_return(true)
      allow(merchant_repo).to receive(:find).and_return(merchant_0)

      result_0 = Produce::Merchant.find_merchant("some-identfier", merchant: merchant_repo)
      result_1 = Produce::Merchant.find_merchant("some-identfier", merchant: merchant_repo)

      expect(result_0).to equal(result_1)
    end

    it "checking cache is only used for the same identifier" do
      merchant_0 = Object.new
      merchant_1 = Object.new
      allow(Produce::Merchant).to receive(:mac?).and_return(true)
      merchant_repo = Object.new
      allow(merchant_repo).to receive(:find).with("some-identfier-0", any_args).and_return(merchant_0)
      allow(merchant_repo).to receive(:find).with("some-identfier-1", any_args).and_return(merchant_1)

      result_0 = Produce::Merchant.find_merchant("some-identfier-0", merchant: merchant_repo)
      result_1 = Produce::Merchant.find_merchant("some-identfier-1", merchant: merchant_repo)

      expect(result_0).to equal(merchant_0)
      expect(result_1).to equal(merchant_1)
    end
  end

  describe ".mac?" do
    it "returns true when config :platform is 'mac'" do
      result = Produce::Merchant.mac?({ platform: "mac" })

      expect(result).to be_truthy
    end

    it "returns false when config :platform is not 'mac'" do
      result = Produce::Merchant.mac?({ platform: "ios" })

      expect(result).to be_falsey
    end
  end

  describe ".merchant_name_from_identifier" do
    it "returns a name derived from identifier" do
      result = Produce::Merchant.merchant_name_from_identifier("merchant.com.example.app")

      expect(result).to eql("App Example Com Merchant")
    end
  end
end
