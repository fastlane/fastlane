module Match
  class Utils
    def self.import(item_path, keychain)
      # Existing code expects that a keychain name will be expanded into a default path to Libary/Keychains
      # in the user's home directory. However, this will not allow the user to pass an absolute path
      # for the keychain value
      keychain_path = File.join(Dir.home, 'Library', 'Keychains', keychain)

      # So, if the passed value can't be resolved as a file in Library/Keychains, just use it as-is
      # as the keychain path.
      keychain_path = keychain unless File.exist?(keychain_path)

      command = "security import #{item_path.shellescape} -k #{keychain_path.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << " &> /dev/null" unless $verbose

      return command if Helper.test?

      Helper.backticks(command, print: $verbose)
    end

    # Fill in the UUID of the profiles in environment variables, much recycling
    def self.fill_environment(params, uuid)
      # instead we specify the UUID of the profiles
      key = environment_variable_name(params)
      UI.important "Setting environment variable '#{key}' to '#{uuid}'" if $verbose
      ENV[key] = uuid
    end

    def self.environment_variable_name(params)
      ["sigh", params[:app_identifier], params[:type]].join("_")
    end
  end
end
