describe Fastlane do
  describe Fastlane::FastFile do
    describe "version_gemspec_file" do
      before do
        @version_gemspec_file = Fastlane::Actions::VersionGemspecFile.new
      end

      it "raises an exception when an incorrect path is given" do
        expect do
          Fastlane::Actions::VersionGemspecFile.new('invalid_gemspec')
        end.to raise_error("Could not find gemspec file at path 'invalid_gemspec'".red)
      end

      it "raises an exception when there is no version in gemspec" do
        expect do
          Fastlane::Actions::VersionGemspecFile.new.parse("")
        end.to raise_error("Could not find version in gemspec content ''".red)
      end

      it "raises an exception when the version is commented-out in gemspec" do
        test_content = '# version = "1.3.2"'
        expect do
          Fastlane::Actions::VersionGemspecFile.new.parse(test_content)
        end.to raise_error("Could not find version in gemspec content '#{test_content}'".red)
      end

      it "returns the current version once parsed" do
        test_content = 'version = "1.3.2"'
        result = @version_gemspec_file.parse(test_content)
        expect(result).to eq('1.3.2')
        expect(@version_gemspec_file.version_value).to eq('1.3.2')
      end

      it "bumps the patch version when passing 'patch'" do
        test_content = 'version = "1.3.2"'
        @version_gemspec_file.parse(test_content)
        result = @version_gemspec_file.bump_version('patch')
        expect(result).to eq('1.3.3')
        expect(@version_gemspec_file.version_value).to eq('1.3.3')
      end

      it "bumps the minor version when passing 'minor'" do
        test_content = 'version = "1.3.2"'
        @version_gemspec_file.parse(test_content)
        result = @version_gemspec_file.bump_version('minor')
        expect(result).to eq('1.4.0')
        expect(@version_gemspec_file.version_value).to eq('1.4.0')
      end

      it "bumps the major version when passing 'major'" do
        test_content = 'version = "1.3.2"'
        @version_gemspec_file.parse(test_content)
        result = @version_gemspec_file.bump_version('major')
        expect(result).to eq('2.0.0')
        expect(@version_gemspec_file.version_value).to eq('2.0.0')
      end

      it "appears to do nothing if reinjecting the same version number" do
        test_content = 'Pod::Spec.new do |s|
        s.version = "1.3.2"
      end'
        @version_gemspec_file.parse(test_content)
        expect(@version_gemspec_file.update_gemspec).to eq('Pod::Spec.new do |s|
        s.version = "1.3.2"
      end')
      end

      it "allows to set a specific version" do
        test_content = 'Pod::Spec.new do |s|
        s.version = "1.3.2"
      end'
        @version_gemspec_file.parse(test_content)
        expect(@version_gemspec_file.update_gemspec('2.0.0')).to eq('Pod::Spec.new do |s|
        s.version = "2.0.0"
      end')
      end

      it "updates only the version when updating gemspec" do
        test_content = 'Pod::Spec.new do |s|
        s.version = "1.3.2"
      end'
        @version_gemspec_file.parse(test_content)
        result = @version_gemspec_file.bump_version('major')
        expect(result).to eq('2.0.0')
        expect(@version_gemspec_file.version_value).to eq('2.0.0')
        expect(@version_gemspec_file.update_gemspec).to eq('Pod::Spec.new do |s|
        s.version = "2.0.0"
      end')
      end
    end

    describe "version_get_gemspec" do
      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            version_get_gemspec
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `version_get_gemspec` action".red)
      end

      it "gets the version from a gemspec file" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_get_gemspec(path: './fastlane/spec/fixtures/gemspecs/1PasswordExtension.podspec')
        end").runner.execute(:test)

        expect(result).to eq('1.5.1')
      end
    end

    describe "version_bump_gemspec" do
      before do
        @gemspec_path = './fastlane/spec/fixtures/gemspecs/1PasswordExtension.podspec'
      end

      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            version_bump_gemspec
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `version_bump_gemspec` action".red)
      end

      it "bumps patch version when only the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_gemspec(path: '#{@gemspec_path}')
        end").runner.execute(:test)

        expect(result).to eq('1.5.2')
      end

      it "bumps patch version when bump_type is set to patch the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_gemspec(path: '#{@gemspec_path}', bump_type: 'patch')
        end").runner.execute(:test)

        expect(result).to eq('1.5.2')
      end

      it "bumps minor version when bump_type is set to minor the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_gemspec(path: '#{@gemspec_path}', bump_type: 'minor')
        end").runner.execute(:test)

        expect(result).to eq('1.6.0')
      end

      it "bumps major version when bump_type is set to major the path is given" do
        result = Fastlane::FastFile.new.parse("lane :test do
          version_bump_gemspec(path: '#{@gemspec_path}', bump_type: 'major')
        end").runner.execute(:test)

        expect(result).to eq('2.0.0')
      end
    end
  end
end
