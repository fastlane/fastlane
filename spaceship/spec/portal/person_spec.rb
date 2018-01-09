describe Spaceship::Portal::Persons do
  before { Spaceship.login }
  let(:client) { Spaceship::Persons.client }
  it "should factor a new person object" do
    joined = "2016-06-20T06:30:26Z"
    attrs = {
      "personId" => "1234",
      "firstName" => "Helmut",
      "lastName" => "Januschka",
      "email" => "helmut@januschka.com",
      "developerStatus" => "active",
      "dateJoined" => joined,
      "teamMemberId" => "1234"
    }
    person = Spaceship::Portal::Person.factory(attrs)
    expect(person.email_address).to eq("helmut@januschka.com")
    expect(person.joined).to eq(Time.parse(joined))
  end

  it "should be OK if person date format changes to timestamp" do
    joined = 1_501_106_986_000
    attrs = {
      "personId" => "1234",
      "firstName" => "Helmut",
      "lastName" => "Januschka",
      "email" => "helmut@januschka.com",
      "developerStatus" => "active",
      "dateJoined" => joined,
      "teamMemberId" => "1234"
    }
    person = Spaceship::Portal::Person.factory(attrs)
    expect(person.joined).to eq(joined)
  end

  it "should be OK if person date format is unparseable" do
    joined = "This is clearly not a timestamp"
    attrs = {
      "personId" => "1234",
      "firstName" => "Helmut",
      "lastName" => "Januschka",
      "email" => "helmut@januschka.com",
      "developerStatus" => "active",
      "dateJoined" => joined,
      "teamMemberId" => "1234"
    }
    person = Spaceship::Portal::Person.factory(attrs)
    expect(person.joined).to eq(joined)
  end

  it "should remove a member" do
    expect(client).to receive(:team_remove_member!).with("5M8TWKRZ3J")
    person = Spaceship::Portal::Persons.find("helmut@januschka.com")
    person.remove!
  end

  it "should change role" do
    person = Spaceship::Portal::Persons.find("helmut@januschka.com")
    expect { person.change_role("member") }.to_not(raise_error)
  end
end
