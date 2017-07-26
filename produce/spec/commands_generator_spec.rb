require 'produce/commands_generator'
require 'produce/service'
require 'produce/group'
require 'produce/merchant'

describe Produce::CommandsGenerator do
  let(:available_options) { Produce::Options.available_options }

  describe ":create option handling" do
    it "can use the skip_itc short flag from tool options" do
      # leaving out the command name defaults to 'create'
      stub_commander_runner_args(['-i', 'true'])

      expected_options = FastlaneCore::Configuration.create(available_options, { skip_itc: true })

      expect(Produce::Manager).to receive(:start_producing)

      Produce::CommandsGenerator.start

      expect(Produce.config[:skip_itc]).to be(true)
    end

    it "can use the skip_devcenter flag from tool options" do
      # leaving out the command name defaults to 'create'
      stub_commander_runner_args(['--skip_devcenter', 'true'])

      expected_options = FastlaneCore::Configuration.create(available_options, { skip_devcenter: true })

      expect(Produce::Manager).to receive(:start_producing)

      Produce::CommandsGenerator.start

      expect(Produce.config[:skip_devcenter]).to be(true)
    end
  end

  describe ":enable_services option handling" do
    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['enable_services', '-u', 'me@it.com', '--healthkit'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })

      expect(Produce::Service).to receive(:enable) do |options, args|
        expect(options.healthkit).to be(true)
        expect(args).to eq([])
      end

      Produce::CommandsGenerator.start

      expect(Produce.config[:username]).to eq('me@it.com')
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['enable_services', '--app_identifier', 'your.awesome.App', '--game-center'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })

      expect(Produce::Service).to receive(:enable) do |options, args|
        expect(options.game_center).to be(true)
        expect(args).to eq([])
      end

      Produce::CommandsGenerator.start

      expect(Produce.config[:app_identifier]).to eq('your.awesome.App')
    end
  end

  describe ":disable_services option handling" do
    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['disable_services', '-u', 'me@it.com', '--healthkit'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })

      expect(Produce::Service).to receive(:disable) do |options, args|
        expect(options.healthkit).to be(true)
        expect(args).to eq([])
      end

      Produce::CommandsGenerator.start

      expect(Produce.config[:username]).to eq('me@it.com')
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['disable_services', '--app_identifier', 'your.awesome.App', '--game-center'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })

      expect(Produce::Service).to receive(:disable) do |options, args|
        expect(options.game_center).to be(true)
        expect(args).to eq([])
      end

      Produce::CommandsGenerator.start

      expect(Produce.config[:app_identifier]).to eq('your.awesome.App')
    end
  end

  describe ":group option handling" do
    def expect_group_create_with(group_name, group_identifier)
      fake_group = "fake_group"
      expect(Produce::Group).to receive(:new).and_return(fake_group)
      expect(fake_group).to receive(:create) do |options, args|
        expect(options.group_name).to eq(group_name)
        expect(options.group_identifier).to eq(group_identifier)
        expect(args).to eq([])
      end
    end

    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['group', '-u', 'me@it.com', '-g', 'group.example.app', '-n', 'Example App Group'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })

      expect_group_create_with('Example App Group', 'group.example.app')

      Produce::CommandsGenerator.start

      expect(Produce.config[:username]).to eq('me@it.com')
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['group', '--app_identifier', 'your.awesome.App', '-g', 'group.example.app', '-n', 'Example App Group'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })

      expect_group_create_with('Example App Group', 'group.example.app')

      Produce::CommandsGenerator.start

      expect(Produce.config[:app_identifier]).to eq('your.awesome.App')
    end
  end

  describe ":associate_group option handling" do
    def expect_group_associate_with(group_ids)
      fake_group = "fake_group"
      expect(Produce::Group).to receive(:new).and_return(fake_group)
      expect(fake_group).to receive(:associate) do |options, args|
        expect(args).to eq(group_ids)
      end
    end

    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['associate_group', '-u', 'me@it.com', 'group1.example.app', 'group2.example.app'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })

      expect_group_associate_with(['group1.example.app', 'group2.example.app'])

      Produce::CommandsGenerator.start

      expect(Produce.config[:username]).to eq('me@it.com')
    end

    it "can use the app_identifier flag from tool options" do
      stub_commander_runner_args(['associate_group', '--app_identifier', 'your.awesome.App', 'group1.example.app', 'group2.example.app'])

      expected_options = FastlaneCore::Configuration.create(available_options, { app_identifier: 'your.awesome.App' })

      expect_group_associate_with(['group1.example.app', 'group2.example.app'])

      Produce::CommandsGenerator.start

      expect(Produce.config[:app_identifier]).to eq('your.awesome.App')
    end
  end

  describe ":merchant option handling" do
    def expect_merchant_create_with(merchant_name, merchant_identifier)
      fake_merchant = "fake_merchant"
      expect(Produce::Merchant).to receive(:new).and_return(fake_merchant)
      expect(fake_merchant).to receive(:create) do |options, args|
        expect(options.merchant_name).to eq(merchant_name)
        expect(options.merchant_identifier).to eq(merchant_identifier)
        expect(args).to eq([])
      end
    end

    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['merchant', '-u', 'me@it.com', '-o', 'merchant.example.app.production', '-r', 'Example Merchant'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })

      expect_merchant_create_with('Example Merchant', 'merchant.example.app.production')

      Produce::CommandsGenerator.start

      expect(Produce.config[:username]).to eq('me@it.com')
    end
  end

  describe ":associate_merchant option handling" do
    def expect_merchant_associate_with(merchant_ids)
      fake_merchant = "fake_merchant"
      expect(Produce::Merchant).to receive(:new).and_return(fake_merchant)
      expect(fake_merchant).to receive(:associate) do |options, args|
        expect(args).to eq(merchant_ids)
      end
    end

    it "can associate multiple merchant identifiers" do
      stub_commander_runner_args(['associate_merchant', 'merchant.example.app.sandbox', 'merchant.example.app.production'])

      expect_merchant_associate_with(['merchant.example.app.sandbox', 'merchant.example.app.production'])

      Produce::CommandsGenerator.start
    end

    it "can use the username short flag from tool options" do
      stub_commander_runner_args(['associate_merchant', '-u', 'me@it.com', 'merchant.example.app.production'])

      expected_options = FastlaneCore::Configuration.create(available_options, { username: 'me@it.com' })

      expect_merchant_associate_with(['merchant.example.app.production'])

      Produce::CommandsGenerator.start

      expect(Produce.config[:username]).to eq('me@it.com')
    end
  end
end
