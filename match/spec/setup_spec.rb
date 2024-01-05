describe Match do
  describe Match::Setup do
    it "creates a new Matchfile, containing the git_url" do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"

      expect(FastlaneCore::UI.ui_object).to receive(:select).and_return("git")
      expect(FastlaneCore::UI.ui_object).to receive(:input).and_return(git_url)

      path = File.join(Dir.mktmpdir, "Matchfile")
      Match::Setup.new.run(path)

      content = File.read(path)
      expect(content).to include("git_url(\"#{git_url}\")")
      expect(content).to include("type(\"development\")")
      expect(content).to include("match --help")
    end
  end
end
