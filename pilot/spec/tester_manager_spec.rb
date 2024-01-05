require 'colored'

describe Pilot::TesterManager do
  describe "Manages adding/removing/displaying testers" do
    let(:tester_manager) { Pilot::TesterManager.new }

    let(:custom_tester_group) do
      Spaceship::ConnectAPI::BetaGroup.new("1", {
        name: "Test Group"
      })
    end

    let(:app_context_testers) do
      [
        Spaceship::ConnectAPI::BetaTester.new("1", {
          firstName: 'First',
          lastName: 'Last',
          email: 'my@email.addr',
          betaGroups: [custom_tester_group]
        }),
        Spaceship::ConnectAPI::BetaTester.new("2", {
          firstName: 'Fabricio',
          lastName: 'Devtoolio',
          email: 'fabric-devtools@gmail.com',
          betaGroups: [custom_tester_group]
        })
      ]
    end

    let(:current_user) do
      Spaceship::Tunes::Member.new({ "firstname" => "Josh",
                           "lastname" => "Liebowitz",
                           "email_address" => "taquitos+nospam@gmail.com" })
    end

    let(:fake_tester) do
      Spaceship::ConnectAPI::BetaTester.new("1", {
        firstName: 'fake',
        lastName: 'tester',
        email: 'fabric-devtools@gmail.com+fake@gmail.com'
      })
    end

    let(:default_add_tester_options) do
      FastlaneCore::Configuration.create(Pilot::Options.available_options, {
        apple_id: '123456789',
        email: fake_tester.email,
        first_name: fake_tester.first_name,
        last_name: fake_tester.last_name
      })
    end

    let(:remove_tester_options) do
      FastlaneCore::Configuration.create(Pilot::Options.available_options, {
        apple_id: '123456789',
        email: fake_tester.email,
        first_name: fake_tester.first_name,
        last_name: fake_tester.last_name
      })
    end

    let(:default_add_tester_options_with_group) do
      FastlaneCore::Configuration.create(Pilot::Options.available_options, {
        apple_id: '123456789',
        email: fake_tester.email,
        first_name: fake_tester.first_name,
        last_name: fake_tester.last_name,
        groups: ["Test Group"]
      })
    end

    let(:fake_app) { "fake_app_object" }
    let(:fake_app_name) { "My Fake App" }

    let(:fake_client) { "fake client" }

    before(:each) do
      allow(fake_app).to receive(:apple_id).and_return("123456789")
      allow(fake_app).to receive(:name).and_return(fake_app_name)
      allow(Spaceship::ConnectAPI::App).to receive(:get).and_return(fake_app)
      allow(Spaceship::ConnectAPI::App).to receive(:find).and_return(fake_app)
      allow(Spaceship::Tunes).to receive(:client).and_return(fake_client)

      allow(tester_manager).to receive(:login) # prevent attempting to log in with iTC
      allow(fake_client).to receive(:user).and_return(current_user)
      allow(fake_client).to receive(:user_email).and_return("taquitos@fastlane.tools")
      allow(fake_client).to receive(:team_id).and_return("1234")
    end

    describe "when invoked from the context of an app" do
      it "prints a table without columns showing device and version info" do
        allow(fake_app).to receive(:get_beta_testers).and_return(app_context_testers)

        headings = ["First", "Last", "Email", "Groups"]
        rows = app_context_testers.map do |tester|
          [tester.first_name, tester.last_name, tester.email, tester.beta_groups.map(&:name).join(";")]
        end

        expect(Terminal::Table).to receive(:new).with(title: "All Testers (2)".green,
                                                   headings: headings,
                                                       rows: rows)

        tester_manager.list_testers(app_identifier: 'com.whatever')
      end
    end

    describe "when asked to invite a new tester to a specific existing custom group" do
      it "creates a new tester and adds it to the default group" do
        allow(tester_manager).to receive(:find_app_tester).and_return(fake_tester)
        allow(fake_app).to receive(:get_beta_groups).and_return([custom_tester_group])

        expect(custom_tester_group).to receive(:post_bulk_beta_tester_assignments)

        groups = [custom_tester_group]
        group_names = groups.map(&:name).join(';')
        expect(FastlaneCore::UI).to receive(:success).with("Successfully added tester #{fake_tester.email} to app #{fake_app_name} in group(s) #{group_names}")

        tester_manager.add_tester(default_add_tester_options_with_group)
      end
    end

    describe "when external tester is removed" do
      it "removes the tester without error" do
        allow(tester_manager).to receive(:find_app_tester).and_return(fake_tester)
        allow(fake_app).to receive(:get_beta_groups).and_return([custom_tester_group])

        expect(fake_tester).to receive(:delete_from_apps)

        expect(FastlaneCore::UI).to receive(:success).with("Successfully removed tester fabric-devtools@gmail.com+fake@gmail.com from app: #{fake_app_name}")

        tester_manager.remove_tester(remove_tester_options)
      end
    end
  end
end
