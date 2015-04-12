describe Fastlane do
  describe "Action List" do
    it "doesn't throw an exception" do
      require 'fastlane/actions_list'
      Fastlane::ActionsList.run nil
    end
  end
end
