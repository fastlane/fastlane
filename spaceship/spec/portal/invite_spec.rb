describe Spaceship::Portal::Persons do
  before { Spaceship.login }
  it "should factor a new invite object" do
    created = 1_501_106_986_000
    expires = 1_503_705_599_000
    attrs = {
      "inviteId" => "A0B4C6D8EF",
      "recipientRole" => "ADMIN",
      "inviterName" => "Felix Krause",
      "dateCreated" => created,
      "recipientEmail" => "abl@g00gle.com",
      "dateExpires" => expires
    }
    invited = Spaceship::Portal::Invite.factory(attrs)
    # Roles are downcased to match Person
    expect(invited.type).to eq("admin")
    # Times are converted from timestamps to objects
    expect(invited.created).to eq(Time.at(created / 1000))
    expect(invited.expires).to eq(Time.at(expires / 1000))
  end
end
