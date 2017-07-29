describe Fastlane do
  describe Fastlane::FastFile do
    describe "Add Git Tag Integration" do
      require 'shellwords'

      build_number = 1337

      before :each do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER] = build_number
      end

      it "generates a tag based on existing context" do
        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag
        end").runner.execute(:test)

        expect(result).to eq("git tag -am builds/test/1337\\ \\(fastlane\\) \'builds/test/1337\'")
      end

      it "allows you to specify grouping and build number" do
        specified_build_number = 42
        grouping = 'grouping'

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            grouping: '#{grouping}',
            build_number: #{specified_build_number},
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am #{grouping}/test/#{specified_build_number}\\ \\(fastlane\\) \'#{grouping}/test/#{specified_build_number}\'")
      end

      it "allows you to specify a prefix" do
        prefix = '16309-'

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            prefix: '#{prefix}',
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am builds/test/#{prefix}#{build_number}\\ \\(fastlane\\) \'builds/test/#{prefix}#{build_number}\'")
      end

      it "allows you to specify your own tag" do
        tag = '2.0.0'

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am #{tag}\\ \\(fastlane\\) \'#{tag}\'")
      end

      it "specified tag overrides generate tag" do
        tag = '2.0.0'

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
            grouping: 'grouping',
            build_number: 'build_number',
            prefix: 'prefix',
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am #{tag}\\ \\(fastlane\\) \'#{tag}\'")
      end

      it "allows you to specify your own message" do
        tag = '2.0.0'
        message = "message"

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
            message: '#{message}'
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am message \'#{tag}\'")
      end

      it "properly shell escapes its message" do
        tag = '2.0.0'
        message = "message with 'quotes' (and parens)"
        escaped_message = "message\\ with\\ \\'quotes\\'\\ \\(and\\ parens\\)"

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
            message: \"#{message}\"
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am #{escaped_message} \'#{tag}\'")
      end

      it "allows you to force the tag creation" do
        tag = '2.0.0'
        message = "message"

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
            message: '#{message}',
            force: true
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am message --force \'#{tag}\'")
      end

      it "allows you to specify the commit where to add the tag" do
        tag = '2.0.0'
        commit = 'beta_tag'
        message = "message"

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
            message: '#{message}',
            commit: '#{commit}'
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am #{message} \'#{tag}\' #{commit}")
      end

      it "allows you to sign the tag using the default e-mail address's key." do
        tag = '2.0.0'
        message = "message"

        result = Fastlane::FastFile.new.parse("lane :test do
          add_git_tag ({
            tag: '#{tag}',
            message: '#{message}',
            sign: true
          })
        end").runner.execute(:test)

        expect(result).to eq("git tag -am #{message} -s \'#{tag}\'")
      end
    end
  end
end
