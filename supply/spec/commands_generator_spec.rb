require 'supply/commands_generator'
require 'supply/setup'

describe Supply::CommandsGenerator do
  def expect_uploader_perform_upload
    fake_uploader = "uploader"
    expect(Supply::Uploader).to receive(:new).and_return(fake_uploader)
    expect(fake_uploader).to receive(:perform_upload)
  end

  def expect_setup_perform_download
    fake_setup = "setup"
    expect(Supply::Setup).to receive(:new).and_return(fake_setup)
    expect(fake_setup).to receive(:perform_download)
  end

  describe ":run options handling" do
    it "can use the skip_upload_metadata flag from tool options" do
      # leaving out the command name defaults to 'run'
      stub_commander_runner_args(['--skip_upload_metadata'])
      expect_uploader_perform_upload
      Supply::CommandsGenerator.start
      expect(Supply.config[:skip_upload_metadata]).to be(true)
    end
  end

  describe ":init options handling" do
    it "can use the package_name short flag from tool options" do
      stub_commander_runner_args(['init', '-p', 'com.test.package'])
      expect_setup_perform_download
      Supply::CommandsGenerator.start
      expect(Supply.config[:package_name]).to eq('com.test.package')
    end
  end
end
