describe Fastlane do
  describe Fastlane::FastFile do
    describe "Produce Integration" do
      it "raises an error if non hash is passed" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do 
              produce('text')
            end").runner.execute(:test)
        }.to raise_error("Parameter of produce must be a hash".red)
      end

      it "stores passed parameters in the environment" do
        test_val = 'some_value'
        Fastlane::FastFile.new.parse("lane :test do 
            produce({
              produce_user_name: '#{test_val}'
              })
          end").runner.execute(:test)

        expect(ENV['PRODUCE_USER_NAME']).to eq(test_val)
      end
    end
  end
end
