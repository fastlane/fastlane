describe "the spec guard against changing keychains" do
  it "refuses a security command that changes a keychain" do
    expect { Security::Keychain.set_search_list(["/a.keychain-db"]) }.to raise_error(/which changes the developer's keychains/)
    expect { Security::Certificate.import("/a.cer", keychain: "/a.keychain-db") }.to raise_error(/which changes the developer's keychains/)
  end

  it "refuses one that takes a password, which the security gem sends to security -i on stdin" do
    expect { Security::Keychain.new("/a.keychain-db").unlock("p4ss word") }.to raise_error(/which changes the developer's keychains/)
    expect { Security::InternetPassword.add("example.com", "user", "p4ss") }.to raise_error(/which changes the developer's keychains/)
  end

  it "decodes profiles without security" do
    profile = "./match/spec/fixtures/test.mobileprovision"
    expect(Security::Command).not_to receive(:run)

    expect(FastlaneCore::ProvisioningProfile.parse(profile)["UUID"]).not_to be_empty
  end

  it "lets a read-only one through" do
    expect(Open3).to receive(:capture3).with(["security", "security"], "list-keychains", "-d", "user").and_return(["", "", double(success?: true)])

    expect(Security::Command.run("security", "list-keychains", "-d", "user").success?).to be(true)
  end
end
