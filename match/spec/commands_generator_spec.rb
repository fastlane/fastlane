require 'match/commands_generator'

describe Match::CommandsGenerator do
  let(:available_options) { Match::Options.available_options }

  def expect_runner_run_with(expected_options)
    fake_runner = "runner"
    expect(Match::Runner).to receive(:new).and_return(fake_runner)
    expect(fake_runner).to receive(:run) do |actual_options|
      expect(expected_options._values).to eq(actual_options._values)
    end
  end

  Match.environments.each do |env|
    describe ":#{env} option handling" do
      it "can use the git_url short flag from tool options" do
        stub_commander_runner_args([env, '-r', 'git@github.com:you/your_repo.git'])

        expected_options = FastlaneCore::Configuration.create(available_options, {
          git_url: 'git@github.com:you/your_repo.git',
          type: env
        })

        expect_runner_run_with(expected_options)

        Match::CommandsGenerator.start
      end

      it "can use the git_branch flag from tool options" do
        stub_commander_runner_args([env, '--git_branch', 'my-branch'])

        expected_options = FastlaneCore::Configuration.create(available_options, {
          git_branch: 'my-branch',
          type: env
        })

        expect_runner_run_with(expected_options)

        Match::CommandsGenerator.start
      end
    end
  end

  describe ":change_password option handling" do
    def expect_change_password_with(expected_options)
      expect(Match::ChangePassword).to receive(:update) do |args|
        expect(args[:params]._values).to eq(expected_options._values)
      end
      expect(FastlaneCore::UI).to receive(:success).with(/Successfully changed the password./)
    end

    it "can use the git_url short flag from tool options" do
      stub_commander_runner_args(['change_password', '-r', 'git@github.com:you/your_repo.git'])

      expected_options = FastlaneCore::Configuration.create(available_options, { git_url: 'git@github.com:you/your_repo.git' })

      expect_change_password_with(expected_options)

      Match::CommandsGenerator.start
    end

    it "can use the shallow_clone flag from tool options" do
      stub_commander_runner_args(['change_password', '--shallow_clone', 'true'])

      expected_options = FastlaneCore::Configuration.create(available_options, { shallow_clone: true })

      expect_change_password_with(expected_options)

      Match::CommandsGenerator.start
    end
  end

  describe ":decrypt option handling" do
    def expect_githelper_clone_with(git_url, shallow_clone, git_branch)
      fake_storage = "fake_storage"
      fake_working_directory = "fake_working_directory"
      fake_encryption = "fake_encryption"

      expect(Match::Storage::GitStorage).to receive(:configure).with({
        git_url: git_url,
        shallow_clone: shallow_clone,
        skip_docs: false,
        git_branch: git_branch[:branch],
        clone_branch_directly: git_branch[:clone_branch_directly],
        git_full_name: nil,
        git_user_email: nil,

        git_private_key: nil,
        git_basic_authorization: nil,
        git_bearer_authorization: nil,

        type: "development",
        platform: "ios"
      }).and_return(fake_storage)

      expect(fake_storage).to receive(:download)
      allow(fake_storage).to receive(:working_directory).and_return(fake_working_directory)
      allow(fake_storage).to receive(:keychain_name).and_return("https://github.com/fastlane/certs")

      expect(Match::Encryption).to receive(:for_storage_mode).with("git", {
        git_url: git_url,
        s3_bucket: nil,
        s3_skip_encryption: false,
        working_directory: fake_working_directory
      }).and_return(fake_encryption)

      expect(fake_encryption).to receive(:decrypt_files)
      expect(FastlaneCore::UI).to receive(:success).with("Repo is at: '#{fake_working_directory}'")
    end

    it "can use the git_url short flag from tool options" do
      stub_const('ENV', { 'MATCH_PASSWORD' => '' })
      stub_commander_runner_args(['decrypt', '-r', 'git@github.com:you/your_repo.git'])

      expect_githelper_clone_with('git@github.com:you/your_repo.git', false, { branch: 'master', clone_branch_directly: false })

      Match::CommandsGenerator.start
    end

    it "can use the shallow_clone flag from tool options" do
      stub_const('ENV', { 'MATCH_PASSWORD' => '' })
      stub_commander_runner_args(['decrypt', '-r', 'git@github.com:you/your_repo.git', '--shallow_clone', 'true'])

      expect_githelper_clone_with('git@github.com:you/your_repo.git', true, { branch: 'master', clone_branch_directly: false })

      Match::CommandsGenerator.start
    end
  end

  describe ":import option handling" do
    let(:fake_match_importer) { double("fake match_importer") }

    before(:each) do
      allow(Match::Importer).to receive(:new).and_return(fake_match_importer)
    end

    def expect_import_with(expected_options)
      expect(fake_match_importer).to receive(:import_cert) do |actual_options|
        expect(actual_options._values).to eq(expected_options._values)
      end
    end

    it "can use the git_url short flag from tool options" do
      stub_commander_runner_args(['import', '-r', 'git@github.com:you/your_repo.git'])

      expected_options = FastlaneCore::Configuration.create(available_options, { git_url: 'git@github.com:you/your_repo.git' })

      expect_import_with(expected_options)

      Match::CommandsGenerator.start
    end
  end

  def expect_nuke_run_with(expected_options, type)
    fake_nuke = "nuke"
    expect(Match::Nuke).to receive(:new).and_return(fake_nuke)
    expect(fake_nuke).to receive(:run) do |actual_options, args|
      expect(actual_options._values).to eq(expected_options._values)
      expect(args[:type]).to eq(type)
    end
  end

  ["development", "distribution"].each do |type|
    describe "nuke #{type} option handling" do
      it "can use the git_url short flag from tool options" do
        stub_commander_runner_args(['nuke', type, '-r', 'git@github.com:you/your_repo.git'])

        expected_options = FastlaneCore::Configuration.create(available_options, { git_url: 'git@github.com:you/your_repo.git' })

        expect_nuke_run_with(expected_options, type)

        Match::CommandsGenerator.start
      end

      it "can use the git_branch flag from tool options" do
        # leaving out the command name defaults to 'run'
        stub_commander_runner_args(['nuke', type, '--git_branch', 'my-branch'])

        expected_options = FastlaneCore::Configuration.create(available_options, { git_branch: 'my-branch' })

        expect_nuke_run_with(expected_options, type)

        Match::CommandsGenerator.start
      end
    end
  end

  # :init is not tested here because it does not use any tool options
end
