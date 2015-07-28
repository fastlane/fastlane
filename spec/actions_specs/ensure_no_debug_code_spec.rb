describe Fastlane do
  describe Fastlane::FastFile do
    describe "ensure_no_debug_code" do

      it "doesn't raise an exception if nothing was found" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          ensure_no_debug_code(text: 'pry', path: './fastlane/', extension: 'rb')
        end").runner.execute(:test)
        expect(result).to eq("grep -R 'pry' './fastlane/'")
      end

    end
  end
end
