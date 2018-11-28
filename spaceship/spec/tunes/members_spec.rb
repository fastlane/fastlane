describe Spaceship::Tunes::Members do
  before { Spaceship::Tunes.login }
  before { TunesStubbing.itc_stub_members }

  describe "members" do
    it "should return a list with members" do
      members = Spaceship::Members.all
      expect(members.length).to eq(3)
    end

    it "finds one member by email" do
      member = Spaceship::Members.find("helmut@januschka.com")
      expect(member.class).to eq(Spaceship::Tunes::Member)
      expect(member.email_address).to eq("helmut@januschka.com")
    end

    describe "creates a new member" do
      it "role: admin, apps: all" do
        Spaceship::Members.create!(firstname: "Helmut", lastname: "Januschka", email_address: "helmut@januschka.com")
      end

      it "role: developer apps: all" do
        Spaceship::Members.create!(firstname: "Helmut", lastname: "Januschka", email_address: "helmut@januschka.com", roles: ["developer"])
      end

      it "role: appmanager, apps: 898536088" do
        Spaceship::Members.create!(firstname: "Helmut", lastname: "Januschka", email_address: "helmut@januschka.com", roles: ["appmanager"], apps: ["898536088"])
      end
    end

    describe "updates roles and apps for an existing member" do
      it "role: admin, apps: all" do
        member = Spaceship::Members.find("helmut@januschka.com")
        Spaceship::Members.update_member_roles!(member, roles: [], apps: [])
      end

      it "role: developer apps: all" do
        member = Spaceship::Members.find("hjanuschka@gmail.com")
        Spaceship::Members.update_member_roles!(member, roles: ["developer"])
      end

      it "role: appmanager, apps: 898536088" do
        member = Spaceship::Members.find("hjanuschka+no-accept@gmail.com")
        Spaceship::Members.update_member_roles!(member, roles: ["appmanager"], apps: ["898536088"])
      end
    end
  end
end
