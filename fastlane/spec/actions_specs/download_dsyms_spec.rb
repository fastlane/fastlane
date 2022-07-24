describe Fastlane do
  describe Fastlane::FastFile do
    describe "download_dsyms" do
      # 1 app, 2 trains/versions, 2 builds each
      let(:app) { double('app') }
      let(:build_resp) { double('build_resp') }
      let(:tunes_client) { double('tunes_client') }

      let(:version) { double('version') }
      let(:live_version) { double('live_version') }

      let(:build1) { double('build1') }
      let(:build2) { double('build2') }
      let(:build3) { double('build3') }
      let(:build4) { double('build4') }
      let(:build5) { double('build5') }
      let(:build6) { double('build6') }

      let(:build_bundle) { double('build_bundle') }
      let(:not_processed_build_bundle) { double('not_processed_build_bundle') }
      let(:no_symbols_build_bundle) { double('no_symbols_build_bundle') }

      let(:not_processed_build) { double('not_processed_build') }
      let(:no_symbols_build) { double('no_symbols_build') }

      let(:download_url) { 'https://example.com/myapp-dsym' }

      before do
        allow(Spaceship::Tunes).to receive(:client).and_return(tunes_client)

        # login
        allow(Spaceship::ConnectAPI).to receive(:login)
        allow(Spaceship::ConnectAPI::App). to receive(:find).and_return(app)
        allow(app).to receive(:id).and_return("id")
        allow(app).to receive(:bundle_id).and_return('tools.fastlane.myapp')

        # builds
        allow(Spaceship::ConnectAPI).to receive(:get_builds).and_return(build_resp)
        allow(build_resp).to receive(:all_pages).and_return([build_resp])

        allow(build1).to receive(:build_bundles).and_return([build_bundle])
        allow(build2).to receive(:build_bundles).and_return([build_bundle])
        allow(build3).to receive(:build_bundles).and_return([build_bundle])
        allow(build4).to receive(:build_bundles).and_return([build_bundle])
        allow(build5).to receive(:build_bundles).and_return([build_bundle])
        allow(build6).to receive(:build_bundles).and_return([build_bundle])

        allow(not_processed_build).to receive(:build_bundles).and_return([not_processed_build_bundle])
        allow(no_symbols_build).to receive(:build_bundles).and_return([no_symbols_build_bundle])

        allow(build_bundle).to receive(:dsym_url).and_return(download_url)
        allow(build_bundle).to receive(:includes_symbols).and_return(true)

        allow(not_processed_build_bundle).to receive(:dsym_url).and_return(nil)
        allow(not_processed_build_bundle).to receive(:includes_symbols).and_return(true)

        allow(no_symbols_build_bundle).to receive(:dsym_url).and_return(nil)
        allow(no_symbols_build_bundle).to receive(:includes_symbols).and_return(false)

        allow(Fastlane::Actions::DownloadDsymsAction).to receive(:download)
      end

      # before do
      #   # login
      #   allow(Spaceship::Tunes).to receive(:login)
      #   allow(Spaceship::Tunes).to receive(:select_team)
      #   allow(Spaceship::Application).to receive(:find).and_return(app)
      #   # trains
      #   allow(app).to receive(:tunes_all_build_trains).and_return([train, train2, train3])
      #   # build_detail + download
      #   allow(build_detail).to receive(:dsym_url).and_return(download_url)
      #   allow(empty_build_detail).to receive(:dsym_url).and_return(nil)
      #   allow(app).to receive(:bundle_id).and_return('tools.fastlane.myapp')
      #   allow(train).to receive(:version_string).and_return('1.0.0')
      #   allow(train2).to receive(:version_string).and_return('1.7.0')
      #   allow(train3).to receive(:version_string).and_return('2.0.0')
      #   allow(build).to receive(:build_version).and_return('1')
      #   allow(build2).to receive(:build_version).and_return('2')
      #   allow(build3).to receive(:build_version).and_return('3')
      #   allow(build4).to receive(:build_version).and_return('4')
      #   allow(empty_build).to receive(:build_version).and_return('5')
      #   allow(Fastlane::Actions::DownloadDsymsAction).to receive(:download)
      # end

      context 'with no special options' do
        it 'downloads all dsyms of all builds in all trains' do
          expect(build_resp).to receive(:all_pages_each).and_yield(build1)
                                                        .and_yield(build2)
                                                        .and_yield(build3)
                                                        .and_yield(build4)
                                                        .and_yield(build5)
                                                        .and_yield(build6)

          [[build1, '1.0.0', '1', '2020-09-12T10:00:00+01:00'],
           [build2, '1.0.0', '2', '2020-09-12T11:00:00+01:00'],
           [build3, '1.7.0', '4', '2020-09-12T12:00:00+01:00'],
           [build4, '2.0.0', '1', '2020-09-12T13:00:00+01:00'],
           [build5, '2.0.0', '2', '2020-09-12T14:00:00+01:00'],
           [build6, '2.0.0', '5', '2020-09-12T15:00:00+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          expect(Fastlane::Actions::DownloadDsymsAction).not_to(receive(:download))

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp')
          end").runner.execute(:test)
        end
      end

      context 'with wait_for_dsym_processing' do
        it 'downloads all dsyms of all builds in all trains' do
          expect(build_resp).to receive(:all_pages_each).and_yield(not_processed_build)

          # Returns not processed build (no dsym url)
          build = not_processed_build
          build_id = 1
          version = '2.0.0'
          build_number = '5'
          uploaded_date = '2020-09-12T15:00:00+01:00'
          expect(build).to receive(:id).and_return(build_id)
          expect(build).to receive(:app_version).and_return(version)
          expect(build).to receive(:version).and_return(build_number)
          expect(build).to receive(:uploaded_date).and_return(uploaded_date)

          # Refetches build info
          expect(Spaceship::ConnectAPI::Build).to receive(:get).with(build_id: build_id).and_return(build1)

          build = build1
          expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          expect(Fastlane::Actions::DownloadDsymsAction).not_to(receive(:download))

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', wait_for_dsym_processing: true)
          end").runner.execute(:test)
        end
      end

      context 'with version with leading zero' do
        it 'downloads all dsyms of all builds in train 1.07.0' do
          expect(build_resp).to receive(:all_pages_each).and_yield(build1)

          [[build1, '1.07.0', '3', '2020-09-12T14:10:30+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: '1.07.0')
          end").runner.execute(:test)
        end
      end

      context 'when build_number is an integer' do
        it 'downloads the correct dsyms' do
          expect(build_resp).to receive(:all_pages_each).and_yield(build1)

          [[build1, '2.0.0', '2', '2020-09-12T14:10:30+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: '2.0.0', build_number: 2)
          end").runner.execute(:test)
        end
      end

      context 'when version is latest' do
        it 'downloads only dsyms of latest build in latest train' do
          expect(Spaceship::ConnectAPI).to receive(:get_builds).and_return([build2, build1])

          expect(build_resp).to receive(:all_pages_each).and_yield(build1)
                                                        .and_yield(build2)

          [[build1, '2.0.0', '2', '2020-09-12T10:00:00+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
          end

          [[build2, '2.0.0', '3', '2020-09-12T11:00:00+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version).twice
            expect(build).to receive(:version).and_return(build_number).exactly(2).times
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)

            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: 'latest')
          end").runner.execute(:test)
        end
      end

      context 'when version is live' do
        it 'downloads only dsyms of live build' do
          expect(app).to receive(:get_live_app_store_version).and_return(version)
          expect(version).to receive(:version_string).and_return('1.0.0')
          version_build = double('version_build')
          expect(version_build).to receive(:version).and_return('42')
          expect(version).to receive(:build).and_return(version_build)

          expect(build_resp).to receive(:all_pages_each).and_yield(build1)
                                                        .and_yield(build2)

          [[build1, '1.0.0', '33', '2020-09-12T14:10:30+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
          end

          [[build2, '1.0.0', '42', '2020-09-12T14:10:30+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)

            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', version: 'live')
          end").runner.execute(:test)
        end
      end

      context 'when min_version is set' do
        it 'downloads only dsyms of trains newer than or equal min_version' do
          expect(build_resp).to receive(:all_pages_each).and_yield(build1)
                                                        .and_yield(build2)

          [[build1, '1.0.0', '33', '2020-09-12T14:10:30+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
          end

          [[build2, '2.0.0', '42', '2020-09-12T14:10:30+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)

            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          Fastlane::FastFile.new.parse("lane :test do
              download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', min_version: '2.0.0')
          end").runner.execute(:test)
        end
      end

      context 'with after_uploaded_date' do
        it 'downloads dsyms with more recent uploaded_date' do

          expect(build_resp).to receive(:all_pages_each).and_yield(build1)
                                                        .and_yield(build2)
                                                        .and_yield(build3)
                                                        .and_yield(build4)
                                                        .and_yield(build5)
                                                        .and_yield(build6)

          # after after_uploaded_date
          [[build1, '2.0.0', '5', '2020-09-12T15:00:00+01:00'],
           [build2, '2.0.0', '2', '2020-09-12T14:00:00+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
            expect(Fastlane::Actions::DownloadDsymsAction).to receive(:download).with(download_url, build, app, nil)
          end

          # on after_uploaded_date
          [[build3, '2.0.0', '1', '2020-09-12T13:00:00+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).to receive(:app_version).and_return(version)
            expect(build).to receive(:version).and_return(build_number)
            expect(build).to receive(:uploaded_date).and_return(uploaded_date)
          end

          # before after_uploaded_date
          [[build4, '1.7.0', '4', '2020-09-12T12:00:00+01:00'],
           [build5, '1.0.0', '2', '2020-09-12T11:00:00+01:00'],
           [build6, '1.0.0', '1', '2020-09-12T10:00:00+01:00']].each do |build, version, build_number, uploaded_date|
            expect(build).not_to(receive(:app_version))
            expect(build).not_to(receive(:version))
            expect(build).not_to(receive(:uploaded_date))
          end

          expect(Fastlane::Actions::DownloadDsymsAction).not_to(receive(:download))

          Fastlane::FastFile.new.parse("lane :test do
            download_dsyms(username: 'user@fastlane.tools', app_identifier: 'tools.fastlane.myapp', after_uploaded_date: '2020-09-12T13:00:00+01:00')
          end").runner.execute(:test)
        end
      end
    end
  end
end
