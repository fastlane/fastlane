describe Gym do
  describe Gym::Options do
    it "raises an exception when project path wasn't found" do
      expect {
        Gym.config = {project: "something.xcodeproj", workspace: "something.xcworkspace" }
      }.to raise_error "You can only pass either a workspace or a project path, not both".red
    end
  end
end