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
      @signing_identity = options.signing_identity || ask("Signing Identity (e.g. 'iPhone Distribution: SunApps GmbH (5A997XAHK2)'): ")
      @provisioning_profile = options.provisioning_profile || find_provisioning_profile || ask("Path to provisioning file: ")
    end

    def find_ipa
      Dir[File.join(Dir.pwd, "*.ipa")].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.first
    end

    def find_provisioning_profile
      Dir[File.join(Dir.pwd, "*.mobileprovision")].sort { |a,b| File.mtime(a) <=> File.mtime(b) }.first
    end
  end
end