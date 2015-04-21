describe Fastlane do
  describe Fastlane::FastFile do
    describe "Produce Integration" do
      it "raises an error if non hash is passed" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
              produce('text')
            end").runner.execute(:test)
        end.to raise_error("You have to pass the options for 'produce' in a different way. Please check out the current documentation on GitHub!".red)
      end

      it "stores passed parameters in the environment" do
        test_val = "some_value"
        Fastlane::FastFile.new.parse("lane :test do
            produce({
              produce_user_name: '#{test_val}'
              })
          end").runner.execute(:test)

        expect(ENV["PRODUCE_USER_NAME"]).to eq(test_val)
      end
    end
  end
end
