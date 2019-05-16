require 'produce/service'

describe Fastlane do
  describe Fastlane::FastFile do
    describe "modify_services" do
      it 'sends enable and disable with strings, symbols, and booleans' do
        allow(Produce).to receive(:config)
        expect(Produce::Service).to receive(:enable) do |options, args|
          expect(options.push_notification).to eq('on')
          expect(options.wallet).to eq('on')
          expect(options.hotspot).to eq('on')
          expect(options.data_protection).to eq('complete')
        end
        expect(Produce::Service).to receive(:disable) do |options, args|
          expect(options.associated_domains).to eq('off')
          expect(options.apple_pay).to eq('off')
          expect(options.multipath).to eq('off')
        end
        Fastlane::FastFile.new.parse("lane :test do
            modify_services(
              username: 'test.account@gmail.com',
              app_identifier: 'com.someorg.app',
              services: {
                push_notification: 'on',
                associated_domains: 'off',
                wallet: :on,
                apple_pay: :off,
                data_protection: 'complete',
                hotspot: true,
                multipath: false
            })
        end").runner.execute(:test)
      end
    end
  end
end
