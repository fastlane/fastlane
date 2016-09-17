describe Fastlane do
  describe Fastlane::FastFile do
    describe "AppetizeViewingUrlGeneratorAction" do
      it "no parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appetize_viewing_url_generator(public_key: '123')
        end").runner.execute(:test)

        expect(result).to eq("https://appetize.io/embed/123?autoplay=true&orientation=portrait&device=iphone5s&deviceColor=black&scale=75")
      end

      it "sensible default scaling" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appetize_viewing_url_generator(device: 'ipadair2', public_key: '123')
        end").runner.execute(:test)

        expect(result).to eq("https://appetize.io/embed/123?autoplay=true&orientation=portrait&device=ipadair2&deviceColor=black&scale=50")
      end
    end
  end
end
