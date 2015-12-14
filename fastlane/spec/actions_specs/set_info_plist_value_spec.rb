describe Fastlane do
  describe Fastlane::FastFile do
    describe "set_info_plist" do
      let (:plist_path) { "./fastlane/spec/fixtures/plist/Info.plist" }
      let (:new_value) { "NewValue#{Time.now.to_i}" }

      it "stores changes in the plist file" do
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
    end
  end
end
