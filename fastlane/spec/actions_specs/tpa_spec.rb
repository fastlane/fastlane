describe Fastlane do
  describe Fastlane::FastFile do
    describe "The Perfect App integration" do
      it "verbosity is set correctly" do
        expect(Fastlane::Actions::TpaAction.verbose(verbose: true)).to eq "--verbose"
        expect(Fastlane::Actions::TpaAction.verbose(verbose: false)).to eq "--silent"
      end

      it "upload url is returned correctly" do
        url = 'https://someproject.tpa.io/some-very-special-uuid/upload'
        expect(Fastlane::Actions::TpaAction.upload_url(upload_url: url)).to eq url

        url = 'My Not So Normal URL ?__.../\.'
        expect(Fastlane::Actions::TpaAction.upload_url(upload_url: url)).to eq url
      end

      it "raises an error if result is not 'OK'" do
        result = "Not enough fish"

        expect do
          Fastlane::Actions::TpaAction.fail_on_error(result)
        end.to raise_exception("Something went wrong while uploading your app to TPA: #{result}")
      end

      it "does not raise an error if result is 'OK'" do
        result = "OK"

        expect do
          Fastlane::Actions::TpaAction.fail_on_error(result)
        end.to_not raise_exception
      end

      it "mandatory options are used correctly" do
        ENV['DSYM_OUTPUT_PATH'] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil

        file_path = '/tmp/file.ipa'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '/tmp/file.ipa',
              upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload')
        end").runner.execute(:test)

        expect(result).to include("-F app=@/tmp/file.ipa")
        expect(result).to include("-F publish=false")
        expect(result).to include("-F force=false")
        expect(result).to include("--silent")
        expect(result).to include("https://my.tpa.io/xxx-yyy-zz/upload")
      end

      it "should include release notes if provided" do
        file_path = '/tmp/file.ipa'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '/tmp/file.ipa',
              upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload',
              notes: 'Now with iMessages extension a.k.a stickers for everyone!')
        end").runner.execute(:test)

        expect(result).to include("-F notes=Now with iMessages extension a.k.a stickers for everyone!")
      end

      it "should publish" do
        file_path = '/tmp/file.ipa'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '/tmp/file.ipa',
              upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload',
              publish: true)
        end").runner.execute(:test)

        expect(result).to include("-F publish=true")
      end

      it "should force upload, overriding existing build" do
        file_path = '/tmp/file.ipa'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '/tmp/file.ipa',
              upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload',
              force: true)
        end").runner.execute(:test)

        expect(result).to include("-F force=true")
      end

      it "should include mapping file if added" do
        file_path = '/tmp/file.ipa'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(ipa: '/tmp/file.ipa',
              upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload',
              mapping: '/tmp/file.dSYM.zip')
        end").runner.execute(:test)

        expect(result).to include("-F mapping=@/tmp/file.dSYM.zip")
      end

      it "supports Android as well" do
        file_path = '/tmp/file.apk'
        FileUtils.touch file_path
        result = Fastlane::FastFile.new.parse("lane :test do
          tpa(apk: '/tmp/file.apk',
              upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload')
        end").runner.execute(:test)

        expect(result).to include("-F app=@/tmp/file.apk")
      end

      it "does not allow both ipa and apk at the same time" do
        file_path_apk = '/tmp/file.apk'
        FileUtils.touch file_path_apk

        file_path_ipa = '/tmp/file.ipa'
        FileUtils.touch file_path_ipa

        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            tpa(apk: '/tmp/file.apk',
                ipa: '/tmp/file.ipa',
                upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload')
          end").runner.execute(:test)
        end.to raise_exception("You can't use 'apk' and 'ipa' options in one run")

        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            tpa(ipa: '/tmp/file.ipa',
                apk: '/tmp/file.apk',
                upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload')
          end").runner.execute(:test)
        end.to raise_exception("You can't use 'ipa' and 'apk' options in one run")
      end

      it "raises an error if no app is provided" do
        expect do
          ENV['IPA_OUTPUT_PATH'] = nil
          ENV['GRADLE_APK_OUTPUT_PATH'] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = nil
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH] = nil

          result = Fastlane::FastFile.new.parse("lane :test do
            tpa(upload_url: 'https://my.tpa.io/xxx-yyy-zz/upload')
          end").runner.execute(:test)
        end.to raise_exception("You have to provide a build file")
      end
    end
  end
end
