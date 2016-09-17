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

      context "when specify strict options" do
        it "adds strict option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              strict: true
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint --strict")
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

      context "when specify output_file, config_file and strict options" do
        it "adds config option, strict option and redirect file" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              strict: true,
              output_file: '#{output_file}',
              config_file: '#{config_file}'
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint --strict --config #{config_file} > #{output_file}")
        end
      end

      context "the `ignore_exit_status` option" do
        context "by default" do
          it 'should raise if swiftlint completes with a non-zero exit status' do
            allow(FastlaneCore::UI).to receive(:important)
            expect(FastlaneCore::UI).to receive(:important).with(/If you want fastlane to continue anyway/)
            # This is simulating the exception raised if the return code is non-zero
            expect(Fastlane::Actions).to receive(:sh).and_raise("fake error")
            expect(FastlaneCore::UI).to receive(:user_error!).with(/SwiftLint finished with errors/).and_call_original

            expect do
              Fastlane::FastFile.new.parse("lane :test do
                swiftlint
              end").runner.execute(:test)
            end.to raise_error
          end
        end

        context "when enabled" do
          it 'should not raise if swiftlint completes with a non-zero exit status' do
            allow(FastlaneCore::UI).to receive(:important)
            expect(FastlaneCore::UI).to receive(:important).with(/fastlane will continue/)
            # This is simulating the exception raised if the return code is non-zero
            expect(Fastlane::Actions).to receive(:sh).and_raise("fake error")
            expect(FastlaneCore::UI).to_not receive(:user_error!)

            result = Fastlane::FastFile.new.parse("lane :test do
              swiftlint(ignore_exit_status: true)
            end").runner.execute(:test)
          end
        end

        context "when disabled" do
          it 'should raise if swiftlint completes with a non-zero exit status' do
            allow(FastlaneCore::UI).to receive(:important)
            expect(FastlaneCore::UI).to receive(:important).with(/If you want fastlane to continue anyway/)
            # This is simulating the exception raised if the return code is non-zero
            expect(Fastlane::Actions).to receive(:sh).and_raise("fake error")
            expect(FastlaneCore::UI).to receive(:user_error!).with(/SwiftLint finished with errors/).and_call_original

            expect do
              Fastlane::FastFile.new.parse("lane :test do
                swiftlint(ignore_exit_status: false)
              end").runner.execute(:test)
            end.to raise_error
          end
        end
      end

      context "when specify mode explicitly" do
        it "uses lint mode as default" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint")
        end

        it "supports lint mode option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              mode: :lint
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint")
        end

        it "supports autocorrect mode option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              mode: :autocorrect
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint autocorrect")
        end
      end

      context "when specify list of files to process" do
        it "adds use script input files option and environment variables" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              files: ['AppDelegate.swift', 'path/to/project/src/Model.swift', 'path/to/project/test/Test.swift']
            )
          end").runner.execute(:test)

          expect(result).to eq("SCRIPT_INPUT_FILE_COUNT=3 SCRIPT_INPUT_FILE_0=AppDelegate.swift SCRIPT_INPUT_FILE_1=path/to/project/src/Model.swift SCRIPT_INPUT_FILE_2=path/to/project/test/Test.swift swiftlint lint --use-script-input-files")
        end
      end

      context "when file paths contain spaces" do
        it "escapes spaces in output and config file paths" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
              output_file: 'output path with spaces.txt',
              config_file: '.config file with spaces.yml'
            )
          end").runner.execute(:test)

          expect(result).to eq("swiftlint lint --config .config\\ file\\ with\\ spaces.yml > output\\ path\\ with\\ spaces.txt")
        end

        it "escapes spaces in list of files to process" do
          result = Fastlane::FastFile.new.parse("lane :test do
            swiftlint(
                files: ['path/to/my project/source code/AppDelegate.swift']
            )
          end").runner.execute(:test)

          expect(result).to eq("SCRIPT_INPUT_FILE_COUNT=1 SCRIPT_INPUT_FILE_0=path/to/my\\ project/source\\ code/AppDelegate.swift swiftlint lint --use-script-input-files")
        end
      end
    end
  end
end
