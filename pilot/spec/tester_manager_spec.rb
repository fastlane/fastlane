require 'colored'
require 'ostruct'

describe Pilot::TesterManager do
  describe "Manages adding/removing/displaying testers" do
    let(:tester_manager) { Pilot::TesterManager.new }

    let(:app_context_testers) do
      [
        OpenStruct.new(
          first_name: 'First',
          last_name: 'Last',
          email: 'my@email.addr',
          something_else: 'blah'
        ),
        OpenStruct.new(
          first_name: 'Fabricio',
          last_name: 'Devtoolio',
          email: 'fabric-devtools@gmail.com',
          something_else: 'blah'
        )
      ]
    end

    let(:custom_tester_group) do
      OpenStruct.new(
        id: "CustomID",
        name: "Test Group",
        is_internal_group: false,
        app_id: "com.whatever",
        is_default_external_group: false
      )
    end

    let(:current_user) do
      Spaceship::Tunes::Member.new({ "firstname" => "Josh",
                           "lastname" => "Liebowitz",
                           "email_address" => "taquitos+nospam@gmail.com" })
    end

    let(:fake_tester) do
      OpenStruct.new(
        first_name: 'fake',
        last_name: 'tester',
        email: 'fabric-devtools@gmail.com+fake@gmail.com'
      )
    end

    let(:default_add_tester_options) do
      FastlaneCore::Configuration.create(Pilot::Options.available_options, {
        apple_id: 'com.whatever',
        email: fake_tester.email,
        first_name: fake_tester.first_name,
        last_name: fake_tester.last_name
      })
    end

    let(:remove_tester_options) do
      FastlaneCore::Configuration.create(Pilot::Options.available_options, {
        email: fake_tester.email,
        first_name: fake_tester.first_name,
        last_name: fake_tester.last_name
      })
    end

    let(:default_add_tester_options_with_group) do
      FastlaneCore::Configuration.create(Pilot::Options.available_options, {
        apple_id: 'com.whatever',
        email: fake_tester.email,
        first_name: fake_tester.first_name,
        last_name: fake_tester.last_name,
        groups: ["Test Group"]
      })
    end

    let(:fake_app) { "fake_app_object" }

    let(:fake_client) { "fake client" }

    before(:each) do
      allow(fake_app).to receive(:apple_id).and_return("com.whatever")
      allow(fake_app).to receive(:name).and_return("My Fake App")
      allow(Spaceship::Application).to receive(:find).and_return(fake_app)
      allow(Spaceship::Tunes).to receive(:client).and_return(fake_client)
      allow(Spaceship::Members).to receive(:find).and_return(current_user)

      allow(tester_manager).to receive(:login) # prevent attempting to log in with iTC
      allow(fake_client).to receive(:user).and_return(current_user)
      allow(fake_client).to receive(:user_email).and_return("taquitos@fastlane.tools")
      allow(fake_client).to receive(:team_id).and_return("1234")
    end

    describe "when invoked from the context of an app" do
      it "prints a table without columns showing device and version info" do
        allow(Spaceship::TestFlight::Tester).to receive(:all).and_return(app_context_testers)

        headings = ["First", "Last", "Email", "Groups"]
        rows = app_context_testers.map do |tester|
          [tester.first_name, tester.last_name, tester.email, tester.group_names]
        end

        expect(Terminal::Table).to receive(:new).with(title: "All Testers (2)".green,
                                                   headings: headings,
                                                       rows: rows)

        tester_manager.list_testers(app_identifier: 'com.whatever')
      end
    end

    describe "when admin asks to create new tester to a specific existing custom group" do
      it "creates a new tester and adds it to the default group" do
        allow(current_user).to receive(:roles).and_return(["admin"])
        allow(tester_manager).to receive(:find_app_tester).and_return(fake_tester)

        expect(Spaceship::TestFlight::Tester).to_not(receive(:create!))
        expect(Spaceship::TestFlight::Group).to receive(:add_tester_to_groups!).and_return([custom_tester_group])
        expect(FastlaneCore::UI).to receive(:success).with('Successfully added tester to group(s): Test Group in app: My Fake App')

        tester_manager.add_tester(default_add_tester_options_with_group)
      end
    end

    describe "when asked to add an existing external tester to a specific existing custom group" do
      it "adds the tester to the custom group" do
        allow(current_user).to receive(:roles).and_return(["appmanager"])
        allow(tester_manager).to receive(:find_app_tester).and_return(fake_tester)

        expect(Spaceship::TestFlight::Tester).to_not(receive(:create_app_level_tester))
        expect(Spaceship::TestFlight::Group).to receive(:add_tester_to_groups!).and_return([custom_tester_group])
        expect(FastlaneCore::UI).to receive(:success).with('Successfully added tester to group(s): Test Group in app: My Fake App')

        tester_manager.add_tester(default_add_tester_options_with_group)
      end
    end

    describe "when asked to add an existing internal tester to a specific existing custom group" do
      it "adds the tester to the custom group" do
        allow(current_user).to receive(:roles).and_return(["appmanager"])

        expect(Spaceship::TestFlight::Tester).to receive(:find).and_return(fake_tester)
        expect(Spaceship::TestFlight::Tester).to_not(receive(:create_app_level_tester))
        expect(Spaceship::TestFlight::Group).to receive(:add_tester_to_groups!).and_return([custom_tester_group])
        expect(FastlaneCore::UI).to receive(:success).with('Found existing tester fabric-devtools@gmail.com+fake@gmail.com')
        expect(FastlaneCore::UI).to receive(:success).with('Successfully added tester to group(s): Test Group in app: My Fake App')

        tester_manager.add_tester(default_add_tester_options_with_group)
      end
    end

    describe "when app manager asks to add an existing external tester to a specific existing custom group" do
      it "adds the tester without calling create" do
        allow(current_user).to receive(:roles).and_return(["appmanager"])
        allow(tester_manager).to receive(:find_app_tester).and_return(fake_tester)

        expect(Spaceship::TestFlight::Tester).to_not(receive(:create_app_level_tester))
        expect(Spaceship::TestFlight::Group).to receive(:add_tester_to_groups!).and_return([custom_tester_group])
        expect(FastlaneCore::UI).to receive(:success).with('Successfully added tester to group(s): Test Group in app: My Fake App')

        tester_manager.add_tester(default_add_tester_options_with_group)
      end
    end

    describe "when external tester is removed without providing app" do
      it "removes the tester without error" do
        allow(current_user).to receive(:roles).and_return(["admin"])
        allow(Spaceship::Application).to receive(:find).and_return(nil)
        allow(tester_manager).to receive(:find_app).and_return(nil)

        expect(Spaceship::TestFlight::Tester).to receive(:find).and_return(fake_tester)
        expect(Spaceship::TestFlight::Group).to_not(receive(:remove_tester_from_groups!))
        expect(FastlaneCore::UI).to receive(:success).with('Found existing tester fabric-devtools@gmail.com+fake@gmail.com')
        expect(FastlaneCore::UI).to receive(:success).with('Successfully removed tester fabric-devtools@gmail.com+fake@gmail.com from Users and Roles')

        tester_manager.remove_tester(remove_tester_options)
      end
    end
  end
end
