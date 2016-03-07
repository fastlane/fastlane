describe Fastlane do
  describe Fastlane::FastFile do
    describe "Say Integration" do
      it "works" do
        result = Fastlane::FastFile.new.parse("lane :test do
          say ['Hi Felix', 'Good Job']
        end").runner.execute(:test)

        expect(result).to eq('say \'Hi Felix Good Job\'')
      end
    end
  end
end
