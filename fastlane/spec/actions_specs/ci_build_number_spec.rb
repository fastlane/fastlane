describe Fastlane do
  describe Fastlane::FastFile do
    describe "ci_build_number" do
      it "Returns build number defined in BUILD_NUMBER environment variable if running on Jenkins" do
        ENV['JENKINS_HOME'] = "Users/user/hudson/workspace"
        ENV['BUILD_NUMBER'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
          ci_build_number
        end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('JENKINS_HOME')
        ENV.delete('BUILD_NUMBER')
      end

      it "Returns build number defined in TRAVIS_BUILD_NUMBER environment variable if running on Travis CI" do
        ENV['TRAVIS'] = '1'
        ENV['TRAVIS_BUILD_NUMBER'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('TRAVIS')
        ENV.delete('TRAVIS_BUILD_NUMBER')
      end

      it "Returns build number defined in CIRCLE_BUILD_NUM environment variable if running on Circle CI" do
        ENV['CIRCLECI'] = '1'
        ENV['CIRCLE_BUILD_NUM'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('CIRCLECI')
        ENV.delete('CIRCLE_BUILD_NUM')
      end

      it "Returns build number defined in BUILD_NUMBER environment variable if running on TeamCity" do
        ENV['TEAMCITY_VERSION'] = '1.0'
        ENV['BUILD_NUMBER'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('TEAMCITY_VERSION')
        ENV.delete('BUILD_NUMBER')
      end

      it "Returns build number defined in GO_PIPELINE_COUNTER environment variable if running on GoCD" do
        ENV['GO_PIPELINE_NAME'] = 'Job'
        ENV['GO_PIPELINE_COUNTER'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('GO_PIPELINE_NAME')
        ENV.delete('GO_PIPELINE_COUNTER')
      end

      it "Returns build number defined in bamboo_buildNumber environment variable if running on Bamboo" do
        ENV['bamboo_buildKey'] = 'JOB'
        ENV['bamboo_buildNumber'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('bamboo_buildKey')
        ENV.delete('bamboo_buildNumber')
      end

      it "Returns build number defined in CI_JOB_ID environment variable if running on GitLab CI" do
        ENV['GITLAB_CI'] = '1'
        ENV['CI_JOB_ID'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('GITLAB_CI')
        ENV.delete('CI_JOB_ID')
      end

      it "Returns build number defined in XCS_INTEGRATION_NUMBER environment variable if running on Xcode Server" do
        ENV['XCS'] = '1'
        ENV['XCS_INTEGRATION_NUMBER'] = '42'

        result = Fastlane::FastFile.new.parse("lane :test do
            ci_build_number
          end").runner.execute(:test)

        expect(result).to eq('42')

        ENV.delete('XCS')
        ENV.delete('XCS_INTEGRATION_NUMBER')
      end

      it "Uses 1 as a default build number if cannot detect" do
        result = Fastlane::FastFile.new.parse("lane :test do
          ci_build_number
        end").runner.execute(:test)

        expect(result).to eq('1')
      end
    end
  end
end
