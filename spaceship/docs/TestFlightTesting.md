# Testing `Spaceship::TestFlight`

(But we would love for all of the _spaceship_ tests to be like this 😀)

## Usage

To run the tests, in your terminal run:

```shell
bundle exec rspec spaceship/spec
```

## Overview

See [Architecture.md](Architecture.md).

## Adding Tests

### Models

Since the data models expect the client to return JSON data as a Ruby hash, we can reasonably mock the client response using RSpec doubles. We should *not* rely on HTTP fixtures because they are brittle, introduce global state, are not easily decomposable and are difficult to maintain. Instead, use the helper method `mock_client_response` to set up the expected data returned by the API. This design also leads the client to be as thin and logic-free as possible.

Defining the response near the test site makes it easy to understand and maintain. Try not to include any more data than is necessary for the spec to pass.

**Examples:**

At the top of your data model spec, set the client to be a `mock_client`:

```ruby
describe Spaceship::TestFlight::Tester do
  let(:mock_client) { double('MockClient') }
  before do
    allow(Spaceship::TestFlight::Base).to receive(:client).and_return(mock_client)
    allow(mock_client).to receive(:team_id).and_return('')
  end
end
```

Now, anytime we use a data model that is a subclass of `Spaceship::TestFlight::Base`, it has a `client` that is our mock.

We then configure the response for a given client method using the `mock_client_response` method defined in `spaceship/spec/spec_helper.rb` which can be required by `require 'spec_helper`. This method is defined within an RSpec configuration block:

```ruby
before do
  mock_client_response(:get_tester, with: { tester_id: 1 }) do
    {
      id: 1,
      name: 'Mr. Tester'
    }
  end
end
```

The first parameter is the name of the method we are mocking, and `with:` parameter specifies required parameters to that method. If you don't give it a `with:`, the mock will accept any parameters. The block is the return value of calling `client.get_tester`.

Now we can test our data model method that uses the client:

```ruby
it 'finds the test by id' do
  tester = Spaceship::TestFlight::Tester.find(1)
  expect(tester.name).to eq('Mr. Tester')
end
```

Collection methods:

```ruby
context '.all' do
  it 'contains all of the builds across all build trains' do
    builds = Spaceship::TestFlight::Build.all(app_id: 10, platform: 'ios')
    expect(builds.size).to eq(3)
    expect(builds.sample).to be_instance_of(Spaceship::TestFlight::Build)
    expect(builds.map(&:train_version).uniq).to eq(['1.0', '1.1'])
  end
end
```

Instance methods:

```ruby
context '#upload_date' do
  it 'parses the string value' do
    expect(build.upload_date).to eq(Time.utc(2017, 1, 1, 12))
  end
end
```

### Client

**Examples:**

GET:

```ruby
context '#get_build_trains' do
  it 'executes the request' do
    MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains') {}
    subject.get_build_trains(app_id: app_id, platform: platform)
    expect(WebMock).to have_requested(:get, 'https://appstoreconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains')
  end
end
```

PUT:

```ruby
context '#add_group_to_build' do
  it 'executes the request' do
    MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id') {}
    subject.add_group_to_build(app_id: app_id, group_id: 'fake-group-id', build_id: 'fake-build-id')
    expect(WebMock).to have_requested(:put, 'https://appstoreconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id')
  end
end
```

#### How client tests work

The client adds routes to a [sinatra](http://www.sinatrarb.com/) server to receive and mock the responses that will be handled by `handle_response`.
