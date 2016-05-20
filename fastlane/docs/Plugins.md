# fastlane Plugins

## Local actions

You can create your own actions to extend the functionality of fastlane for your project. The action you create will behave exactly like the built in actions.

Just run `fastlane new_action`, enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`. After you finished writing your action, add it to your version control, so it is available for your whole team.

From then on, you can just use your action in your `Fastfile`, just like any other action.

### Submitting the action to the fastlane main repo
If you think your plugin will be useful to other developers as well, clone fastlane, copy your local action to fastlane/lib/fastlane/actions and submit a pull request.
**TODO**: Add more information about what kind of PRs we want to merge

## Remote plugins

Alternatively you can also keep the action separate from the fastlane code base, so you have the full power and responsibility of maintaining your action and keeping it up to date. This is useful if you maintain your own library or web service, and want to make sure the `fastlane` plugin is always up to date.

### Add a plugin to your project

```
fastlane add_plugin [name]
```

`fastlane` will assist you on setting up your project to start using plugins.

What will this do

- Add the plugin to `fastlane/Pluginfile`
- Make sure your `fastlane/Pluginfile` is properly referenced from your `./Gemfile`
- Run `bundle install` to make sure all required dependencies are installed on your local machine (this step might ask for your admin password to install Ruby gems)

### Install plugins on another machine

To make sure all plugins are installed on the local machine, run

```
fastlane install_plugins
```

### Remove a plugin

Open your `fastlane/Plugins` and remove the line that looks like this

```
gem "fastlane_[plugin_name]"
```

### Create your own plugin

```
cd ~/Developer/[plugin_name]

fastlane new_plugin
```

This will do the following:

- Create the directory structure that's needed to have a valid gem
- You need to edit the `lib/fastlane_[plugin_name]/actions/[plugin_name].rb`
- Easily test the plugin locally by adding the following line to your `Plugins` file
```ruby
gem 'fastlane_[plugin_name]', path: "../../path/to/fastlane_[plugin_name]"
```

#### Publishing your plugin

##### RubyGems

The recommended way to publish your plugin is to publish it on [RubyGems.org](https://rubygems.org). You'll first have to create an account, and then push a new release using

```sh
bundle install && rake install
gem push ./pkg/fastlane_[plugin_name]-0.0.1.gem
```

Now all your users can run `fastlane add_plugin [plugin_name]` to install and use your plugin.

##### GitHub

If for some reason you don't want to use RubyGems, you can also make your plugin available on GitHub. Your users then need to add the following to the `Pluginfile`

```ruby
gem "fastlane_[plugin_name]", git: "https://github.com/[user]/[plugin_name]"
```

### Advanced

#### Multiple actions in one plugin

Let's assume you work on a `fastlane` plugin for project management software. You could call it `fastlane_pm` and it may contain any number of actions and helpers, just add them to your `actions` folder.
