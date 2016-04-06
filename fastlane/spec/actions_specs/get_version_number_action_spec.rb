describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Version Number Integration" do
      require 'shellwords'

      it "gets the correct version number for 'SchemeA'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', scheme: 'SchemeA')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number for 'SchemeB'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', scheme: 'SchemeB')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number with no scheme" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "raises an exception when use passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace")
      end
    end
  end
end
