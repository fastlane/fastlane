require 'zlib'
require 'plist' # Some responses are in the plist format

module Spaceship
  class Client
    # Is used to unzip compress server responses
    def unzip(resp)
      Zlib::GzipReader.new(StringIO.new(resp.body)).read
    rescue => ex
      return resp.body if Helper.is_test? # Tests don't use compressed data
      Helper.log.error "#{resp.data}\nSomething went wrong with the request: #{ex}"
      return nil
    end
  end
end