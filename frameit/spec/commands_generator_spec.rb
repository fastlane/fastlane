require 'frameit/commands_generator'

describe Frameit::CommandsGenerator do
  def expect_runner_run
    fake_runner = "runner"
    expect(Frameit::Runner).to receive(:new).and_return(fake_runner)
    expect(fake_runner).to receive(:run)
  end

  describe ":run options handling" do
    it "can use the use_legacy_iphone5s flag from tool options" do
      # leaving out the command name defaults to 'run'
      stub_commander_runner_args(['--use_legacy_iphone5s', 'true'])
      expect_runner_run
      Frameit::CommandsGenerator.start
      expect(Frameit.config[:use_legacy_iphone5s]).to be(true)
    end
  end

  describe ":silver options handling" do
    it "can use the use_legacy_iphone5s flag from tool options" do
      stub_commander_runner_args(['silver', '--use_legacy_iphone5s', 'true'])
      expect_runner_run
      Frameit::CommandsGenerator.start
      expect(Frameit.config[:use_legacy_iphone5s]).to be(true)
    end
  end

  describe ":gold options handling" do
    it "can use the use_legacy_iphone5s flag from tool options" do
      stub_commander_runner_args(['gold', '--use_legacy_iphone5s', 'true'])
      expect_runner_run
      Frameit::CommandsGenerator.start
      expect(Frameit.config[:use_legacy_iphone5s]).to be(true)
    end
  end

  describe ":rose_gold options handling" do
    it "can use the use_legacy_iphone5s flag from tool options" do
      stub_commander_runner_args(['rose_gold', '--use_legacy_iphone5s', 'true'])
      expect_runner_run
      Frameit::CommandsGenerator.start
      expect(Frameit.config[:use_legacy_iphone5s]).to be(true)
    end
  end

  # :setup and :download_frames are not tested here because they do not use any
  # tool options.
end
