describe Fastlane do
  describe Fastlane::FastFile do
    describe "set_info_plist" do
      let(:plist_path) { "./fastlane/spec/fixtures/plist/Info.plist" }
      let(:test_path) { "/tmp/fastlane/tests/fastlane" }
      let(:output_path) { "Folder/output.plist" }
      let(:new_value) { "NewValue#{Time.now.to_i}" }

      it "stores changes in the plist file" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        old_value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier', value: '#{new_value}')
        end").runner.execute(:test)

        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq(new_value)

        ret = Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier', value: '#{old_value}')
        end").runner.execute(:test)
        expect(ret).to eq(old_value)
      end

      it "stores changes in the output plist file" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        old_value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier', value: '#{new_value}', output_file_name:'#{File.join(test_path, output_path)}')
        end").runner.execute(:test)

        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq(old_value)

        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{File.join(test_path, output_path)}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq(new_value)

        File.delete(File.join(test_path, output_path))
      end
    end
  end
end
