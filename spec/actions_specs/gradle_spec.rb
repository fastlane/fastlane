describe Fastlane do
  describe Fastlane::FastFile do
    describe "gradle" do
      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', build_type: 'Release', properties: { 'versionCode' => 200}, gradle_path: './fastlane/README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md')} assembleWorldDominationRelease -p . -PversionCode=200")
      end

      it "correctly uses the serial" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', build_type: 'Release', properties: { 'versionCode' => 200}, serial: 'abc123', gradle_path: './fastlane/README.md')
        end").runner.execute(:build)

        expect(result).to eq("ANDROID_SERIAL=abc123 #{File.expand_path('README.md')} assembleWorldDominationRelease -p . -PversionCode=200")
      end

      it "supports multiple flavors" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', build_type: 'Release', gradle_path: './fastlane/README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md')} assembleRelease -p .")
      end

      it "supports multiple build types" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', flavor: 'WorldDomination', gradle_path: './fastlane/README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md')} assembleWorldDomination -p .")
      end

      it "supports multiple flavors and build types" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assemble', gradle_path: './fastlane/README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md')} assemble -p .")
      end

      it "supports the backwards compatible syntax" do
        result = Fastlane::FastFile.new.parse("lane :build do
          gradle(task: 'assembleWorldDominationRelease', gradle_path: './fastlane/README.md')
        end").runner.execute(:build)

        expect(result).to eq("#{File.expand_path('README.md')} assembleWorldDominationRelease -p .")
      end
    end
  end
end
