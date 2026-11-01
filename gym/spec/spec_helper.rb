# What xcodebuild -showBuildSettings answers for the keys gym reads, for
# fake_out_build_settings. Projects whose specs check a build setting are left
# out so that they keep the real lookup.
GYM_IOS_APP_BUILD_SETTINGS = {
  "SUPPORTED_PLATFORMS" => "iphoneos iphonesimulator",
  "SUPPORTS_MACCATALYST" => "NO",
  "SUPPORTS_UIKITFORMAC" => nil,
  "DEVELOPMENT_TEAM" => nil,
  "WRAPPER_NAME" => "ExampleProductName.app",
  "WRAPPER_SUFFIX" => ".app",
  "CONFIGURATION" => "Debug"
}.freeze

GYM_BUILD_SETTINGS = {
  "./gym/examples/standard/Example.xcodeproj" => { "Example" => GYM_IOS_APP_BUILD_SETTINGS },
  "./gym/examples/multipleSchemes/Example.xcodeproj" => { "Example" => GYM_IOS_APP_BUILD_SETTINGS },
  "./gym/spec/fixtures/projects/cocoapods/Example.xcworkspace" => {
    "Example" => GYM_IOS_APP_BUILD_SETTINGS.merge("DEVELOPMENT_TEAM" => "39WKQBKTL5"),
    "Example (Debug)" => GYM_IOS_APP_BUILD_SETTINGS.merge("DEVELOPMENT_TEAM" => "39WKQBKTL5"),
    "ExampletvOS" => GYM_IOS_APP_BUILD_SETTINGS.merge("SUPPORTED_PLATFORMS" => "appletvos appletvsimulator", "WRAPPER_NAME" => "ExampletvOS.app")
  },
  "./gym/spec/fixtures/projects/projectBasedOnInheritance/ExampleWithInheritedXcconfig.xcworkspace" => {
    "Target A" => GYM_IOS_APP_BUILD_SETTINGS.merge("DEVELOPMENT_TEAM" => "TARGETADEVTEAM", "WRAPPER_NAME" => "Target A.app")
  }
}.freeze
