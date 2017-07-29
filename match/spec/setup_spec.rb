describe Match do
  describe Match::Setup do
    it "works" do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      allow(FastlaneCore::UI).to receive(:input).and_return(git_url.to_s)

      path = File.join(Dir.mktmpdir, "Matchfile")
      Match::Setup.new.run(path)

      content = File.read(path)
      expect(content).to include("git_url \"#{git_url}\"")
      expect(content).to include("type \"development\"")
      expect(content).to include("match --help")
    end
  end
end
