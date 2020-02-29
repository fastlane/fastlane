describe Fastlane::Helper::DotenvHelper do
  describe "directory discovery" do
    it "discovers in fastlane directory" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/dotenvs/withFastfiles/fastlaneonly/fastlane").at_least(:once)
      expect(Fastlane::Helper::DotenvHelper.find_dotenv_directory).to eq("./fastlane/spec/fixtures/dotenvs/withFastfiles/fastlaneonly/fastlane")
    end

    it "discovers in the parent directory" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentonly/fastlane").at_least(:once)
      expect(Fastlane::Helper::DotenvHelper.find_dotenv_directory).to eq("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentonly/fastlane/..")
    end

    it "prioritises fastlane directory" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentandfastlane/fastlane").at_least(:once)
      expect(Fastlane::Helper::DotenvHelper.find_dotenv_directory).to eq("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentandfastlane/fastlane")
    end

    it "returns nil when no .env files exist" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/fastfiles").at_least(:once)
      expect(Fastlane::Helper::DotenvHelper.find_dotenv_directory).to eq(nil)
    end
  end

  describe "load" do
    require 'dotenv'

    it "loads the .env and .env.default files" do
      expect(Dotenv).to receive(:load).with('/base/path/.env', '/base/path/.env.default')
      expect(Dotenv).not_to(receive(:overload))
      Fastlane::Helper::DotenvHelper.load_dot_envs_from(nil, '/base/path')
    end

    it "overloads additional files with param" do
      expect(Dotenv).to receive(:load).with('/base/path/.env', '/base/path/.env.default')
      expect(Dotenv).to receive(:overload).with('/base/path/.env.one')
      expect(Dotenv).to receive(:overload).with('/base/path/.env.two')
      Fastlane::Helper::DotenvHelper.load_dot_envs_from('one,two', '/base/path')
    end
  end
end
