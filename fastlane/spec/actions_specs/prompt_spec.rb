describe Fastlane do
  describe Fastlane::FastFile do
    describe "prompt" do
      it "uses the CI value if necessary" do
        ENV["CI"] = '1'
        result = Fastlane::FastFile.new.parse("lane :test do
          prompt(text: 'text', ci_input: 'ci')
        end").runner.execute(:test)
        expect(result).to eq('ci')
        ENV.delete('CI')
      end
    end
  end
end
