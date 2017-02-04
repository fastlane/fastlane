describe "Build Manager" do
  it "Truncates Changelog" do
    changelog = File.read("./pilot/spec/fixtures/build_manager/changelog_long")
    changelog = Pilot::BuildManager.truncate_changelog(changelog)
    expect(changelog).to eq(File.read("./pilot/spec/fixtures/build_manager/changelog_long_truncated"))
  end
  it "Keeps changelog if short enough" do
    changelog = "1234"
    changelog = Pilot::BuildManager.truncate_changelog(changelog)
    expect(changelog).to eq("1234")
  end
end
