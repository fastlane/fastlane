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
      keychain_paths = [
        File.join(Dir.home, 'Library', 'Keychains', keychain),
        keychain
      ].map { |path| File.expand_path(path) }

      keychain_path = keychain_paths.find { |path| File.exist?(path) }

      UI.user_error!("Could not locate the provided keychain. Tried:\n\t#{keychain_paths.join("\n\t")}") unless keychain_path

      command = "security import #{item_path.shellescape} -k #{keychain_path.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << " &> /dev/null" unless $verbose

      Helper.backticks(command, print: $verbose)
    end

    def self.get_cert_info(cer_certificate_path)
      command = "openssl x509 -inform der -in #{cer_certificate_path.shellescape} -subject -dates -noout"
      command << " &" # start in separate process

      output = Helper.backticks(command, print: $verbose).split("\n")

      # openssl output:

      # subject= /UID={User ID}/CN={Certificate Name}/OU={Certificate User}/O={Organisation}/C={Country}\n
      # notBefore={Start datetime}\n
      # notAfter={End datetime}

      # removing subject= in first line
      subject_value = output[0][output[0].index('=') + 2, output[0].length]

      out_array = subject_value.split('/')
      out_array << output[1]
      out_array << output[2]

      oppenssl_keys_to_readable_keys = {
          'UID' => 'User ID',
          'CN' => 'Common Name',
          'OU' => 'Organisation Unit',
          'O' => 'Organisation',
          'C' => 'Country',
          'notBefore' => 'Start Datetime',
          'notAfter' => 'End Datetime'
      }

      # collect openssl answer to structure [[key1, v1], [key2, v2], ...]
      key_value_pairs = out_array.map { |x| x.split(/=+/) if x.include? "=" }.compact

      # change keys to readable
      table_data = key_value_pairs.map { |k, v| [oppenssl_keys_to_readable_keys.fetch(k, k), v] }

      return table_data
    rescue => ex
      UI.error(ex)
      return {}
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

    def self.environment_variable_name_cert(params)
      ["sigh", params[:app_identifier], params[:type], "cert"].join("_")
    end

    # Fill identity(name) of certificate to env variable
    def self.fill_environment_cert(params, identity)
      # instead we specify the UUID of the profiles
      key = environment_variable_name_cert(params)
      UI.important "Setting environment variable '#{key}' to '#{identity}'" if $verbose
      ENV[key] = identity
    end
  end
end
