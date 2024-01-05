require 'json'

describe Spaceship::ConnectAPI::Model do
  it "#to_json" do
    class TestModel
      include Spaceship::ConnectAPI::Model

      attr_accessor :foo
      attr_accessor :foo_bar

      attr_mapping({
        "fooBar" => "foo_bar"
      })
    end

    test = TestModel.new("id", { foo: "foo", foo_bar: "foo_bar" })
    expect(JSON.parse(test.to_json)).to eq({
      "id" => "id",
      "foo" => "foo",
      "foo_bar" => "foo_bar"
    })
  end
end
