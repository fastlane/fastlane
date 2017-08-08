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

  it "should be OK if invite date format changes" do
    created = "Wed Aug  2 23:24:08 PDT 2017"
    expires = 1_503_705_599
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
    # If a time field isn't a number, it should be passed through as-is
    expect(invited.created).to eq(created)
    # If Apple changes time precision the output will be useless but this is
    # unlikely; other time-centric fields use string formatted times but all
    # numeric timestamps have the same precision.
    expect(invited.expires).to eq(Time.at(expires / 1000))
  end
end
