describe Fastlane do
  describe Fastlane::Setup do
    it "#files_to_copy" do
      expect(Fastlane::SetupIos.new.files_to_copy).to eq(['Deliverfile', 'deliver', 'screenshots'])
    end

    it "#show_infos" do
      Fastlane::SetupIos.new.show_infos
    end

    describe "Complete setup process" do
      let (:fixtures) { File.expand_path("./spec/fixtures/setup_workspace/") }
      let (:workspace) { File.expand_path("/tmp/setup_workspace/") }
      before do
        fastlane_folder = File.join(workspace, 'fastlane')
        FileUtils.rm_rf(workspace) if File.directory? workspace
        FileUtils.cp_r(fixtures, File.expand_path('..', workspace)) # copy workspace to work on to /tmp

        $terminal = HighLine.new # mock user inputs :)
        allow($terminal).to receive(:ask).and_return("y\n")

        allow(Fastlane::FastlaneFolder).to receive(:path).and_return(fastlane_folder)

        ENV['DELIVER_USER'] = 'felix@sunapps.net'
      end

      it "setup is successful and generated inital Fastfile" do
        if FastlaneCore::Helper.mac?
          require 'snapshot'
          require 'snapshot/setup'
          expect(Snapshot::Setup).to receive(:create).with("/tmp/setup_workspace/fastlane")
        end

        Fastlane::FastlaneFolder.create_folder!(workspace)
        setup = Fastlane::SetupIos.new
        expect(setup.run).to eq(true)
        expect(setup.tools).to eq({deliver: true, snapshot: FastlaneCore::Helper.mac?, xctool: true, cocoapods: true, sigh: true, carthage: false})

        content = File.read(File.join(Fastlane::FastlaneFolder.path, 'Fastfile'))
        expect(content).to include "# update_fastlane"
        expect(content).to include "# opt_out_usage"
        expect(content).to include "  deliver"
        expect(content).to include "  xctool"
        expect(content).to include "gym(scheme: \"y\")"
      end

      after do
        ENV.delete('DELIVER_USER')
      end
    end
  end
end
