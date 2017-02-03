require 'colored'
require 'ostruct'

describe Pilot::TesterManager do
  describe "prints tester lists" do
    let(:global_testers) do
      [
        OpenStruct.new(
          first_name: 'First',
          last_name: 'Last',
          email: 'my@email.addr',
          groups: ['testers'],
          devices: ["d"],
          full_version: '1.0 (21)',
          pretty_install_date: '2016-01-01',
          something_else: 'blah'
        ),
        OpenStruct.new(
          first_name: 'Fabricio',
          last_name: 'Devtoolio',
          email: 'fabric-devtools@gmail.com',
          groups: ['testers'],
          devices: ["d", "d2"],
          full_version: '1.1 (22)',
          pretty_install_date: '2016-02-02',
          something_else: 'blah'
        )
      ]
    end

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

    let(:tester_manager) { Pilot::TesterManager.new }

    let(:fake_app) { "fake_app_object" }

    before(:each) do
      allow(fake_app).to receive(:apple_id).and_return("whatever")
      allow(Spaceship::Application).to receive(:find).and_return(fake_app)
      allow(tester_manager).to receive(:login) # prevent attempting to log in with iTC
    end

    describe "when invoked from a global context" do
      it "prints a table with columns including device and version info" do
        allow(Spaceship::Tunes::Tester::Internal).to receive(:all).and_return(global_testers)
        allow(Spaceship::Tunes::Tester::External).to receive(:all).and_return(global_testers)

        headings = ["First", "Last", "Email", "Groups", "Devices", "Latest Version", "Latest Install Date"]
        rows = global_testers.map do |tester|
          [
            tester.first_name,
            tester.last_name,
            tester.email,
            tester.group_names,
            tester.devices.count,
            tester.full_version,
            tester.pretty_install_date
          ]
        end

        expect(Terminal::Table).to receive(:new).with(title: "Internal Testers".green,
                                                   headings: headings,
                                                       rows: rows)
        expect(Terminal::Table).to receive(:new).with(title: "External Testers".green,
                                                   headings: headings,
                                                       rows: rows)

        tester_manager.list_testers({})
      end
    end

    describe "when invoked from the context of an app" do
      it "prints a table without columns showing device and version info" do
        allow(Spaceship::Tunes::Tester::Internal).to receive(:all_by_app).and_return(app_context_testers)
        allow(Spaceship::Tunes::Tester::External).to receive(:all_by_app).and_return(app_context_testers)

        headings = ["First", "Last", "Email", "Groups"]
        rows = app_context_testers.map do |tester|
          [tester.first_name, tester.last_name, tester.email, tester.group_names]
        end

        expect(Terminal::Table).to receive(:new).with(title: "Internal Testers".green,
                                                   headings: headings,
                                                       rows: rows)
        expect(Terminal::Table).to receive(:new).with(title: "External Testers".green,
                                                   headings: headings,
                                                       rows: rows)

        tester_manager.list_testers(app_identifier: 'com.whatever')
      end
    end
  end
end
