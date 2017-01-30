describe Spaceship::Portal::Persons do
  before { Spaceship.login }
  let(:client) { Spaceship::Portal::App.client }
  it "Should load all persons" do
    all = Spaceship::Portal::Persons.all
    expect(all.length).to eq(3)
  end
  it "Should find a specific person" do
    person = Spaceship::Portal::Persons.find("helmut@januschka.com")
    expect(person.email_address).to eq("helmut@januschka.com")
  end
  it "should invite a new one" do
    expect { Spaceship::Portal::Persons.invite("helmut@januschka.com", "admin") }.to_not raise_error
  end
end
