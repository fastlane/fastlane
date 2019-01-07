describe Fastlane do
  describe Fastlane::FastFile do
    describe "download_dsyms" do
      let(:app) { double('app') }
      let(:version) { double('version') }
      let(:build) { double('build') }
      let(:train) { double('train') }
      let(:build_detail) { double('build_detail') }
      let(:download_url) { 'https://example.com/myapp-dsym' }
      before do
        allow(Spaceship::Tunes).to receive(:login)
        allow(Spaceship::Tunes).to receive(:select_team)
        allow(Spaceship::Application).to receive(:find).and_return(app)
        allow(app).to receive(:edit_version).and_return(version)
        allow(version).to receive(:version).and_return('1.0.0')
        allow(version).to receive(:build_version).and_return('1.0.0')
        allow(version).to receive(:candidate_builds).and_return([build])
        allow(build).to receive(:train_version).and_return('2.0.0')
        allow(Fastlane::Actions::DownloadDsymsAction).to receive(:download)
        allow(app).to receive(:tunes_all_build_trains).and_return([train])
        allow(train).to receive(:version_string).and_return('2.0.0')
        allow(build).to receive(:build_version).and_return('1.0.0')
        allow(build_detail).to receive(:dsym_url).and_return(download_url)
        allow(app).to receive(:bundle_id).and_return('tools.fastlane.myapp')
      end

      context 'when version is latest' do
        it do
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build])
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '1.0.0', platform: :ios).and_return(build_detail)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train.version_string, build.build_version, nil)
          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: 'latest')
          end").runner.execute(:test)
        end
      end
    end
  end
end
