# Asking simctl and xcodebuild for simulators takes seconds per Scan.config;
# fake it out for tests that are not about simulator detection.
# The real lookups are checked in device_manager_spec and detect_values_spec.
def fake_out_simulator_detection
  simulator = FastlaneCore::DeviceManager::Device.new(name: 'iPhone 16', udid: '00000000-0000-0000-0000-000000000000', os_type: 'iOS', os_version: '18.0', state: 'Shutdown', is_simulator: true)
  allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([simulator])
  allow(Scan::DetectValues).to receive(:default_os_version).and_return(Gem::Version.new('18.0'))
end

# What xcodebuild -showBuildSettings answers for the keys scan reads from
# scan/examples/standard/app.xcodeproj. BUILT_PRODUCTS_DIR is left out: it is a
# path on the machine that answered.
SCAN_STANDARD_APP_BUILD_SETTINGS = {
  "SUPPORTED_PLATFORMS" => "iphoneos iphonesimulator",
  "IPHONEOS_DEPLOYMENT_TARGET" => "9.0",
  "WRAPPER_NAME" => "app.app",
  "WRAPPER_SUFFIX" => ".app"
}.freeze

# Fetching build settings runs xcodebuild twice, over a second per Scan.config;
# fake it out for tests that do not check a build setting.
# The real lookup is checked in fastlane_core's project_spec.
def fake_out_build_settings
  standard_app = File.expand_path("./scan/examples/standard/app.xcodeproj")
  allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).and_wrap_original do |original, key: nil, optional: true|
    next original.call(key: key, optional: optional) unless original.receiver.path == standard_app

    SCAN_STANDARD_APP_BUILD_SETTINGS[key]
  end
end
