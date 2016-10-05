module Match
  class Utils
    def self.import(item_path, keychain)
      # Existing code expects that a keychain name will be expanded into a default path to Libary/Keychains
      # in the user's home directory. However, this will not allow the user to pass an absolute path
      # for the keychain value
      #
      # So, if the passed value can't be resolved as a file in Library/Keychains, just use it as-is
      # as the keychain path.
      #
      # We need to expand each path because File.exist? won't handle directories including ~ properly
      #
      # We also try to append `-db` at the end of the file path, as with Sierra the default Keychain name
      # has changed for some users: https://github.com/fastlane/fastlane/issues/5649
      #
      keychain_paths = [
        File.join(Dir.home, 'Library', 'Keychains', keychain),
        File.join(Dir.home, 'Library', 'Keychains', "#{keychain}-db"),
        keychain,
        "#{keychain}-db"
      ].map { |path| File.expand_path(path) }

      keychain_path = keychain_paths.find { |path| File.exist?(path) }

      UI.user_error!("Could not locate the provided keychain. Tried:\n\t#{keychain_paths.join("\n\t")}") unless keychain_path

      command = "security import #{item_path.shellescape} -k #{keychain_path.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << " &> /dev/null" unless $verbose

      Helper.backticks(command, print: $verbose)
    end

    # Fill in an environment variable, ready to be used in _xcodebuild_
    def self.fill_environment(key, value)
      UI.important "Setting environment variable '#{key}' to '#{value}'" if $verbose
      ENV[key] = value
    end

    def self.environment_variable_name(app_identifier: nil, type: nil)
      base_environment_variable_name(app_identifier: app_identifier, type: type).join("_")
    end

    def self.environment_variable_name_team_id(app_identifier: nil, type: nil)
      (base_environment_variable_name(app_identifier: app_identifier, type: type) + ["team-id"]).join("_")
    end

    def self.environment_variable_name_profile_name(app_identifier: nil, type: nil)
      (base_environment_variable_name(app_identifier: app_identifier, type: type) + ["profile-name"]).join("_")
    end

    def self.base_environment_variable_name(app_identifier: nil, type: nil)
      ["sigh", app_identifier, type]
    end
  end
end
