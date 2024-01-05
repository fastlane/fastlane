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
        ENV.delete("DEVELOPER_DIR")
      end

      it "throws an exception if no params are passed" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_select
          end").runner.execute(:test)
        end.to raise_error("Path to Xcode application required (e.g. `xcode_select(\"/Applications/Xcode.app\")`)")
      end

      it "throws an exception if the Xcode path is not a valid directory" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            xcode_select \"#{invalid_path}\"
          end").runner.execute(:test)
        end.to raise_error("Path '/path/to/nonexistent/dir' doesn't exist")
      end

      it "sets the DEVELOPER_DIR environment variable" do
        Fastlane::FastFile.new.parse("lane :test do
          xcode_select \"#{valid_path}\"
        end").runner.execute(:test)

        expect(ENV["DEVELOPER_DIR"]).to eq(valid_path + "/Contents/Developer")
      end
    end
  end
end
