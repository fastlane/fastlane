module Sigh
  # Resigns an existing ipa file
  class Resign
    def run(options)
      get_inputs(options)

      command = [
        @resign_path,
        "'#{@ipa}'",
        "'#{@signing_identity}'",
        "-p '#{@provisioning_profile}'",
        "'#{@ipa}'"
      ].join(' ')

      puts command.magenta
      puts `#{command}`
    end

    def get_inputs(options)
      @resign_path = File.join(Helper.gem_path, 'lib', 'assets', 'resign.sh')
      raise "Could not find resign.sh file. Please try re-installing the gem.".red unless File.exists?@resign_path

      @ipa = options.ipa || find_ipa || ask("Path to ipa file: ")
      @signing_identity = options.signing_identity || ask_for_signing_identity
      validate_signing_identity
      @provisioning_profile = options.provisioning_profile || find_provisioning_profile || ask("Path to provisioning file: ")
    end

    def find_ipa
      Dir[File.join(Dir.pwd, "*.ipa")].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def find_provisioning_profile
      Dir[File.join(Dir.pwd, "*.mobileprovision")].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def validate_signing_identity
      while not installed_identies.include?@signing_identity
        Helper.log.error "Couldn't find signing identity '#{@signing_identity}'. Available identities: \n\t#{installed_identies.join("\n\t")}\n"
        @signing_identity = ask_for_signing_identity
      end
    end

    def ask_for_signing_identity
      ask("Signing Identity (e.g. 'iPhone Distribution: SunApps GmbH (5A997XAHK2)'): ")
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