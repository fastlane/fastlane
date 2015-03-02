describe FastlaneCore do
  describe FastlaneCore::Helper do
    describe "#is_ci?" do
      it "returns false when not building in a known CI environment" do
        expect(FastlaneCore::Helper.is_ci?).to be false
      end

      it "returns true when building in Jenkins" do
        stub_const('ENV', { 'JENKINS_URL' => 'http://fake.jenkins.url' })
        expect(FastlaneCore::Helper.is_ci?).to be true
      end

      it "returns true when building in Travis CI" do
        stub_const('ENV', { 'TRAVIS' => true })
        expect(FastlaneCore::Helper.is_ci?).to be true
      end
    end
  end
end