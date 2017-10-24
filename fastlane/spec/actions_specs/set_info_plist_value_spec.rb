describe Fastlane do
  describe Fastlane::FastFile do
    describe "set_info_plist" do
      require 'plist'

      let (:plist_path) { "./fastlane/spec/fixtures/plist/Info.plist" }
      let (:expected_plist_path) { './fastlane/spec/fixtures/plist/Info-expected.plist' }
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:output_path) { "Folder/output.plist" }
      let (:new_value) { "NewValue#{Time.now.to_i}" }
      let (:output_file) { File.join(test_path, output_path) }
      let (:old_plist) { Plist.parse_xml(plist_path) }
      let (:expected_plist) { Plist.parse_xml(expected_plist_path) }

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
          set_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier', value: '#{new_value}', output_file_name:'#{output_file}')
        end").runner.execute(:test)

        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq(old_value)

        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{output_file}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq(new_value)

        File.delete(output_file)
      end

      it "stores changes in the plist file when using map" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        ret = Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(
            path: '#{plist_path}',
            map: {
              CFBundleIdentifier: 'com.krausefx.app123',
              CFBundleShortVersionString: '9.9.9',
              UIRequiredDeviceCapabilities: ['arm64'],
              CFBundleURLTypes: [{
                'CFBundleURLName'=>'com.krausefx.app123',
              }]
            },
            output_file_name: '#{output_file}'
          )
        end").runner.execute(:test)

        expect(ret).to eq(expected_plist)

        ret = Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(
            path: '#{plist_path}',
            map: #{old_plist},
            replace: true,
            output_file_name: '#{output_file}'
          )
        end").runner.execute(:test)

        expect(ret).to eq(old_plist)
        File.delete(output_file)
      end
    end
  end
end
