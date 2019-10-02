describe Fastlane do
  describe Fastlane::FastFile do
    describe "download_dsyms" do
      # 1 app, 2 trains/versions, 2 builds each
      let(:app) { double('app') }
      let(:version) { double('version') }
      let(:live_version) { double('live_version') }
      let(:train) { double('train') }
      let(:train2) { double('train2') }
      let(:build) { double('build') }
      let(:build2) { double('build2') }
      let(:build3) { double('build3') }
      let(:empty_build) { double('empty_build') }
      let(:build_detail) { double('build_detail') }
      let(:empty_build_detail) { double('empty_build_detail') }
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
        allow(empty_build_detail).to receive(:dsym_url).and_return(nil)
        allow(app).to receive(:bundle_id).and_return('tools.fastlane.myapp')
        allow(train).to receive(:version_string).and_return('1.0.0')
        allow(train2).to receive(:version_string).and_return('2.0.0')
        allow(build).to receive(:build_version).and_return('1')
        allow(build2).to receive(:build_version).and_return('2')
        allow(empty_build).to receive(:build_version).and_return('3')
        allow(Fastlane::Actions::DownloadDsymsAction).to receive(:download)
      end

      context 'with no special options' do
        it 'downloads all dsyms of all builds in all trains' do
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build, build2])
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build, build2, empty_build])
          expect(app).to receive(:tunes_build_details).with(train: '1.0.0', build_number: '1', platform: :ios).and_return(build_detail)
          expect(app).to receive(:tunes_build_details).with(train: '1.0.0', build_number: '2', platform: :ios).and_return(build_detail)
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '1', platform: :ios).and_return(build_detail)
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '2', platform: :ios).and_return(build_detail)
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '3', platform: :ios).and_return(empty_build_detail)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train.version_string, build.build_version, nil)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train.version_string, build2.build_version, nil)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train2.version_string, build.build_version, nil)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train2.version_string, build2.build_version, nil)
          expect(Fastlane::Actions::DownloadDsymsAction).not_to(receive(:download))
          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp')
          end").runner.execute(:test)
        end
      end

      context 'when version is latest' do
        before do
          # latest
          allow(app).to receive(:edit_version).and_return(version)
          allow(version).to receive(:version).and_return('2.0.0')
          allow(version).to receive(:candidate_builds).and_return([build2, build3])
          allow(build2).to receive(:train_version).and_return('2.0.0')
          allow(build2).to receive(:upload_date).and_return(1_547_145_145_000)
          allow(build3).to receive(:train_version).and_return('2.0.0')
          allow(build3).to receive(:build_version).and_return('2')
          allow(build3).to receive(:upload_date).and_return(1_547_196_482_000)
        end
        it 'downloads only dsyms of latest build in latest train' do
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build, build2, build3])
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '2', platform: :ios).and_return(build_detail)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train2.version_string, build2.build_version, nil)
          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: 'latest')
          end").runner.execute(:test)
        end
      end

      context 'when version is live' do
        before do
          # live
          allow(app).to receive(:live_version).and_return(live_version)
          allow(live_version).to receive(:version).and_return('1.0.0')
          allow(live_version).to receive(:build_version).and_return('42')
          allow(live_version).to receive(:candidate_builds).and_return([build])
          allow(build).to receive(:build_version).and_return('42')
          allow(build).to receive(:upload_date).and_return(1_547_196_482_000)
        end
        it 'downloads only dsyms of live build' do
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build, build2, build3])
          expect(app).to receive(:tunes_build_details).with(train: '1.0.0', build_number: '42', platform: :ios).and_return(build_detail)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train.version_string, build.build_version, nil)

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: 'live')
          end").runner.execute(:test)
        end
      end

      context 'when min_version is set' do
        it 'downloads only dsyms of trains newer than or equal min_version' do
          expect(app).to receive(:tunes_all_builds_for_train).and_return([build, build2])
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '1', platform: :ios).and_return(build_detail)
          expect(app).to receive(:tunes_build_details).with(train: '2.0.0', build_number: '2', platform: :ios).and_return(build_detail)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train2.version_string, build.build_version, nil)
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, app.bundle_id, train2.version_string, build2.build_version, nil)

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', min_version: '2.0.0')
          end").runner.execute(:test)
        end
      end
    end
  end
end
