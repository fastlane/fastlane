require_relative 'module'
require_relative 'change_password'

module Match
  class Encrypt
    require 'security'
    require 'shellwords'
    require 'open3'

    def server_name(git_url)
      ["match", git_url].join("_")
    end

    def password(git_url)
      password = ENV["MATCH_PASSWORD"]
      unless password
        item = Security::InternetPassword.find(server: server_name(git_url))
        password = item.password if item
      end

      unless password
        if !UI.interactive?
          UI.error("Neither the MATCH_PASSWORD environment variable nor the local keychain contained a password.")
          UI.error("Bailing out instead of asking for a password, since this is non-interactive mode.")
          UI.user_error!("Try setting the MATCH_PASSWORD environment variable, or temporarily enable interactive mode to store a password.")
        else
          UI.important("Enter the passphrase that should be used to encrypt/decrypt your certificates")
          UI.important("This passphrase is specific per repository and will be stored in your local keychain")
          UI.important("Make sure to remember the password, as you'll need it when you run match on a different machine")
          password = ChangePassword.ask_password(confirm: true)
          store_password(git_url, password)
        end
      end

      return password
    end

    def store_password(git_url, password)
      Security::InternetPassword.add(server_name(git_url), "", password)
    end

    # removes the password from the keychain again
    def clear_password(git_url)
      Security::InternetPassword.delete(server: server_name(git_url))
    end

    def encrypt_repo(path: nil, git_url: nil)
      iterate(path) do |current|
        crypt(path: current,
          password: password(git_url),
           encrypt: true)
        UI.success("🔒  Encrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
      end
      UI.success("🔒  Successfully encrypted certificates repo")
    end

    def decrypt_repo(path: nil, git_url: nil, manual_password: nil)
      iterate(path) do |current|
        begin
          crypt(path: current,
            password: manual_password || password(git_url),
             encrypt: false)
        rescue
          UI.error("Couldn't decrypt the repo, please make sure you enter the right password!")
          UI.user_error!("Invalid password passed via 'MATCH_PASSWORD'") if ENV["MATCH_PASSWORD"]
          clear_password(git_url)
          decrypt_repo(path: path, git_url: git_url)
          return
        end
        UI.success("🔓  Decrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
      end
      UI.success("🔓  Successfully decrypted certificates repo")
    end

    private

    def iterate(source_path)
      Dir[File.join(source_path, "**", "*.{cer,p12,mobileprovision}")].each do |path|
        next if File.directory?(path)
        yield(path)
      end
    end

    def crypt(path: nil, password: nil, encrypt: true)
      if password.to_s.strip.length == 0 && encrypt
        UI.user_error!("No password supplied")
      end

      tmpfile = File.join(Dir.mktmpdir, "temporary")
      command = ["openssl aes-256-cbc"]
      command << "-k #{password.shellescape}"
      command << "-in #{path.shellescape}"
      command << "-out #{tmpfile.shellescape}"
      command << "-a"
      command << "-d" unless encrypt
      command << "&> /dev/null" unless FastlaneCore::Globals.verbose? # to show an error message if something goes wrong

      _out, err, st = Open3.capture3(command.join(' '))
      success = st.success?

      # Ubuntu `openssl` does not fail on failure
      # but at least outputs an error message
      unless err.to_s.empty?
        success = false
      end

      UI.crash!("Error decrypting '#{path}'") unless success

      # On non-Mac systems (more specific Ubuntu Linux) it might take some time for the file to actually be there (see #11182).
      # To try to circumvent this flakyness (in tests), we wait a bit until the file appears (max 2s) (usually only 0.1 is actually waited)
      unless FastlaneCore::Helper.is_mac?
        count = 0
        # sleep until file exists or 20*0.1s (=2s) passed
        until File.exist?(tmpfile) || count == 20
          sleep(0.1)
          count += 1
        end
      end

      FileUtils.mv(tmpfile, path)
    end
  end
end
