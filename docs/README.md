# Documentation

- [fastlane guide](https://github.com/fastlane/fastlane/blob/master/docs/Guide.md) to get started. 
- [Actions.md](https://github.com/fastlane/fastlane/blob/master/docs/Actions.md) for all the built-in integrations
- [Bamboo.md](https://github.com/fastlane/fastlane/blob/master/docs/Bamboo.md) for Bamboo specific help
- [Code signing guide](https://github.com/fastlane/fastlane/blob/master/docs/CodeSigning.md) to show you how to do code signing right.
- [FAQs](https://github.com/fastlane/fastlane/blob/master/docs/FAQs.md) for frequently asked questions
- [Advanced.md](https://github.com/fastlane/fastlane/blob/master/docs/Advanced.md) for more advanced settings and tips.
- [Jenkins.md](https://github.com/fastlane/fastlane/blob/master/docs/Jenkins.md) for Jenkins specific help
- [Platforms.md](https://github.com/fastlane/fastlane/blob/master/docs/Platforms.md) for more information about the cross-platform support of `fastlane`.
- [Appfile.md](https://github.com/fastlane/fastlane/blob/master/docs/Appfile.md) describes the `Appfile`
- [Advanced.md](https://github.com/fastlane/fastlane/blob/master/docs/Advanced.md#passing-parameters) to show how to pass parameters to lanes from the command line.
- [Extensions.md](https://github.com/fastlane/fastlane/blob/master/docs/Extensions.md) for more information about local actions and remote plugins
- [Android.md](https://github.com/fastlane/fastlane/blob/master/docs/Android.md) Getting started with fastlane for Android
- [Gitignore.md](https://github.com/fastlane/fastlane/blob/master/docs/Gitignore.md) Recommended content for your `.gitignore` file

## Fastfile

The Fastfile is used to configure `fastlane`. Open it in your favourite text editor, using Ruby syntax highlighting.

Defining lanes is easy. 

```rb
lane :my_lane do
  # Whatever actions you like go in here.
end
```

Make as many lanes as you like!

### `before_all` block

This block will get executed *before* running the requested lane. It supports the same actions as lanes.

```ruby
before_all do |lane|
  cocoapods
end
```

### `after_all` block

This block will get executed *after* running the requested lane. It supports the same actions as lanes.

It will only be called, if the selected lane was executed **successfully**.

```ruby
after_all do |lane|
  say "Successfully finished deployment (#{lane})!"
  slack(
    message: "Successfully submitted new App Update"
  )
  sh "./send_screenshots_to_team.sh" # Example
end
```

### `error` block

This block will get executed when an error occurs, in any of the blocks (*before_all*, the lane itself or *after_all*).

```ruby
error do |lane, exception|
  slack(
    message: "Something went wrong with the deployment.",
    success: false
  )
end
```

## Extensions

The documentation for local actions and plugins was moved to [Extensions.md](https://github.com/fastlane/fastlane/blob/master/docs/Extensions.md).
