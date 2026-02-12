describe Gym do
  it "detects when a multiplatform project is building for iOS", requires_xcodebuild: true do
    options = { project: "./gym/examples/multiplatform/Example.xcodeproj", sdk: "iphoneos" }
    Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

    expect(Gym.project.multiplatform?).to eq(true)
    expect(Gym.project.ios?).to eq(true)
    expect(Gym.project.mac?).to eq(true)

    expect(Gym.building_for_mac?).to eq(false)
    expect(Gym.building_for_ios?).to eq(true)
    expect(Gym.building_for_ipa?).to eq(true)
    expect(Gym.building_for_pkg?).to eq(false)
    expect(Gym.building_multiplatform_for_ios?).to eq(true)
  end

  it "detects when a multiplatform project is building for macOS", requires_xcodebuild: true do
    options = { project: "./gym/examples/multiplatform/Example.xcodeproj", sdk: "macosx" }
    Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

    expect(Gym.project.multiplatform?).to eq(true)
    expect(Gym.project.ios?).to eq(true)
    expect(Gym.project.mac?).to eq(true)

    expect(Gym.building_for_ios?).to eq(false)
    expect(Gym.building_for_mac?).to eq(true)
    expect(Gym.building_for_ipa?).to eq(false)
    expect(Gym.building_for_pkg?).to eq(true)
    expect(Gym.building_multiplatform_for_mac?).to eq(true)
  end

  it "detects the correct platform for a visionOS project", requires_xcodebuild: true, if: FastlaneCore::Helper.mac? && FastlaneCore::Helper.xcode_at_least?('15.0') do
    options = { project: "./gym/examples/visionos/VisionExample.xcodeproj", sdk: "xros", skip_package_dependencies_resolution: true }
    Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

    expect(Gym.project.multiplatform?).to eq(false)
    expect(Gym.project.visionos?).to eq(true)
    expect(Gym.project.ios?).to eq(false)

    expect(Gym.building_for_ios?).to eq(true)
    expect(Gym.building_for_mac?).to eq(false)
    expect(Gym.building_for_ipa?).to eq(true)
    expect(Gym.building_for_pkg?).to eq(false)
    expect(Gym.building_multiplatform_for_mac?).to eq(false)
  end

  it "detects when a Mac Catalyst project with macosx SDK is building for macOS without explicit catalyst_platform" do
    options = { project: "./gym/examples/standard/Example.xcodeproj", sdk: "macosx" }
    Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

    # Mock the project to support Mac Catalyst
    allow(Gym.project).to receive(:supports_mac_catalyst?).and_return(true)
    allow(Gym.project).to receive(:mac?).and_return(true)
    allow(Gym.project).to receive(:ios?).and_return(true)

    # When SDK is macosx and no explicit catalyst_platform is set, should build for Mac (PKG)
    expect(Gym.building_for_mac?).to eq(true)
    expect(Gym.building_for_ios?).to eq(false)
    expect(Gym.building_for_ipa?).to eq(false)
    expect(Gym.building_for_pkg?).to eq(true)
  end

  it "detects when a Mac Catalyst project with iphoneos SDK is building for iOS without explicit catalyst_platform" do
    options = { project: "./gym/examples/standard/Example.xcodeproj", sdk: "iphoneos" }
    Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

    # Mock the project to support Mac Catalyst
    allow(Gym.project).to receive(:supports_mac_catalyst?).and_return(true)
    allow(Gym.project).to receive(:mac?).and_return(true)
    allow(Gym.project).to receive(:ios?).and_return(true)

    # When SDK is iphoneos and no explicit catalyst_platform is set, should build for iOS (IPA)
    expect(Gym.building_for_mac?).to eq(false)
    expect(Gym.building_for_ios?).to eq(true)
    expect(Gym.building_for_ipa?).to eq(true)
    expect(Gym.building_for_pkg?).to eq(false)
  end
end
