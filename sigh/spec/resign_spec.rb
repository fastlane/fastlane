describe Sigh do
  describe Sigh::Resign do
    IDENTITY_1_NAME = "iPhone Developer: ed.belarus@gmail.com (ABCDEFGHIJ)"
    IDENTITY_1_SHA1 = "A123000000000000000BBBBBBBBBBBBBBBBBBBBB"
    IDENTITY_2_NAME = "iPhone Distribution: Some Company LLC  (F12345678F)"
    IDENTITY_2_SHA1 = "ACCCDDD123456789098765432101234567890987"
    IDENTITY_3_NAME = "iPhone Distribution: Some Company LLC  (F12345678F)"
    IDENTITY_3_SHA1 = "EB67FCBDDAEBBCE9767F6DC8654AF6ACDBDF875D"
    VALID_IDENTITIES_OUTPUT = "
1) #{IDENTITY_1_SHA1} \"#{IDENTITY_1_NAME}\"
2) #{IDENTITY_2_SHA1} \"#{IDENTITY_2_NAME}\"
3) #{IDENTITY_3_SHA1} \"#{IDENTITY_3_NAME}\"
   3 valid identities found"

    before do
      @resign = Sigh::Resign.new
    end

    it "Create provisioning options from hash" do
      tmp_path = Dir.mktmpdir
      provisioning_profiles = {
        "at.fastlane" => "#{tmp_path}/folder/mobile.mobileprovision",
        "at.fastlane.today" => "#{tmp_path}/folder/mobile.today.mobileprovision"
      }
      provisioning_options = @resign.create_provisioning_options(provisioning_profiles)
      expect(provisioning_options).to eq("-p at.fastlane=#{tmp_path}/folder/mobile.mobileprovision -p at.fastlane.today=#{tmp_path}/folder/mobile.today.mobileprovision")
    end

    it "Create provisioning options from array" do
      tmp_path = Dir.mktmpdir
      provisioning_profiles = ["#{tmp_path}/folder/mobile.mobileprovision"]
      provisioning_options = @resign.create_provisioning_options(provisioning_profiles)
      expect(provisioning_options).to eq("-p #{tmp_path}/folder/mobile.mobileprovision")
    end

    describe "version options" do
      def resign_command(version: nil, short_version: nil, bundle_version: nil)
        command = nil
        allow(@resign).to receive(:find_signing_identity).and_return(IDENTITY_1_SHA1)
        allow(@resign).to receive(:validate_params)
        allow(@resign).to receive(:puts)
        allow(@resign).to receive(:`) do |cmd|
          command = cmd
          ""
        end
        @resign.resign("MyApp.ipa", IDENTITY_1_SHA1, ["MyApp.mobileprovision"], nil, version, nil, short_version, bundle_version, nil, nil, nil)
        command
      end

      def shell_arguments(command)
        `printf '%s\\n' #{command.delete_prefix(@resign.find_resign_path.shellescape)}`.split("\n")
      end

      ["2.0 (beta)", "1.0$HOME"].each do |value|
        it "passes the version #{value} to resign.sh as one argument" do
          command = resign_command(version: value)

          expect(command).to include(" -n #{value.shellescape} ")
          unless FastlaneCore::Helper.windows?
            expect(shell_arguments(command).each_cons(2)).to include(["-n", value])
          end
        end

        it "passes the short version and bundle version #{value} to resign.sh as one argument each" do
          command = resign_command(short_version: value, bundle_version: value)

          expect(command).to include(" --short-version #{value.shellescape} --bundle-version #{value.shellescape} ")
          unless FastlaneCore::Helper.windows?
            arguments = shell_arguments(command)
            expect(arguments.each_cons(2)).to include(["--short-version", value])
            expect(arguments.each_cons(2)).to include(["--bundle-version", value])
          end
        end
      end
    end

    it "Installed identities parser" do
      stub_valid_identities(VALID_IDENTITIES_OUTPUT)
      actualresult = @resign.installed_identities
      expect(actualresult.keys.count).to eq(3)
      expect(actualresult[IDENTITY_1_SHA1]).to eq(IDENTITY_1_NAME)
      expect(actualresult[IDENTITY_2_SHA1]).to eq(IDENTITY_2_NAME)
      expect(actualresult[IDENTITY_3_SHA1]).to eq(IDENTITY_3_NAME)
    end

    it "Installed identities descriptions" do
      stub_valid_identities(VALID_IDENTITIES_OUTPUT)
      actualresult = @resign.installed_identity_descriptions
      result = [IDENTITY_1_NAME, "\t#{IDENTITY_1_SHA1}", IDENTITY_2_NAME, "\t#{IDENTITY_2_SHA1}", "\t#{IDENTITY_3_SHA1}"]
      expect(actualresult).to eq(result)
    end

    it "SHA1 for identity with name input" do
      stub_valid_identities(VALID_IDENTITIES_OUTPUT)
      actualresult = @resign.sha1_for_signing_identity(IDENTITY_3_NAME)
      # due to order of of identities in the VALID_IDENTITIES_OUTPUT and since names of identities 2) and 3) are equal
      # sha1_for_signing_identity(name) returns first matching SHA1 for identity name
      expect(actualresult).to eq(IDENTITY_2_SHA1)
    end

    it "SHA1 for identity with SHA1 input" do
      stub_valid_identities(VALID_IDENTITIES_OUTPUT)
      actualresult = @resign.sha1_for_signing_identity(IDENTITY_1_SHA1)
      expect(actualresult).to eq(IDENTITY_1_SHA1)
    end
  end
end
