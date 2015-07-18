describe Fastlane do
  describe Fastlane::FastFile do
    describe "Produce Integration" do
      it "raises an error if non hash is passed" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
              produce('text')
            end").runner.execute(:test)
        }.to raise_error("You have to pass the options for 'produce' in a different way. Please check out the current documentation on GitHub!".red)
      end
    end
  end
end
