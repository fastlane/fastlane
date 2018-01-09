describe Fastlane do
  describe Fastlane::FastFile do
    describe "Splunk MINT integration" do
      it "verbosity is set correctly" do
        expect(Fastlane::Actions::SplunkmintAction.verbose(verbose: true)).to eq("--verbose")
        expect(Fastlane::Actions::SplunkmintAction.verbose(verbose: false)).to eq("")
      end

      it "upload url is set correctly" do
        expect(Fastlane::Actions::SplunkmintAction.upload_url).to eq("https://ios.splkmobile.com/api/v1/dsyms/upload")
      end

      it "raises an error if no dsym source has been found" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')

        expect do
          ENV['DSYM_OUTPUT_PATH'] = nil
          ENV['DSYM_ZIP_PATH'] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

          Fastlane::Actions::SplunkmintAction.dsym_path(params: nil)
        end.to raise_exception("Couldn't find any dSYM file")
      end

      it "raises an error if no dsym source has been found in SharedValues::DSYM_OUTPUT_PATH" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = file_path
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        expect do
          Fastlane::Actions::SplunkmintAction.dsym_path(params: nil)
        end.to raise_exception("Couldn't find file at path '#{file_path}'")
      end

      it "raises an error if no dsym source has been found in SharedValues::DSYM_ZIP_PATH" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = file_path
        ENV['DSYM_OUTPUT_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil

        expect do
          Fastlane::Actions::SplunkmintAction.dsym_path(params: nil)
        end.to raise_exception("Couldn't find file at path '#{file_path}'")
      end

      it "raises an error if no dsym source has been found in ENV['DSYM_OUTPUT_PATH']" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')
        ENV['DSYM_OUTPUT_PATH'] = file_path
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        expect do
          Fastlane::Actions::SplunkmintAction.dsym_path(params: nil)
        end.to raise_exception("Couldn't find file at path '#{file_path}'")
      end

      it "raises an error if no dsym source has been found in ENV['DSYM_ZIP_PATH']" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')
        ENV['DSYM_ZIP_PATH'] = file_path
        ENV['DSYM_OUTPUT_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        expect do
          Fastlane::Actions::SplunkmintAction.dsym_path(params: nil)
        end.to raise_exception("Couldn't find file at path '#{file_path}'")
      end

      it "proxy options are set correctly" do
        expect(Fastlane::Actions::SplunkmintAction.proxy_options(proxy_address: "",
          proxy_port: nil, proxy_username: nil, proxy_password: nil)).to eq([])
        expect(Fastlane::Actions::SplunkmintAction.proxy_options(proxy_address: nil,
          proxy_port: "", proxy_username: nil, proxy_password: nil)).to eq([])
        expect(Fastlane::Actions::SplunkmintAction.proxy_options(proxy_address: nil,
          proxy_port: nil, proxy_username: "", proxy_password: "")).to eq([])
        expect(Fastlane::Actions::SplunkmintAction.proxy_options(proxy_address: "http://1",
          proxy_port: "2", proxy_username: "3", proxy_password: "4")).to eq(["-x http://1:2", "--proxy-user 3:4"])
      end

      it "raises an error if file does not exist" do
        file_path = File.expand_path('/tmp/wwxfile.dsym.zip')

        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            splunkmint(dsym: '/tmp/wwxfile.dsym.zip',
                        api_key: '33823d3a',
                        api_token: 'e05ba40754c4869fb7e0b61')
          end").runner.execute(:test)
        end.to raise_exception("Couldn't find file at path '#{file_path}'")
      end

      it "raises an error if file could not be read from any source" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            splunkmint(api_key: '33823d3a',
                        api_token: 'e05ba40754c4869fb7e0b61')
          end").runner.execute(:test)
        end.to raise_exception("Couldn't find any dSYM file")
      end

      it "mandatory options are used correctly" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        file_path = '/tmp/file.dSYM.zip'
        FileUtils.touch(file_path)
        result = Fastlane::FastFile.new.parse("lane :test do
          splunkmint(dsym: '/tmp/file.dSYM.zip',
                      api_key: '33823d3a',
                      api_token: 'e05ba40754c4869fb7e0b61',
                      verbose: true,
                      proxy_address: 'http://server',
                      proxy_port: '30',
                      proxy_username: 'admin',
                      proxy_password: 'admin')
        end").runner.execute(:test)

        expect(result).to include("-F file=@/tmp/file.dSYM.zip")
        expect(result).to include('--verbose')
        expect(result).to include("--header 'X-Splunk-Mint-Auth-Token: e05ba40754c4869fb7e0b61'")
        expect(result).to include("--header 'X-Splunk-Mint-apikey: 33823d3a'")
        expect(result).to include('-x http://server:30')
        expect(result).to include('--proxy-user admin:admin')
      end

      it "optional options are used correctly" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        file_path = '/tmp/file.dSYM.zip'
        FileUtils.touch(file_path)
        result = Fastlane::FastFile.new.parse("lane :test do
          splunkmint(dsym: '/tmp/file.dSYM.zip',
                      api_key: '33823d3a',
                      api_token: 'e05ba40754c4869fb7e0b61',
                      verbose: true)
        end").runner.execute(:test)

        expect(result).to include("-F file=@/tmp/file.dSYM.zip")
        expect(result).to include('--verbose')
        expect(result).to include("--header 'X-Splunk-Mint-Auth-Token: e05ba40754c4869fb7e0b61'")
        expect(result).to include("--header 'X-Splunk-Mint-apikey: 33823d3a'")
        expect(result).not_to(include('-x'))
        expect(result).not_to(include('--proxy-user'))
      end

      it "show progres bar option is used" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        ENV['DSYM_ZIP_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_ZIP_PATH] = nil

        file_path = '/tmp/file.dSYM.zip'
        FileUtils.touch(file_path)
        result = Fastlane::FastFile.new.parse("lane :test do
          splunkmint(dsym: '/tmp/file.dSYM.zip',
                      api_key: '33823d3a',
                      api_token: 'e05ba40754c4869fb7e0b61',
                      verbose: true,
                      upload_progress: true)
        end").runner.execute(:test)

        expect(result).to include("-F file=@/tmp/file.dSYM.zip")
        expect(result).to include('--verbose')
        expect(result).to include("--header 'X-Splunk-Mint-Auth-Token: e05ba40754c4869fb7e0b61'")
        expect(result).to include("--header 'X-Splunk-Mint-apikey: 33823d3a'")
        expect(result).to include('--progress-bar -o /dev/null --no-buffer')
        expect(result).not_to(include('-x'))
        expect(result).not_to(include('--proxy-user'))
      end
    end
  end
end
