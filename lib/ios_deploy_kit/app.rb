module IosDeployKit
  class App
    attr_accessor :apple_id, :app_identifier

    def itc
      unless @itc
        @itc = IosDeployKit::ItunesConnect.new
        @itc.login
      end
      @itc
    end

    def open_in_itunes_connect
      itc.open_app_page(self)
    end

    def create_new_version(version_number)
      itc.create_new_version(self, version_number)
    end

    def to_s
      "#{apple_id} - #{app_identifier}"
    end
  end
end