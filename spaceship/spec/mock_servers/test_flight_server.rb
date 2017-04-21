require 'sinatra/base'

module MockAPI
  class TestFlightServer < Sinatra::Base
    # put errors in stdout instead of returning HTML
    set :dump_errors, true
    set :show_exceptions, false

    before do
      content_type :json
    end

    after do
      if response.body.is_a?(Hash)
        response.body = JSON.dump(response.body)
      end
    end
  end
end
