require 'net/http'

## monkey-patch Net::HTTP
#
# Certain apple endpoints return 415 responses if a Content-Type is supplied.
# Net::HTTP will default a content-type if none is provided by faraday
# This monkey-patch allows us to leave out the content-type if we do not specify one.
module Net
  class HTTPGenericRequest
    def supply_default_content_type
      return if content_type
    end
  end
end
