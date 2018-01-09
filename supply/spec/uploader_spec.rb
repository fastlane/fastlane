require 'fileutils'

describe Supply do
  describe Supply::Uploader do
    describe "#find_obbs" do
      let(:subject) { Supply::Uploader.new }

      before(:all) do
        @obb_dir = Dir.mktmpdir('supply')
        @apk_path = File.join(@obb_dir, 'my.apk')

        # Makes Supply::Uploader.new.all_languages public for testing reasons
        Supply::Uploader.send(:public, *Supply::Uploader.private_instance_methods)
      end

      def create_obb(name)
        path = "#{@obb_dir}/#{name}"
        FileUtils.touch(path)
        path
      end

      before do
        FileUtils.rm_rf(Dir.glob("#{@obb_dir}/*.obb"))
      end

      def find_obbs
        subject.send(:find_obbs, @apk_path)
      end

      it "finds no obb when there's none to find" do
        expect(find_obbs.count).to eq(0)
      end

      it "skips unrecognized obbs" do
        main_obb = create_obb('unknown.obb')
        expect(find_obbs.count).to eq(0)
      end

      it "finds one match and one patch obb" do
        main_obb = create_obb('main.obb')
        patch_obb = create_obb('patch.obb')
        obbs = find_obbs
        expect(obbs.count).to eq(2)
        expect(obbs).to eq({ 'main' => main_obb, 'patch' => patch_obb })
      end

      it "finds zero obb if too main mains" do
        create_obb('main.obb')
        create_obb('other.main.obb')
        obbs = find_obbs
        expect(obbs.count).to eq(0)
      end

      it "finds zero obb if too many patches" do
        create_obb('patch.obb')
        create_obb('patch.other.obb')
        obbs = find_obbs
        expect(obbs.count).to eq(0)
      end
    end

    describe 'metadata encoding' do
      it 'prints a user friendly error message if metadata is not UTF-8 encoded' do
        fake_config = 'fake config'
        allow(fake_config).to receive(:[]).and_return('fake config value')
        Supply.config = fake_config

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return("fake content")

        fake_listing = "listing"
        Supply::AVAILABLE_METADATA_FIELDS.each do |field|
          allow(fake_listing).to receive("#{field}=".to_sym)
        end

        expect(fake_listing).to receive(:save).and_raise(Encoding::InvalidByteSequenceError)
        expect(FastlaneCore::UI).to receive(:user_error!).with(/Metadata must be UTF-8 encoded./)

        Supply::Uploader.new.upload_metadata('en-US', fake_listing)
      end
    end

    describe 'all_languages' do
      it 'only grabs directories' do
        Supply.config = {
          metadata_path: 'supply/spec/fixtures/metadata/android'
        }

        only_directories = Supply::Uploader.new.all_languages
        expect(only_directories).to eq(['en-US', 'fr-FR', 'ja-JP'])
      end
    end

    describe 'check superseded tracks' do
      let(:client) { double('client') }

      before do
        allow(Supply::Client).to receive(:make_from_config).and_return(client)
      end

      it 'remove lesser than the greatest of any later (i.e. production) track' do
        allow(client).to receive(:track_version_codes) do |track|
          next [103] if track.eql?('production')
          next [102] if track.eql?('rollout')
          next [101] if track.eql?('beta')
          []
        end

        allow(client).to receive(:update_track) do |track, rollout, apk_version_code|
          expect(track).to eq('beta').or(eq('rollout'))
          expect(rollout).to eq(1.0)
          expect(apk_version_code).to be_empty
        end

        expect(client).to receive(:update_track).exactly(2).times

        Supply.config = {
          track: 'alpha'
        }
        Supply::Uploader.new.check_superseded_tracks([104])
      end

      it 'remove lesser than the currently being uploaded if it is in an earlier (i.e. alpha) track' do
        allow(client).to receive(:track_version_codes) do |track|
          next [100] if track.eql?('alpha')
          []
        end

        allow(client).to receive(:update_track) do |track, rollout, apk_version_code|
          expect(track).to eq('alpha')
          expect(rollout).to eq(1.0)
          expect(apk_version_code).to be_empty
        end

        expect(client).to receive(:update_track).exactly(1).times

        Supply.config = {
          track: 'beta'
        }
        Supply::Uploader.new.check_superseded_tracks([101])
      end

      it 'combined case' do
        allow(client).to receive(:track_version_codes) do |track|
          next [102] if track.eql?('production')
          next [101] if track.eql?('rollout')
          next [103] if track.eql?('alpha')
          []
        end

        allow(client).to receive(:update_track) do |track, rollout, apk_version_code|
          expect(track).to eq('rollout').or(eq('alpha'))
          expect(rollout).to eq(1.0)
          expect(apk_version_code).to be_empty
        end

        expect(client).to receive(:update_track).exactly(2).times

        Supply.config = {
          track: 'beta'
        }
        Supply::Uploader.new.check_superseded_tracks([104])
      end
    end
  end
end
