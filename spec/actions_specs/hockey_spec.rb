describe Fastlane do
  describe Fastlane::FastFile do
    describe "Hockey Integration" do
      it "raises an error if no ipa file was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
            hockey({
              api_token: 'xxx'
            })
          end").runner.execute(:test)
        }.to raise_error("Couldn't find ipa file at path ''".red)
      end

      it "raises an error if given ipa file was not found" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
            hockey({
              api_token: 'xxx',
              ipa: './notHere.ipa'
            })
          end").runner.execute(:test)
        }.to raise_error("Couldn't find ipa file at path './notHere.ipa'".red)
      end

      it "raises an error if supplied dsym file was not found" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
            hockey({
              api_token: 'xxx',
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              dsym: './notHere.dSYM.zip'
            })
          end").runner.execute(:test)
        }.to raise_error("Symbols on path '#{File.expand_path('../notHere.dSYM.zip')}' not found".red)
      end

      it "works with valid parameters" do
        Fastlane::FastFile.new.parse("lane :test do 
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1'
          })
        end").runner.execute(:test)
      end
    end
  end
end
