require 'spec_helper'

describe FastlaneCore::BuildWatcher do

  # methods that need mocking:
  # Build.all_processing_builds
  # Build.latest
  # Build.builds_for_train
  # Build#upload_date
  # Build#train_version
  # Build#build_version
  # Build#active?
  # Build#ready_to_submit?
  # Build#export_compliance_missing?

  context '.wait_for_build_processing_to_be_complete' do
    let(:build) { double('Build', processed?: true, active?: true, train_version: '1.0', build_version: '2') }
    it 'returns an already-active build' do
      expect(Spaceship::TestFlight::Build).to receive(:all_processing_builds).and_return([])
      expect(Spaceship::TestFlight::Build).to receive(:latest).and_return(build)
      expect(Spaceship::TestFlight::Build).to receive(:builds_for_train).and_return([build])

      expect(UI).to receive(:success).with('Build 1.0 - 2 is already being tested')
      found_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, delay: 0)

      expect(found_build).to eq(build)
    end
  end
end