module Match
  class ChangePassword
    def self.update(params: nil, from: nil, to: nil)
      to ||= UI.password("New password: ")
      GitHelper.clear_changes
      workspace = GitHelper.clone(params[:git_url], params[:shallow_clone], manual_password: from)
      Encrypt.new.clear_password(params[:git_url])
      Encrypt.new.store_password(params[:git_url], to)

      message = "[fastlane] Changed password"
      GitHelper.commit_changes(workspace, message, params[:git_url])
    end
  end
end
