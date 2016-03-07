describe Fastlane do
  describe Fastlane::FastFile do
    describe "Cocoapods Integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods
        end").runner.execute(:test)

        expect(result).to eq("pod install")
      end

      it "adds no-clean to command if clean is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            clean: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-clean")
      end

      it "adds no-integrate to command if integrate is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            integrate: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-integrate")
      end

      it "adds no-repo-update to command if repo_update is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            repo_update: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-repo-update")
      end

      it "adds silent to command if silent is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            silent: true
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --silent")
      end

      it "adds verbose to command if verbose is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            verbose: true
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --verbose")
      end

      it "adds no-ansi to command if ansi is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            ansi: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-ansi")
      end

      it "changes directory if podfile is set to the Podfile path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            podfile: 'Project/Podfile'
          )
        end").runner.execute(:test)

        expect(result).to eq("cd 'Project' && pod install")
      end

      it "changes directory if podfile is set to a directory" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            podfile: 'Project'
          )
        end").runner.execute(:test)

        expect(result).to eq("cd 'Project' && pod install")
      end
    end
  end
end
