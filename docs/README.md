# Documentation

All of the ```fastlane``` documentation is available in this directory. 

Check out the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/docs/Guide.md) to get started. Once you're up and running, check out all the awesome stuff you can do in [Actions.md](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md).

Check out the [code signing guide](https://github.com/KrauseFx/fastlane/blob/master/docs/CodeSigning.md).

More advanced settings and tips can be found in [Advanced.md](https://github.com/KrauseFx/fastlane/blob/master/docs/Advanced.md).

`Jenkins` setup can be found in [Jenkins.md](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md).

For more information about multi platform support check out [Platforms.md](https://github.com/KrauseFx/fastlane/blob/master/docs/Platforms.md).

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

Why only use the default actions? Create your own to extend the functionality of `fastlane`.

The build step you create will behave exactly like the built in actions.

Just run `fastlane new_action`. Then enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`.

From then on, you can just start using your action in your `Fastfile`.

If you think your extension can be used by other developers as well, let me know, and we can bundle it with `fastlane`.
