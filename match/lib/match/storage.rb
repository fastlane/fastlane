require_relative 'storage/interface'
require_relative 'storage/git_storage'

module Match
  module Storage
    def self.for_mode(storage_mode, params)
      if storage_mode == "git"
        return Storage::GitStorage.configure(params)
      elsif storage_mode == "google_cloud"
        # return Storage::GoogleCloudStorage
      else
        UI.user_error!("Invalid storage mode '#{storage_mode}'")
      end
    end
  end
end
