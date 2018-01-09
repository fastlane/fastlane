require 'sinatra/base'

module MockAPI
  class DeveloperPortalServer < Sinatra::Base
    set :dump_errors, true
    set :show_exceptions, false

    before do
      if request.post?
        content_type(:json)
      end
    end

    after do
      if response.body.kind_of?(Hash)
        response.body = JSON.dump(response.body)
      end
    end
  end
end
