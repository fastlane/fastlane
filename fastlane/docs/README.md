-----

<h4 align="center">For fastlane guides, check out the new <a href="https://docs.fastlane.tools">docs.fastlane.tools</a> page</h4>

-----

# Documentation

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
You can get more information about the error using the `error_info` property.

```ruby
error do |lane, exception|
  slack(
    message: "Something went wrong with the deployment.",
    success: false,
    payload: { "Error Info" => exception.error_info.to_s } 
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
