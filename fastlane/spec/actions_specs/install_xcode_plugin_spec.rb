describe Fastlane do
  describe Fastlane::FastFile do
    describe "install_xcode_plugin" do
      it "downloads plugin using argument-safe curl invocation" do
        tmp_home = Dir.mktmpdir
        stub_const('ENV', ENV.to_hash.merge('HOME' => tmp_home))

        plugins_path = "#{tmp_home}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
        url = "https://example.com/plugin.zip; touch /tmp/fastlane_pwned"

        expect(FileUtils).to receive(:mkdir_p).with(plugins_path)
        expect(Fastlane::Action).to receive(:sh).with("curl", "-L", "-s", "-o", kind_of(String), url)
        expect(Fastlane::Action).to receive(:sh).with("unzip", "-qo", kind_of(String), "-d", plugins_path)

        Fastlane::FastFile.new.parse("lane :test do
          install_xcode_plugin(url: '#{url}')
        end").runner.execute(:test)
      ensure
        FileUtils.remove_entry(tmp_home) if tmp_home && File.directory?(tmp_home)
      end
    end
  end
end
