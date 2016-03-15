require 'spec_helper'
require 'fakefs/spec_helpers'
require 'stubs/upload_stubbing'

describe Deliver::UploadScreenshots do
  include FakeFS::SpecHelpers

  before :each do
    @root = '/tmp/screenshots/'
    FileUtils.mkdir_p(@root)

    (1..5).each do |i|
      file_path = File.join(@root, "scr_#{i}.jpg")
      File.open(file_path, 'w') { |file| file.write(i.to_s) }
    end
  end

  def mock_local_upload(sequence)
    @order = 0
    to_upload = sequence.map do |i|
      file_path = File.join(@root, "scr_#{i}.jpg")
      md5 = Spaceship::Utilities.md5digest(file_path)
      file = Screenshot.new({file_path: file_path, language: 'en-US', original_file_name: "ftl_#{md5}_scr_#{i}.jpg", sort_order: @order})
      @order += 1
      file
    end
    to_upload
  end

  let(:options) { { app: FakeApp.new } }
  let(:deliver) { Deliver::UploadScreenshots.new }

  context "Deleting screenshots from ITC" do
    it "should delete screenshot from ITC when order had been changed" do
      # 1st and 2nd changed places. Expecting deletion of both
      expect do
        deliver.upload(options, mock_local_upload([2, 1, 3, 4]))
      end.to output(/Deleting 1 for device iphone4\nDeleting 2 for device iphone4/).to_stdout
    end

    it "should delete screenshot from ITC when file had been changed" do
      # 1st changed. Expecting deletion of first
      expect do
        deliver.upload(options, mock_local_upload([5, 2, 3, 4]))
      end.to output(/Deleting 1 for device iphone4/).to_stdout
    end

    it "should delete screenshot from ITC when there's no md5 in filename" do
      # add screenshot without md5 - simulate screenshot not uploaded by spaceship
      file_path = File.join(@root, "scr_5.jpg")
      file = Screenshot.new({file_path: file_path, language: 'en-US', original_file_name: "scr_5.jpg", sort_order: 5})
      options[:app].edit_version.screenshots['en-US'] << file

      # 5th don't have md5 in file name. Expecting deletion
      to_upload = mock_local_upload([1, 2, 3, 4, 5])

      expect do
        deliver.upload(options, to_upload)
      end.to output(/Deleting 5 for device iphone4/).to_stdout
    end

    it "should delete all screenshots and upload noting if no screenshots local" do
      to_upload = []
      expected_stdout = "Deleting 1 for device iphone4\n" \
        "Deleting 2 for device iphone4\n" \
        "Deleting 3 for device iphone4\n" \
        "Deleting 4 for device iphone4\n"
      expect do
        deliver.upload(options, to_upload)
      end.to output(expected_stdout).to_stdout
    end
  end

  context "Uploading screenshots to ITC" do
    it "should re-upload first 2 screenshots when changed order of 1st and 2nd" do
      # 1st and 2nd changed places. Expecting re-upload of both
      expected_stdout = "Deleting 1 for device iphone4\n" \
        "Deleting 2 for device iphone4\n" \
        "Uploading '/tmp/screenshots/scr_2.jpg' for device iphone4\n" \
        "Uploading '/tmp/screenshots/scr_1.jpg' for device iphone4\n"
      expect do
        deliver.upload(options, mock_local_upload([2, 1, 3, 4]))
      end.to output(expected_stdout).to_stdout
    end

    it "should re-upload first screenshot when 1st changed" do
      # 1st changed. Expecting re-upload of first
      expected_stdout = "Deleting 1 for device iphone4\n" \
        "Uploading '/tmp/screenshots/scr_5.jpg' for device iphone4\n"
      expect do
        deliver.upload(options, mock_local_upload([5, 2, 3, 4]))
      end.to output(expected_stdout).to_stdout
    end

    it "should skip screenshot upload when screenshot is already uploaded on ITC with the same order" do
      # nothing's changed upload_screenshot! won't be called at all
      expect do
        deliver.upload(options, mock_local_upload([1, 2, 3, 4]))
      end.to output('').to_stdout
    end
  end
end
