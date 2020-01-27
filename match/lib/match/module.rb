require 'fastlane_core/helper'
require 'fastlane/boolean'

module Match
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Easily sync your certificates and profiles across your team"

  def self.environments
    return %w(appstore adhoc development enterprise developer_id)
  end

  def self.storage_modes
    return %w(git google_cloud)
  end

  def self.profile_type_sym(type)
    return type.to_sym
  end

  def self.cert_type_sym(type)
    return :mac_installer_distribution if type == "mac_installer_distribution"
    return :developer_id_installer if type == "developer_id_installer"
    return :developer_id_application if type == "developer_id"
    return :enterprise if type == "enterprise"
    return :development if type == "development"
    return :distribution if ["adhoc", "appstore", "distribution"].include?(type)
    raise "Unknown cert type: '#{type}'"
  end
end
