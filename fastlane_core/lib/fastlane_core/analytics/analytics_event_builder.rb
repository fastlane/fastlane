module FastlaneCore
  class AnalyticsEventBuilder

    attr_accessor :base_launch_hash
    attr_accessor :base_completion_hash

    def initialize(oauth_app_name: nil, p_hash: nil, session_id: nil, action_name: nil)
      @base_launch_hash = {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: p_hash,
          detail: session_id
        },
        action: {
          name: 'launched',
          detail: action_name
        }
        version: 1
      }

      @base_completion_hash = {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: p_hash,
          detail: session_id
        },
        action: {
          name: 'completed',
          detail: action_name
        }
        version: 1
      }
    end

    def fastlane_version_launched_event(fastlane_version: nil, timestamp: nil)
      version_event = base_launch_hash.dup
      version_event[:primary_target] = {
        name: 'fastlane_version',
        detail: fastlane_version
      }
      version_event[:millis_since_epoch] = timestamp
      return version_event
    end

    def install_method_launched_event(install_method: nil, timestamp: nil)
      install_method_event = base_launch_hash.dup
      install_method_event[:primary_target] = {
        name: 'install_method',
        detail: install_method
      }
      install_method_event[:millis_since_epoch] = timestamp
      return install_method_event
    end

    def os_version_launched_event(operating_system: nil, version: nil, timestamp: nil)
      os_version_event = base_launch_hash.dup
      os_version_event[:primary_target] = {
        name: 'operating_system',
        detail: operating_system
      }
      os_version_event[:secondary_target] = {
        name: 'version',
        detail: version
      }
      os_version_event[:millis_since_epoch] = timestamp
      return os_version_event
    end

    def ide_version_launched_event(ide_version: nil, timestamp: nil)
      ide_version_event = base_launch_hash.dup
      ide_version_event[:primary_target] = {
        name: 'ide_version',
        detail: ide_version
      }
      ide_version_event[:millis_since_epoch] = timestamp
      return ide_version_event
    end

    def ci_launched_event(ci: nil, timestamp: nil)
      ci_event = base_launch_hash.dup
      ci_event[:primary_target] = {
        name: 'ci',
        detail: ci
      }
      ci_event[:millis_since_epoch] = timestamp
      return ci_event
    end

    def fastfile_launched_event(fastfile: nil, fastfile_id: nil, timestamp: nil)
      fastfile_event = base_launch_hash.dup
      fastfile_event[:primary_target] = {
        name: 'fastfile',
        detail: fastfile
      }
      fastfile_event[:secondary_target] = {
        name: 'fastfile_id',
        detail: fastfile_id
      }
      fastfile_event[:millis_since_epoch] = timestamp
      return fastfile_event
    end

    def platform_launched_event(platform: nil, timestamp: nil)
      platform_event = base_launch_hash.dup
      platform_event[:primary_target] = {
        name: 'platform',
        detail: platform
      }
      platform_event[:millis_since_epoch] = timestamp
      return platform_event
    end

    def ruby_version_launched_event(ruby_version: nil, timestamp: nil)
      ruby_version_event = base_launch_hash.dup
      ruby_version_event[:primary_target] = {
        name: 'ruby_version',
        detail: ruby_version
      }
      ruby_version_event[:millis_since_epoch] = timestamp
      return ruby_version_event
    end

    def completed_event(status: nil, timestamp: nil)
      completed_event = base_completion_hash.dup
      completed_event[:primary_target] = {
        name: 'status',
        detail: status
      }
      completed_event[:millis_since_epoch] = timestamp
      return completed_event
    end
  end
end
