describe Fastlane do
  describe Fastlane::FastFile do
    describe "artifactory" do
      it "Call the artifactory plugin with 'username' and 'password' " do
        result = Fastlane::FastFile.new.parse("lane :test do
            artifactory(username:'username', password: 'password', endpoint: 'artifactory.example.com', file: 'file.txt', repo: '/file.txt')
          end").runner.execute(:test)

        expect(result).to be true
      end

      it "Call the artifactory plugin with 'api_key' " do
        result = Fastlane::FastFile.new.parse("lane :test do
            artifactory(api_key:'MY_API_KEY', endpoint: 'artifactory.example.com', file: 'file.txt', repo: '/file.txt')
          end").runner.execute(:test)

        expect(result).to be true
      end

      it "Require 'username' or 'api_key' parameter" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
              artifactory(endpoint: 'artifactory.example.com', file: 'file.txt', repo: '/file.txt')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "Require 'password' if 'username' is provided" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
              artifactory(username:'username', endpoint: 'artifactory.example.com', file: 'file.txt', repo: '/file.txt')
            end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end

      it "Require 'username' if 'password' is provided" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
              artifactory(username:'username', endpoint: 'artifactory.example.com', file: 'file.txt', repo: '/file.txt')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end
end
