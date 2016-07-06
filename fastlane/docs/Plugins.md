# fastlane Plugins

The instructions below require `fastlane` 1.93.0 or higher

## Local actions

You can create your own actions to extend the functionality of fastlane for your project. The action you create will behave exactly like the built in actions.

Just run `fastlane new_action`, enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`. After you finished writing your action, add it to your version control, so it is available for your whole team.

From then on, you can just use your action in your `Fastfile`, just like any other action.

### Submitting the action to the fastlane main repo

Please be aware we may not accept all actions submitted to be bundled with `fastlane`. Before you submit a pull request adding the action to the `fastlane` code base, submit an issue proposing the new action and why it should be built-in.

In general we tend to accept actions that

- Generally usable for a big majority of developers (e.g. basic interactions with git)
- Solve pain points for mobile app developers (iOS and Android)
- have an easy to read documentation and great test coverage

In general, we might not accept actions that

- Solve specific use-cases for only a small subset of developers
- Access the API of a third party service, the third party service should own and maintain the action
- Complex actions, that will require a lot of work to maintain in the future
- Everything that isn't mobile developer related

## Plugins

`fastlane` is an open platform and we enable every developer to extend it to fit their needs. That's why we built a plugin system that allows you and your company to provide `fastlane` plugins to other `fastlane` users. You have the full power and responsibility of maintaining your plugin and keeping it up to date. This is useful if you maintain your own library or web service, and want to make sure the `fastlane` plugin is always up to date.

### Find a plugin

Head over the [AvailablePlugins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/AvailablePlugins.md) for a list of plugins you can use.

List all available plugins using

```
fastlane search_plugins
```

To search for something specific 
```
fastlane search_plugins [query]
```

### Add a plugin to your project

```
fastlane add_plugin [name]
```

`fastlane` will assist you on setting up your project to start using plugins.

This will:

- Add the plugin to `fastlane/Pluginfile`
- Make sure your `fastlane/Pluginfile` is properly referenced from your `./Gemfile`
- Run `fastlane install_plugins` to make sure all required dependencies are installed on your local machine (this step might ask for your admin password to install Ruby gems)
- You'll have 3 new files, that should all be checked into version control: `Gemfile`, `Gemfile.lock` and `fastlane/Pluginfile`

#### Plugin Source

Your `fastlane/Pluginfile` contains the list of all `fastlane` plugins your project uses. The `Pluginfile` is a [Gemfile](http://bundler.io/gemfile.html) that gets imported from your main `Gemfile`.
You specificy all dependencies, including the required version numbers:

```ruby
# Fetched from RubyGems.org
gem "fastlane-plugin-xcversion"

# Fetched from GitHub
gem "fastlane-plugin-xcversion", git: "https://github.com/fastlane/fastlane-plugin-xcversion"

# Fetched from a local directory
gem "fastlane-plugin-xcversion", path: "../fastlane-plugin-xcversion"

# Specify a version requirements
gem "fastlane-plugin-xcversion", "1.1.0"
gem "fastlane-plugin-xcversion", ">= 1.0"
```

[More information about a Gemfile](http://bundler.io/gemfile.html)

### Install plugins on another machine

To make sure all plugins are installed on the local machine, run

```
fastlane install_plugins
```

### Remove a plugin

Open your `fastlane/Pluginfile` and remove the line that looks like this

```
gem "fastlane-plugin-[plugin_name]"
```

### Create your own plugin

```
cd ~/new/folder/

fastlane new_plugin [plugin_name]
```

- `fastlane` creates the directory structure that's needed to be a valid Ruby gem
- Edit the `lib/fastlane/plugin/[plugin_name]/actions/[plugin_name].rb` and implement your action
- Easily test the plugin locally by running `fastlane add_plugin` in your project's directory and specifying the local path when asked for it

##### New plugin for existing gem

If you already have an exiting gem you want to provide a `fastlane` plugin for, you'll still have to create a new Ruby gem. The reason for that is the way plugins are imported.

The example project [xcake](https://github.com/jcampbell05/xcake) contains a folder named `fastlane-plugin-xcake`.

All you have to do if you have an exiting gem:

- Navigate to your gem
- `fastlane new_plugin [plugin_name]`
- Inside the newly created folder, edit the `fastlane-plugin-[plugin_name].gemspec` and add your gem as a dependency. It is recommended to also specify a version number requirement

#### Publishing your plugin

##### RubyGems

The recommended way to publish your plugin is to publish it on [RubyGems.org](https://rubygems.org). Follow the steps below to publish your plugin.

1. Create an account at [RubyGems.org](https://rubygems.org)
2. Publish your plugin to a [GitHub](https://github.com) repo
3. Update the `fastlane-plugin-[plugin_name].gemspec` file so that the `spec.homepage` points to your github repo.
4. Publish the first release of your plugin:
```sh
bundle install
rake install
rake release
```

Now all your users can run `fastlane add_plugin [plugin_name]` to install and use your plugin.

##### GitHub

If for some reason you don't want to use RubyGems, you can also make your plugin available on GitHub. Your users then need to add the following to the `Pluginfile`

```ruby
gem "fastlane-plugin-[plugin_name]", git: "https://github.com/[user]/[plugin_name]"
```

### Advanced

#### Multiple actions in one plugin

Let's assume you work on a `fastlane` plugin for project management software. You could call it `fastlane-plugin-pm` and it may contain any number of actions and helpers, just add them to your `actions` folder. Make sure to mention the available actions in your plugin's `README.md`.
