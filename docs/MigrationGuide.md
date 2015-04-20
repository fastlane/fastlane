fastlane 1.0 Migration Guide
============================


With `fastlane` `1.0.0` it was necessary to do some breaking changes. More information in the [release notes](https://github.com/KrauseFx/fastlane/releases/tag/0.12.0).

**Important**: When migrating the actions to the new format, don't forget to specify the `fastlane` version on the top of your `Fastfile`:

```ruby
fastlane_version "0.12.0"
```

## Changed Integrations:

### deliver

If you want to pass options to `deliver`, you have to upgrade to the new syntax:

```ruby
deliver(
  beta: true
)
```

All available options:
```ruby
deliver(
  force: true, # Set to true to skip PDF verification
  beta: true, # Upload a new version to TestFlight
  skip_deploy: true, # Set true to not submit app for review (works with both App Store and beta builds)
  deliver_file_path: './nothere' # Specify a path to the directory containing the Deliverfile
)

### increment_build_number

You now have to specify the key `build_number` New syntax:

```ruby
increment_build_number(
  build_number: '75' # set a specific number
)


```

### increment_version_number

You now have to specify the key `bump_type` to make this integration work. New syntax:

```ruby
increment_version_number # Automatically increment patch version number.
increment_version_number(
  bump_type: "patch" # Automatically increment patch version number
)
increment_version_number(
  bump_type: "minor" # Automatically increment minor version number
)
increment_version_number(
  bump_type: "major" # Automatically increment major version number
)
increment_version_number(
  version_number: '2.1.1' # Set a specific version number
)

increment_version_number(
  version_number: '2.1.1',                # specify specific version number (optional, omitting it increments patch version number)
  xcodeproj: './path/to/MyApp.xcodeproj'  # (optional, you must specify the path to your main Xcode project if it is not in the project root directory)
)
```


### snapshot

For `verbose` and `noclean` update your code to this:

```ruby
snapshot(
  verbose: true, 
  noclean: true
)
```
