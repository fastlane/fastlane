# Loading the XCode Project is really slow (>1 second)
# fake it out for tests
def fake_out_xcode_project_loading
  fake_result = <<-EOS
Information about project "Example":
    Targets:
        Example
        ExampleUITests
        ExampleMacOS
        ExampleMacOSUITests
    Build Configurations:
        Debug
        Release
    If no build configuration is specified and -scheme is not passed then "Release" is used.
    Schemes:
        Example
        ExampleUITests
        ExampleMacOS
EOS
  allow_any_instance_of(FastlaneCore::Project).to receive(:raw_info).and_return(fake_result)
end

# What xcodebuild -showBuildSettings answers for the keys snapshot reads, for
# fake_out_build_settings.
SNAPSHOT_BUILD_SETTINGS = {
  "./snapshot/example/Example.xcodeproj" => {
    "ExampleUITests" => {
      "SUPPORTED_PLATFORMS" => "iphoneos iphonesimulator",
      "WRAPPER_NAME" => "Example.app",
      "WRAPPER_SUFFIX" => ".app"
    },
    "ExampleMacOS" => {
      "WRAPPER_NAME" => "ExampleMacOS.app",
      "WRAPPER_SUFFIX" => ".app"
    }
  }
}.freeze
