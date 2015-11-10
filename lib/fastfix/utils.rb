module Fastfix
  class Utils
    def self.import(params, item_path)
      command = "security import #{item_path.shellescape} -k ~/Library/Keychains/#{params[:keychain_name].shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      begin
        puts command.yellow
        `#{command}`
      rescue => ex
        if ex.to_s.include?("SecKeychainItemImport: The specified item already exists in the keychain")
          return true
        else
          raise ex
        end
      end
      true
    end

    # Fill in the UUID of the profiles in environment variables, much recycling
    def self.fill_environment(params, uuid)
      # instead we specify the UUID of the profiles
      key = environment_variable_name(params)
      Helper.log.info "Setting environment variable '#{key}' to '#{uuid}'".yellow
      ENV[key] = uuid
    end

    def self.environment_variable_name(params)
      ["sigh", params[:app_identifier], params[:type]].join("_")
    end
  end
end
