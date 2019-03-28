require 'sinatra/base'

module MockAPI
  class DeveloperPortalServer < Sinatra::Base
    set :dump_errors, true
    set :show_exceptions, false

    before { content_type(:json) if request.post? }

    after do
      response.body = JSON.dump(response.body) if response.body.kind_of?(Hash)
    end
  end
end
