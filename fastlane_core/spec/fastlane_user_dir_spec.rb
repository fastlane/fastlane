describe FastlaneCore do
  it "returns the path to the user's directory" do
    expected_path = File.join(ENV["HOME"], ".fastlane")

    expect(File).to receive(:directory?).and_return(false)
    expect(FileUtils).to receive(:mkdir_p).with(expected_path)

    expect(FastlaneCore.fastlane_user_dir).to eq(expected_path)
  end
end
