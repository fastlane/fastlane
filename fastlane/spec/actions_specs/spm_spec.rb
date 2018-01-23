describe Fastlane do
  describe Fastlane::FastFile do
    describe "SPM Integration" do
      it "raises an error if command is invalid" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            spm(command: 'invalid_command')
          end").runner.execute(:test)
        end.to raise_error("Please pass a valid command. Use one of the following: build, test, clean, reset, update")
      end

      # Commands

      it "default use case is build" do
        result = Fastlane::FastFile.new.parse("lane :test do
            spm
          end").runner.execute(:test)

        expect(result).to eq("swift build")
      end

      it "sets the command to build" do
        result = Fastlane::FastFile.new.parse("lane :test do
            spm(command: 'build')
          end").runner.execute(:test)

        expect(result).to eq("swift build")
      end

      it "sets the command to test" do
        result = Fastlane::FastFile.new.parse("lane :test do
            spm(command: 'test')
          end").runner.execute(:test)

        expect(result).to eq("swift test")
      end

      it "sets the command to update" do
        result = Fastlane::FastFile.new.parse("lane :test do
            spm(command: 'update')
          end").runner.execute(:test)

        expect(result).to eq("swift package update")
      end

      it "sets the command to clean" do
        result = Fastlane::FastFile.new.parse("lane :test do
            spm(command: 'clean')
          end").runner.execute(:test)

        expect(result).to eq("swift package clean")
      end

      it "sets the command to reset" do
        result = Fastlane::FastFile.new.parse("lane :test do
            spm(command: 'reset')
          end").runner.execute(:test)

        expect(result).to eq("swift package reset")
      end

      # Arguments

      context "when command is not package related" do
        it "adds verbose flag to command if verbose is set to true" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(verbose: true)
            end").runner.execute(:test)

          expect(result).to eq("swift build --verbose")
        end

        it "doesn't add a verbose flag to command if verbose is set to false" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(verbose: false)
            end").runner.execute(:test)

          expect(result).to eq("swift build")
        end

        it "adds build-path flag to command if build_path is set" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(build_path: 'foobar')
            end").runner.execute(:test)

          expect(result).to eq("swift build --build-path foobar")
        end

        it "adds package-path flag to command if package_path is set" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(package_path: 'foobar')
            end").runner.execute(:test)

          expect(result).to eq("swift build --package-path foobar")
        end

        it "adds configuration flag to command if configuration is set" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(configuration: 'release')
            end").runner.execute(:test)

          expect(result).to eq("swift build --configuration release")
        end

        it "raises an error if configuration is invalid" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              spm(configuration: 'foobar')
            end").runner.execute(:test)
          end.to raise_error("Please pass a valid configuration: (debug|release)")
        end

        it "works with no parameters" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              spm
            end").runner.execute(:test)
          end.not_to(raise_error)
        end
      end

      context "when command is package related" do
        let(:command) { 'update' }

        it "adds verbose flag to package command if verbose is set to true" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(
                command: '#{command}',
                verbose: true
              )
            end").runner.execute(:test)

          expect(result).to eq("swift package --verbose #{command}")
        end

        it "doesn't add a verbose flag to package command if verbose is set to false" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(
                command: '#{command}',
                verbose: false
              )
            end").runner.execute(:test)

          expect(result).to eq("swift package #{command}")
        end

        it "adds build-path flag to package command if package_path is set to true" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(
                command: '#{command}',
                build_path: 'foobar'
              )
            end").runner.execute(:test)

          expect(result).to eq("swift package --build-path foobar #{command}")
        end

        it "adds package-path flag to package command if package_path is set" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(
                command: '#{command}',
                package_path: 'foobar'
              )
            end").runner.execute(:test)

          expect(result).to eq("swift package --package-path foobar #{command}")
        end

        it "adds configuration flag to package command if configuration is set" do
          result = Fastlane::FastFile.new.parse("lane :test do
              spm(
                command: '#{command}',
                configuration: 'release'
              )
            end").runner.execute(:test)

          expect(result).to eq("swift package --configuration release #{command}")
        end

        it "raises an error if configuration is invalid" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              spm(
                command: '#{command}',
                configuration: 'foobar'
              )
            end").runner.execute(:test)
          end.to raise_error("Please pass a valid configuration: (debug|release)")
        end
      end
    end
  end
end
