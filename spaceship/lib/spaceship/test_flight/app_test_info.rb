module Spaceship::TestFlight
  class AppTestInfo < Base
    # AppTestInfo wraps a test_info and beta_review_info in the format required to manage test_info
    # for an application. Note that this structure, although looking similar to build test_info
    # is test information about the application

    attr_accessor :test_info

    def self.find(app_id: nil)
      raw_app_test_info = client.get_app_test_info(app_id: app_id)
      self.new(raw_app_test_info)
    end

    def test_info
      Spaceship::TestFlight::TestInfo.new(raw_data['details'])
    end

    def test_info=(value)
      raw_data.set(['details'], value.raw_data)
    end

    # saves the changes to the App Test Info object to TestFlight
    def save_for_app!(app_id: nil)
      client.put_app_test_info(app_id: app_id, app_test_info: self)
    end
  end
end
