require 'deliver/availability'

describe Deliver::Availability do
  let(:all_territories) { ["AA", "BB", "CC", "DD", "EE", "FF"] }
  let(:tmpdir) { Dir.mktmpdir }

  describe "Create Availability" do
    describe "From territories" do
      it 'Sets all_available correctly' do
        config = Deliver::Availability.from_territories(all_territories, all_territories)

        expect(config.all_available).to be true
        expect(config.exclude).to eq([])
        expect(config.available).to eq([])
      end

      it 'Sets exclude correctly' do
        territories = ["AA", "BB", "CC", "DD"]
        config = Deliver::Availability.from_territories(territories, all_territories)

        expect(config.all_available).to be false
        expect(config.exclude).to eq(["EE", "FF"])
        expect(config.available).to eq([])
      end

      it 'Sets available correctly' do
        territories = ["AA", "BB", "CC"]
        config = Deliver::Availability.from_territories(territories, all_territories)

        expect(config.all_available).to be false
        expect(config.exclude).to eq([])
        expect(config.available).to eq(territories)
      end
    end

    let(:example_all_available) { true }
    let(:example_available) { ["AA", "BB"] }
    let(:example_exclude) { ["CC", "DD"] }

    describe "From territories YAML file" do
      let(:file_path) { File.join(tmpdir, "territories.yml") }

      def create_territories_file
        file_object = { available: example_available,
                        exclude: example_exclude,
                        all_available: example_all_available }

        File.write(file_path, file_object.to_yaml)
      end

      it "Parses file correctly" do
        create_territories_file

        config = Deliver::Availability.from_file(file_path)
        expect(config.all_available).to eq(example_all_available)
        expect(config.available).to eq(example_available)
        expect(config.exclude).to eq(example_exclude)
      end
    end

    describe "From options" do
      def create_options
        return { availability_all_territories: example_all_available,
                 availability_exclude_territories: example_exclude,
                 availability_territories: example_available }
      end

      it "Parses options correctly" do
        config = Deliver::Availability.from_options(create_options)
        expect(config.all_available).to eq(example_all_available)
        expect(config.available).to eq(example_available)
        expect(config.exclude).to eq(example_exclude)
      end

      it "Correct defaults" do
        config = Deliver::Availability.from_options({})
        expect(config.all_available).to eq(false)
        expect(config.available).to eq([])
        expect(config.exclude).to eq([])
      end
    end
  end

  describe "Validate availability options" do
    let(:example_all_available) { true }
    let(:example_available) { ["AA", "BB"] }
    let(:example_exclude) { ["CC", "DD"] }

    it "Warn of conflicting lists" do
      warning_message = "Both availbile and exclude lists provided, exlude list will be used only."
      expect(FastlaneCore::UI).to receive(:important).with(warning_message)
      config = Deliver::Availability.new(false, example_exclude, example_available)
      config.validate
    end

    let(:all_available_conflict_message) { "Availability_all_territories is true and list of territories provided, lists will be ignored." }

    it "Warn of conflicting exclude list" do
      expect(FastlaneCore::UI).to receive(:important).with(all_available_conflict_message)
      config = Deliver::Availability.new(true, example_exclude, [])
      config.validate
    end

    it "Warn of conflicting available list" do
      expect(FastlaneCore::UI).to receive(:important).with(all_available_conflict_message)
      config = Deliver::Availability.new(true, [], example_available)
      config.validate
    end

    it "Successfull validation with all_available option" do
      expect(FastlaneCore::UI).not_to receive(:important)
      config = Deliver::Availability.new(true, [], [])
      config.validate
    end

    it "Successfull validation with exclude list" do
      expect(FastlaneCore::UI).not_to receive(:important)
      config = Deliver::Availability.new(false, example_exclude, [])
      config.validate
    end

    it "Successfull validation with available list" do
      expect(FastlaneCore::UI).not_to receive(:important)
      config = Deliver::Availability.new(false, [], example_available)
      config.validate
    end
  end

  describe "Create list of territories from Availability" do
    it "Creates correctly from all_available" do
      config = Deliver::Availability.new(true, [], [])

      expect(config.territories(all_territories)).to eq(all_territories)
    end

    it "Creates correctly from exclude list" do
      exclude = ["EE", "FF"]
      config = Deliver::Availability.new(false, exclude, [])

      expected_territories = ["AA", "BB", "CC", "DD"]
      expect(config.territories(all_territories)).to eq(expected_territories)
    end

    it "Creates correctly from available list" do
      available = ["AA", "BB", "CC"]
      config = Deliver::Availability.new(false, [], available)

      expect(config.territories(all_territories)).to eq(available)
    end
  end

  describe "Save the current config to YAML file" do
    let(:all_available) { true }
    let(:available) { ["AA", "BB"] }
    let(:exclude) { ["CC", "DD"] }
    let(:file_path) { File.join(tmpdir, "territories.yml") }
    let(:config) { Deliver::Availability.new(all_available, exclude, available) }

    it "Saves correctly" do
      config.save_to_file(file_path)

      file_obj = YAML.load_file(file_path)
      expect(file_obj[:all_available]).to eq(all_available)
      expect(file_obj[:available]).to eq(available)
      expect(file_obj[:exclude]).to eq(exclude)
    end
  end
end
