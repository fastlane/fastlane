describe Fastlane do
  describe Fastlane::FastFile do
    describe "version_podspec_file" do
      before do
        @version_podspec_file = Fastlane::Helper::PodspecHelper.new
      end

      it "raises an exception when an incorrect path is given" do
        expect do
          Fastlane::Helper::PodspecHelper.new('invalid_podspec')
        end.to raise_error("Could not find podspec file at path 'invalid_podspec'".red)
      end

      it "raises an exception when there is no version in podspec" do
        expect do
          Fastlane::Helper::PodspecHelper.new.parse("")
        end.to raise_error("Could not find version in podspec content ''".red)
      end

      it "raises an exception when the version is commented-out in podspec" do
        test_content = '# version = "1.3.2"'
        expect do
          Fastlane::Helper::PodspecHelper.new.parse(test_content)
        end.to raise_error("Could not find version in podspec content '#{test_content}'".red)
      end

      it "returns the current version once parsed" do
        test_content = 'version = "1.3.2"'
        result = @version_podspec_file.parse(test_content)
        expect(result).to eq('1.3.2')
        expect(@version_podspec_file.version_value).to eq('1.3.2')
      end

      it "bumps the patch version when passing 'patch'" do
        test_content = 'version = "1.3.2"'
        @version_podspec_file.parse(test_content)
        result = @version_podspec_file.bump_version('patch')
        expect(result).to eq('1.3.3')
        expect(@version_podspec_file.version_value).to eq('1.3.3')
      end

      it "bumps the minor version when passing 'minor'" do
        test_content = 'version = "1.3.2"'
        @version_podspec_file.parse(test_content)
        result = @version_podspec_file.bump_version('minor')
        expect(result).to eq('1.4.0')
        expect(@version_podspec_file.version_value).to eq('1.4.0')
      end

      it "bumps the major version when passing 'major'" do
        test_content = 'version = "1.3.2"'
        @version_podspec_file.parse(test_content)
        result = @version_podspec_file.bump_version('major')
        expect(result).to eq('2.0.0')
        expect(@version_podspec_file.version_value).to eq('2.0.0')
      end

      it "appears to do nothing if reinjecting the same version number" do
        test_content = 'Pod::Spec.new do |s|
        s.version = "1.3.2"
      end'
        @version_podspec_file.parse(test_content)
        expect(@version_podspec_file.update_podspec).to eq('Pod::Spec.new do |s|
        s.version = "1.3.2"
      end')
      end

      it "allows to set a specific version" do
        test_content = 'Pod::Spec.new do |s|
        s.version = "1.3.2"
      end'
        @version_podspec_file.parse(test_content)
        expect(@version_podspec_file.update_podspec('2.0.0')).to eq('Pod::Spec.new do |s|
        s.version = "2.0.0"
      end')
      end

      it "updates only the version when updating podspec" do
        test_content = 'Pod::Spec.new do |s|
        s.version = "1.3.2"
      end'
        @version_podspec_file.parse(test_content)
        result = @version_podspec_file.bump_version('major')
        expect(result).to eq('2.0.0')
        expect(@version_podspec_file.version_value).to eq('2.0.0')
        expect(@version_podspec_file.update_podspec).to eq('Pod::Spec.new do |s|
        s.version = "2.0.0"
      end')
      end
    end

    describe "version_get_podspec" do
      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            version_get_podspec
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `version_get_podspec` action".red)
      end

      it "gets the version from a podspec file" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_get_podspec(path: './fastlane/spec/fixtures/podspecs/test.podspec')
        end").runner.execute(:test)

        expect(result).to eq('1.5.1')
      end
    end

    describe "version_bump_podspec" do
      before do
        @podspec_path = './fastlane/spec/fixtures/podspecs/test.podspec'
      end

      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            version_bump_podspec
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `version_bump_podspec` action".red)
      end

      it "bumps patch version when only the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_podspec(path: '#{@podspec_path}')
        end").runner.execute(:test)

        expect(result).to eq('1.5.2')
      end

      it "bumps patch version when bump_type is set to patch the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_podspec(path: '#{@podspec_path}', bump_type: 'patch')
        end").runner.execute(:test)

        expect(result).to eq('1.5.2')
      end

      it "bumps minor version when bump_type is set to minor the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_podspec(path: '#{@podspec_path}', bump_type: 'minor')
        end").runner.execute(:test)

        expect(result).to eq('1.6.0')
      end

      it "bumps major version when bump_type is set to major the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_podspec(path: '#{@podspec_path}', bump_type: 'major')
        end").runner.execute(:test)

        expect(result).to eq('2.0.0')
      end
    end
  end
end
