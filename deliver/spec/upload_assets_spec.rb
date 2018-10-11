require 'deliver/upload_metadata'

describe Deliver::UploadAssets do
  let(:uploader) { Deliver::UploadAssets.new }
  let(:app) { double('app') }
  let(:version) { double('version') }
  let(:app_icon) { double('app_icon') }
  let(:apple_watch_app_icon) { double('apple_watch_app_icon') }

  before do
    allow(version).to receive(:upload_large_icon!)
    allow(version).to receive(:upload_watch_icon!)
    allow(version).to receive(:save!)
    allow(app).to receive(:edit_version).and_return(version)
    allow(app).to receive(:name).and_return("MyApp")
  end

  it "should upload app icon and save when app icon is given" do
    options = { app: app, app_icon: app_icon }
    uploader.upload(options)
    expect(version).to have_received(:upload_large_icon!).with(app_icon)
    expect(version).to have_received(:save!)
  end

  it "should upload apple watch app icon and save when only apple watch app icon is given" do
    options = { app: app, apple_watch_app_icon: apple_watch_app_icon }
    uploader.upload(options)
    expect(version).to have_received(:upload_watch_icon!).with(apple_watch_app_icon)
    expect(version).to have_received(:save!)
  end

  it "should not upload or save when icons are not given" do
    options = { app: app }
    uploader.upload(options)
    expect(version).to_not(have_received(:upload_watch_icon!))
    expect(version).to_not(have_received(:upload_large_icon!))
    expect(version).to_not(have_received(:save!))
  end

  it "should not upload or save when editing live even if icon is given" do
    options = { app: app, edit_live: true, app_icon: app_icon }
    uploader.upload(options)
    expect(version).to_not(have_received(:upload_watch_icon!))
    expect(version).to_not(have_received(:upload_large_icon!))
    expect(version).to_not(have_received(:save!))
  end

  it "should raise when app icon is given but version is nil" do
    options = { app: app, app_icon: app_icon }
    allow(app).to receive(:edit_version).and_return(nil)
    expect do
      uploader.upload(options)
    end.to raise_error(FastlaneCore::Interface::FastlaneError)
  end
end
