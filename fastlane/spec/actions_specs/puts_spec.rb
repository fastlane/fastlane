describe Fastlane do
  describe Fastlane::FastFile do
    describe "puts" do
      it "works" do
        Fastlane::FastFile.new.parse("lane :test do
          puts 'hi'
        end").runner.execute(:test)
      end
    end
  end
end
