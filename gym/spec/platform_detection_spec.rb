describe Gym do
  it "detects when a multiplatform project is building for iOS", requires_xcodebuild: true do
    options = { project: "./gym/examples/multiplatform/Example.xcodeproj", sdk: "iphoneos" }
    Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

    expect(Gym.project.multiplatform?).to eq(true)
    expect(Gym.project.ios?).to eq(true)
    expect(Gym.project.mac?).to eq(true)

    expect(Gym.building_for_mac?).to eq(false)
    expect(Gym.building_for_ios?).to eq(true)
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
    expect(Gym.building_multiplatform_for_mac?).to eq(true)
  end
end
