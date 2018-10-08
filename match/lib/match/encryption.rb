require_relative 'encryption/interface'
require_relative 'encryption/openssl'

module Match
  module Encryption
    # Returns the class to be used for a given `storage_mode`
    def self.for_storage_mode(storage_mode, params)
      if storage_mode == "git"
        params[:keychain_name] = params[:git_url]
        return Encryption::OpenSSL.configure(params)
      elsif storage_mode == "google_cloud"
        # return Encryption::GoogleCloudKMS.configure(params)
      else
        UI.user_error!("Invalid storage mode '#{storage_mode}'")
      end
    end
  end
end
