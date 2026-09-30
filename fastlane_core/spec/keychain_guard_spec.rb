describe "the spec guard against changing keychains" do
  it "refuses a security command that changes a keychain" do
    expect { Security::Keychain.set_search_list(["/a.keychain-db"]) }.to raise_error(/which changes the developer's keychains/)
    expect { Security::Certificate.import("/a.cer", keychain: "/a.keychain-db") }.to raise_error(/which changes the developer's keychains/)
  end

  it "decodes profiles without security" do
    profile = "./match/spec/fixtures/test.mobileprovision"
    expect(Security::Command).not_to receive(:run)

    expect(FastlaneCore::ProvisioningProfile.parse(profile)["UUID"]).not_to be_empty
  end

  it "refuses to decode a profile with security" do
    allow(Security::ProvisioningProfile).to receive(:decode).and_call_original

    expect { Security::ProvisioningProfile.decode("/a.mobileprovision", keychain: "/a.keychain-db") }.to raise_error(/which changes the developer's keychains/)
  end

  it "lets a read-only one through" do
    expect(Open3).to receive(:capture3).with(["security", "security"], "list-keychains", "-d", "user").and_return(["", "", double(success?: true)])

    expect(Security::Command.run("security", "list-keychains", "-d", "user").success?).to be(true)
  end
end
