describe Fastlane do
  describe Fastlane::FastFile do
    describe "Pod Lib Lint action" do
      it "generates the correct pod lib lint command with no parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_lib_lint
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod lib lint")
      end

      it "generates the correct pod lib lint command with a verbose parameter" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_lib_lint(verbose: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod lib lint --verbose")
      end

      it "generates the correct pod lib lint command with allow warnings parameter" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_lib_lint(allow_warnings: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod lib lint --allow-warnings")
      end
    end
  end
end
