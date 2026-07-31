require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents the details of a build
    class BuildDetails < TunesBase
      # @return (String) The App identifier of this app, provided by App Store Connect
      # @example
      #   '1013943394'
      attr_accessor :apple_id

      # @return (Integer) Upload date of build as UNIX timestamp
      # @example 1563813377000
      attr_accessor :upload_date

      # @return (String) State of the build/binary
      # @example 'ITC.apps.preReleaseBuildStatus.Validated'
      attr_accessor :binary_state

      # @return (String) Name of uploaded file
      # @example 'MyApp.ipa'
      attr_accessor :file_name

      # @return (String) SDK used to build app
      # @example '13A340'
      attr_accessor :build_sdk

      # @return (String) Platform
      # @example '13A340'
      attr_accessor :build_platform

      # @return (String) Bundle ID of build
      # @example 'com.sample.app'
      attr_accessor :bundle_id

      # @return (String) Name of app
      # @example 'Test App'
      attr_accessor :app_name

      # @return (String) Supported architectures of the build
      # @example 'armv7, arm64'
      attr_accessor :supported_architectures

      # @return (String) Localizations of the build
      # @example 'English'
      attr_accessor :localizations

      # @return (Boolean) Is this a Newsstand app?
      # @example false
      attr_accessor :newsstand_app

      # @return (Boolean) Does the build contain an app icon?
      # @example true
      attr_accessor :prerendered_icon_flag

      # @return [Hash] containing all entitlements for all targets
      # @example 'Sample.app/Sample: {'com.apple.developer.team-identifier': 'ABC123DEF456'}'
      attr_accessor :entitlements

      # @return (String) Platform of the app
      # @example 'ios'
      attr_accessor :app_platform

      # @return (String) Device Requirements / Device Protocols
      attr_accessor :device_protocols

      # @return (String) Version code of the build
      # @example '4'
      attr_accessor :cf_bundle_version

      # @return (String) Version code of the build train
      # @example '1.6'
      attr_accessor :cf_bundle_short_version

      # @return (String) Minimum iOS Version
      # @example '9.3'
      attr_accessor :min_os_version

      # @return (String) Enabled Device Family
      # @example 'iPhone / iPod touch, iPad''
      attr_accessor :device_families

      # @return (String) Required Capabilities
      # @example 'armv7'
      attr_accessor :capabilities

      # @return (Int) Compressed File Size in bytes
      # @example '9365224'
      attr_accessor :size_in_bytes

      # @return (Hash) Estimated App Store file sizes for all devices in bytes
      attr_accessor :sizes_in_bytes

      # @return (Hash) Estimated App Store file sizes for all devices in bytes
      attr_accessor :sizes_in_bytes_with_device_loc

      # @return (Boolean) Contains On Demand Resources
      # @example false
      attr_accessor :contains_odr

      # @return (Integer) Number of Asset packs
      # @example 0
      attr_accessor :number_of_asset_packs

      # @return (Boolean) Includes Symbols
      # @example true
      attr_accessor :include_symbols

      # @return (Boolean) App Uses Non-Exempt Encryption (Optional)
      # @example null
      attr_accessor :use_encryption_in_plist

      # @return (Boolean) App Encryption Export Compliance Code (Optional)
      # @example null
      attr_accessor :export_compliance_code_value_in_plist

      # @return (Boolean) Includes Stickers
      # @example false
      attr_accessor :has_stickers

      # @return (Boolean) Includes iMessage App
      # @example false
      attr_accessor :has_messages_extension

      # @return (Boolean) // Not sure what this is for
      # @example false
      attr_accessor :launch_prohibited

      # @return (Boolean) Uses SiriKit
      # @example false
      attr_accessor :uses_synapse

      # @return (Boolean) App uses Location Services
      # @example false
      attr_accessor :uses_location_background_mode

      # @return (String) Link to the dSYM file (not always available)
      # @example build/***.****.*****.*****-1.0.0-2647.dSYM.zip
      attr_accessor :dsym_url

      # @return (Boolean) Watch-Only App
      # @example false
      attr_accessor :watch_only

      attr_mapping(
        'apple_id' => :apple_id,
        'uploadDate' => :upload_date,
        'binaryState' => :binary_state,
        'fileName' => :file_name,
        'buildSdk' => :build_sdk,
        'buildPlatform' => :build_platform,
        'bundleId' => :bundle_id,
        'appName' => :app_name,
        'supportedArchitectures' => :supported_architectures,
        'localizations' => :localizations,
        'newsstandApp' => :newsstand_app,
        'prerenderedIconFlag' => :prerendered_icon_flag,
        'entitlements' => :entitlements,
        'appPlatform' => :app_platform,
        'deviceProtocols' => :device_protocols,
        'cfBundleVersion' => :cf_bundle_version,
        'cfBundleShortVersion' => :cf_bundle_short_version,
        'minOsVersion' => :min_os_version,
        'deviceFamilies' => :device_families,
        'capabilities' => :capabilities,
        'sizeInBytes' => :size_in_bytes,
        'sizesInBytes' => :sizes_in_bytes,
        'sizesInBytesWithDeviceLoc' => :sizes_in_bytes_with_device_loc,
        'containsODR' => :contains_odr,
        'numberOfAssetPacks' => :number_of_asset_packs,
        'includesSymbols' => :include_symbols,
        'useEncryptionInPlist' => :use_encryption_in_plist,
        'exportComplianceCodeValueInPlist' => :export_compliance_code_value_in_plist,
        'hasStickers' => :has_stickers,
        'hasMessagesExtension' => :has_messages_extension,
        'launchProhibited' => :launch_prohibited,
        'usesSynapse' => :uses_synapse,
        'usesLocationBackgroundMode' => :uses_location_background_mode,
        'dsymurl' => :dsym_url,
        'watchOnly' => :watch_only
      )
    end
  end
end
