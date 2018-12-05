describe Fastlane do
  describe Fastlane::FastFile do
    describe "Hockey Integration" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "raises an error if no build file was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            hockey({
              api_token: 'xxx'
            })
          end").runner.execute(:test)
        end.to raise_error("You have to provide a build file (params 'apk' or 'ipa')")
      end

      describe "iOS" do
        it "raises an error if given ipa file was not found" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              hockey({
                api_token: 'xxx',
                ipa: './notHere.ipa'
              })
            end").runner.execute(:test)
          end.to raise_error("Couldn't find ipa file at path './notHere.ipa'")
        end
      end

      describe "Android" do
        it "raises an error if given apk file was not found" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              hockey({
                api_token: 'xxx',
                apk: './notHere.ipa'
              })
            end").runner.execute(:test)
          end.to raise_error("Couldn't find apk file at path './notHere.ipa'")
        end
      end

      it "raises an error if supplied dsym file was not found" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            hockey({
              api_token: 'xxx',
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              dsym: './notHere.dSYM.zip'
            })
          end").runner.execute(:test)
        end.to raise_error("Symbols on path '#{File.expand_path('./notHere.dSYM.zip')}' not found")
      end

      it "allows to send a dsym only" do
        values = Fastlane::FastFile.new.parse("lane :test do
            hockey({
              api_token: 'xxx',
              upload_dsym_only: true,
              dsym: './fastlane/spec/fixtures/dSYM/Themoji.dSYM.zip'
            })
          end").runner.execute(:test)

        expect(values[:notify]).to eq(1.to_s)
        expect(values[:status]).to eq(2.to_s)
        expect(values[:create_status]).to eq(2.to_s)
        expect(values[:notes]).to eq("No changelog given")
        expect(values[:release_type]).to eq(0.to_s)
        expect(values.key?(:tags)).to eq(false)
        expect(values.key?(:teams)).to eq(false)
        expect(values.key?(:owner_id)).to eq(false)
        expect(values.key?(:ipa)).to eq(false)
        expect(values[:mandatory]).to eq(0.to_s)
        expect(values[:notes_type]).to eq(1.to_s)
        expect(values[:upload_dsym_only]).to eq(true)
        expect(values[:strategy]).to eq("add")
      end

      it "raises an error if both ipa and apk provided" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            hockey({
              api_token: 'xxx',
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              apk: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            })
          end").runner.execute(:test)
        end.to raise_error("You can't use 'ipa' and 'apk' options in one run")
      end

      it "raises an error if no api token was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            hockey({
              apk: './fastlane/spec/fixtures/fastfiles/Fastfile1'
            })
          end").runner.execute(:test)
        end.to raise_error("No API token for Hockey given, pass using `api_token: 'token'`")
      end

      it "works with valid parameters" do
        Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            apk: './fastlane/spec/fixtures/fastfiles/Fastfile1'
          })
        end").runner.execute(:test)
      end

      it "has the correct default values" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1'
          })
        end").runner.execute(:test)

        expect(values[:notify]).to eq("1")
        expect(values[:status]).to eq("2")
        expect(values[:create_status]).to eq(2.to_s)
        expect(values[:notes]).to eq("No changelog given")
        expect(values[:release_type]).to eq("0")
        expect(values.key?(:tags)).to eq(false)
        expect(values.key?(:teams)).to eq(false)
        expect(values.key?(:owner_id)).to eq(false)
        expect(values[:mandatory]).to eq("0")
        expect(values[:notes_type]).to eq("1")
        expect(values[:upload_dsym_only]).to eq(false)
        expect(values[:strategy]).to eq("add")
      end

      it "can use a generated changelog as release notes" do
        values = Fastlane::FastFile.new.parse("lane :test do
          # changelog_from_git_commits sets this lane context variable
          Actions.lane_context[SharedValues::FL_CHANGELOG] = 'autogenerated changelog'
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
          })
        end").runner.execute(:test)

        expect(values[:notes]).to eq('autogenerated changelog')
      end

      it "has the correct default notes_type value" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
          })
        end").runner.execute(:test)

        expect(values[:notes_type]).to eq("1")
      end

      it "can change the notes_type" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            notes_type: '0'
          })
        end").runner.execute(:test)

        expect(values[:notes_type]).to eq("0")
      end

      it "can change the release_type" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            release_type: '1'
          })
        end").runner.execute(:test)

        expect(values[:release_type]).to eq(1.to_s)
      end

      it "can change teams" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            teams: '123,123'
          })
        end").runner.execute(:test)

        expect(values[:teams]).to eq('123,123')
      end

      it "can change mandatory" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            mandatory: '1'
          })
        end").runner.execute(:test)

        expect(values[:mandatory]).to eq("1")
      end

      it "can change tags" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            tags: '123,123'
          })
        end").runner.execute(:test)

        expect(values[:tags]).to eq('123,123')
      end

      it "can change owners" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            owner_id: '123'
          })
        end").runner.execute(:test)

        expect(values[:owner_id]).to eq('123')
      end

      it "has the correct default strategy value" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
          })
        end").runner.execute(:test)

        expect(values[:strategy]).to eq("add")
      end

      it "can change the strategy" do
        values = Fastlane::FastFile.new.parse("lane :test do
          hockey({
            api_token: 'xxx',
            ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
            strategy: 'replace'
          })
        end").runner.execute(:test)

        expect(values[:strategy]).to eq("replace")
      end

      it "raises an error if supplied strategy was invalid" do
        expect do
          values = Fastlane::FastFile.new.parse("lane :test do
            hockey({
              api_token: 'xxx',
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              strategy: 'wrongvalue'
            })
          end").runner.execute(:test)
        end.to raise_error("Invalid value 'wrongvalue' for key 'strategy'. Allowed values are 'add', 'replace'.")
      end
    end
  end
end
