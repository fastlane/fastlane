describe Spaceship::Base do
  before { Spaceship.login }
  let(:client) { Spaceship::App.client }

  class TestBase < Spaceship::Base
    attr_accessor :child

    def initialize
    end

    def self.self_reference
      r = TestBase.new
      r.child = r
      r
    end
  end

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

    it 'handles circular references' do
      test_base = TestBase.self_reference
      expect do
        test_base.inspect
      end.to_not raise_error
    end

    it 'displays a placeholder value in inspect/to_s' do
      test_base = TestBase.self_reference
      expect(test_base.to_s).to eq("<TestBase \n\tchild=<TestBase \n\t~~DUPE~~>>")
    end

    it "doesn't leak state when throwing expections while inspecting objects" do
      # an object with a broken inspect
      test_base2 = TestBase.new
      error = "faked inspect error"
      allow(test_base2).to receive(:inspect).and_raise(error)

      # will break the parent
      test_base = TestBase.new
      test_base.child = test_base2
      expect do
        test_base.inspect
      end.to raise_error(error)

      expect(Thread.current[:inspected_objects]).to be_nil
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
