require 'fileutils'

describe Supply do
  describe Supply::Uploader do
    describe "#verify_config!" do
      let(:subject) { Supply::Uploader.new }

      it "raises error if empty config" do
        Supply.config = {}
        expect do
          subject.verify_config!
        end.to raise_error("No local metadata, apks, aab, or track to promote were found, make sure to run `fastlane supply init` to setup supply")
      end

      it "raises error if only track" do
        Supply.config = {
          track: 'alpha'
        }
        expect do
          subject.verify_config!
        end.to raise_error("No local metadata, apks, aab, or track to promote were found, make sure to run `fastlane supply init` to setup supply")
      end

      it "raises error if only track_promote_to" do
        Supply.config = {
          track_promote_to: 'beta'
        }
        expect do
          subject.verify_config!
        end.to raise_error("No local metadata, apks, aab, or track to promote were found, make sure to run `fastlane supply init` to setup supply")
      end

      it "does not raise error if only metadata" do
        Supply.config = {
          metadata_path: 'some/path'
        }
        subject.verify_config!
      end

      it "does not raise error if only apk" do
        Supply.config = {
          apk: 'some/path/app.apk'
        }
        subject.verify_config!
      end

      it "does not raise error if only apk_paths" do
        Supply.config = {
          apk_paths: ['some/path/app1.apk', 'some/path/app2.apk']
        }
        subject.verify_config!
      end

      it "does not raise error if only aab" do
        Supply.config = {
          aab: 'some/path/app1.aab'
        }
        subject.verify_config!
      end

      it "does not raise error if only aab_paths" do
        Supply.config = {
          aab_paths: ['some/path/app1.aab', 'some/path/app2.aab']
        }
        subject.verify_config!
      end

      it "does not raise error if only track and track_promote_to" do
        Supply.config = {
          track: 'alpha',
          track_promote_to: 'beta'
        }
        subject.verify_config!
      end
    end

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

    describe 'promote_track' do
      subject { Supply::Uploader.new.promote_track }

      let(:client) { double('client') }
      let(:version_codes) { [1, 2, 3] }
      let(:config) {
        {
          release_status: Supply::ReleaseStatus::COMPLETED,
          track_promote_release_status: Supply::ReleaseStatus::COMPLETED,
          track: 'alpha',
          track_promote_to: 'beta'
        }
      }
      let(:track) { double('alpha') }
      let(:release) { double('release1') }

      before do
        Supply.config = config
        allow(Supply::Client).to receive(:make_from_config).and_return(client)
        allow(client).to receive(:tracks).and_return([track])
        allow(track).to receive(:releases).and_return([release])
        allow(track).to receive(:releases=)

        allow(client).to receive(:track_version_codes).and_return(version_codes)
        allow(client).to receive(:update_track).with(config[:track], 0.1, nil)
        allow(client).to receive(:update_track).with(config[:track_promote_to], 0.1, version_codes)

        allow(release).to receive(:status).and_return(Supply::ReleaseStatus::COMPLETED)
      end

      it 'should only update track once' do
        expect(release).to receive(:status=).with(Supply::ReleaseStatus::COMPLETED)
        expect(release).to receive(:user_fraction=).with(nil)

        expect(client).not_to(receive(:update_track).with(config[:track], anything))
        expect(client).to receive(:update_track).with(config[:track_promote_to], track).once
        subject
      end
    end

    describe '#perform_upload' do
      let(:client) { double('client') }
      let(:config) { { apk: 'some/path/app.apk' } }

      before do
        Supply.config = config
        allow(Supply::Client).to receive(:make_from_config).and_return(client)
        allow(client).to receive(:upload_apk).with(config[:apk]).and_return(1) # newly uploaded version code
        allow(client).to receive(:begin_edit).and_return(nil)
        allow(client).to receive(:commit_current_edit!).and_return(nil)
      end

      it 'should update track with correct version codes' do
        uploader = Supply::Uploader.new
        expect(uploader).to receive(:update_track).with([1]).once
        uploader.perform_upload
      end
    end

    context 'when sync_image_upload is set' do
      let(:client) { double('client') }
      let(:language) { 'pt-BR' }
      let(:config) { { metadata_path: 'spec_metadata', sync_image_upload: true } }

      before do
        Supply.config = config
        allow(Supply::Client).to receive(:make_from_config).and_return(client)
        expect(client).not_to receive(:clear_screenshots)
      end

      describe '#upload_images' do
        it 'should upload and replace image if sha256 does not match remote image' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "sha256-of-#{file}") }
          allow(Dir).to receive(:glob).and_return(['image.png'])
          remote_images = [Supply::ImageListing.new('id123', '_unused_', 'different-remote-sha256', '_unused_')]

          Supply::IMAGES_TYPES.each do |image_type|
            allow(client).to receive(:fetch_images).with(image_type: image_type, language: language).and_return(remote_images)
            expect(client).to receive(:upload_image).with(image_path: File.expand_path('image.png'), image_type: image_type, language: language)
          end

          uploader = Supply::Uploader.new
          uploader.upload_images(language)
        end

        it 'should skip image upload if sha256 matches remote image' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "sha256-of-#{file}") }
          allow(Dir).to receive(:glob).and_return(['image.png'])
          remote_images = [Supply::ImageListing.new('id123', '_unused_', 'sha256-of-image.png', '_unused_')]

          Supply::IMAGES_TYPES.each do |image_type|
            allow(client).to receive(:fetch_images).with(image_type: image_type, language: language).and_return(remote_images)
            expect(client).not_to receive(:upload_image).with(image_path: File.expand_path('image.png'), image_type: image_type, language: language)
          end

          uploader = Supply::Uploader.new
          uploader.upload_images(language)
        end
      end

      describe '#upload_screenshots' do
        it 'should upload and replace all screenshots if no sha256 matches any remote screenshot' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "local-sha256-of-#{file}") }
          local_images = %w[image1.png image2.png image3.png]
          allow(Dir).to receive(:glob).and_return(local_images)
          remote_images = [1, 2, 3].map do |idx|
            Supply::ImageListing.new("id_#{idx}", '_unused_', "remote-sha256-#{idx}", '_unused_')
          end

          Supply::SCREENSHOT_TYPES.each do |screenshot_type|
            allow(client).to receive(:fetch_images).with(image_type: screenshot_type, language: language).and_return(remote_images)
            remote_images.each do |image|
              expect(client).to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: image.id)
            end
            local_images.each do |path|
              expect(client).to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
          end

          uploader = Supply::Uploader.new
          uploader.upload_screenshots(language)
        end

        it 'should skip all screenshots if all sha256 matches the remote screenshots' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "common-sha256-of-#{file}") }
          local_images = %w[image1.png image2.png image3.png]
          allow(Dir).to receive(:glob).and_return(local_images)
          remote_images = local_images.map do |path|
            Supply::ImageListing.new("id_#{path}", '_unused_', "common-sha256-of-#{path}", '_unused_')
          end

          Supply::SCREENSHOT_TYPES.each do |screenshot_type|
            allow(client).to receive(:fetch_images).with(image_type: screenshot_type, language: language).and_return(remote_images)
            remote_images.each do |image|
              expect(client).not_to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: image.id)
            end
            local_images.each do |path|
              expect(client).not_to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
          end

          uploader = Supply::Uploader.new
          uploader.upload_screenshots(language)
        end

        it 'should delete and re-upload screenshots that changed locally, as long as start of list is in order' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "sha256-of-#{file}") }
          local_images = %w[image0.png image1.png new-image2.png new-image3.png]
          allow(Dir).to receive(:glob).and_return(local_images)

          remote_images = %w[image0.png image1.png old-image2.png old-image3.png].map.with_index do |path, idx|
            Supply::ImageListing.new("id_#{idx}", '_unused_', "sha256-of-#{path}", '_unused_')
          end

          Supply::SCREENSHOT_TYPES.each do |screenshot_type|
            allow(client).to receive(:fetch_images).with(image_type: screenshot_type, language: language).and_return(remote_images)
            local_images[0..1].each_with_index do |path, idx|
              expect(client).not_to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: "id_#{idx}")
              expect(client).not_to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
            local_images[2..3].each_with_index do |path, idx|
              expect(client).to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: "id_#{idx + 2}")
              expect(client).to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
          end

          uploader = Supply::Uploader.new
          uploader.upload_screenshots(language)
        end

        it 'should delete remote screenshots that are no longer present locally' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "common-sha256-of-#{file}") }
          local_images = %w[image1.png image2.png image3.png]
          allow(Dir).to receive(:glob).and_return(local_images)

          same_remote_images = local_images.map do |path|
            Supply::ImageListing.new("id_#{path}", '_unused_', "common-sha256-of-#{path}", '_unused_')
          end
          extra_remote_image = Supply::ImageListing.new("id_extra", '_unused_', "common-sha256-of-extra-image", '_unused_')
          remote_images = [same_remote_images[0], extra_remote_image, same_remote_images[1], same_remote_images[2]]

          Supply::SCREENSHOT_TYPES.each do |screenshot_type|
            allow(client).to receive(:fetch_images).with(image_type: screenshot_type, language: language).and_return(remote_images)
            same_remote_images.each do |image|
              expect(client).not_to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: image.id)
            end
            expect(client).to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: extra_remote_image.id)
            local_images.each do |path|
              expect(client).not_to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
          end

          uploader = Supply::Uploader.new
          uploader.upload_screenshots(language)
        end

        it 'should delete screenshots that are out of order and re-upload them in the correct order' do
          allow(Digest::SHA256).to receive(:file) { |file| instance_double(Digest::SHA256, hexdigest: "sha256-of-#{file}") }
          local_images = %w[image0.png image1.png image2.png image4.png image3.png image5.png image6.png] # those will be sorted after Dir.glob
          allow(Dir).to receive(:glob).and_return(local_images)

          # Record the mocked deletions and uploads in list of remote images to check the final state at the end
          final_remote_images_ids = {}
          allow(client).to receive(:clear_screenshot) do |**args|
            image_type = args[:image_id].split('_')[1]
            final_remote_images_ids[image_type].delete(args[:image_id])
          end
          allow(client).to receive(:upload_image) do |**args|
            path = File.basename(args[:image_path])
            image_type = args[:image_type]
            final_remote_images_ids[image_type] << "new-id_#{image_type}_#{path}"
          end

          Supply::SCREENSHOT_TYPES.each do |screenshot_type|
            remote_images = local_images.map do |path|
              Supply::ImageListing.new("id_#{screenshot_type}_#{path}", '_unused_', "sha256-of-#{path}", '_unused_')
            end # remote images will be in order 0124356 though
            allow(client).to receive(:fetch_images).with(image_type: screenshot_type, language: language).and_return(remote_images)

            final_remote_images_ids[screenshot_type] = remote_images.map(&:id)

            # We should skip image0, image1, image2 from remote as they are the same as the first local images,
            # But also skip image3 (which was after image4 in remote listing, but is still present in local images)
            # While deleting image4 (because it was in-between image2 and image3 in the `remote_images`, so out of order)
            # And finally deleting image5 and image6, before re-uploading image4, image5 and image6 in the right order
            local_images.sort[0..3].each do |path|
              expect(client).not_to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: "id_#{screenshot_type}_#{path}")
              expect(client).not_to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
            local_images.sort[4..6].each do |path|
              expect(client).to receive(:clear_screenshot).with(image_type: screenshot_type, language: language, image_id: "id_#{screenshot_type}_#{path}")
              expect(client).to receive(:upload_image).with(image_path: File.expand_path(path), image_type: screenshot_type, language: language)
            end
          end

          uploader = Supply::Uploader.new
          uploader.upload_screenshots(language)

          # Check the final order of the remote images after the whole skip/delete/upload dance
          Supply::SCREENSHOT_TYPES.each do |screenshot_type|
            expected_final_images_ids = %W[
              id_#{screenshot_type}_image0.png
              id_#{screenshot_type}_image1.png
              id_#{screenshot_type}_image2.png
              id_#{screenshot_type}_image3.png
              new-id_#{screenshot_type}_image4.png
              new-id_#{screenshot_type}_image5.png
              new-id_#{screenshot_type}_image6.png
            ]
            expect(final_remote_images_ids[screenshot_type]).to eq(expected_final_images_ids)
          end
        end
      end
    end
  end
end
