describe Fastlane do
  describe Fastlane::FastFile do
    describe "Xcode Select Integration" do
      let(:invalid_path) { "/path/to/nonexistent/dir" }
      let(:valid_path) { "/valid/path/to/xcode" }

      before(:each) do
        allow(Dir).to receive(:exist?).with(invalid_path).and_return(false)
        allow(Dir).to receive(:exist?).with(valid_path).and_return(true)
      end

      after(:each) do
        ENV.delete "DEVELOPER_DIR"
      end

      context "when no params are passed" do
        it "raises an error" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              xcode_select
            end").runner.execute(:test)
          end.to raise_error("path or version must be specified")
        end
      end

      context "when conflicting params are passed" do
        it "raises an error" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              xcode_select path: '/valid/path/to/xcode', version: '= 6.0'
            end").runner.execute(:test)
          end.to raise_error("You cannot specify 'path' and 'version' options at the same time")
        end
      end

      context "when a path is specified" do
        it "raises an error if the Xcode path is not a valid directory" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              xcode_select path: '#{invalid_path}'
            end").runner.execute(:test)
          end.to raise_error("Path '/path/to/nonexistent/dir' does not exist")
        end

        it "sets the DEVELOPER_DIR environment variable" do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_select path: '#{valid_path}'
          end").runner.execute(:test)

          expect(ENV["DEVELOPER_DIR"]).to eq(valid_path + "/Contents/Developer")
        end
      end

      context "when a version requirement is specified" do
        let(:v7_2) do
          double("XcodeInstall::Xcode", version: "7.2", path: "/Test/Xcode7.2")
        end

        let(:v7_2_1) do
          double("XcodeInstall::Xcode", version: "7.2.1", path: "/Test/Xcode7.2.1")
        end

        let(:v7_3) do
          double("XcodeInstall::Xcode", version: "7.3", path: "/Test/Xcode7.3")
        end

        context "with an invalid requirement" do
          it "raises an error" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                xcode_select version: '= aaaa'
              end").runner.execute(:test)
            end.to raise_error("The requirement '= aaaa' is not a valid RubyGems style requirement")
          end
        end

        context "with a valid requirement" do
          before do
            require "xcode/install"
            installer = double("XcodeInstall::Installer")
            allow(installer).to receive(:installed_versions).and_return([v7_2, v7_2_1, v7_3])
            allow(XcodeInstall::Installer).to receive(:new).and_return(installer)
          end

          context "with a specific requirement" do
            it "selects the correct version of xcode" do
              Fastlane::FastFile.new.parse("lane :test do
                xcode_select version: '= 7.2'
              end").runner.execute(:test)

              expect(ENV["DEVELOPER_DIR"]).to eq(File.join(v7_2.path, "Contents/Developer"))
            end
          end

          context "with a loose requirement" do
            it "selects the correct version of xcode" do
              Fastlane::FastFile.new.parse("lane :test do
                xcode_select version: '~> 7.2.0'
              end").runner.execute(:test)

              expect(ENV["DEVELOPER_DIR"]).to eq(File.join(v7_2_1.path, "Contents/Developer"))
            end
          end

          context "with an unsatisfiable requirement" do
            it "raises an error" do
              expect do
                Fastlane::FastFile.new.parse("lane :test do
                  xcode_select version: '= 7.1'
                end").runner.execute(:test)
              end.to raise_error("Cannot find an installed Xcode satisfying '= 7.1'")
            end
          end
        end
      end
    end
  end
end
