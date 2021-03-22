describe Fastlane do
  describe Fastlane::FastFile do
    describe "SourceDocs" do
      context "when specify output path" do
        it "default use case" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs")
        end
      end

      context "when specify false for clean option" do
        it "doesn't add clean option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
              clean: false
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs")
        end
      end

      context "when specify true for clean option" do
        it "adds clean option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
              clean: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs --clean")
        end
      end

      context "when specify reproducible parameter" do
        it "adds reproducible-docs parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
              reproducible: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --reproducible-docs -o docs")
        end
      end

      context "when specify scheme parameter" do
        it "adds scheme parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
              scheme: 'MyApp'
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs -- -scheme MyApp")
        end

        it "adds sdk platform parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
              scheme: 'MyApp',
              sdk_platform: 'iphoneos'
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs -- -scheme MyApp -sdk iphoneos")
        end
      end

      context "when scheme parameter not specified" do
        it "adds no scheme parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs")
        end

        it "adds no sdk platform parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output: 'docs',
              sdk_platform: 'iphoneos'
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate -o docs")
        end
      end

      context "when specify all parameters" do
        it "adds all parameters" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              sdk_platform: 'macosx',
              output: 'docs',
              clean: true,
              reproducible: true,
              scheme: 'MyApp',

            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --reproducible-docs -o docs --clean -- -scheme MyApp -sdk macosx")
        end
      end
    end
  end
end
