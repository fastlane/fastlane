require 'spec_helper'
require_relative '../mock_servers'

describe Spaceship::TestFlight::Build do
  let(:mock_client) { double('MockClient') }

  before do
    # Use a simple client for all data models
    Spaceship::TestFlight::Base.client = mock_client
  end

  context '.find' do
    it 'finds a build by a build_id' do
      mock_client_response(:get_build) do
        {
          id: 456,
          bundleId: 'com.foo.bar',
          trainVersion: '1.0'
        }
      end

      build = Spaceship::TestFlight::Build.find(app_id: 123, build_id: 456)
      expect(build).to be_instance_of(Spaceship::TestFlight::Build)
      expect(build.id).to eq(456)
      expect(build.bundle_id).to eq('com.foo.bar')
    end

    it 'returns raises when the build cannot be found' do
      mock_client_response(:get_build).and_raise(Spaceship::Client::UnexpectedResponse)

      expect do
        Spaceship::TestFlight::Build.find(app_id: 123, build_id: 456)
      end.to raise_error(Spaceship::Client::UnexpectedResponse)
    end
  end

  context 'collections' do
    before do
      mock_client_response(:get_build_trains) do
        ['1.0', '1.1']
      end

      mock_client_response(:get_builds_for_train, with: hash_including(train_version: '1.0')) do
        [
          {
            id: 1,
            appAdamId: 10,
            trainVersion: '1.0',
            uploadDate: '2017-01-01T12:00:00.000+0000',
            externalState: 'testflight.build.state.export.compliance.missing'
          }
        ]
      end

      mock_client_response(:get_builds_for_train, with: hash_including(train_version: '1.1')) do
        [
          {
            id: 2,
            appAdamId: 10,
            trainVersion: '1.1',
            uploadDate: '2017-01-02T12:00:00.000+0000',
            externalState: 'testflight.build.state.submit.ready'
          },
          {
            id: 3,
            appAdamId: 10,
            trainVersion: '1.1',
            uploadDate: '2017-01-03T12:00:00.000+0000',
            externalState: 'testflight.build.state.processing'
          }
        ]
      end
    end

    context '.all' do
      it 'contains all of the builds across all build trains' do
        builds = Spaceship::TestFlight::Build.all(app_id: 10, platform: 'ios')
        expect(builds.size).to eq(3)
        expect(builds.sample).to be_instance_of(Spaceship::TestFlight::Build)
        expect(builds.map(&:train_version).uniq).to eq(['1.0', '1.1'])
      end
    end

    context '.builds_for_train' do
      it 'returns the builds for a given train version' do
        builds = Spaceship::TestFlight::Build.builds_for_train(app_id: 10, platform: 'ios', train_version: '1.0')
        expect(builds.size).to eq(1)
        expect(builds.map(&:train_version)).to eq(['1.0'])
      end
    end

    context '.all_processing_builds' do
      it 'returns a collection of builds that are processing' do
        builds = Spaceship::TestFlight::Build.all_processing_builds(app_id: 10, platform: 'ios')
        expect(builds.size).to eq(1)
        expect(builds.sample.id).to eq(3)
      end
    end

    context '.latest' do
      it 'returns the latest build across all build trains' do
        latest_build = Spaceship::TestFlight::Build.latest(app_id: 10, platform: 'ios')
        expect(latest_build.upload_date).to eq(Time.utc(2017, 1, 3, 12))
      end
    end
  end

  context 'instances' do
    let(:build) { Spaceship::TestFlight::Build.find(app_id: 'some-app-id', build_id: 'some-build-id') }

    before do
      mock_client_response(:get_build) do
        {
          id: 1,
          bundleId: 'some-bundle-id',
          appAdamId: 'some-app-id',
          uploadDate: '2017-01-01T12:00:00.000+0000',
          betaReviewInfo: {
            contactFirstName: 'Dev',
            contactLastName: 'Toolio',
            contactEmail: 'dev-toolio@fabric.io'
          },
          exportCompliance: {
            usesEncryption: true,
            encryptionUpdated: false
          },
          testInfo: [
            {
              locale: 'en-US',
              description: 'test info',
              feedbackEmail: 'email@example.com',
              whatsNew: 'this is new!'
            }
          ],
          dSYMUrl: 'https://some_dsym_url.com',
          includesSymbols: false,
          buildSdk: '13A340',
          fileName: 'AppName.ipa',
          containsODR: false,
          numberOfAssetPacks: 1
        }
      end
    end

    it 'reloads a build' do
      build = Spaceship::TestFlight::Build.new
      build.id = 1
      build.app_id = 2
      expect do
        build.reload
      end.to change(build, :bundle_id).from(nil).to('some-bundle-id')
    end

    context 'submission state' do
      it 'is ready to submit' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.submit.ready'
          }
        end
        expect(build).to be_ready_to_submit
      end

      it 'is ready to test' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.testing.ready'
          }
        end
        expect(build).to be_ready_to_test
      end

      it 'is active' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.testing.active'
          }
        end
        expect(build).to be_active
      end

      it 'is processing' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.processing'
          }
        end
        expect(build).to be_processing
      end

      it 'is has missing export compliance' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.export.compliance.missing'
          }
        end
        expect(build).to be_export_compliance_missing
      end

      it 'is processed on active' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.testing.active'
          }
        end
        expect(build).to be_processed
      end

      it 'is processed on ready to submit' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.submit.ready'
          }
        end
        expect(build).to be_processed
      end

      it 'is processed on export compliance missing' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.export.compliance.missing'
          }
        end
        expect(build).to be_processed
      end

      it 'is processed on review rejected' do
        mock_client_response(:get_build) do
          {
            'externalState' => 'testflight.build.state.review.rejected'
          }
        end
        expect(build).to be_processed
      end

      it "access build details and dSYM URL" do
        expect(build.dsym_url).to eq("https://some_dsym_url.com")
        expect(build.include_symbols).to eq(false)
        expect(build.number_of_asset_packs).to eq(1)
        expect(build.contains_odr).to eq(false)
        expect(build.build_sdk).to eq("13A340")
        expect(build.file_name).to eq("AppName.ipa")
      end
    end

    context '#upload_date' do
      it 'parses the string value' do
        expect(build.upload_date).to eq(Time.utc(2017, 1, 1, 12))
      end
    end

    context 'lazy loading attribute' do
      let(:build) { Spaceship::TestFlight::Build.new('bundleId' => 1, 'appAdamId' => 1) }
      it 'loads TestInfo' do
        expect(build).to receive(:reload).once.and_call_original
        expect(build.test_info).to be_instance_of(Spaceship::TestFlight::TestInfo)
      end
      it 'loads BetaReviewInfo' do
        expect(build).to receive(:reload).once.and_call_original
        expect(build.beta_review_info).to be_instance_of(Spaceship::TestFlight::BetaReviewInfo)
      end
      it 'loads ExportCompliance' do
        expect(build).to receive(:reload).once.and_call_original
        expect(build.export_compliance).to be_instance_of(Spaceship::TestFlight::ExportCompliance)
      end
    end

    context '#save!' do
      it 'saves via the client' do
        expect(build.client).to receive(:put_build).with(app_id: 'some-app-id', build_id: 1, build: instance_of(Spaceship::TestFlight::Build))
        build.test_info.whats_new = 'changes!'
        build.save!
      end
    end

    RSpec::Matchers.define(:same_test_info) do |other_test_info|
      match do |args|
        args[:build].test_info.to_s == other_test_info.to_s
      end
    end

    context '#update_build_information!' do
      it 'updates description' do
        updated_test_info = build.test_info.deep_copy
        updated_test_info.description = 'a newer description'

        expect(build.client).to receive(:put_build).with(same_test_info(updated_test_info))

        build.update_build_information!(description: 'a newer description')
      end

      it 'updates feedback_email' do
        updated_test_info = build.test_info.deep_copy
        updated_test_info.feedback_email = 'new_email@example.com'

        expect(build.client).to receive(:put_build).with(same_test_info(updated_test_info))

        build.update_build_information!(feedback_email: 'new_email@example.com')
      end

      it 'updates whats_new' do
        updated_test_info = build.test_info.deep_copy
        updated_test_info.whats_new = 'this fixture data is new'

        expect(build.client).to receive(:put_build).with(same_test_info(updated_test_info))

        build.update_build_information!(whats_new: 'this fixture data is new')
      end

      it 'does nothing if nothing is passed' do
        updated_test_info = build.test_info.deep_copy

        expect(build.client).to receive(:put_build).with(same_test_info(updated_test_info))

        build.update_build_information!
      end
    end
  end
end
