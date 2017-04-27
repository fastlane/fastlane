Testing `Spaceship::TestFlight`
===================
(But we would love for all of the _spaceship_ tests to be like this 😀)

## Usage
To run the tests, in your terminal run:

```
bundle exec rspec spaceship/spec
```

## Adding Tests
### Models
**Examples:**

Mocked responses:

```
mock_client_response(:get_build) do
  {
	id: 1,
	bundleId: 'some-bundle-id',
	appAdamId: 'some-app-id',
	uploadDate: '2017-01-01T12:00:00.000+0000',
	betaReviewInfo: {
	  contactFirstName: 'Dev',
	  contactLastName: 'Toolio',
	  contactEmail: 'dev-toolio@fabric.io'
	},
	exportCompliance: {
	  usesEncryption: true,
	  encryptionUpdated: false
	},
	testInfo: [
	  {
	    locale: 'en-US',
	    description: 'test info',
	    feedbackEmail: 'email@example.com',
	    whatsNew: 'this is new!'
	  }
	]
  }
end
```


Collection methods:

```
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

```
context '#upload_date' do
  it 'parses the string value' do
    expect(build.upload_date).to eq(Time.utc(2017, 1, 1, 12))
  end
end
```

#### How model tests work
`mock_client_response` takes a method symbol and a block that defines the minimum amount of data necessary to execute the test.

### Client
**Examples:**

GET:

```
context '#get_build_trains' do
  it 'executes the request' do
    MockAPI::TestFlightServer.get('/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains') {}
    subject.get_build_trains(app_id: app_id, platform: platform)
    expect(WebMock).to have_requested(:get, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/platforms/ios/trains')
  end
end
```

PUT:

```
context '#add_group_to_build' do
  it 'executes the request' do
    MockAPI::TestFlightServer.put('/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id') {}
    subject.add_group_to_build(app_id: app_id, group_id: 'fake-group-id', build_id: 'fake-build-id')
    expect(WebMock).to have_requested(:put, 'https://itunesconnect.apple.com/testflight/v2/providers/fake-team-id/apps/some-app-id/groups/fake-group-id/builds/fake-build-id')
  end
end
```

#### How client tests work
The client adds routes to a [sinatra](http://www.sinatrarb.com/) server to receive and mock the responses that will be handled by `handle_response`.
