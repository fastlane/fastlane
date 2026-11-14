# Asking simctl and xcodebuild for simulators takes seconds per Scan.config;
# fake it out for tests that are not about simulator detection.
# The real lookups are checked in device_manager_spec and detect_values_spec.
def fake_out_simulator_detection
  simulator = FastlaneCore::DeviceManager::Device.new(name: 'iPhone 16', udid: '00000000-0000-0000-0000-000000000000', os_type: 'iOS', os_version: '18.0', state: 'Shutdown', is_simulator: true)
  allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([simulator])
  allow(Scan::DetectValues).to receive(:default_os_version).and_return(Gem::Version.new('18.0'))
end

# What xcodebuild -showBuildSettings answers for the keys scan reads, for
# fake_out_build_settings.
SCAN_BUILD_SETTINGS = {
  "./scan/examples/standard/app.xcodeproj" => {
    "app" => {
      "SUPPORTED_PLATFORMS" => "iphoneos iphonesimulator",
      "IPHONEOS_DEPLOYMENT_TARGET" => "9.0",
      "WRAPPER_NAME" => "app.app",
      "WRAPPER_SUFFIX" => ".app"
    }
  }
}.freeze
