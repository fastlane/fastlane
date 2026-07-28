describe Spaceship::Tunes::Members do
  include_examples "common spaceship login"
  before { TunesStubbing.itc_stub_members }
  let(:client) { Spaceship::AppVersion.client }

  describe "Member Object" do
    it "parses selected apps" do
      member = Spaceship::Members.find("helmut@januschka.com")
      expect(member.has_all_apps).to eq(true)

      member = Spaceship::Members.find("hjanuschka+no-accept@gmail.com")
      expect(member.has_all_apps).to eq(false)
      expect(member.selected_apps.find { |a| a.apple_id == "898536088" }.name).to eq("App Name 1")
    end

    it "checks if invitation is accepted" do
      member = Spaceship::Members.find("hjanuschka+no-accept@gmail.com")
      expect(member.not_accepted_invitation).to eq(true)
    end

    it "parses currency" do
      member = Spaceship::Members.find("hjanuschka+no-accept@gmail.com")
      expect(member.preferred_currency).to eq({ name: "Euro", code: "EUR", country: "Austria", country_code: "AUT" })
    end

    it "parses roles" do
      member = Spaceship::Members.find("helmut@januschka.com")
      expect(member.roles).to eq(["legal", "admin"])
    end

    it "finds one member by email" do
      member = Spaceship::Members.find("helmut@januschka.com")
      expect(member.class).to eq(Spaceship::Tunes::Member)
      expect(member.email_address).to eq("helmut@januschka.com")
    end

    it "resends invitation" do
      member = Spaceship::Members.find("helmut@januschka.com")
      expect(client).to receive(:reinvite_member).with("helmut@januschka.com")
      member.resend_invitation
    end

    it "deletes a member" do
      member = Spaceship::Members.find("helmut@januschka.com")
      expect(client).to receive(:delete_member!).with("283226505", "helmut@januschka.com")
      member.delete!
    end

    describe "creates a new member" do
      it "role: admin, apps: all" do
        Spaceship::Members.create!(firstname: "Helmut", lastname: "Januschka", email_address: "helmut@januschka.com")
      end

      it "role: developer apps: all" do
        Spaceship::Members.create!(firstname: "Helmut", lastname: "Januschka", email_address: "helmut@januschka.com", roles: ["developer"])
      end

      it "role: appmanager, apps: 12344444" do
        Spaceship::Members.create!(firstname: "Helmut", lastname: "Januschka", email_address: "helmut@januschka.com", roles: ["appmanager"], apps: ["898536088"])
      end
    end
  end
end
