describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Version Number Integration" do
      require 'shellwords'

      path = File.absolute_path("./fastlane/spec/fixtures/actions/get_version_number/get_version_number/")

      it "gets the correct version number for 'TargetA'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetA')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number for 'TargetATests'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetATests')
        end").runner.execute(:test)
        expect(result).to eq("4.3.2")
      end

      it "gets the correct version number for 'TargetB'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetB')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number for 'TargetBTests'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetBTests')
        end").runner.execute(:test)
        expect(result).to eq("5.4.3")
      end

      it "gets the correct version number for 'TargetC_internal'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetC_internal')
        end").runner.execute(:test)
        expect(result).to eq("7.5.2")
      end

      it "gets the correct version number for 'TargetC_production'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetC_production')
        end").runner.execute(:test)
        expect(result).to eq("6.4.9")
      end

      it "gets the correct version number for 'SampleProject_tests'", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'SampleProject_tests')
        end").runner.execute(:test)
        expect(result).to eq("1.0")
      end

      it "raises if in non-interactive mode with no target", requires_xcodeproj: true do
        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneCrash, /non-interactive mode/)
      end

      it "raises if in non-interactive mode if cannot infer configuration", requires_xcodeproj: true do
        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: '#{path}', target: 'TargetDifferentConfigurations')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneCrash, /non-interactive mode/)
      end

      it "get correct version for different configurations", requires_xcodeproj: true do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetDifferentConfigurations', configuration: 'Debug')
        end").runner.execute(:test)
        expect(result).to eq("1.2.3")

        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '#{path}', target: 'TargetDifferentConfigurations', configuration: 'Release')
        end").runner.execute(:test)
        expect(result).to eq("3.2.1")
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
