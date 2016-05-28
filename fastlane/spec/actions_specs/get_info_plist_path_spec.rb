describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Info.plist Path Integration" do
      before do
        # Create test folder
        FileUtils.mkdir_p(test_path)
        source = File.join(fixtures_path, proj_file)
        destination = File.join(test_path, proj_file)

        # Copy .xcodeproj fixture, as it will be modified during the test
        FileUtils.cp_r(source, destination)
      end

      describe "for targets with the same Info.plist paths for all build configurations" do
        # Variables
        let (:test_path) { "/tmp/fastlane/tests/fastlane" }
        let (:fixtures_path) { "./spec/fixtures/xcodeproj" }
        let (:proj_file) { "bundle.xcodeproj" }

        # Action parameters
        let (:xcodeproj) { File.join(test_path, proj_file) }
        let (:target) { "bundle" }

        it "should return Info.plist path with explicitly provided xcodeproj and target" do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_info_plist_path ({
              xcodeproj: '#{xcodeproj}',
              target: '#{target}'
            })
          end").runner.execute(:test)
          expect(result).to eq("bundle/Info.plist")
        end

        it "should detect xcodeproj in the root directory and return Info.plist path for explicitly provided target" do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_info_plist_path ({
              target: '#{target}'
            })
          end").runner.execute(:test)
          expect(result).to eq("bundle/Info.plist")
        end

        it "should detect target and return its Info.plist path for explicitly provided xcodeproj" do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_info_plist_path ({
              xcodeproj: '#{xcodeproj}'
            })
          end").runner.execute(:test)
          expect(result).to eq("bundle/Info.plist")
        end

        it "should detect xcodeproj in the root directory and target and return its Info.plist path" do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_info_plist_path
          end").runner.execute(:test)
          expect(result).to eq("bundle/Info.plist")
        end
      end

      describe "for targets with different Info.plist paths for all build configurations" do
        let (:test_path) { "/tmp/fastlane/tests/fastlane" }
        let (:fixtures_path) { "./spec/fixtures/xcodeproj" }
        let (:proj_file) { "get_info_plist_path.xcodeproj" }

        # Action parameters
        let (:xcodeproj) { File.join(test_path, proj_file) }
        let (:target) { "get_info_plist_path" }

        it "should return its Info.plist path" do
          result = Fastlane::FastFile.new.parse("lane :test do
            get_info_plist_path ({
              xcodeproj: '#{xcodeproj}',
              target: '#{target}',
              build_configuration_name: 'Debug'
            })
          end").runner.execute(:test)
          expect(result).to eq("get_info_plist_path/Info_Debug.plist")

          # it will also check an $(SRCROOT) substitution
          result = Fastlane::FastFile.new.parse("lane :test do
            get_info_plist_path ({
              xcodeproj: '#{xcodeproj}',
              target: '#{target}',
              build_configuration_name: 'Release'
            })
          end").runner.execute(:test)
          expect(result).to eq("/tmp/fastlane/tests/fastlane/get_info_plist_path/Info_Release.plist")
        end

        it "should raise error if :build_configuration_name is not provided" do
          error_msg = "Cannot resolve Info.plist build setting. Maybe you should specify :build_configuration_name?"

          expect do
            result = Fastlane::FastFile.new.parse("lane :test do
              get_info_plist_path ({
                xcodeproj: '#{xcodeproj}',
                target: '#{target}'
              })
            end").runner.execute(:test)
          end.to raise_error(error_msg)
        end
      end

      after do
        # Clean up files
        FileUtils.rm_r(test_path)
      end
    end
  end
end
