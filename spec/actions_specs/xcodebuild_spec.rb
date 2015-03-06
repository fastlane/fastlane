describe Fastlane do
  describe Fastlane::FastFile do
    describe "Xcodebuild Integration" do
      before :each do
        Fastlane::Actions.lane_context.delete :IPA_OUTPUT_PATH
        Fastlane::Actions.lane_context.delete :XCODEBUILD_ARCHIVE
      end

      it "works with all parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xcodebuild(
            analyze: true,
            archive: true,
            build: true,
            clean: true,
            install: true,
            installsrc: true,
            test: true,
            arch: 'architecture',
            alltargets: true,
            archive_path: './build/MyApp.xcarchive',
            configuration: 'Debug',
            derived_data_path: '/derived/data/path',
            destination: 'name=iPhone 5s,OS=8.1',
            export_archive: true,
            export_format: 'ipa',
            export_installer_identity: true,
            export_path: './build/MyApp',
            export_profile: 'MyApp Distribution',
            export_signing_identity: 'Distribution: MyCompany, LLC',
            export_with_original_signing_identity: true,
            keychain: '/path/to/My.keychain',
            project: 'MyApp.xcodeproj',
            result_bundle_path: '/result/bundle/path',
            scheme: 'MyApp',
            sdk: 'iphonesimulator',
            skip_unavailable_actions: true,
            target: 'MyAppTarget',
            workspace: 'MyApp.xcworkspace',
            xcconfig: 'my.xcconfig'
          )
        end").runner.execute(:test)

        expect(result).to eq(
          "xcodebuild " \
          + "analyze " \
          + "archive " \
          + "build " \
          + "clean " \
          + "install " \
          + "installsrc " \
          + "test " \
          + "-arch \"architecture\" " \
          + "-alltargets " \
          + "-archivePath \"./build/MyApp.xcarchive\" " \
          + "-configuration \"Debug\" " \
          + "-destination \"name=iPhone 5s,OS=8.1\" " \
          + "-exportArchive " \
          + "-exportFormat \"ipa\" " \
          + "-exportInstallerIdentity " \
          + "-exportPath \"./build/MyApp\" " \
          + "-exportProvisioningProfile \"MyApp Distribution\" " \
          + "-exportSigningIdentity \"Distribution: MyCompany, LLC\" " \
          + "-exportWithOriginalSigningIdentity " \
          + "OTHER_CODE_SIGN_FLAGS=\"--keychain /path/to/My.keychain\" " \
          + "-project \"MyApp.xcodeproj\" " \
          + "-resultBundlePath \"/result/bundle/path\" " \
          + "-scheme \"MyApp\" " \
          + "-sdk \"iphonesimulator\" " \
          + "-skipUnavailableActions " \
          + "-target \"MyAppTarget\" " \
          + "-workspace \"MyApp.xcworkspace\" " \
          + "-xcconfig \"my.xcconfig\" " \
          + "| xcpretty --simple --color"
      )
    end

    it "when archiving, should cache the archive path for a later export step" do
        Fastlane::FastFile.new.parse("lane :test do
          xcodebuild(
            archive: true,
            archive_path: './build/MyApp.xcarchive',
            scheme: 'MyApp',
            workspace: 'MyApp.xcworkspace'
          )
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[:XCODEBUILD_ARCHIVE]).to eq("./build/MyApp.xcarchive")
    end

    it "when exporting, should use the cached archive path from a previous archive step" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xcodebuild(
            archive: true,
            archive_path: './build-dir/MyApp.xcarchive',
            scheme: 'MyApp',
            workspace: 'MyApp.xcworkspace'
          )

          xcodebuild(
            export_archive: true,
            export_path: './build-dir/MyApp'
          )
        end").runner.execute(:test)

        expect(result).to eq(
          "xcodebuild " \
          + "-exportArchive " \
          + "-exportPath \"./build-dir/MyApp\" " \
          + "-archivePath \"./build-dir/MyApp.xcarchive\" " \
          + "-exportFormat \"ipa\" " \
          + "| xcpretty --simple --color"
        )
    end

    it "when exporting, should cache the ipa path for a later deploy step" do
        Fastlane::FastFile.new.parse("lane :test do
          xcodebuild(
            archive_path: './build-dir/MyApp.xcarchive',
            export_archive: true,
            export_path: './build-dir/MyApp'
          )
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[:IPA_OUTPUT_PATH]).to eq("./build-dir/MyApp.ipa")
    end

    context "when using environment variables"
      before :each do
        ENV["BUILD_PATH"] = "./build-dir/"
        ENV["SCHEME"] = "MyApp"
        ENV["WORKSPACE"] = "MyApp.xcworkspace"
      end

      after :each do
        ENV.delete("BUILD_PATH")
        ENV.delete("SCHEME")
        ENV.delete("WORKSPACE")
      end

      it "can archive" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xcodebuild(
            archive: true
          )
        end").runner.execute(:test)

        expect(result).to eq(
          "xcodebuild " \
          + "archive " \
          + "-scheme \"MyApp\" " \
          + "-workspace \"MyApp.xcworkspace\" " \
          + "-archivePath \"./build-dir/MyApp.xcarchive\" " \
          + "| xcpretty --simple --color"
        )
      end

      it "can export" do
        result = Fastlane::FastFile.new.parse("lane :test do
          xcodebuild(
            archive_path: './build-dir/MyApp.xcarchive',
            export_archive: true
          )
        end").runner.execute(:test)

        expect(result).to eq(
          "xcodebuild " \
          + "-archivePath \"./build-dir/MyApp.xcarchive\" " \
          + "-exportArchive " \
          + "-exportFormat \"ipa\" " \
          + "-exportPath \"./build-dir/MyApp\" " \
          + "| xcpretty --simple --color"
        )
      end
    end
  end
end
