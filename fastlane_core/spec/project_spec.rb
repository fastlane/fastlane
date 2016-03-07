describe FastlaneCore do
  describe FastlaneCore::Project do
    describe 'project and workspace detection' do
      def within_a_temp_dir
        Dir.mktmpdir do |dir|
          FileUtils.cd(dir) do
            yield dir if block_given?
          end
        end
      end

      let(:options) do
        [
          FastlaneCore::ConfigItem.new(key: :project, description: "Project", optional: true),
          FastlaneCore::ConfigItem.new(key: :workspace, description: "Workspace", optional: true)
        ]
      end

      it 'raises if both project and workspace are specified' do
        expect do
          config = FastlaneCore::Configuration.new(options, { project: 'yup', workspace: 'yeah' })
          FastlaneCore::Project.detect_projects(config)
        end.to raise_error
      end

      it 'keeps the specified project' do
        config = FastlaneCore::Configuration.new(options, { project: 'yup' })
        FastlaneCore::Project.detect_projects(config)

        expect(config[:project]).to eq('yup')
        expect(config[:workspace]).to be_nil
      end

      it 'keeps the specified workspace' do
        config = FastlaneCore::Configuration.new(options, { workspace: 'yeah' })
        FastlaneCore::Project.detect_projects(config)

        expect(config[:project]).to be_nil
        expect(config[:workspace]).to eq('yeah')
      end

      it 'picks the only workspace file present' do
        within_a_temp_dir do |dir|
          workspace = './Something.xcworkspace'
          FileUtils.mkdir_p(workspace)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspace)
        end
      end

      it 'picks the only project file present' do
        within_a_temp_dir do |dir|
          project = './Something.xcodeproj'
          FileUtils.mkdir_p(project)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:project]).to eq(project)
        end
      end

      it 'prompts to select among multiple workspace files' do
        within_a_temp_dir do |dir|
          workspaces = ['./Something.xcworkspace', './SomethingElse.xcworkspace']
          FileUtils.mkdir_p(workspaces)

          expect(FastlaneCore::Project).to receive(:choose).and_return(workspaces.last)
          expect(FastlaneCore::Project).not_to receive(:select_project)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspaces.last)
        end
      end

      it 'prompts to select among multiple project files' do
        within_a_temp_dir do |dir|
          projects = ['./Something.xcodeproj', './SomethingElse.xcodeproj']
          FileUtils.mkdir_p(projects)

          expect(FastlaneCore::Project).to receive(:choose).and_return(projects.last)
          expect(FastlaneCore::Project).not_to receive(:select_project)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:project]).to eq(projects.last)
        end
      end

      it 'asks the user to specify a project when none are found' do
        within_a_temp_dir do |dir|
          project = './subdir/Something.xcodeproj'
          FileUtils.mkdir_p(project)

          expect(FastlaneCore::Project).to receive(:ask).and_return(project)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:project]).to eq(project)
        end
      end

      it 'asks the user to specify a workspace when none are found' do
        within_a_temp_dir do |dir|
          workspace = './subdir/Something.xcworkspace'
          FileUtils.mkdir_p(workspace)

          expect(FastlaneCore::Project).to receive(:ask).and_return(workspace)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspace)
        end
      end

      it 'explains when a provided path is not found' do
        within_a_temp_dir do |dir|
          workspace = './subdir/Something.xcworkspace'
          FileUtils.mkdir_p(workspace)

          expect(FastlaneCore::Project).to receive(:ask).and_return("something wrong")
          expect(FastlaneCore::Helper.log).to receive(:error).with(/Couldn't find/)
          expect(FastlaneCore::Project).to receive(:ask).and_return(workspace)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspace)
        end
      end

      it 'explains when a provided path is not valid' do
        within_a_temp_dir do |dir|
          workspace = './subdir/Something.xcworkspace'
          FileUtils.mkdir_p(workspace)
          FileUtils.mkdir_p('other-directory')

          expect(FastlaneCore::Project).to receive(:ask).and_return('other-directory')
          expect(FastlaneCore::Helper.log).to receive(:error).with(/Path must end with/)
          expect(FastlaneCore::Project).to receive(:ask).and_return(workspace)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspace)
        end
      end
    end

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

      it "#project_name" do
        expect(@project.project_name).to eq("Example")
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
        sleep(5)
        expect(count_processes(text)).to eq(count)
        # you would be expected to be able to see the number of processes go back to count right away.
      end
    end
  end
end
