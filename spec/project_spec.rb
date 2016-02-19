describe FastlaneCore do
  describe FastlaneCore::Project do
    it "raises an exception if path was not found" do
      expect do
        FastlaneCore::Project.new(project: "/tmp/notHere123")
      end.to raise_error "Could not find project at path '/tmp/notHere123'".red
    end

    describe "Valid Standard Project" do
      before do
        options = { project: "./spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "#path" do
        expect(@project.path).to eq(File.expand_path("./spec/fixtures/projects/Example.xcodeproj"))
      end

      it "#is_workspace" do
        expect(@project.is_workspace).to eq(false)
      end

      it "#schemes returns all available schemes" do
        expect(@project.schemes).to eq(["Example"])
      end

      it "#configurations returns all available configurations" do
        expect(@project.configurations).to eq(["Debug", "Release"])
      end

      it "#app_name" do
        expect(@project.app_name).to eq("ExampleProductName")
      end

      it "#mac?" do
        expect(@project.mac?).to eq(false)
      end

      it "#ios?" do
        expect(@project.ios?).to eq(true)
      end

      it "#tvos?" do
        expect(@project.tvos?).to eq(false)
      end
    end

    describe "Valid CocoaPods Project" do
      before do
        options = { workspace: "./spec/fixtures/projects/cocoapods/Example.xcworkspace", scheme: "Example" }
        @workspace = FastlaneCore::Project.new(options)
      end

      it "#schemes returns all schemes" do
        expect(@workspace.schemes).to eq(["Example"])
      end

      it "#schemes returns all configurations" do
        expect(@workspace.configurations).to eq([])
      end
    end

    describe "Mac Project" do
      before do
        options = { project: "./spec/fixtures/projects/Mac.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "#mac?" do
        expect(@project.mac?).to eq(true)
      end

      it "#ios?" do
        expect(@project.ios?).to eq(false)
      end

      it "#tvos?" do
        expect(@project.tvos?).to eq(false)
      end

      it "schemes" do
        expect(@project.schemes).to eq(["Mac"])
      end
    end

    describe "TVOS Project" do
      before do
        options = { project: "./spec/fixtures/projects/ExampleTVOS.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "#mac?" do
        expect(@project.mac?).to eq(false)
      end

      it "#ios?" do
        expect(@project.ios?).to eq(false)
      end

      it "#tvos?" do
        expect(@project.tvos?).to eq(true)
      end

      it "schemes" do
        expect(@project.schemes).to eq(["ExampleTVOS"])
      end
    end

    describe "Build Settings" do
      before do
        options = { project: "./spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options)
      end

      it "IPHONEOS_DEPLOYMENT_TARGET should be 9.0" do
        expect(@project.build_settings(key: "IPHONEOS_DEPLOYMENT_TARGET")).to eq("9.0")
      end
    end

    describe "Project.xcode_list_timeout" do
      before do
        ENV['FASTLANE_XCODE_LIST_TIMEOUT'] = nil
      end
      it "returns default value" do
        expect(FastlaneCore::Project.xcode_list_timeout).to eq(10)
      end
      it "returns specified value" do
        ENV['FASTLANE_XCODE_LIST_TIMEOUT'] = '5'
        expect(FastlaneCore::Project.xcode_list_timeout).to eq(5)
      end
      it "returns 0 if empty" do
        ENV['FASTLANE_XCODE_LIST_TIMEOUT'] = ''
        expect(FastlaneCore::Project.xcode_list_timeout).to eq(0)
      end
      it "returns 0 if garbage" do
        ENV['FASTLANE_XCODE_LIST_TIMEOUT'] = 'hiho'
        expect(FastlaneCore::Project.xcode_list_timeout).to eq(0)
      end
    end

    describe "Project.run_command" do
      def count_processes(text)
        `ps -aef | grep #{text} | grep -v grep | wc -l`.to_i
      end

      it "runs simple commands" do
        cmd = 'echo "HO"'
        expect(FastlaneCore::Project.run_command(cmd)).to eq("HO\n")
      end

      it "runs more complicated commands" do
        cmd = "ruby -e 'sleep 0.1; puts \"HI\"'"
        expect(FastlaneCore::Project.run_command(cmd)).to eq("HI\n")
      end

      it "should timeouts and kills" do
        text = "FOOBAR" # random text
        count = count_processes(text)
        cmd = "ruby -e 'sleep 3; puts \"#{text}\"'"
        # this doesn't work
        expect do
          FastlaneCore::Project.run_command(cmd, timeout: 1)
        end.to raise_error(Timeout::Error)

        # this shows the current implementation issue
        # Timeout doesn't kill the running process
        # i.e. see fastlane/fastlane_core#102
        expect(count_processes(text)).to eq(count + 1)
        sleep(3)
        expect(count_processes(text)).to eq(count)
        # you would be expected to be able to see the number of processes go back to count right away.
      end
    end
  end
end
