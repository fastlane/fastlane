describe Fastlane do
  describe Fastlane::FastFile do
    describe "download_dsyms" do
      # 1 app, 2 trains/versions, 2 builds each
      let(:app) { double('app') }
      let(:version) { double('version') }
      let(:train) { double('train') }
      let(:train2) { double('train2') }
      let(:build) { double('build') }
      let(:build2) { double('build2') }
      let(:build_detail) { double('build_detail') }
      let(:download_url) { 'https://example.com/myapp-dsym' }
      before do
        # login
        allow(Spaceship::Tunes).to receive(:login)
        allow(Spaceship::Tunes).to receive(:select_team)
        allow(Spaceship::Application).to receive(:find).and_return(app)
        # trains
        allow(app).to receive(:tunes_all_build_trains).and_return([train, train2])
        # build_detail + download
        allow(build_detail).to receive(:dsym_url).and_return(download_url)
        allow(app).to receive(:bundle_id).and_return('tools.fastlane.myapp')
        allow(train).to receive(:version_string).and_return('1.0.0')
        allow(train2).to receive(:version_string).and_return('2.0.0')
        allow(build).to receive(:build_version).and_return('1')
        allow(build2).to receive(:build_version).and_return('2')
        allow(Fastlane::Actions::DownloadDsymsAction).to receive(:download)       
      end

          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train.version_string, build.build_version, nil)
      context 'when version is latest' do
        before do
          # latest
          allow(app).to receive(:edit_version).and_return(version)
          allow(version).to receive(:version).and_return('2.0.0')
          allow(version).to receive(:build_version).and_return('2')
          allow(version).to receive(:candidate_builds).and_return([build2])
          allow(build2).to receive(:train_version).and_return('2.0.0')
        end
        it 'downloads only dsyms of latest build in latest train' do
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build, build2])
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '2', platform: :ios).and_return(build_detail)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train2.version_string, build2.build_version, nil)
          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: 'latest')
          end").runner.execute(:test)
        end
      end
    end
  end
end
