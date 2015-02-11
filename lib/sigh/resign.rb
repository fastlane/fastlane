module Sigh
  # Resigns an existing ipa file
  class Resign
    def run(options, args)
      get_inputs(options, args)

      command = [
        @resign_path,
        "'#{@ipa}'",
        "'#{@signing_identity}'",
        "-p '#{@provisioning_profile}'",
        "'#{@ipa}'"
      ].join(' ')

      puts command.magenta
      output = `#{command}`
      puts output
      if output.include?"Assuming Distribution Identity"
        Helper.log.info "Successfully signed #{@ipa}!".green
      else
        Helper.log.fatal "Something went wrong while code signing #{@ipa}".red
      end
    end

    def get_inputs(options, args)
      @resign_path = File.join(Helper.gem_path, 'lib', 'assets', 'resign.sh')
      raise "Could not find resign.sh file. Please try re-installing the gem.".red unless File.exists?@resign_path

      @ipa = args.first || find_ipa || ask("Path to ipa file: ")
      validate_ipa_file!
      @signing_identity = options.signing_identity || ask_for_signing_identity
      validate_signing_identity
      @provisioning_profile = options.provisioning_profile || find_provisioning_profile || ask("Path to provisioning file: ")
      validate_provisioning_file!
    end

    def find_ipa
      Dir[File.join(Dir.pwd, "*.ipa")].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def find_provisioning_profile
      Dir[File.join(Dir.pwd, "*.mobileprovision")].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def validate_ipa_file!
      raise "ipa file could not be found or is not an ipa file (#{@ipa})".red unless (File.exists?(@ipa) and @ipa.end_with?".ipa")
    end

    def validate_provisioning_file!
      raise "Provisioning profile file could not be found or is not a .mobileprovision file (#{@provisioning_profile})".red unless (File.exists?(@provisioning_profile) and @provisioning_profile.end_with?".mobileprovision")
    end

    def validate_signing_identity
      while not installed_identies.include?@signing_identity
        Helper.log.error "Couldn't find signing identity '#{@signing_identity}'."
        @signing_identity = ask_for_signing_identity
      end
    end

    def print_available_identities
      Helper.log.info "Available identities: \n\t#{installed_identies.join("\n\t")}\n"
    end

    def ask_for_signing_identity
      print_available_identities
      ask("Signing Identity: ")
    end

    # Array of available signing identities
    def installed_identies
      available = `security find-identity -v -p codesigning`
      ids = []
      available.split("\n").each do |current|
        (ids << current.match(/.*\"(.*)\"/)[1]) rescue nil # the last line does not match
      end

      return ids
    end
  end
end