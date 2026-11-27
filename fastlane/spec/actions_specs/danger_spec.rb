describe Fastlane do
  describe Fastlane::FastFile do
    describe "danger integration" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

      it "no bundle exec" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(use_bundle_exec: false)
        end").runner.execute(:test)

        expect(result).to eq("danger")
      end

      it "appends verbose" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(verbose: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --verbose")
      end

      it "sets github token" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(github_api_token: '1234')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
        expect(ENV['DANGER_GITHUB_API_TOKEN']).to eq("1234")
      end

      it "sets github enterprise host" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(github_enterprise_host: 'test.de')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
        expect(ENV['DANGER_GITHUB_HOST']).to eq("test.de")
      end

      it "sets github enterprise api base url" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(github_enterprise_api_base_url: 'https://test.de/api/v3')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
        expect(ENV['DANGER_GITHUB_API_BASE_URL']).to eq("https://test.de/api/v3")
      end

      it "appends danger_id" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(danger_id: 'unit-tests')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --danger_id=unit-tests")
      end

      it "appends dangerfile" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(dangerfile: 'test/OtherDangerfile')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --dangerfile=test/OtherDangerfile")
      end

      it "appends fail-on-errors flag when set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(fail_on_errors: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --fail-on-errors=true")
      end

      it "does not append fail-on-errors flag when unset" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(fail_on_errors: false)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

      it "appends new-comment flag when set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(new_comment: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --new-comment")
      end

      it "does not append new-comment flag when unset" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(new_comment: false)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

      it "appends remove-previous-comments flag when set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(remove_previous_comments: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --remove-previous-comments")
      end

      it "does not append remove-previous-comments flag when unset" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(remove_previous_comments: false)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

      it "appends base" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(base: 'master')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --base=master")
      end

      it "appends head" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(head: 'master')
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --head=master")
      end

      it "escapes base, head and pr" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(use_bundle_exec: false, base: 'release/2.0 (beta)', head: 'feature/price-$5-fix', pr: 'https://github.com/danger/danger/pull/518')
        end").runner.execute(:test)

        expect(result).to eq("danger --base=#{'release/2.0 (beta)'.shellescape} --head=#{'feature/price-$5-fix'.shellescape} pr #{'https://github.com/danger/danger/pull/518'.shellescape}")
      end

      it "escapes danger_id and dangerfile" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(use_bundle_exec: false, danger_id: 'unit tests', dangerfile: 'ci/My Dangerfile')
        end").runner.execute(:test)

        expect(result).to eq("danger --danger_id=#{'unit tests'.shellescape} --dangerfile=#{'ci/My Dangerfile'.shellescape}")
      end

      unless FastlaneCore::Helper.windows?
        it "passes base, head, pr, danger_id and dangerfile to the shell unchanged" do
          result = Fastlane::FastFile.new.parse("lane :test do
            danger(use_bundle_exec: false, danger_id: 'unit tests', dangerfile: 'ci/My Dangerfile', base: 'release/2.0 (beta)', head: 'feature/price-$5-fix', pr: '518')
          end").runner.execute(:test)

          arguments = result.delete_prefix("danger ")
          expected = [
            "--danger_id=unit tests",
            "--dangerfile=ci/My Dangerfile",
            "--base=release/2.0 (beta)",
            "--head=feature/price-$5-fix",
            "pr",
            "518"
          ]
          expect(`printf '%s\\n' #{arguments}`.lines.map(&:chomp)).to eq(expected)
        end
      end

      it "appends fail-if-no-pr flag when set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(fail_if_no_pr: true)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger --fail-if-no-pr=true")
      end

      it "does not append fail-if-no-pr flag when unset" do
        result = Fastlane::FastFile.new.parse("lane :test do
          danger(fail_if_no_pr: false)
        end").runner.execute(:test)

        expect(result).to eq("bundle exec danger")
      end

    end
  end
end
