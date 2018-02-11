describe Fastlane do
  describe Fastlane::FastFile do
    let(:response_string) do
      <<-"EOS"
      {
        "privateKey" : "private_Djksfj",
        "publicKey"  : "sKdfjL",
        "appURL"  : "https://appetize.io/app/sKdfjL",
        "manageURL"  : "https://appetize.io/manage/private_Djksfj"
      }
      EOS
    end

    let(:api_token) { 'mysecrettoken' }
    let(:url) { 'https://example.com/app.zip' }
    let(:http) { double('http') }
    let(:request) { double('request') }
    let(:response) { double('response') }
    let(:params) do
      { token: api_token,
       url: url,
       platform: 'ios' }
    end

    before do
      allow(Net::HTTP).to receive(:new).and_return(http)
      allow(Net::HTTP::Post).to receive(:new).and_return(request)

      allow(http).to receive(:use_ssl=).with(true)
      allow(http).to receive(:request).with(request).and_return(response)

      allow(request).to receive(:basic_auth).with(api_token, nil)
      allow(request).to receive(:body=).with(kind_of(String)).and_return(response)

      allow(response).to receive(:body).and_return(response_string)
    end

    describe "Appetize Integration" do
      it "raises an error if no parameters were given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appetize()
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "raises an error if no url or path was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appetize({
              api_token: '#{api_token}'
            })
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /url parameter is required/)
      end

      it "works with valid parameters" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            appetize({
              api_token: '#{api_token}',
              url: '#{url}'
            })
          end").runner.execute(:test)
        end.not_to(raise_error)

        expect(http).not_to(receive(:request).with(JSON.generate(params)))
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APPETIZE_PUBLIC_KEY]).to eql('sKdfjL')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APPETIZE_APP_URL]).to eql('https://appetize.io/app/sKdfjL')
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APPETIZE_MANAGE_URL]).to eql('https://appetize.io/manage/private_Djksfj')
      end
    end
  end
end
