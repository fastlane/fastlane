# fastlane extensions

### Local actions

You can create your own actions to extend the functionality of `fastlane`. The action you create will behave exactly like the built in actions.

Just run `fastlane new_action`. Then enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`.

From then on, you can just start using your action in your `Fastfile`.

### Submitting the action to the fastlane main repo

If you think your extension will be useful to other developers as well, clone fastlane, copy your local action to `fastlane/lib/fastlane/actions` and submit a pull request.

### Remote plugins

If you want to keep your action implementation separate from the `fastlane` main code base, you can provide it as a remote plugin.

You can take a look at the example repo [https://github.com/fastlane/plugin_example](https://github.com/fastlane/plugin_example). You can store the action anywhere in your repo, to use it in your `Fastfile`, just add this to your `Fastfile`

```ruby
lane :beta do
  load_plugin(url: "https://github.com/fastlane/plugin_example")
  remote_plugin # that's the action that is stored in this git repo
end
```

Additionally you can also provide the path to the action

```ruby
lane :beta do
  # assuming the action file is the actions subfolder:
  load_plugin(url: "https://github.com/fastlane/plugin_example", 
             path: "actions/remote_plugin")
  remote_plugin
end
```

**Reminder**: When you want to import a `Fastfile` and all its local actions from a git repository, you can use the `import_from_git` action, more information in [Advanced.md](https://github.com/fastlane/fastlane/blob/master/docs/Advanced.md#import_from_git).

### Calling actions from other actions

To call another action from within your action, use the following code:

```ruby
  Actions::DeliverAction.run(text: "Please input your password:", 
                              key: 123)
```

In general, think twice before you do this, most of the times, these action should be separate. Only call actions from within action if it makes sense.
