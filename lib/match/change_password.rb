module Match
  class ChangePassword
    def self.update(params: nil, from: nil, to: nil)
      to ||= ChangePassword.ask_password("New passphrase for Git Repo: ")
      from ||= ChangePassword.ask_password("Old passphrase for Git Repo: ")
      GitHelper.clear_changes
      workspace = GitHelper.clone(params[:git_url], params[:shallow_clone], manual_password: from)
      Encrypt.new.clear_password(params[:git_url])
      Encrypt.new.store_password(params[:git_url], to)

      message = "[fastlane] Changed passphrase"
      GitHelper.commit_changes(workspace, message, params[:git_url])
    end

    def self.ask_password(msg = "Passphrase for Git Repo: ")
      password = nil
      while password == nil
        password = ask(msg.yellow) { |q| q.echo = "*" }
        password2 = ask("Type passphrase again: ".yellow) { |q| q.echo = "*" }
        if password != password2
          UI.error("Passhprases differ. Try again")
          password = ""
        end
      end
      password
    end
  end
end
