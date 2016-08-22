require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  def self.silence_stderr
    begin
      orig_stderr = $stderr.clone
      $stderr.reopen File.new('/dev/null', 'w')
      retval = yield
    ensure
      $stderr.reopen orig_stderr
    end
    retval
  end

  describe Curl do
    it 'reports failure' do
      `true`
      curl = XcodeInstall::Curl.new
      result = nil
      XcodeInstall.silence_stderr do
        result = curl.fetch('http://0.0.0.0/test')
      end
      result.should == false
    end
  end
end
