describe FastlaneCore do
  it "returns the path to the user's directory" do
    # spec_helper redirects it for every other example.
    allow(FastlaneCore).to receive(:fastlane_user_dir).and_call_original
    expected_path = File.join(Dir.home, ".fastlane")

    expect(File).to receive(:directory?).and_return(false)
    expect(FileUtils).to receive(:mkdir_p).with(expected_path)

    expect(FastlaneCore.fastlane_user_dir).to eq(expected_path)
  end
end
