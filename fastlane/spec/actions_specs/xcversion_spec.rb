describe Fastlane do
  describe Fastlane::FastFile do
    describe "xcversion integration" do
      after(:each) do
        ENV.delete("DEVELOPER_DIR")
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
                xcversion version: '= 7.2'
              end").runner.execute(:test)

              expect(ENV["DEVELOPER_DIR"]).to eq(File.join(v7_2.path, "Contents/Developer"))
            end
          end

          context "with a pessimistic requirement" do
            it "selects the correct version of xcode" do
              Fastlane::FastFile.new.parse("lane :test do
                xcversion version: '~> 7.2.0'
              end").runner.execute(:test)

              expect(ENV["DEVELOPER_DIR"]).to eq(File.join(v7_2_1.path, "Contents/Developer"))
            end
          end

          context "with an unsatisfiable requirement" do
            it "raises an error" do
              expect do
                Fastlane::FastFile.new.parse("lane :test do
                  xcversion version: '= 7.1'
                end").runner.execute(:test)
              end.to raise_error("Cannot find an installed Xcode satisfying '= 7.1'")
            end
          end
        end
      end

      describe "version default value" do
        context "load a .xcode-version file if it exists" do
          context "uses default" do
            let(:v13_0) do
              double("XcodeInstall::Xcode", version: "13.0", path: "/Test/Xcode13.0")
            end

            let(:xcode_version_path) { ".xcode-version" }
            before do
              require "xcode/install"
              installer = double("XcodeInstall::Installer")
              allow(installer).to receive(:installed_versions).and_return([v13_0])
              allow(XcodeInstall::Installer).to receive(:new).and_return(installer)
              allow(Dir).to receive(:glob).with(".xcode-version").and_return([xcode_version_path])
            end

            it "succeeds if the numbers match" do
              expect(UI).to receive(:message).with(/Setting Xcode version/)
              allow(File).to receive(:read).with(xcode_version_path).and_return("13.0")

              result = Fastlane::FastFile.new.parse("lane :test do
                xcversion
              end").runner.execute(:test)

              expect(ENV["DEVELOPER_DIR"]).to eq(File.join(v13_0.path, "Contents/Developer"))
            end

            it "fails if the numbers don't match" do
              allow(File).to receive(:read).with(xcode_version_path).and_return("14.0")

              expect do
                Fastlane::FastFile.new.parse("lane :test do
                  xcversion
                end").runner.execute(:test)
              end.to raise_error("Cannot find an installed Xcode satisfying '14.0'")
            end
          end

          context "overrides default" do
            let(:v13_0) do
              double("XcodeInstall::Xcode", version: "13.0", path: "/Test/Xcode13.0")
            end

            let(:xcode_version_path) { ".xcode-version" }
            before do
              require "xcode/install"
              installer = double("XcodeInstall::Installer")
              allow(installer).to receive(:installed_versions).and_return([v13_0])
              allow(XcodeInstall::Installer).to receive(:new).and_return(installer)
              allow(Dir).to receive(:glob).with(".xcode-version").and_return([xcode_version_path])
            end

            it "succeeds if the numbers match" do
              expect(UI).to receive(:message).with(/Setting Xcode version/)
              allow(File).to receive(:read).with(xcode_version_path).and_return("14.0")

              result = Fastlane::FastFile.new.parse("lane :test do
                xcversion(version: '13.0')
              end").runner.execute(:test)

              expect(ENV["DEVELOPER_DIR"]).to eq(File.join(v13_0.path, "Contents/Developer"))
            end
          end
        end

        context "no .xcode-version file exists" do
          it "raises an error" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                xcversion
              end").runner.execute(:test)
            end.to raise_error("Version must be specified")
          end
        end
      end
    end
  end
end
