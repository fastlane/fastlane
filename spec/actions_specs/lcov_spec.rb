describe Fastlane do
  describe Fastlane::FastFile do
    describe "Lcov Action" do
      before :each do
        ENV['PROJECT_NAME'] = 'a_project_name'
        ENV['SCHEME'] = 'a_scheme'
      end



      it "raises an error if no project name is given" do
        ENV.delete 'PROJECT_NAME'
        expect {
          Fastlane::FastFile.new.parse("lane :test do
          lcov({
            :scheme => 'a_valid_scheme'
            })
          end").runner.execute(:test)
        }.to raise_exception('No PROJECT_NAME given.'.red)
      end

      it "raises an error if no scheme is given" do
        ENV.delete 'SCHEME'
        expect {
          Fastlane::FastFile.new.parse("lane :test do
          lcov({
            :project_name => 'a_valid_project_name'
            })
          end").runner.execute(:test)
        }.to raise_exception('No SCHEME given.'.red)
      end

    end
  end
end
