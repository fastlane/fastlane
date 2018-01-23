require 'fastlane_core/helper'

module PEM
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  tmp_dir = Dir.tmpdir
  TMP_FOLDER = "#{tmp_dir}/fastlane/PEM/"
  FileUtils.mkdir_p(TMP_FOLDER)

  ENV['FASTLANE_TEAM_ID'] ||= ENV["PEM_TEAM_ID"]
  ENV['DELIVER_USER'] ||= ENV["PEM_USERNAME"]

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
end
