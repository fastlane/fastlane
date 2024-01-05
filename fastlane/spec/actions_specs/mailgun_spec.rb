describe Fastlane do
  describe Fastlane::FastFile do
    describe "Mailgun Action" do
      before :each do
        ENV['MAILGUN_SANDBOX_POSTMASTER'] = 'fakepostmaster@fakesandboxtest.mailgun.org'
        ENV['MAILGUN_APIKEY'] = 'key-73827fakeapikey2329'
        ENV['MAILGUN_APP_LINK'] = 'http://www.anapplink.com'
      end

      it "raises an error if no mailgun sandbox postmaster is given" do
        ENV.delete('MAILGUN_SANDBOX_POSTMASTER')
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            to: 'valid@gmail.com',
            message: 'A valid email text',
            subject: 'A valid subject'
            })
          end").runner.execute(:test)
        end.to raise_exception("No value found for 'postmaster'")
      end

      it "raises an error if no mailgun apikey is given" do
        ENV.delete('MAILGUN_APIKEY')
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            to: 'valid@gmail.com',
            message: 'A valid email text'
            })
          end").runner.execute(:test)
        end.to raise_exception("No value found for 'apikey'")
      end

      it "raises an error if no mailgun to is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            message: 'A valid email text'
            })
          end").runner.execute(:test)
        end.to raise_exception("No value found for 'to'")
      end

      it "raises an error if no mailgun message is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            to: 'valid@gmail.com'
            })
          end").runner.execute(:test)
        end.to raise_exception("No value found for 'message'")
      end

      it "raises an error if no mailgun app_link is given" do
        ENV.delete('MAILGUN_APP_LINK')
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            to: 'valid@gmail.com',
            message: 'A valid email text'
            })
          end").runner.execute(:test)
        end.to raise_exception("No value found for 'app_link'")
      end
    end
  end
end
