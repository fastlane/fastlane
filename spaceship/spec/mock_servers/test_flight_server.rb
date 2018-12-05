require 'sinatra/base'

module MockAPI
  class TestFlightServer < Sinatra::Base
    # put errors in stdout instead of returning HTML
    set :dump_errors, true
    set :show_exceptions, false

    before do
      content_type(:json)
    end

    after do
      if response.body.kind_of?(Hash)
        response.body = JSON.dump(response.body)
      end
    end

    not_found do
      content_type(:html)
      status(404)
      <<-HTML
        <html>
          <body>
            #{request.request_method} : #{request.url}
            HTTP ERROR: 404
          </body>
        </html>
      HTML
    end
  end
end
