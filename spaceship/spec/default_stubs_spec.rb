require "net/http"

describe "the spaceship default stubs" do
  let(:uri) { URI("https://appstoreconnect.apple.com/iris/v1/betaGroups") }

  it "answer during a spaceship example" do
    expect(Net::HTTP.get_response(uri).code).to eq("200")
  end

  it "stop answering once the spaceship example is over, so other specs still get no network" do
    after_each_spaceship

    expect { Net::HTTP.get_response(uri) }.to raise_error(WebMock::NetConnectNotAllowedError)
  end
end
