require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  xcode_path = '/Volumes/Macintosh HD/Applications/Xcode Beta'

  describe InstalledXcode do
    it 'finds the current Xcode version with whitespace chars' do
      InstalledXcode.any_instance.expects(:`).with("DEVELOPER_DIR='' \"#{xcode_path}/Contents/Developer/usr/bin/xcodebuild\" -version").returns("Xcode 6.3.1\nBuild version 6D1002")
      installed = InstalledXcode.new(xcode_path)
      installed.version.should == '6.3.1'
    end

    it 'is robust against broken Xcode installations' do
      InstalledXcode.any_instance.expects(:`).with("DEVELOPER_DIR='' \"#{xcode_path}/Contents/Developer/usr/bin/xcodebuild\" -version").returns(nil)
      installed = InstalledXcode.new(xcode_path)
      installed.version.should == '0.0'
    end
  end
end
