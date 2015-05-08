describe Fastlane do
  describe Fastlane::FastFile do
    describe "Mailgun Action" do
      before :each do
        ENV['MAILGUN_SANDBOX_DOMAIN'] = 'fakesandboxtest.mailgun.org'
        ENV['MAILGUN_SANDBOX_POSTMASTER'] = 'fakepostmaster@fakesandboxtest.mailgun.org'
        ENV['MAILGUN_APIKEY'] = 'key-73827fakeapikey2329'
      end


      it "raises an error if no mailgun sandbox domain is given" do
        ENV.delete 'MAILGUN_SANDBOX_DOMAIN'
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            mailgun({
              :to => 'valid@gmail.com',
              :message => 'A valid email text',
              :subject => 'A valid subject'
              })
          end").runner.execute(:test)
        }.to raise_exception('No MAILGUN_SANDBOX_DOMAIN given.'.red)
      end

      it "raises an error if no mailgun sandbox postmaster is given" do
        ENV.delete 'MAILGUN_SANDBOX_POSTMASTER'
        expect {
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            :to => 'valid@gmail.com',
            :message => 'A valid email text',
            :subject => 'A valid subject'
            })
          end").runner.execute(:test)
        }.to raise_exception('No MAILGUN_SANDBOX_POSTMASTER given.'.red)
      end

      it "raises an error if no mailgun apikey is given" do
        ENV.delete 'MAILGUN_APIKEY'
        expect {
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            :to => 'valid@gmail.com',
            :message => 'A valid email text'
            })
          end").runner.execute(:test)
        }.to raise_exception('No MAILGUN_APIKEY given.'.red)
      end

      it "raises an error if no mailgun to is given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            :message => 'A valid email text'
            })
          end").runner.execute(:test)
        }.to raise_exception('No MAILGUN_TO given.'.red)
      end

      it "raises an error if no mailgun message is given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
          mailgun({
            :to => 'valid@gmail.com'
            })
          end").runner.execute(:test)
        }.to raise_exception('No MAILGUN_MESSAGE given.'.red)
      end

    end
  end
end
