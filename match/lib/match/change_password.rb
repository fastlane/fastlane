module Match
  class ChangePassword
    def self.update(params: nil, from: nil, to: nil)
      to ||= ChangePassword.ask_password(message: "New passphrase for Git Repo: ", confirm: false)
      from ||= ChangePassword.ask_password(message: "Old passphrase for Git Repo: ", confirm: true)
      GitHelper.clear_changes
      workspace = GitHelper.clone(params[:git_url], params[:shallow_clone], manual_password: from, skip_docs: params[:skip_docs], branch: params[:git_branch])
      Encrypt.new.clear_password(params[:git_url])
      Encrypt.new.store_password(params[:git_url], to)

      message = "[fastlane] Changed passphrase"
      GitHelper.commit_changes(workspace, message, params[:git_url], params[:git_branch])
    end

    def self.ask_password(message: "Passphrase for Git Repo: ", confirm: true)
      loop do
        password = UI.password(message)
        if confirm
          password2 = UI.password("Type passphrase again: ")
          if password == password2
            return password
          end
        else
          return password
        end
        UI.error("Passhprases differ. Try again")
      end
    end
  end
end
