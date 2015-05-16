require 'spec_helper'

describe Spaceship::Base do
  before { Spaceship.login }
  let(:client) { Spaceship::App.client }

  describe "#inspect" do
    it "contains the relevant data" do
      app = Spaceship::App.all.first
      output = app.inspect
      expect(output).to include"B7JBD8LHAA"
      expect(output).to include"The App Name"
    end
  end
end
