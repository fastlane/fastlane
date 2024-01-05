# _spaceship_ Architecture

_spaceship_ uses [Faraday](https://github.com/lostisland/faraday) to interact with multiple Apple API endpoints:

## Overview

_spaceship_ wraps various APIs using the following pattern:

A simple `client` and various data models, usually subclassed from a `Base` model (e.g. Spaceship::TestFlight::Base)
The `client` is responsible for making HTTP requests for a given API or domain. It should be very simple and have no logic.
It is only responsible for creating the request and parsing the response. The best practice is for each method to have a single request and return the data from the response.

The data models generally map to a REST resource or some logical grouping of data. Each data model has an instance of `client` which it can use to put or get data. It should encapsulate all interactions with the API, so other _fastlane_ tools interface with the data models, and not the `client` directly.

## Technical

_spaceship_ is split into 3 layers:

- `client.rb` which is the client superclass that contains all shared code between App Store Connect the Developer Portal
- `tunes_client.rb` and `portal_client.rb` which are the implementations for both App Store Connect and Developer Portal. Those classes include the actual HTTP requests that are being sent:
```ruby
def app_version_data(app_id, version_platform: nil, version_id: nil)
  r = request(:get, "ra/apps/#{app_id}/platforms/#{version_platform}/versions/#{version_id}")
  parse_response(r, 'data')
end
```
- _spaceship_ classes, e.g. `app_version.rb` which contain the API the user works with. These classes usually have some logic on how to handle responses.

Don’t use any custom HTML parsing in _spaceship_, instead try to only use JSON and XML APIs.
