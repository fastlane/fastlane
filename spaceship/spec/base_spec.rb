describe Spaceship::Base do
  before { Spaceship.login }
  let(:client) { Spaceship::App.client }

  describe "#inspect" do
    it "contains the relevant data" do
      app = Spaceship::App.all.first
      output = app.inspect
      expect(output).to include "B7JBD8LHAA"
      expect(output).to include "The App Name"
    end

    it "prints out references" do
      Spaceship::Tunes.login
      app = Spaceship::Application.all.first
      v = app.live_version
      output = v.inspect
      expect(output).to include "Tunes::AppVersion"
      expect(output).to include "Tunes::Application"
    end
  end

  it "doesn't blow up if it was initialized with a nil data hash" do
    hash = Spaceship::Base::DataHash.new(nil)
    expect { hash["key"] }.not_to raise_exception
  end

  it "allows modification of values and properly retrieving them" do
    app = Spaceship::App.all.first
    app.name = "12"
    expect(app.name).to eq("12")
  end
end
