describe Fastlane do
  describe Fastlane::FastFile do
    describe "frameit Integration" do
      before do
        @path = File.expand_path("./spec/fixtures/screenshots")
      end

      # it "uses the screenshot folder to frame it" do

      #   Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = @path

      #   result = Fastlane::FastFile.new.parse("lane :test do
      #     frameit
      #   end").runner.execute(:test)

      #   expect(result).to eq(['./screenshot1.png'])
      #   expect(File.exists?(File.join(@path, 'screenshot1_framed.png'))).to eq(true)
      # end

      # after do
      #   File.delete(File.join(@path, 'screenshot1_framed.png'))
      # end
    end
  end
end
