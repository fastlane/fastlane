describe Fastlane do
  describe Fastlane::FastFile do
    describe "xcode_install" do
      it "works" do
        require 'xcode/install'
        i = "installer"
        path = "my_path"
        project = "project"
        xcode_version = "7.1"
        expect(XcodeInstall::Installer).to receive(:new).and_return(i)
        expect(i).to receive(:installed?).and_return(false)
        expect(i).to receive(:install_version).with(xcode_version, true, true, true, true).and_return(path)
        expect(i).to receive(:installed_versions).and_return([project])
        expect(project).to receive(:version).and_return(xcode_version)
        allow(project).to receive(:path).and_return(path)
        expect(project).to receive(:approve_license).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          xcode_install(version: '#{xcode_version}', username: 'flapple@krausefx.com')
        end").runner.execute(:test)

        expect(result).to eq(path)
      end
    end
  end
end
