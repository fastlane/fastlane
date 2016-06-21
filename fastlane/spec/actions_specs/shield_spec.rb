describe Fastlane do
  describe Fastlane::FastFile do
    describe "Shield Action" do
      it "downloads a shield with specified options" do
        result = Fastlane::FastFile.new.parse("lane :test do
            shield(
              output_path: './badge.png',
              format: 'png',
              subject: 'shields.io',
              status: 'UP',
              color: '00ff00',
              style: 'plastic',
            )
          end").runner.execute(:test)

        expect(result).to eq("wget -O \"./badge.png\" \"https://img.shields.io/badge/shields.io-UP-00ff00.png?style=plastic\"")
      end

      it "escapes option text appropriately" do
        result = Fastlane::FastFile.new.parse("lane :test do
            shield(
              output_path: './badge.svg',
              subject: 'fastlane_core-tests',
              status: 'all-passing'
            )
          end").runner.execute(:test)

        expect(result).to eq("wget -O \"./badge.svg\" \"https://img.shields.io/badge/fastlane__core--tests-all--passing-green.svg?style=flat\"")
      end
    end
  end
end
