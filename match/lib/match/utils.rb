module Match
  class Utils
    def self.import(item_path, keychain)
      command = "security import #{item_path.shellescape} -k ~/Library/Keychains/#{keychain.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << "&> /dev/null" # we couldn't care less about the output

      Helper.backticks(command, print: $verbose)
    end

    # logs public key's  name, user, organisation, country, availability dates
    def self.log_certificate_public_key(cer_certificate_path)
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
          'CN' => 'Certificate Name',
          'OU' => 'Organisation Unit',
          'O' => 'Organisation Name',
          'C' => 'Country',
          'notBefore' => 'Start Datetime',
          'notAfter' => 'End Datetime'
      }

      # collect openssl answer to structure [[key1, v1], [key2, v2], ...]
      key_value_pairs = out_array.map { |x| x.split(/=+/) if x.include? "=" }.compact

      # change keys to readable
      table_data = key_value_pairs.map { |k, v| [oppenssl_keys_to_readable_keys.fetch(k, k), v] }

      params = {
          rows: table_data,
          title: "Installed Code Certificate".green
      }

      puts ""
      puts Terminal::Table.new(params)
      puts ""
      return table_data
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
