describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Version Number Integration" do
      require 'shellwords'

      it "gets the correct version number for 'TargetA'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'TargetA')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number for 'TargetATests'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'TargetATests')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number for 'TargetB'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'TargetB')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number for 'TargetBTests'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'TargetBTests')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number for 'TargetC_internal'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'TargetC_internal')
        end").runner.execute(:test)
        expect(result).to eq("7.5.2")
      end

      it "gets the correct version number for 'TargetC_production'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'TargetC_production')
        end").runner.execute(:test)
        expect(result).to eq("6.4.9")
      end

      it "gets the correct version number for 'SampleProject_tests'" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject', target: 'SampleProject_tests')
        end").runner.execute(:test)
        expect(result).to eq("1.0")
      end

      it "gets the correct version number with no target specified" do
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
