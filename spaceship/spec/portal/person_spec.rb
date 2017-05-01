describe Spaceship::Portal::Persons do
  before { Spaceship.login }
  let(:client) { Spaceship::Persons.client }
  it "should factor a new person object" do
    attrs = {
      "personId" => "1234",
      "firstName" => "Helmut",
      "lastName" => "Januschka",
      "email" => "helmut@januschka.com",
      "developerStatus" => "active",
      "dateJoined" => "XXXXX",
      "teamMemberId" => "1234"
    }
    person = Spaceship::Portal::Person.factory(attrs)
    expect(person.email_address).to eq("helmut@januschka.com")
  end
  it "Should remove a member" do
    expect(client).to receive(:team_remove_member!).with("5M8TWKRZ3J")
    person = Spaceship::Portal::Persons.find("helmut@januschka.com")
    person.remove!
  end

  it "should change role" do
    person = Spaceship::Portal::Persons.find("helmut@januschka.com")
    expect { person.change_role("member") }.to_not raise_error
  end
end
