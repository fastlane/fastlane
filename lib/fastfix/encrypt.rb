module Fastfix
  class Encrypt
    require 'encrypted_strings'
    require 'security'

    def server_name(git_url)
      ["fastfix", git_url].join("_")
    end

    def password(git_url)
      @password ||= ENV["FASTFIX_PASSWORD"]
      unless @password
        item = Security::InternetPassword.find(server: server_name(git_url))
        @password = item.password if item
      end

      unless @password
        @password = ask("Password for Git Repo: ".yellow) while @password.to_s.length == 0
        Security::InternetPassword.add(server_name(git_url), "", @password)
      end

      return @password
    end

    # removes the password from the keychain again
    def clear_password(git_url)
      Security::InternetPassword.delete(server: server_name(git_url))
      @password = nil
    end

    def encrypt_repo(params)
      iterate(params[:path]) do |path|
        content = File.read(path)
        encrypted = content.encrypt(:symmetric, password: password(params[:git_url]))
        File.write(path, encrypted)
        Helper.log.info "🔒  Encrypted '#{File.basename(path)}'".green
      end
    end

    def decrypt_repo(params)
      iterate(params[:path]) do |path|
        content = File.read(path)
        begin
          decrypted = content.decrypt(:symmetric, password: password(params[:git_url]))
        rescue => ex
          Helper.log.error "Couldn't decrypt the repo, please make sure you enter the right password!".red
          clear_password(params[:git_url])
          decrypt_repo(params)
          return
        end
        File.write(path, decrypted)
        Helper.log.info "🔓  Decrypted '#{File.basename(path)}'".green
      end
    end

    private

    def iterate(source_path)
      Dir[File.join(source_path, "**", "*")].each do |path|
        next if File.directory?(path)
        yield(path)
      end
    end
  end
end
