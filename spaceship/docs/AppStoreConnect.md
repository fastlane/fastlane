# App Store Connect API

- [Usage](#usage)
  * [Login](#login)
  * [Applications](#applications)
  * [AppVersions](#appversions)
  * [Select a build for review](#select-a-build-for-review)
  * [Build Trains (TestFlight)](#build-trains-testflight)
  * [Builds](#builds)
  * [Processing builds](#processing-builds)
  * [Submit app for App Store Review](#submit-app-for-app-store-review)
  * [Testers](#testers)
  * [App ratings & reviews](#app-ratings--reviews)
  * [App Analytics](#app-analytics)
- [License](#license)

## Usage

To quickly play around with _spaceship_ launch `irb` in your terminal and execute `require "spaceship"`.

In general the classes are pre-fixed with the `ConnectAPI` module. If you want to use the legacy web API, make sure to use `Tunes`, which is an artifact from when "App Store Connect" was still called "iTunes Connect".

### Login

*Note*: If you use both the Developer Portal and App Store Connect API, you'll have to login on both, as the user might have different user credentials.

```ruby

token = Spaceship::ConnectAPI::Token.create(
  key_id: 'the-key-id',
  issuer_id: 'the-issuer-id',
  filepath:  File.absolute_path("../AuthKey_the-key-id.p8")
)

Spaceship::ConnectAPI.token = token

```

### Applications

```ruby
# Fetch all available applications
all_apps = Spaceship::ConnectAPI::App.all

# Find a specific app based on the bundle identifier
app = Spaceship::ConnectAPI::App.find("com.krausefx.app")

app = Spaceship::ConnectAPI.get_app(app_id: 1013943394).first

# Access information about the app
app.id              # => 1013943394
app.name            # => "Spaceship App"
app.bundle_id       # => "com.krausefx.app"
app.sku             # => "SpaceshipApp01"
app.primary_locale  # => "en-US"

# Show the names of all your apps
Spaceship::ConnectAPI::App.all.collect do |app|
  app.name
end

# Create a new app
// Not working yet
app = Spaceship::ConnectAPI::App.create(name: "App Name",
                                        primary_language: "English",
                                        version_string: "1.0", # initial version
                                        sku: "123",
                                        bundle_id: "com.krausefx.app",
                                        platforms: ["IOS"])
```

To update non version specific details, use the following code

```ruby
details = app.details
details.name['en-US'] = "App Name"
details.privacy_url['en-US'] = "https://fastlane.tools"
details.save!
```

To change the price of the app (it's not necessary to call `save!` when updating the price)

```ruby
app.update_price_tier!("3")
```

### AppVersions

<img src="/spaceship/assets/docs/AppVersions.png" width="500">

You can have up to 2 app versions at the same time. One is usually the version already available in the App Store (`get_live_app_store_version`) and one being the one you can edit (`get_edit_app_store_version`).

While you usually can modify some values in the production version (e.g. app description), most options are already locked.

With _spaceship_ you can access the versions like this

```ruby
app.get_live_app_store_version # the version that's currently available in the App Store
app.get_edit_app_store_version # the version that's in `Prepare for Submission` mode
```

You can then go ahead and modify app metadata on the version objects:

```ruby
v = app.get_edit_app_store_version

# Access information
v.app_status        # => "Waiting for Review"
v.version           # => "0.9.14"

# Update app metadata
v.copyright = "#{Time.now.year} Felix Krause"

# Get a list of available languages for this app
v.description.languages # => ["German", "English"]

# Update localized app metadata
v.description["en-US"] = "App Description"

# set the app age rating
v.set_rating({
  'CARTOON_FANTASY_VIOLENCE' => 0,
  'MATURE_SUGGESTIVE' => 2,
  'UNRESTRICTED_WEB_ACCESS' => 0
})
# Available values:
# https://github.com/fastlane/fastlane/blob/master/deliver/assets/example_rating_config.json
# https://docs.fastlane.tools/actions/deliver/#reference (Open "View all available categories, languages, etc.")

# Push the changes back to the server
v.save!
```

All available options:
```ruby
####
# General app version metadata
####

attr_accessor :application
attr_accessor :version
attr_accessor :copyright
attr_reader :app_status
attr_accessor :is_live
attr_accessor :primary_category
attr_accessor :primary_first_sub_category
attr_accessor :primary_second_sub_category
attr_accessor :secondary_category
attr_accessor :secondary_first_sub_category
attr_accessor :secondary_second_sub_category
attr_accessor :raw_status
attr_accessor :can_reject_version
attr_accessor :can_prepare_for_upload
attr_accessor :can_send_version_live
attr_accessor :release_on_approval
attr_accessor :ratings_reset
attr_accessor :can_beta_test
attr_accessor :supports_apple_watch
attr_accessor :app_icon_url
attr_accessor :app_icon_original_name
attr_accessor :watch_app_icon_url
attr_accessor :watch_app_icon_original_name
attr_accessor :version_id

####
# Trade Representative Contact Information
####

attr_accessor :trade_representative_trade_name
attr_accessor :trade_representative_first_name
attr_accessor :trade_representative_last_name
attr_accessor :trade_representative_address_line_1
attr_accessor :trade_representative_address_line_2
attr_accessor :trade_representative_address_line_3
attr_accessor :trade_representative_city_name
attr_accessor :trade_representative_state
attr_accessor :trade_representative_country
attr_accessor :trade_representative_postal_code
attr_accessor :trade_representative_phone_number
attr_accessor :trade_representative_email
attr_accessor :trade_representative_is_displayed_on_app_store

####
# App Review Information
####

attr_accessor :review_first_name
attr_accessor :review_last_name
attr_accessor :review_phone_number
attr_accessor :review_email
attr_accessor :review_demo_user
attr_accessor :review_demo_password
attr_accessor :review_notes

####
# Localized values
# attr_reader, since you have to access using ["English"]
####

attr_accessor :languages
attr_reader :keywords
attr_reader :description
attr_reader :release_notes
attr_reader :support_url
attr_reader :marketing_url
attr_reader :screenshots
```

**Important**: For a complete documentation with the return type, description and notes for each of the properties, check out [app_version.rb](https://github.com/fastlane/fastlane/blob/master/spaceship/lib/spaceship/tunes/app_version.rb).

### Select a build for review

```ruby
version = app.get_edit_app_store_version

builds = version.candidate_builds
version.select_build(builds.first)
version.save!
```

### Build Trains (TestFlight)

<img src="/spaceship/assets/docs/BuildTrains.png" width="700">

To clarify:

- **version number**: Is set via the `CFBundleShortVersionString` property. It's the version number that appears on the App Store. (`0.9.21` on the screenshot)
- **build number**: Is set via the `CFBundleVersion` property. It's not visible in the App Store. It has to be incremented before uploading a new build. (`99993` on the screenshot)

A build train contains all builds for a give `version number` (e.g. `0.9.21`). Within the build train you have *n* builds, each having a different `build number` (e.g. `99993`).

```ruby
# Access all build trains for an app
app.all_build_train_numbers   # => ["0.9.21"]

# Access the build train via the version number
train = app.build_trains["0.9.21"]

# Access all builds for a given train
train.count            # => 1
build = train.first
```

### Builds

```ruby
# Continue from the BuildTrains example
build.build_version           # => "99993"  (the build number)
build.train_version           # => "0.9.21" (the version number)
build.install_count           # => 1
build.crash_count             # => 0

build.internal_state          # => testflight.build.state.testing.ready
build.external_state          # => testflight.build.state.submit.ready
```

You can even submit a build for external beta review (after you have set all necessary metadata - see above)
```ruby
build.submit_for_testflight_review!
```

### Processing builds

To also access those builds that are "stuck" at `Processing` at App Store Connect for a while:

```ruby
app.all_processing_builds       # => Array of processing builds for this application
```

### Submit app for App Store Review

```ruby
submission = app.create_submission

# Set app submission information
submission.content_rights_contains_third_party_content = false
submission.content_rights_has_rights = true
submission.add_id_info_uses_idfa = false

# Finalize app submission
submission.complete!
```

For a full list of available options, check out [app_submission.rb](https://github.com/fastlane/fastlane/blob/master/spaceship/lib/spaceship/tunes/app_submission.rb).

### Testers

There are 3 types of testers:

- **External testers**: usually not part of your team. You can invite up to 10000 external testers. Before distributing a build to those testers you need to submit your app to beta review.
- **Internal testers**: Employees that are registered in your App Store Connect team. They get access to all builds without having to wait for review.
- **Sandbox testers**: Dummy accounts to test development-mode apps with in-app purchase or Apple Pay.

```ruby
# Find a tester based on the email address
tester = Spaceship::TestFlight::Tester.find(app_id: "some_app_id", email: "felix@krausefx.com")

# Creating new testers
Spaceship::TestFlight::Tester.create_app_level_tester(
      app_id: "io.myapp",
       email: "github@krausefx.com",
  first_name: "Felix",
   last_name: "Krause"
)

```
Right now, _spaceship_ can't modify or create internal testers.

```ruby
# Load all sandbox testers
testers = Spaceship::Tunes::SandboxTester.all

# Create a sandbox tester
testers = Spaceship::Tunes::SandboxTester.create!(
  email: 'sandbox@test.com', # required
  password: 'Passwordtest1', # required. Must contain >=8 characters, >=1 uppercase, >=1 lowercase, >=1 numeric.
  country: 'US', # optional, defaults to 'US'
  first_name: 'Steve', # optional, defaults to 'Test'
  last_name: 'Brule', # optional, defaults to 'Test'
)

# Delete sandbox testers by email
Spaceship::Tunes::SandboxTester.delete!(['sandbox@test.com', 'sandbox2@test.com'])

# Delete all sandbox testers
Spaceship::Tunes::SandboxTester.delete_all!
```

### App ratings & reviews

```ruby
# Get the rating summary for an application
ratings = app.ratings # => Spaceship::Tunes::AppRatings

# Get the number of 5 star ratings
five_star_count = ratings.five_star_rating_count

# Find the average rating across all stores
average_rating = ratings.average_rating

# Find the average rating for a given store front
average_rating = app.ratings(storefront: "US").average_rating

# Get reviews for a given store front
reviews = ratings.reviews("US") # => Array of hashes representing review data

```

### App Analytics

```ruby
# Start app analytics
analytics = app.analytics                # => Spaceship::Tunes::AppAnalytics

# Get all the different metrics from App Analytics
# By default covering the last 7 days

# Get app units
units = analytics.app_units              # => Array of dates representing raw data for each day

# Get app store page views
views = analytics.app_views              # => Array of dates representing raw data for each day

# Get impressions metrics
impressions = analytics.app_impressions  # => Array of dates representing raw data for each day

# Get app sales
sales = analytics.app_sales              # => Array of dates representing raw data for each day

# Get paying users
users = analytics.paying_users           # => Array of dates representing raw data for each day

# Get in app purchases
iap = analytics.app_in_app_purchases     # => Array of dates representing raw data for each day

# Get app installs
installs = analytics.app_installs        # => Array of dates representing raw data for each day

# Get app sessions
sessions = analytics.app_sessions        # => Array of dates representing raw data for each day

# Get active devices
devices = analytics.app_active_devices   # => Array of dates representing raw data for each day

# Get crashes
crashes = analytics.app_crashes          # => Array of dates representing raw data for each day
```

## License

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
