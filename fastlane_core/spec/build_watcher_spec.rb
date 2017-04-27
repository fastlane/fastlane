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
    let(:build) { double('Build', processing?: false, active?: true, train_version: '1.0', build_version: '2') }
    it 'returns a processed build' do
      # allow(Spaceship::TestFlight::Build).to receive(:all_processing_builds) do
      #   [
      #     double('Build', processing?: true),
      #     double('Build', processing?: true),
      #     double('Build', processing?: true)
      #   ]
      # end
      # builds = Spaceship::TestFlight::Build.all_processing_builds(app_id: 'fake-app-id', platform: :ios)
      # require 'pry'; binding.pry
      # puts ''
      allow(Spaceship::TestFlight::Build).to receive(:all_processing_builds).and_return([])
      allow(Spaceship::TestFlight::Build).to receive(:latest).and_return(build)
      allow(Spaceship::TestFlight::Build).to receive(:builds_for_train).and_return([build])

      build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: 'some-app-id', platform: :ios, delay: 0)
    end
  end
end