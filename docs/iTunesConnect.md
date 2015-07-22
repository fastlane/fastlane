Developer Portal API
====================

# Usage

To quickly play around with `spaceship` launch `irb` in your terminal and execute `require "spaceship"`. 

In general the classes are pre-fixed with the `Tunes` module.

## Login

*Note*: If you use both the Developer Portal and iTunes Connect API, you'll have to login on both, as the user might have different user credentials.

```ruby
Spaceship::Tunes.login("felix@krausefx.com", "password")
```

## Applications

```ruby
# Fetch all available applications
all_apps = Spaceship::Tunes::Application.all

# Find a specific app based on the bundle identifier or Apple ID
app = Spaceship::Tunes::Application.find("com.krausefx.app")
# or
app = Spaceship::Tunes::Application.find(794902327)

# Access information about the app
app.apple_id        # => 1013943394
app.name            # => "Spaceship App"
app.bundle_id       # => "com.krausefx.app"

# Show the names of all your apps
Spaceship::Tunes::Application.all.collect do |app|
  app.name
end

# Create a new app
app = Spaceship::Tunes::Application.create!(name: "App Name", 
                                primary_language: "English", 
                                         version: "1.0", # initial version
                                             sku: 123, 
                                       bundle_id: "com.krausefx.app")
```

## AppVersions

<img src="/assets/docs/AppVersions.png" width="500">

You can have up to 2 app versions at the same time. One is usually the version already available in the App Store (`live_version`) and one being the one you can edit (`edit_version`).

While you usually can modify some values in the production version (e.g. app description), most options are already locked. 

With `spaceship` you can access the versions like this

```ruby
app.live_version # the version that's currently available in the App Store
app.edit_version # the version that's in `Prepare for Submission` mode
```

You can then go ahead and modify app metadata on the version objects:

```ruby
v = app.edit_version

# Access information
v.app_status        # => "Waiting for Review" 
v.version           # => "0.9.14"

# Update app metadata
v.copyright = "#{Time.now.year} Felix Krause"

# Get a list of available languages for this app
v.name.keys         # => ["German", "English"]

# Update localised app metadata
v.name["English"] = "New Title"
v.description["English"] = "App Description"

# Push the changes back to the server
v.save!
```

## Build Trains

<img src="/assets/docs/BuildTrains.png" width="700">

- **version number**: Is set via the `CFBundleShortVersionString` property. It's the version number that appears on the App Store.
- **build number**: Is set via the `CFBundleVersion` property. It's not visible in the App Store. It has to be incrememented before uploading a new build.

A build train contains all builds for a give `version number` (e.g. `0.9.21`). Within the build train you have *n* builds, each having a different `build number` (e.g. `99993`).

```ruby
# Access the build train via the version number
train = app.build_trains["0.9.21"]

train.version_string          # => "0.9.21"
train.testing_enabled         # => false, as testing is enabled for 0.9.20

# Access all builds for a given train
train.builds.count            # => 1
build = train.builds.first
```

## Builds

```ruby
# continue from the BuildTrains example
build.build_version           # => "99993"  (the build number)
build.train_version           # => "0.9.21" (the version number)
build.install_count           # => 1
build.crash_count             # => 0

build.testing_status          # => "Internal" or "External" or "Expired" or "Inactive"
```

You can even submit a build for external beta review
```ruby
parameters = {
  changelog: "Awesome new features",
  description: "Why would I want to provide that?",
  feedback_email: "contact@company.com",
  marketing_url: "http://marketing.com",
  first_name: "Felix",
  last_name: "Krause",
  review_email: "contact@company.com",
  phone_number: "0123456789",

  # Optional Metadata:
  privacy_policy_url: nil,
  review_notes: nil,
  review_user_name: nil,
  review_password: nil,
  encryption: false
}
build.submit_for_beta_review!(parameters)
```

## Processing builds

To also access those builds that are "stuck" at `Processing` at iTunes Connect for a while:

```ruby
app.all_processing_builds       # => Array of processing builds for this application
```

## Submit app for App Store Review

```ruby
submission = app.create_submission

# set app submission information
submission.content_rights_contains_third_party_content = true
submission.content_rights_has_rights = true
submission.add_id_info_uses_idfa = false

# finalize app submission
submission.complete!
```

For a full list of available options, check out [app_submission.rb](https://github.com/fastlane/spaceship/blob/master/lib/spaceship/tunes/app_submission.rb).


### License

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
