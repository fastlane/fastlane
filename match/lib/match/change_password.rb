require_relative 'module'
require_relative 'encrypt'
require_relative 'git_helper'

module Match
  # These functions should only be used while in (UI.) interactive mode
  class ChangePassword
    def self.update(params: nil, from: nil, to: nil)
      ensure_ui_interactive
      to ||= ChangePassword.ask_password(message: "New passphrase for Git Repo: ", confirm: false)
      from ||= ChangePassword.ask_password(message: "Old passphrase for Git Repo: ", confirm: true)
      GitHelper.clear_changes
      workspace = GitHelper.clone(params[:git_url],
                                  params[:shallow_clone],
                                  manual_password: from,
                                  skip_docs: params[:skip_docs],
                                  branch: params[:git_branch],
                                  git_full_name: params[:git_full_name],
                                  git_user_email: params[:git_user_email],
                                  clone_branch_directly: params[:clone_branch_directly])
      Encrypt.new.clear_password(params[:git_url])
      Encrypt.new.store_password(params[:git_url], to)

      message = "[fastlane] Changed passphrase"
      GitHelper.commit_changes(workspace, message, params[:git_url], params[:git_branch])
    end

    def self.ask_password(message: "Passphrase for Git Repo: ", confirm: true)
      ensure_ui_interactive
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
        UI.error("Passphrases differ. Try again")
      end
    end

    def self.ensure_ui_interactive
      raise "This code should only run in interactive mode" unless UI.interactive?
    end

    private_class_method :ensure_ui_interactive
  end
end
