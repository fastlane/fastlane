describe Fastlane do
  describe Fastlane::FastFile do
    describe "SwiftLint" do
      let (:output_file) { "swiftlint.result.json" }
      let (:config_file) { ".swiftlint-ci.yml" }

      context "default use case" do
        it "default use case" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint")
        end
      end

      context "when specify output_file options" do
        it "adds redirect file to command" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              output_file: '#{output_file}'
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint > #{output_file}")
        end
      end

      context "when specify config_file options" do
        it "adds config option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              config_file: '#{config_file}'
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint --config #{config_file}")
        end
      end

      context "when specify output_file and config_file options" do
        it "adds config option and redirect file" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              output_file: '#{output_file}',
              config_file: '#{config_file}'
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint --config #{config_file} > #{output_file}")
        end
      end
    end
  end
end
