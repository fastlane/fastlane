module Match
  class Utils
    def self.import(item_path, keychain)
      command = "security import #{item_path.shellescape} -k ~/Library/Keychains/#{keychain.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << "&> /dev/null" # we couldn't care less about the output

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
