require 'dotenv'

describe Fastlane::Helper::DotenvHelper do
  describe "#load_dot_env" do
    it "does not load dotenvs when there is no directory" do
      expect(subject.class).to receive(:find_dotenv_directory).and_return(nil)
      expect(subject.class).to_not(receive(:load_dot_envs_from))
      subject.class.load_dot_env(nil)
    end

    it "loads dotenvs when there is a directory" do
      expect(subject.class).to receive(:find_dotenv_directory).and_return("./some/path")
      expect(subject.class).to receive(:load_dot_envs_from).with("one", "./some/path")
      subject.class.load_dot_env("one")
    end
  end

  describe "#find_dotenv_directory" do
    it "discovers in fastlane directory" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/dotenvs/withFastfiles/fastlaneonly/fastlane").at_least(:once)
      expect(subject.class.find_dotenv_directory).to eq("./fastlane/spec/fixtures/dotenvs/withFastfiles/fastlaneonly/fastlane")
    end

    it "discovers in the parent directory" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentonly/fastlane").at_least(:once)
      expect(subject.class.find_dotenv_directory).to eq("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentonly/fastlane/..")
    end

    it "prioritises fastlane directory" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentandfastlane/fastlane").at_least(:once)
      expect(subject.class.find_dotenv_directory).to eq("./fastlane/spec/fixtures/dotenvs/withFastfiles/parentandfastlane/fastlane")
    end

    it "returns nil when no .env files exist" do
      expect(FastlaneCore::FastlaneFolder).to receive(:path).and_return("./fastlane/spec/fixtures/fastfiles").at_least(:once)
      expect(subject.class.find_dotenv_directory).to eq(nil)
    end
  end

  describe "#load_dot_envs_from" do
    it "loads the .env and .env.default files" do
      expect(Dotenv).to receive(:load).with('/base/path/.env', '/base/path/.env.default')
      expect(Dotenv).not_to(receive(:overload))
      subject.class.load_dot_envs_from(nil, '/base/path')
    end

    it "overloads additional files with param" do
      expect(Dotenv).to receive(:load).with('/base/path/.env', '/base/path/.env.default')
      expect(Dotenv).to receive(:overload).with('/base/path/.env.one')
      expect(Dotenv).to receive(:overload).with('/base/path/.env.two')
      subject.class.load_dot_envs_from('one,two', '/base/path')
    end
  end
end
