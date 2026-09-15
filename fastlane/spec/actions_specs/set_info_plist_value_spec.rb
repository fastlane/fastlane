require 'tmpdir'

describe Fastlane do
  describe Fastlane::FastFile do
    describe "set_info_plist" do
      # A copy, not the committed fixture. These examples mutate the plist and
      # then put it back, which leaves a window where the file on disk holds
      # NewValue<timestamp>. The checkout is shared by every worker when the
      # suite is split, so get_info_plist_value_spec reading the same fixture on
      # another worker saw that window and failed expecting com.krausefx.app.
      #
      # Working on a copy removes the restore step as well as the race: nothing
      # else can observe this file, so nothing has to be put back.
      let(:fixture_path) { "./fastlane/spec/fixtures/plist/Info.plist" }
      let(:plist_dir) { Dir.mktmpdir("fl_spec_set_info_plist") }
      let(:plist_path) { File.join(plist_dir, "Info.plist") }
      let(:test_path) { Dir.mktmpdir("fl_spec_set_info_plist_out") }
      let(:output_path) { "Folder/output.plist" }
      let(:new_value) { "NewValue#{Time.now.to_i}" }

      before(:each) do
        FileUtils.cp(fixture_path, plist_path)
      end

      after(:each) do
        FileUtils.remove_entry(plist_dir) if File.directory?(plist_dir)
        FileUtils.remove_entry(test_path) if File.directory?(test_path)
      end

      it "stores changes in the plist file" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        old_value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier', value: '#{new_value}')
        end").runner.execute(:test)

        Fastlane::FastFile.new.parse("lane :test do
          set_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier', value: '#{new_value}')
        end").runner.execute(:test)

        value = Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{plist_path}', key: 'CFBundleIdentifier')
        end").runner.execute(:test)

        expect(value).to eq(new_value)

        # Setting it back is still worth asserting: it is the round trip that
        # proves the action writes what it is given rather than a fixed value.
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
      end
    end
  end
end
