require_relative 'storage/interface'
require_relative 'storage/git_storage'
require_relative 'storage/google_cloud_storage'
require_relative 'storage/s3_storage'

module Match
  module Storage
    class << self
      def backends
        @backends ||= {
          "git" => lambda { |params|
            return Storage::GitStorage.configure(params)
          },
          "google_cloud" => lambda { |params|
            return Storage::GoogleCloudStorage.configure(params)
          },
          "s3" => lambda { |params|
            return Storage::S3Storage.configure(params)
          }
        }
      end

      def register_backend(type: nil, storage_class: nil, &configurator)
        UI.user_error!("No type specified for storage backend") if type.nil?

        normalized_name = type.to_s
        UI.message("Replacing Match::Encryption backend for type '#{normalized_name}'") if backends.include?(normalized_name)

        if configurator
          @backends[normalized_name] = configurator
        elsif storage_class
          @backends[normalized_name] = ->(params) { return storage_class.configure(params) }
        else
          UI.user_error!("Specify either a `storage_class` or a configuration block when registering a storage backend")
        end
      end

      def for_mode(storage_mode, params)
        configurator = backends[storage_mode.to_s]
        return configurator.call(params) if configurator

        UI.user_error!("No storage backend for storage mode '#{storage_mode}'")
      end
    end
  end
end
