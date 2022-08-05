require 'net/http'

## monkey-patch Net::HTTP
#
# Certain apple endpoints return 415 responses if a Content-Type is supplied.
# Net::HTTP will default a content-type if none is provided by faraday
# This monkey-patch allows us to leave out the content-type if we do not specify one.
module NetHTTPGenericRequestMonkeypatch
  def supply_default_content_type
    # Return no content type if we communicating with an apple.com domain
    return if !self['host'].nil? && self['host'].end_with?('.apple.com')

    # Otherwise use the default implementation
    super
  end
end

# We prepend the monkeypatch so the patch has access to the original implementation
# using `super`.
Net::HTTPGenericRequest.prepend(NetHTTPGenericRequestMonkeypatch)
