describe Fastlane do
  describe Fastlane::FastFile do
    describe "Jazzy" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          jazzy
        end").runner.execute(:test)

        expect(result).to eq("jazzy")
      end

      it "add config option" do
        result = Fastlane::FastFile.new.parse("lane :test do
          jazzy(
            config: '.jazzy.yaml'
          )
        end").runner.execute(:test)

        expect(result).to eq("jazzy --config .jazzy.yaml")
      end

      it "add module_version option" do
        result = Fastlane::FastFile.new.parse("lane :test do
          jazzy(
            module_version: '1.2.6'
          )
        end").runner.execute(:test)

        expect(result).to eq("jazzy --module-version 1.2.6")
      end
    end
  end
end
