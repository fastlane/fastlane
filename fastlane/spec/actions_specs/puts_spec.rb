describe Fastlane do
  describe Fastlane::FastFile do
    describe "puts" do
      it "works" do
        Fastlane::FastFile.new.parse("lane :test do
          puts 'hi'
        end").runner.execute(:test)
      end
      it "works in Swift" do
        Fastlane::FastFile.new.parse("lane :test do
          puts(message: 'hi from Swift')
        end").runner.execute(:test)
      end
    end
  end
end
