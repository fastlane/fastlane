require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerDeviceGrid do
    it 'should be a plugin' do
      expect(Danger::DangerDeviceGrid.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
  end
end
