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

![/assets/AppVersions.png](/assets/AppVersions.png)

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

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
