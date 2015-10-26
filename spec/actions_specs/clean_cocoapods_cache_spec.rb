describe Fastlane do
  describe Fastlane::FastFile do
    describe "Clean Cocoapods Cache Integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          clean_cocoapods_cache
        end").runner.execute(:test)

        expect(result).to eq("pod cache clean --all")
      end

      it "adds pod name to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          clean_cocoapods_cache(
            name: 'Name'
          )
        end").runner.execute(:test)

        expect(result).to eq("pod cache clean Name --all")
      end

      it "raise an exception if name is empty" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            clean_cocoapods_cache(
              name: ''
            )
            end").runner.execute(:test)
        end.to raise_error(RuntimeError)
      end
    end
  end
end
