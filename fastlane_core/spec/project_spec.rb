describe FastlaneCore do
  describe FastlaneCore::Project do
    describe 'project and workspace detection' do
      def within_a_temp_dir
        Dir.mktmpdir do |dir|
          FileUtils.cd(dir) do
            yield(dir) if block_given?
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
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "You can only pass either a workspace or a project path, not both")
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
          expect(FastlaneCore::Project).not_to(receive(:select_project))

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
          expect(FastlaneCore::Project).not_to(receive(:select_project))

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:project]).to eq(projects.last)
        end
      end

      it 'asks the user to specify a project when none are found' do
        within_a_temp_dir do |dir|
          project = './subdir/Something.xcodeproj'
          FileUtils.mkdir_p(project)

          expect(FastlaneCore::UI).to receive(:input).and_return(project)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:project]).to eq(project)
        end
      end

      it 'asks the user to specify a workspace when none are found' do
        within_a_temp_dir do |dir|
          workspace = './subdir/Something.xcworkspace'
          FileUtils.mkdir_p(workspace)

          expect(FastlaneCore::UI).to receive(:input).and_return(workspace)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspace)
        end
      end

      it 'explains when a provided path is not found' do
        within_a_temp_dir do |dir|
          workspace = './subdir/Something.xcworkspace'
          FileUtils.mkdir_p(workspace)

          expect(FastlaneCore::UI).to receive(:input).and_return("something wrong")
          expect(FastlaneCore::UI).to receive(:error).with(/Couldn't find/)
          expect(FastlaneCore::UI).to receive(:input).and_return(workspace)

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

          expect(FastlaneCore::UI).to receive(:input).and_return('other-directory')
          expect(FastlaneCore::UI).to receive(:error).with(/Path must end with/)
          expect(FastlaneCore::UI).to receive(:input).and_return(workspace)

          config = FastlaneCore::Configuration.new(options, {})
          FastlaneCore::Project.detect_projects(config)

          expect(config[:workspace]).to eq(workspace)
        end
      end
    end

    it "raises an exception if path was not found" do
      expect do
        FastlaneCore::Project.new(project: "/tmp/notHere123")
      end.to raise_error("Could not find project at path '/tmp/notHere123'")
    end

    describe "Valid Standard Project" do
      before do
        options = { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "#path" do
        expect(@project.path).to eq(File.expand_path("./fastlane_core/spec/fixtures/projects/Example.xcodeproj"))
      end

      it "#is_workspace" do
        expect(@project.is_workspace).to eq(false)
      end

      it "#project_name" do
        expect(@project.project_name).to eq("Example")
      end

      it "#schemes returns all available schemes", requires_xcodebuild: true do
        expect(@project.schemes).to eq(["Example"])
      end

      it "#configurations returns all available configurations", requires_xcodebuild: true do
        expect(@project.configurations).to eq(["Debug", "Release", "SpecialConfiguration"])
      end

      it "#app_name", requires_xcode: true do
        expect(@project.app_name).to eq("ExampleProductName")
      end

      it "#mac?", requires_xcode: true do
        expect(@project.mac?).to eq(false)
      end

      it "#ios?", requires_xcode: true do
        expect(@project.ios?).to eq(true)
      end

      it "#tvos?", requires_xcode: true do
        expect(@project.tvos?).to eq(false)
      end
    end

    describe "Valid CocoaPods Project" do
      before do
        options = {
          workspace: "./fastlane_core/spec/fixtures/projects/cocoapods/Example.xcworkspace",
          scheme: "Example"
        }
        @workspace = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "#schemes returns all schemes", requires_xcodebuild: true do
        expect(@workspace.schemes).to eq(["Example"])
      end

      it "#schemes returns all configurations", requires_xcodebuild: true do
        expect(@workspace.configurations).to eq([])
      end
    end

    describe "Mac Project" do
      before do
        options = { project: "./fastlane_core/spec/fixtures/projects/Mac.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "#mac?", requires_xcode: true do
        expect(@project.mac?).to eq(true)
      end

      it "#ios?", requires_xcode: true do
        expect(@project.ios?).to eq(false)
      end

      it "#tvos?", requires_xcode: true do
        expect(@project.tvos?).to eq(false)
      end

      it "schemes", requires_xcodebuild: true do
        expect(@project.schemes).to eq(["Mac"])
      end
    end

    describe "TVOS Project" do
      before do
        options = { project: "./fastlane_core/spec/fixtures/projects/ExampleTVOS.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "#mac?", requires_xcode: true do
        expect(@project.mac?).to eq(false)
      end

      it "#ios?", requires_xcode: true do
        expect(@project.ios?).to eq(false)
      end

      it "#tvos?", requires_xcode: true do
        expect(@project.tvos?).to eq(true)
      end

      it "schemes", requires_xcodebuild: true do
        expect(@project.schemes).to eq(["ExampleTVOS"])
      end
    end

    describe "Cross-Platform Project" do
      before do
        options = { project: "./fastlane_core/spec/fixtures/projects/Cross-Platform.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "supported_platforms", requires_xcode: true do
        expect(@project.supported_platforms).to eq([:macOS, :iOS, :tvOS, :watchOS])
      end

      it "#mac?", requires_xcode: true do
        expect(@project.mac?).to eq(true)
      end

      it "#ios?", requires_xcode: true do
        expect(@project.ios?).to eq(true)
      end

      it "#tvos?", requires_xcode: true do
        expect(@project.tvos?).to eq(true)
      end

      it "schemes", requires_xcodebuild: true do
        expect(@project.schemes).to eq(["CrossPlatformFramework"])
      end
    end

    describe "build_settings() can handle empty lines" do
      it "SUPPORTED_PLATFORMS should be iphonesimulator iphoneos on Xcode >= 8.3" do
        options = { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
        expect(FastlaneCore::Helper).to receive(:xcode_at_least?).and_return(true)
        command = "xcodebuild -showBuildSettings -project ./fastlane_core/spec/fixtures/projects/Example.xcodeproj 2> /dev/null"
        expect(FastlaneCore::Project).to receive(:run_command).with(command.to_s, { timeout: 10, retries: 3, print: false }).and_return(File.read("./fastlane_core/spec/fixtures/projects/build_settings_with_toolchains"))
        expect(@project.build_settings(key: "SUPPORTED_PLATFORMS")).to eq("iphonesimulator iphoneos")
      end

      it "SUPPORTED_PLATFORMS should be iphonesimulator iphoneos on Xcode < 8.3" do
        options = { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
        expect(FastlaneCore::Helper).to receive(:xcode_at_least?).and_return(false)
        command = "xcodebuild clean -showBuildSettings -project ./fastlane_core/spec/fixtures/projects/Example.xcodeproj 2> /dev/null"
        expect(FastlaneCore::Project).to receive(:run_command).with(command.to_s, { timeout: 10, retries: 3, print: false }).and_return(File.read("./fastlane_core/spec/fixtures/projects/build_settings_with_toolchains"))
        expect(@project.build_settings(key: "SUPPORTED_PLATFORMS")).to eq("iphonesimulator iphoneos")
      end
    end

    describe "Build Settings with default configuration" do
      before do
        options = { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "IPHONEOS_DEPLOYMENT_TARGET should be 9.0", requires_xcode: true do
        expect(@project.build_settings(key: "IPHONEOS_DEPLOYMENT_TARGET")).to eq("9.0")
      end

      it "PRODUCT_BUNDLE_IDENTIFIER should be tools.fastlane.app", requires_xcode: true do
        expect(@project.build_settings(key: "PRODUCT_BUNDLE_IDENTIFIER")).to eq("tools.fastlane.app")
      end
    end

    describe "Build Settings with specific configuration" do
      before do
        options = {
          project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj",
          configuration: "SpecialConfiguration"
        }
        @project = FastlaneCore::Project.new(options, xcodebuild_list_silent: true, xcodebuild_suppress_stderr: true)
      end

      it "IPHONEOS_DEPLOYMENT_TARGET should be 9.0", requires_xcode: true do
        expect(@project.build_settings(key: "IPHONEOS_DEPLOYMENT_TARGET")).to eq("9.0")
      end

      it "PRODUCT_BUNDLE_IDENTIFIER should be tools.fastlane.app.special", requires_xcode: true do
        expect(@project.build_settings(key: "PRODUCT_BUNDLE_IDENTIFIER")).to eq("tools.fastlane.app.special")
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

    describe 'Project.xcode_build_settings_timeout' do
      before do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT'] = nil
      end
      it "returns default value" do
        expect(FastlaneCore::Project.xcode_build_settings_timeout).to eq(10)
      end
      it "returns specified value" do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT'] = '5'
        expect(FastlaneCore::Project.xcode_build_settings_timeout).to eq(5)
      end
      it "returns 0 if empty" do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT'] = ''
        expect(FastlaneCore::Project.xcode_build_settings_timeout).to eq(0)
      end
      it "returns 0 if garbage" do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT'] = 'hiho'
        expect(FastlaneCore::Project.xcode_build_settings_timeout).to eq(0)
      end
    end

    describe 'Project.xcode_build_settings_retries' do
      before do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_RETRIES'] = nil
      end
      it "returns default value" do
        expect(FastlaneCore::Project.xcode_build_settings_retries).to eq(3)
      end
      it "returns specified value" do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_RETRIES'] = '5'
        expect(FastlaneCore::Project.xcode_build_settings_retries).to eq(5)
      end
      it "returns 0 if empty" do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_RETRIES'] = ''
        expect(FastlaneCore::Project.xcode_build_settings_retries).to eq(0)
      end
      it "returns 0 if garbage" do
        ENV['FASTLANE_XCODEBUILD_SETTINGS_RETRIES'] = 'hiho'
        expect(FastlaneCore::Project.xcode_build_settings_retries).to eq(0)
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
        expect do
          FastlaneCore::Project.run_command(cmd, timeout: 1)
        end.to raise_error(Timeout::Error)

        # on mac this before only partially works as expected
        if FastlaneCore::Helper.is_mac?
          # this shows the current implementation issue
          # Timeout doesn't kill the running process
          # i.e. see fastlane/fastlane_core#102
          expect(count_processes(text)).to eq(count + 1)
          sleep(5)
          expect(count_processes(text)).to eq(count)
          # you would be expected to be able to see the number of processes go back to count right away.
        end
      end

      it "retries and kills" do
        text = "NEEDSRETRY"
        cmd = "ruby -e 'sleep 3; puts \"#{text}\"'"

        expect(FastlaneCore::Project).to receive(:`).and_call_original.exactly(4).times

        expect do
          FastlaneCore::Project.run_command(cmd, timeout: 1, retries: 3)
        end.to raise_error(Timeout::Error)
      end
    end

    describe 'xcodebuild_list_silent option', requires_xcodebuild: true do
      it 'is not silent by default' do
        project = FastlaneCore::Project.new(
          { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" },
          xcodebuild_suppress_stderr: true
        )

        expect(project).to receive(:raw_info).with(silent: false).and_call_original

        project.configurations
      end

      it 'makes the raw_info method be silent if configured', requires_xcodebuild: true do
        project = FastlaneCore::Project.new(
          { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" },
          xcodebuild_list_silent: true,
          xcodebuild_suppress_stderr: true
        )
        expect(project).to receive(:raw_info).with(silent: true).and_call_original

        project.configurations
      end
    end

    describe 'xcodebuild_suppress_stderr option', requires_xcode: true do
      it 'generates an xcodebuild -list command without stderr redirection by default' do
        project = FastlaneCore::Project.new({ project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" })
        expect(project.build_xcodebuild_list_command).not_to(match(%r{2> /dev/null}))
      end

      it 'generates an xcodebuild -list command that redirects stderr to /dev/null' do
        project = FastlaneCore::Project.new(
          { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" },
          xcodebuild_suppress_stderr: true
        )
        expect(project.build_xcodebuild_list_command).to match(%r{2> /dev/null})
      end

      it 'generates an xcodebuild -showBuildSettings command without stderr redirection by default' do
        project = FastlaneCore::Project.new({ project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" })
        expect(project.build_xcodebuild_showbuildsettings_command).not_to(match(%r{2> /dev/null}))
      end

      it 'generates an xcodebuild -showBuildSettings command that redirects stderr to /dev/null', requires_xcode: true do
        project = FastlaneCore::Project.new(
          { project: "./fastlane_core/spec/fixtures/projects/Example.xcodeproj" },
          xcodebuild_suppress_stderr: true
        )
        expect(project.build_xcodebuild_showbuildsettings_command).to match(%r{2> /dev/null})
      end
    end

    describe "#project_paths" do
      it "works with basic projects" do
        project = FastlaneCore::Project.new({
          project: "gym/lib"
        })

        expect(project.project_paths).to be_an(Array)
        expect(project.project_paths).to eq([File.expand_path("gym/lib")])
      end

      it "works with workspaces" do
        workspace_path = "gym/spec/fixtures/projects/cocoapods/Example.xcworkspace"
        project = FastlaneCore::Project.new({
          workspace: workspace_path
        })

        expect(project.project_paths).to eq([
                                              File.expand_path(workspace_path.gsub("xcworkspace", "xcodeproj")) # this should point to the included Xcode project
                                            ])
      end
    end
  end
end
