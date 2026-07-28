describe Spaceship::Hashcash do
  it "makes hashcash with 11 bits" do
    allow_any_instance_of(Time).to receive(:strftime).and_return("20230223170600")

    sha = Spaceship::Hashcash.make(bits: "11", challenge: "4d74fb15eb23f465f1f6fcbf534e5877")
    expect(sha).to eq("1:11:20230223170600:4d74fb15eb23f465f1f6fcbf534e5877::6373")
  end

  it "finds hashcash with 12 bits" do
    allow_any_instance_of(Time).to receive(:strftime).and_return("20230223213732")

    sha = Spaceship::Hashcash.make(bits: "12", challenge: "f8b58554b2f22960fc0dc99aea342276")
    expect(sha).to eq("1:12:20230223213732:f8b58554b2f22960fc0dc99aea342276::2381")
  end
end
