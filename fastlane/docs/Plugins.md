# fastlane Plugins

## Local actions

You can create your own actions to extend the functionality of fastlane. The action you create will behave exactly like the built in actions.

Just run `fastlane new_action`, enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`. After you finished writing your action, add it to your version control, so it is available for your whole team.

From then on, you can just use your action in your `Fastfile`, just like any other action.

### Submitting the action to the fastlane main repo
If you think your plugin will be useful to other developers as well, clone fastlane, copy your local action to fastlane/lib/fastlane/actions and submit a pull request.
**TODO**: Add more information about what kind of PRs we want to merge

## Remote plugins

Alternatively you can also keep the action separate from the fastlane code base, so you have the full power and responsibility of maintaining your action and keeping it up to date.

### Add a plugin to your project

```
fastlane add_plugin [name]
```

`fastlane` will assist you on creating the necessary `Plugins` file if that's your first plugin.

What will this do

- Add the plugin to the `fastlane/Plugins` file
- Make sure your `fastlane/Plugins` file is properly referenced from your `./Gemfile`
- Run `bundle install` to make sure all required dependencies are installed on your local machine (this step might ask for your password, which sometimes is required to install native extensions of gem dependencies)

### Install plugins on another machine

```
fastlane install_plugins
```

### Remove a plugin

Open your `fastlane/Plugins` and remove the line that looks like this

```
gem "fastlane-[plugin_name]"
```

### Create your own plugin

TODO: This is not available yet
```
cd ~/Developer/my_plugin

fastlane new_plugin
```

This will do the following:

- Create the directory structure that's needed to have a valid gem
- You need to edit the `lib/fastlane_[plugin_nme]/actions/[plugin_name].rb`
- Easily test the plugin locally by adding the following line to your `Plugins` file
```ruby
gem 'fastlane_[plugin_name]', path: "../../path/to/fastlane-[plugin_name]"
```
- Once you're ready submit a PR to our `PluginsCollections.md` (TODO: How do we call it?)