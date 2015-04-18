fastlane 1.0 Migration Guide
============================


With `fastlane` `1.0.0` it was necessary to do some breaking changes:

## Changed Integrations:

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

### increment_build_number

You now have to specify the key `build_number` New syntax:

```ruby
increment_build_number(
  build_number: '75' # set a specific number
)
```