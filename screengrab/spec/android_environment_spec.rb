describe Screengrab do
  describe Screengrab::AndroidEnvironment do
    describe "with an empty ANDROID_HOME and an empty PATH" do
      it "finds no useful values" do
        with_env_values('PATH' => 'screengrab/spec/fixtures/empty_home_empty_path/path') do
          android_env = Screengrab::AndroidEnvironment.new('screengrab/spec/fixtures/empty_home_empty_path/android_home', nil)

          expect(android_env.android_home).to eq('screengrab/spec/fixtures/empty_home_empty_path/android_home')
          expect(android_env.build_tools_version).to be_nil
          expect(android_env.build_tools_path).to be_nil
          expect(android_env.platform_tools_path).to be_nil
          expect(android_env.adb_path).to be_nil
          expect(android_env.aapt_path).to be_nil
        end
      end
    end

    describe "with an empty ANDROID_HOME and a complete PATH" do
      it "finds commands on the PATH" do
        with_env_values('PATH' => 'screengrab/spec/fixtures/empty_home_complete_path/path') do
          android_env = Screengrab::AndroidEnvironment.new('screengrab/spec/fixtures/empty_home_complete_path/android_home', nil)

          expect(android_env.android_home).to eq('screengrab/spec/fixtures/empty_home_complete_path/android_home')
          expect(android_env.build_tools_version).to be_nil
          expect(android_env.build_tools_path).to be_nil
          expect(android_env.platform_tools_path).to be_nil
          expect(android_env.adb_path).to eq('screengrab/spec/fixtures/empty_home_complete_path/path/adb')
          expect(android_env.aapt_path).to eq('screengrab/spec/fixtures/empty_home_complete_path/path/aapt')
        end
      end
    end

    describe "with a complete ANDROID_HOME and a complete PATH and no build tools version specified" do
      it "finds adb in platform-tools and aapt in the highest version build tools dir" do
        with_env_values('PATH' => 'screengrab/spec/fixtures/complete_home_complete_path/path') do
          android_env = Screengrab::AndroidEnvironment.new('screengrab/spec/fixtures/complete_home_complete_path/android_home', nil)

          expect(android_env.android_home).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home')
          expect(android_env.build_tools_version).to be_nil
          expect(android_env.build_tools_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/build-tools/23.0.2')
          expect(android_env.platform_tools_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/platform-tools')
          expect(android_env.adb_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/platform-tools/adb')
          expect(android_env.aapt_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/build-tools/23.0.2/aapt')
        end
      end
    end

    describe "with a complete ANDROID_HOME and a complete PATH and a build tools version specified" do
      it "finds adb in platform-tools and aapt in the specified version build tools dir" do
        with_env_values('PATH' => 'screengrab/spec/fixtures/complete_home_complete_path/path') do
          android_env = Screengrab::AndroidEnvironment.new('screengrab/spec/fixtures/complete_home_complete_path/android_home', '23.0.1')

          expect(android_env.android_home).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home')
          expect(android_env.build_tools_version).to eq('23.0.1')
          expect(android_env.build_tools_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/build-tools/23.0.1')
          expect(android_env.platform_tools_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/platform-tools')
          expect(android_env.adb_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/platform-tools/adb')
          expect(android_env.aapt_path).to eq('screengrab/spec/fixtures/complete_home_complete_path/android_home/build-tools/23.0.1/aapt')
        end
      end
    end
  end
end
