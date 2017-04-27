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

end