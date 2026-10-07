describe Fastlane do
  describe Fastlane::FastFile do
    describe "Appium Integration" do
      describe "#invoke_appium_server" do
        it "starts an appium whose path has a space, passing it as one argument" do
          Dir.mktmpdir do |dir|
            appium = File.join(dir, "Node Tools", "appium")
            FileUtils.mkdir_p(File.dirname(appium))
            FileUtils.touch(appium)

            expect(Process).to receive(:spawn).with(appium, "-a", "0.0.0.0", "-p", "4723").and_return(1234)

            pid = Fastlane::Actions::AppiumAction.invoke_appium_server(appium_path: appium, host: "0.0.0.0", port: 4723)
            expect(pid).to eq(1234)
          end
        end
      end
    end
  end
end
