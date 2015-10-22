describe Fastlane do
  describe Fastlane::FastFile do
    describe "Carthage Integration" do
      it "raises an error if use_ssh is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_ssh: 'thisistest'
            )
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid value for use_ssh. Use one of the following: true, false")
      end

      it "raises an error if use_submodules is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_submodules: 'thisistest'
            )
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid value for use_submodules. Use one of the following: true, false")
      end

      it "raises an error if use_binaries is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_binaries: 'thisistest'
            )
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid value for use_binaries. Use one of the following: true, false")
      end

      it "raises an error if no_build is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              no_build: 'thisistest'
            )
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid value for no_build. Use one of the following: true, false")
      end

      it "raises an error if verbose is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              verbose: 'thisistest'
            )
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid value for verbose. Use one of the following: true, false")
      end

      it "raises an error if platform is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              platform: 'thisistest'
            )
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid platform. Use one of the following: all, iOS, Mac, watchOS")
      end

      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap")
      end

      it "adds use-ssh flag to command if use_ssh is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_ssh: true
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --use-ssh")
      end

      it "doesn't add a use-ssh flag to command if use_ssh is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_ssh: false
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap")
      end

      it "adds use-submodules flag to command if use_submodules is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_submodules: true
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --use-submodules")
      end

      it "doesn't add a use-submodules flag to command if use_submodules is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_submodules: false
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap")
      end

      it "adds no-use-binaries flag to command if use_binaries is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_binaries: false
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --no-use-binaries")
      end

      it "doesn't add a no-use-binaries flag to command if use_binaries is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_binaries: true
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap")
      end

      it "adds no-build flag to command if no_build is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              no_build: true
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --no-build")
      end

      it "does not add a no-build flag to command if no_build is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              no_build: false
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap")
      end

      it "adds verbose flag to command if verbose is set to true" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              verbose: true
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --verbose")
      end

      it "does not add a verbose flag to command if verbose is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              verbose: false
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap")
      end

      it "sets the platform to iOS" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              platform: 'iOS'
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --platform iOS")
      end

      it "sets the platform to Mac" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              platform: 'Mac'
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --platform Mac")
      end

      it "sets the platform to watchOS" do
        result = Fastlane::FastFile.new.parse("lane :test do
            carthage(
              platform: 'watchOS'
            )
          end").runner.execute(:test)

        expect(result).to eq("carthage bootstrap --platform watchOS")
      end

      it "works with no parameters" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage
          end").runner.execute(:test)
        end.not_to raise_error
      end

      it "works with valid parameters" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            carthage(
              use_ssh: true,
              use_submodules: true,
              use_binaries: false,
              platform: 'iOS'
            )
          end").runner.execute(:test)
        end.not_to raise_error
      end
    end
  end
end
