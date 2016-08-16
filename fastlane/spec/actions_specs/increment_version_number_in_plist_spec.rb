describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Version Number in Info.plist Integration" do
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:fixtures_path) { "./spec/fixtures/plist" }
      let (:plist_file) { "Info.plist" }

      # Action parameters
      let (:info_plist_file) { File.join(test_path, plist_file) }

      before do
        FileUtils.mkdir_p(test_path)
        source = File.join(fixtures_path, plist_file)
        destination = File.join(test_path, plist_file)

        FileUtils.cp_r(source, destination)
      end

      def current_version
        Fastlane::FastFile.new.parse("lane :test do
          get_info_plist_value(path: '#{info_plist_file}', key: 'CFBundleShortVersionString')
        end").runner.execute(:test)
      end

      it "should set explicitly provided version number to Info.plist" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number_in_plist(version_number: '1.9.4')
        end").runner.execute(:test)

        expect(current_version).to eq("1.9.4")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.9.4")
      end

      it "should bump patch version by default and set it to Info.plist" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number_in_plist
        end").runner.execute(:test)

        expect(current_version).to eq("0.9.15")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.15")
      end

      it "should bump patch version and set it to Info.plist" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number_in_plist(bump_type: 'patch')
        end").runner.execute(:test)

        expect(current_version).to eq("0.9.15")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.15")
      end

      it "should bump minor version and set it to Info.plist" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number_in_plist(bump_type: 'minor')
        end").runner.execute(:test)

        expect(current_version).to eq("0.10.0")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.10.0")
      end

      it "should bump major version and set it to Info.plist" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number_in_plist(bump_type: 'major')
        end").runner.execute(:test)

        expect(current_version).to eq("1.0.0")
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
      end

      after do
        FileUtils.rm_r(test_path)
      end
    end
  end
end
