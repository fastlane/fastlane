describe Match do
  describe Match::GitHelper do
    describe "generate_commit_message" do
      it "works" do
        values = {
          app_identifier: "tools.fastlane.app",
          type: "appstore"
        }
        result = Match::GitHelper.generate_commit_message(values)
        expect(result).to eq("[fastlane] Updated tools.fastlane.app for appstore")
      end
    end

    describe "#clone" do
      it "clones the repo" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/certificates"
        command = "git clone '#{git_url}' '#{path}' --depth 1"
        to_params = {
          command: command, 
          print_all: nil, 
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor). 
                      to receive(:execute).
                      with(to_params).
                      and_return(nil)

        result = Match::GitHelper.clone(git_url)
        expect(result).to match(/\/var\/folders.*/)
        expect(File.directory?(result)).to eq(true)
      end
    end
  end
end