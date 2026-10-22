require 'colored'

describe Pilot::TesterManager do
  describe "Manages adding/removing/displaying testers" do
    let(:tester_manager) { Pilot::TesterManager.new }

    let(:custom_tester_group) do
      Spaceship::ConnectAPI::BetaGroup.new("1", {
        name: "Test Group"
      })
    end

    let(:second_tester_group) do
      Spaceship::ConnectAPI::BetaGroup.new("2", {
        name: "Second Group"
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
        email: 'fabric-devtools@gmail.com+fake@gmail.com',
        betaGroups: [custom_tester_group, second_tester_group]
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
        groups: ["Test Group", second_tester_group.id]
      })
    end

    let(:fake_app) { "fake_app_object" }
    let(:fake_app_name) { "My Fake App" }

    let(:fake_client) { "fake client" }

    let(:api_token) { instance_double(Spaceship::ConnectAPI::Token) }
    let(:groups) { [custom_tester_group, second_tester_group] }

    before(:each) do
      allow(Spaceship::ConnectAPI).to receive(:token).and_return(nil)
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

    describe "when asked to invite a new tester to specific existing custom groups" do
      it "creates a new tester and adds it to the default groups" do
        allow(tester_manager).to receive(:find_app_tester).and_return(fake_tester)
        allow(fake_app).to receive(:get_beta_groups).and_return([custom_tester_group, second_tester_group])

        expect(custom_tester_group).to receive(:post_bulk_beta_tester_assignments)
        expect(second_tester_group).to receive(:post_bulk_beta_tester_assignments)

        group_names = [custom_tester_group.name, second_tester_group.id].join(';')
        expect(FastlaneCore::UI).to receive(:success).with("Successfully added tester #{fake_tester.email} to app #{fake_app_name} in group(s) #{group_names}")

        tester_manager.add_tester(default_add_tester_options_with_group)
      end
    end

    describe "when asked to add a tester with Apple ID login" do
      it "sends no request when no group matches" do
        allow(fake_app).to receive(:get_beta_groups).and_return(groups)
        options = FastlaneCore::Configuration.create(Pilot::Options.available_options, {
          apple_id: '123456789',
          email: fake_tester.email,
          groups: ["Unknown Group"]
        })

        expect(custom_tester_group).not_to receive(:post_bulk_beta_tester_assignments)
        expect(second_tester_group).not_to receive(:post_bulk_beta_tester_assignments)
        expect(FastlaneCore::UI).to receive(:success).with("Successfully added tester #{fake_tester.email} to app #{fake_app_name} in group(s) Unknown Group")

        tester_manager.add_tester(options)
      end
    end

    describe "when asked to add a tester with an App Store Connect API key" do
      let(:matching_groups_param) { ["Test Group", "2"] }

      def add_tester_options(extra)
        FastlaneCore::Configuration.create(Pilot::Options.available_options, {
          apple_id: '123456789',
          email: fake_tester.email
        }.merge(extra))
      end

      def expect_success_message(groups_param)
        expect(FastlaneCore::UI).to receive(:success).with("Successfully added tester #{fake_tester.email} to app #{fake_app_name} in group(s) #{groups_param.join(';')}")
      end

      before(:each) do
        allow(Spaceship::ConnectAPI).to receive(:token).and_return(api_token)
        allow(fake_app).to receive(:get_beta_groups).and_return(groups)
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:find).with(email: fake_tester.email, includes: "betaGroups").and_return(nil)
      end

      it "creates a new tester in all matched groups with one request" do
        expect(Spaceship::ConnectAPI).to receive(:post_beta_tester_assignment).with(beta_group_ids: ["1", "2"], attributes: { email: fake_tester.email, firstName: "fake", lastName: "tester" })
        expect(custom_tester_group).not_to receive(:post_bulk_beta_tester_assignments)
        expect(second_tester_group).not_to receive(:post_bulk_beta_tester_assignments)
        expect_success_message(["Test Group", second_tester_group.id])

        tester_manager.add_tester(default_add_tester_options_with_group)
      end

      it "leaves out names that are not set" do
        expect(Spaceship::ConnectAPI).to receive(:post_beta_tester_assignment).with(beta_group_ids: ["1", "2"], attributes: { email: fake_tester.email })
        expect_success_message(matching_groups_param)

        tester_manager.add_tester(add_tester_options(groups: matching_groups_param))
      end

      it "sends only the name that is set" do
        expect(Spaceship::ConnectAPI).to receive(:post_beta_tester_assignment).with(beta_group_ids: ["1", "2"], attributes: { email: fake_tester.email, firstName: "fake" })
        expect_success_message(matching_groups_param)

        tester_manager.add_tester(add_tester_options(groups: matching_groups_param, first_name: "fake"))
      end

      it "adds an existing tester to each matched group they are not in" do
        existing = Spaceship::ConnectAPI::BetaTester.new("42", { email: fake_tester.email, betaGroups: [] })
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:find).with(email: fake_tester.email, includes: "betaGroups").and_return(existing)

        expect(custom_tester_group).to receive(:add_beta_testers).with(beta_tester_ids: ["42"])
        expect(second_tester_group).to receive(:add_beta_testers).with(beta_tester_ids: ["42"])
        expect(Spaceship::ConnectAPI).not_to receive(:post_beta_tester_assignment)
        expect_success_message(matching_groups_param)

        tester_manager.add_tester(add_tester_options(groups: matching_groups_param))
      end

      it "adds an existing tester only to the matched group they are not in" do
        member_of = Spaceship::ConnectAPI::BetaGroup.new("1", { name: "Test Group" })
        existing = Spaceship::ConnectAPI::BetaTester.new("42", { email: fake_tester.email, betaGroups: [member_of] })
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:find).with(email: fake_tester.email, includes: "betaGroups").and_return(existing)

        expect(custom_tester_group).not_to receive(:add_beta_testers)
        expect(second_tester_group).to receive(:add_beta_testers).with(beta_tester_ids: ["42"])
        expect_success_message(matching_groups_param)

        tester_manager.add_tester(add_tester_options(groups: matching_groups_param))
      end

      it "sends no request when an existing tester is in every matched group" do
        member_of = [
          Spaceship::ConnectAPI::BetaGroup.new("1", { name: "Test Group" }),
          Spaceship::ConnectAPI::BetaGroup.new("2", { name: "Second Group" })
        ]
        existing = Spaceship::ConnectAPI::BetaTester.new("42", { email: fake_tester.email, betaGroups: member_of })
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:find).with(email: fake_tester.email, includes: "betaGroups").and_return(existing)

        expect(custom_tester_group).not_to receive(:add_beta_testers)
        expect(second_tester_group).not_to receive(:add_beta_testers)
        expect(Spaceship::ConnectAPI).not_to receive(:post_beta_tester_assignment)
        expect_success_message(matching_groups_param)

        tester_manager.add_tester(add_tester_options(groups: matching_groups_param))
      end

      it "treats missing group membership as no groups" do
        existing = Spaceship::ConnectAPI::BetaTester.new("42", { email: fake_tester.email })
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:find).with(email: fake_tester.email, includes: "betaGroups").and_return(existing)

        expect(custom_tester_group).to receive(:add_beta_testers).with(beta_tester_ids: ["42"])
        expect(second_tester_group).to receive(:add_beta_testers).with(beta_tester_ids: ["42"])
        expect_success_message(matching_groups_param)

        tester_manager.add_tester(add_tester_options(groups: matching_groups_param))
      end

      it "sends no request when no group matches" do
        expect(Spaceship::ConnectAPI::BetaTester).not_to receive(:find)
        expect(Spaceship::ConnectAPI).not_to receive(:post_beta_tester_assignment)
        expect(custom_tester_group).not_to receive(:post_bulk_beta_tester_assignments)
        expect(second_tester_group).not_to receive(:post_bulk_beta_tester_assignments)
        expect_success_message(["Unknown Group"])

        tester_manager.add_tester(add_tester_options(groups: ["Unknown Group"]))
      end

      it "lists a group named twice only once" do
        expect(Spaceship::ConnectAPI).to receive(:post_beta_tester_assignment).with(beta_group_ids: ["1"], attributes: { email: fake_tester.email })
        expect_success_message(["Test Group", "1"])

        tester_manager.add_tester(add_tester_options(groups: ["Test Group", "1"]))
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
