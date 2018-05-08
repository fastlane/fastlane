describe Fastlane do
  describe Fastlane::FastFile do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"

      # pem_stub_spaceship
    end

    before :all do
      FileUtils.mkdir("tmp")
    end

    it "Successful run" do
		Fastlane::FastFile.new.parse("lane :test do
	        apple_pay_cert(
	         username: 'test@fastlane.tools'
	        )
	      end").runner.execute(:test)
      
      # expect(File.exist?("production_com.krausefx.app.pem")).to eq(true)
      # expect(File.exist?("production_com.krausefx.app.pkey")).to eq(true)
    end

    after :all do
      # FileUtils.rm_r("tmp")
      # File.delete("production_com.krausefx.app.pem")
      # File.delete("production_com.krausefx.app.pkey")

      # ENV.delete("DELIVER_USER")
      # ENV.delete("DELIVER_PASSWORD")
    end
  end
end
