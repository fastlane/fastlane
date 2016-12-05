# Documentation

- [fastlane guide](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Guide.md) to get started. 
- [Actions.md](https://docs.fastlane.tools/actions) for all the built-in integrations
- [Code signing guide](Codesigning) How to get started with code signing and resolve common issues
- [FAQs](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/FAQs.md) for frequently asked questions
- [Advanced.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Advanced.md) for more advanced settings and tips.
- [Platforms.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md) for more information about the cross-platform support of `fastlane`.
- [Appfile.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Appfile.md) describes the `Appfile`
- [Advanced.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Advanced.md#passing-parameters) to show how to pass parameters to lanes from the command line.
- [Android.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Android.md) Getting started with fastlane for Android
- [Gitignore.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Gitignore.md) Recommended content for your `.gitignore` file
- [UI.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/UI.md) More information about how to print out text and ask the user for inputs

### Plugins

- [Plugins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md) Getting started with using and building fastlane plugins
- [AvailablePlugins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/AvailablePlugins.md) A list of all available fastlane plugins
- [PluginsTroubleshooting.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) for help when plugins don't work

### CI Systems

- [Jenkins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Jenkins.md) for Jenkins specific help
- [Circle.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Circle.md) for Circle CI specific help
- [Bamboo.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Bamboo.md) for Bamboo specific help

## Fastfile

The Fastfile is used to configure [fastlane](https://fastlane.tools). Open it in your favourite text editor, using Ruby syntax highlighting.

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

To call another action from within your action, just use the same code you would use in a `Fastfile`:

```ruby
other_action.deliver(text: "Please input your password:", 
                      key: 123)
```

In general, think twice before you do this, most of the times, these action should be separate. Only call actions from within action if it makes sense.
