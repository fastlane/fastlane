describe Fastlane do
  describe Fastlane::FastFile do
    describe "xcodes" do
      let(:xcode_path) { "/valid/path/to/xcode.app" }
      let(:xcode_developer_path) { "#{xcode_path}/Contents/Developer" }
      let(:xcodes_binary_path) { "/path/to/bin/xcodes" }
      let(:valid_xcodes_version) { "1.1.0" }
      let(:outdated_xcodes_version) { "1.0.0" }

      before(:each) do
        allow(Fastlane::Helper::XcodesHelper).to receive(:find_xcodes_binary_path).and_return(xcodes_binary_path)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(xcodes_binary_path).and_return(true)
        allow(Fastlane::Actions).to receive(:sh).and_call_original
        allow(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} installed '14'").and_return(xcode_path)
        allow(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} version", { log: false }).and_return(valid_xcodes_version)
      end

      after(:each) do
        ENV.delete("DEVELOPER_DIR")
      end

      describe "update_list argument" do
        it "invokes update command when true" do
          expect(Fastlane::Actions).to receive(:sh).with(/--update/)
          Fastlane::FastFile.new.parse("lane :test do
            xcodes(version: '14', update_list: true)
          end").runner.execute(:test)
        end

        it "doesn't invoke update command when false" do
          expect(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} install '14' --select")
          expect(Fastlane::Actions).to_not(receive(:sh).with(/--update/))
          Fastlane::FastFile.new.parse("lane :test do
            xcodes(version: '14', update_list: false)
          end").runner.execute(:test)
        end
      end

      context "when select_for_current_build_only is true" do
        it "doesn't invoke 'update' nor 'install'" do
          expect(Fastlane::Actions).to_not(receive(:sh).with(/--update|--install/))
          expect(Fastlane::Actions).to receive(:sh).with(/installed/)
          Fastlane::FastFile.new.parse("lane :test do
            xcodes(version: '14', select_for_current_build_only: true)
          end").runner.execute(:test)
        end

        it "errors when there is no matching Xcode version" do
          # Note that this test is very tied to the code's implementation as it
          # relies on the action using `sh` with the block syntax.
          allow(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} installed '14'") do |_, _, &block|
            # Simulate the `xcodes installed` call failing
            fake_status = instance_double(Process::Status)
            allow(fake_status).to receive(:success?).and_return(false)
            allow(fake_status).to receive(:exitstatus).and_return('fake status')

            block.call(fake_status, 'fake result', 'fake command')
          end

          expect do
            Fastlane::FastFile.new.parse("lane :test do
              xcodes(version: '14', select_for_current_build_only: true)
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, 'Command `fake command` failed with status fake status and message: fake result')
        end
      end

      it "passes any received string to the command if xcodes_args is passed" do
        random_string = "xcodes compiles pikachu into a mewtwo"
        expect(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} #{random_string}")
        Fastlane::FastFile.new.parse("lane :test do
          xcodes(version: '14', xcodes_args: '#{random_string}')
        end").runner.execute(:test)
      end

      it "invokes install command when xcodes_args is not passed" do
        expect(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} install '14' --update --select")
        expect(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} installed '14'")
        Fastlane::FastFile.new.parse("lane :test do
          xcodes(version: '14')
        end").runner.execute(:test)
      end

      context "when no params are passed" do
        describe ".xcode-version file is present" do
          before do
            allow(Fastlane::Helper::XcodesHelper).to receive(:read_xcode_version_file).and_return("14")
          end

          it "doesn't raise error" do
            expect(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} installed '14'")
            Fastlane::FastFile.new.parse("lane :test do
              xcodes
            end").runner.execute(:test)
          end
        end

        describe ".xcode-version file is not present" do
          before do
            allow(Fastlane::Helper::XcodesHelper).to receive(:read_xcode_version_file).and_return(nil)
          end

          it "raises error" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                xcodes
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError, "Version must be specified")
          end
        end
      end

      it "sets the DEVELOPER_DIR environment variable" do
        Fastlane::FastFile.new.parse("lane :test do
          xcodes(version: '14')
        end").runner.execute(:test)
        expect(ENV.fetch("DEVELOPER_DIR", nil)).to eq(xcode_developer_path)
      end

      it "sets the SharedValues::XCODES_XCODE_PATH lane context" do
        Fastlane::FastFile.new.parse("lane :test do
          xcodes(version: '14')
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::XCODES_XCODE_PATH]).to eql(xcode_developer_path)
      end

      it "raises error when using an xcodes version earlier than v1.1.0" do
        allow(Fastlane::Actions).to receive(:sh).with("#{xcodes_binary_path} version", { log: false }).and_return(outdated_xcodes_version)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcodes(version: '14')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /minimum version(?:.*)1.1.0(?:.*)please update(?:.*)brew upgrade xcodes/i)
      end
    end
  end
end
