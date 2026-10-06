describe Fastlane do
  describe Fastlane::FastFile do
    describe "PEM Integration" do
      it "works with no parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pem
        end").runner.execute(:test)
      end

      it "support a success callback block" do
        # Avoid fixed paths under /tmp: parallel test processes would share them. See fastlane#30184.
        temp_path = File.join(Dir.mktmpdir("fl_spec_pem"), "callback.txt")

        expect(File.exist?(temp_path)).to eq(false)

        result = Fastlane::FastFile.new.parse("lane :test do
          pem(
            new_profile: proc do |value|
              File.write('#{temp_path}', '1')
            end
            )
        end").runner.execute(:test)

        expect(File.exist?(temp_path)).to eq(true)
      end
    end
  end
end
