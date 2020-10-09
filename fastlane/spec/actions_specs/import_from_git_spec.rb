describe Fastlane do
  describe Fastlane::FastFile do
    describe "import_from_git" do
      it "raises an exception when no path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            import_from_git
          end").runner.execute(:test)
        end.to raise_error("Please pass a path to the `import_from_git` action")
      end

      describe "with caching" do
        let(:caching_message) { "Eligible for caching" }

        source_directory_path = nil

        cache_directory_path = nil
        missing_cache_directory_path = nil

        before :all do
          # This is needed for tag searching that `import_from_git` needs.
          ENV["FORCE_SH_DURING_TESTS"] = "1"

          source_directory_path = Dir.mktmpdir("fl_spec_import_from_git_source")

          Dir.chdir(source_directory_path) do
            `git init`

            `mkdir fastlane`
            `echo "lane :works do\n\tUI.important('Works since v1')\nend" > fastlane/Fastfile`
            `git add .`
            `git commit --message "Version 1"`
            `git tag "1"`

            `echo "lane :works_extra do\n\tUI.important('Works from extra since v2')\nend" > fastlane/FastfileExtra`
            `git add .`
            `git commit --message "Version 2"`
            `git tag "2"`

            `echo "lane :works_root do\n\tUI.important('Works from root since v3')\nend" > FastfileRoot`
            `git add .`
            `git commit --message "Version 3"`
            `git tag "3"`

            `mkdir fastlane/actions`
            `echo "module Fastlane\n\tmodule Actions\n\t\tclass WorkActionAction < Action\n\t\t\tdef self.run(params)\n\t\t\t\tUI.important('Works from action since v4')\n\t\t\tend\n\n\t\t\tdef self.is_supported?(platform)\n\t\t\t\ttrue\n\t\t\tend\n\t\tend\n\tend\nend" > fastlane/actions/work_action.rb`
            `git add .`
            `git commit --message "Version 4"`
            `git tag "4"`

            `git checkout tags/2 -b version-2.1 > /dev/null 2>&1`
            `echo "lane :works do\n\tUI.important('Works since v2.1')\nend" > fastlane/Fastfile`
            `git add .`
            `git commit --message "Version 2.1"`
          end

          cache_directory_path = Dir.mktmpdir("fl_spec_import_from_git_cache")

          missing_cache_directory_path = Dir.mktmpdir("fl_spec_import_from_git_missing_cache")
          FileUtils.remove_dir(missing_cache_directory_path)
        end

        it "works with version" do
          allow(UI).to receive(:message)
          expect(UI).to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works since v1')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', version: '1', cache_path: '#{cache_directory_path}')

            works
          end").runner.execute(:test)
        end

        it "works with dependencies and version" do
          allow(UI).to receive(:message)
          expect(UI).to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works from extra since v2')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', dependencies: ['fastlane/FastfileExtra'], version: '2', cache_path: '#{cache_directory_path}')

            works_extra
          end").runner.execute(:test)
        end

        it "works with path and version" do
          allow(UI).to receive(:message)
          expect(UI).to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works from root since v3')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', path: 'FastfileRoot', version: '3', cache_path: '#{cache_directory_path}')

            works_root
          end").runner.execute(:test)
        end

        it "works with actions" do
          allow(UI).to receive(:message)
          expect(UI).to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works from action since v4')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', version: '4', cache_path: '#{cache_directory_path}')

            work_action
          end").runner.execute(:test)
        end

        # This is based on the fact that rspec runs the tests in the order
        # they're defined in this file, so it tests the fact that importing
        # works with an older version after a newer one was previously checked
        # out.
        it "works with older version" do
          allow(UI).to receive(:message)
          expect(UI).to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works since v1')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', version: '1', cache_path: '#{cache_directory_path}')

            works
          end").runner.execute(:test)
        end

        # Meaning, a `git pull` is performed when the specified tag is not found
        # in the local clone.
        it "works with new tags" do
          Dir.chdir(source_directory_path) do
            `git checkout "master" > /dev/null 2>&1`
            `echo "lane :works do\n\tUI.important('Works until v5')\nend" > fastlane/Fastfile`
            `git add .`
            `git commit --message "Version 5"`
            `git tag "5"`
          end

          allow(UI).to receive(:message)
          expect(UI).to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works until v5')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', branch: 'master', version: '5', cache_path: '#{cache_directory_path}')

            works
          end").runner.execute(:test)
        end

        # Actually, `git checkout` makes sure of this, but I think it's ok to
        # keep this test, in case we change the implementation.
        it "works with inexistent paths" do
          expect(UI).to receive(:important).with('Works since v1')

          expect do
            Fastlane::FastFile.new.parse("lane :test do
              import_from_git(url: '#{source_directory_path}', version: '3', cache_path: '#{missing_cache_directory_path}')

              works
            end").runner.execute(:test)
          end.not_to(raise_error)
        end

        it "ignores it when branch is specified" do
          expect(UI).not_to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works since v2.1')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', branch: 'version-2.1', cache_path: '#{cache_directory_path}')

            works
          end").runner.execute(:test)
        end

        # Because we don't know if the specified value represents a branch or a
        # tag. And knowing that it doesn't make sense to cache a branch, that
        # points to a different commit when one is added, as opposed to a tag,
        # we decided to enable caching only when used with the `version` param.
        it "ignores it when tag is specified via branch param" do
          expect(UI).not_to receive(:message).with(caching_message)
          expect(UI).to receive(:important).with('Works since v1')

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', branch: '3', cache_path: '#{cache_directory_path}')

            works
          end").runner.execute(:test)
        end

        it "ignores it when version is not specified" do
          expect(UI).not_to receive(:message).with(caching_message)

          Fastlane::FastFile.new.parse("lane :test do
            import_from_git(url: '#{source_directory_path}', cache_path: '#{cache_directory_path}')
          end").runner.execute(:test)
        end

        after :all do
          ENV.delete("FORCE_SH_DURING_TESTS")

          FileUtils.remove_dir(source_directory_path)
          FileUtils.remove_dir(missing_cache_directory_path)
          FileUtils.remove_dir(cache_directory_path)
        end
      end
    end
  end
end
