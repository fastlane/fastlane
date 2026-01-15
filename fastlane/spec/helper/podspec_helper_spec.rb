require "stringio"

describe Fastlane::Actions do
  describe "#podspechelper" do
    before do
      @version_podspec_file = Fastlane::Helper::PodspecHelper.new
    end

    it "raises an exception when an incorrect path is given" do
      expect do
        Fastlane::Helper::PodspecHelper.new('invalid_podspec')
      end.to raise_error("Could not find podspec file at path 'invalid_podspec'")
    end

    it "raises an exception when there is no version in podspec" do
      expect do
        Fastlane::Helper::PodspecHelper.new.parse("")
      end.to raise_error("Could not find version in podspec content ''")
    end

    it "raises an exception when the version is commented-out in podspec" do
      test_content = '# s.version = "1.3.2"'
      expect do
        Fastlane::Helper::PodspecHelper.new.parse(test_content)
      end.to raise_error("Could not find version in podspec content '#{test_content}'")
    end

    context "when semantic version" do
      it "returns the current version once parsed" do
        test_content = 'spec.version = "1.3.2"'
        result = @version_podspec_file.parse(test_content)
        expect(result).to eq('1.3.2')
        expect(@version_podspec_file.version_value).to eq('1.3.2')
        expect(@version_podspec_file.version_match[:major]).to eq('1')
        expect(@version_podspec_file.version_match[:minor]).to eq('3')
        expect(@version_podspec_file.version_match[:patch]).to eq('2')
      end

      context "with appendix" do
        it "returns the current version once parsed with appendix" do
          test_content = 'spec.version = "1.3.2.4"'
          result = @version_podspec_file.parse(test_content)
          expect(result).to eq('1.3.2.4')
          expect(@version_podspec_file.version_value).to eq('1.3.2.4')
          expect(@version_podspec_file.version_match[:major]).to eq('1')
          expect(@version_podspec_file.version_match[:minor]).to eq('3')
          expect(@version_podspec_file.version_match[:patch]).to eq('2')
          expect(@version_podspec_file.version_match[:appendix]).to eq('.4')
        end

        it "returns the current version once parsed with longer appendix" do
          test_content = 'spec.version = "1.3.2.4.5"'
          result = @version_podspec_file.parse(test_content)
          expect(result).to eq('1.3.2.4.5')
          expect(@version_podspec_file.version_value).to eq('1.3.2.4.5')
          expect(@version_podspec_file.version_match[:major]).to eq('1')
          expect(@version_podspec_file.version_match[:minor]).to eq('3')
          expect(@version_podspec_file.version_match[:patch]).to eq('2')
          expect(@version_podspec_file.version_match[:appendix]).to eq('.4.5')
        end
      end

      it "returns the current version once parsed with prerelease" do
        test_content = 'spec.version = "1.3.2-SNAPSHOT"'
        result = @version_podspec_file.parse(test_content)
        expect(result).to eq('1.3.2-SNAPSHOT')
        expect(@version_podspec_file.version_value).to eq('1.3.2-SNAPSHOT')
        expect(@version_podspec_file.version_match[:major]).to eq('1')
        expect(@version_podspec_file.version_match[:minor]).to eq('3')
        expect(@version_podspec_file.version_match[:patch]).to eq('2')
        expect(@version_podspec_file.version_match[:prerelease]).to eq('SNAPSHOT')
      end

      it "returns the current version once parsed with appendix and prerelease" do
        test_content = 'spec.version = "1.3.2.4-SNAPSHOT"'
        result = @version_podspec_file.parse(test_content)
        expect(result).to eq('1.3.2.4-SNAPSHOT')
        expect(@version_podspec_file.version_value).to eq('1.3.2.4-SNAPSHOT')
        expect(@version_podspec_file.version_match[:major]).to eq('1')
        expect(@version_podspec_file.version_match[:minor]).to eq('3')
        expect(@version_podspec_file.version_match[:patch]).to eq('2')
        expect(@version_podspec_file.version_match[:appendix]).to eq('.4')
        expect(@version_podspec_file.version_match[:prerelease]).to eq('SNAPSHOT')
      end
    end
    context "with custom version_var_name" do
      it "returns the current version once parsed with custom version_var_name" do
        test_content = 'spec.my_version = "1.3.2"'
        version_podspec_file = Fastlane::Helper::PodspecHelper.new(nil, true, 'my_version')
        result = version_podspec_file.parse(test_content)
        expect(result).to eq('1.3.2')
        expect(version_podspec_file.version_value).to eq('1.3.2')
      end

      it "returns the current version once parsed with custom version_var_name and no prefix" do
        test_content = 'MY_VERSION = "1.3.2"'
        version_podspec_file = Fastlane::Helper::PodspecHelper.new(nil, false, 'MY_VERSION')
        result = version_podspec_file.parse(test_content)
        expect(result).to eq('1.3.2')
        expect(version_podspec_file.version_value).to eq('1.3.2')
      end

      it "matches the correct version when multiple version-like strings exist" do
        test_content = <<RUBY
          module Fastlane
            VERSION = '2.230.0'.freeze
            SUGGESTED_RUBY_MIN_VERSION = '3.2.0'.freeze
          end
RUBY
        # Default behavior matches first one if case-insensitive and no prefix
        version_podspec_file = Fastlane::Helper::PodspecHelper.new(nil, false, 'version')
        expect(version_podspec_file.parse(test_content)).to eq('2.230.0')

        # Explicitly matching SUGGESTED_RUBY_MIN_VERSION
        version_podspec_file = Fastlane::Helper::PodspecHelper.new(nil, false, 'SUGGESTED_RUBY_MIN_VERSION')
        expect(version_podspec_file.parse(test_content)).to eq('3.2.0')
      end
    end
  end
end
