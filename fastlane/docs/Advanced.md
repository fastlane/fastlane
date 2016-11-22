# Advanced fastlane

## Passing Parameters

To pass parameters from the command line to your lane, use the following syntax:

```
fastlane [lane] key:value key2:value2

fastlane deploy submit:false build_number:24
```

To access those values, change your lane declaration to also include `|options|`

```ruby
before_all do |lane, options|
  ...
end

before_each do |lane, options|
  ...
end

lane :deploy do |options|
  ...
  if options[:submit]
    # Only when submit is true
  end
  ...
  increment_build_number(build_number: options[:build_number])
  ...
end

after_all do |lane, options|
  ...
end

after_each do |lane, options|
  ...
end

error do |lane, exception, options|
  if options[:debug]
    puts "Hi :)"
  end
end
```

## Switching lanes

To switch lanes while executing a lane, use the following code:

```ruby
lane :deploy do |options|
  ...
  build(release: true) # that's the important bit
  hockey
  ...
end

lane :staging do |options|
  ...
  build # it also works when you don't pass parameters
  hockey
  ...
end

lane :build do |options|
  scheme = (options[:release] ? "Release" : "Staging")
  ipa(scheme: scheme)
end
```

`fastlane` takes care of all the magic for you. You can call lanes of the same platform or a general lane outside of the `platform` definition.

Passing parameters is optional.

## Returning values
Additionally, you can retrieve the return value. In Ruby, the last line of the `lane` definition is the return value. Here is an example:

```ruby
lane :deploy do |options|
  value = calculate(value: 3)
  puts value # => 5
end

lane :calculate do |options|
  ...
  2 + options[:value] # the last line will always be the return value
end
```

## Stop executing a lane early

The `next` keyword can be used to stop executing a `lane` before it reaches the end.

```ruby
lane :build do |options|
  if cached_build_available?
    UI.important 'Skipping build because a cached build is available!'
    next # skip doing the rest of this lane
  end
  match
  gym
end

private_lane :cached_build_available? do |options|
  # ...
  true
end
```

When `next` is used during a `lane` switch, control returns to the previous `lane` that was executing.

```ruby
lane :first_lane do |options|
  puts "If you run: `fastlane first_lane`"
  puts "You'll see this!"
  second_lane
  puts "As well as this!"
end

private_lane :second_lane do |options|
  next
  puts "This won't be shown"
end
```

When you stop executing a lane early with `next`, any `after_each` and `after_all` blocks you have will still trigger as usual :+1:

## `before_each` and `after_each` blocks

`before_each` blocks are called before any lane is called. This would include being called before each lane you've switched to.
```ruby
before_each do |lane, options|
  ...
end
```

`after_each` blocks are called after any lane is called. This would include being called after each lane you've switched to.
Just like `after_all`, `after_each` is not called if an error occurs. The `error` block should be used in this case.
```ruby
after_each do |lane, options|
  ...
end
```

e.g. With this scenario, `before_each` and `after_each` would be called 4 times: before the `deploy` lane, before the switch to `archive`, `sign`, and `upload`, and after each of these lanes as well.

```ruby
lane :deploy do
  archive
  sign
  upload
end

lane :archive do
  ...
end

lane :sign do
  ...
end

lane :upload do
  ...
end
```
## Run actions directly

If you just want to try an action without adding them to your `Fastfile` yet, you can use

```sh
fastlane run notification message:"My Text" title:"The Title"
```

To get the avaiable options for any action run `fastlane action [action_name]`. You might not be able to set some kind of parameters using this method.

## Shell values
You can get value from shell commands:
```ruby
output = sh("pod update")
```

## Priorities of parameters and options

The order in which `fastlane` tools take their values from

1. CLI parameter (e.g. `gym --scheme Example`) or Fastfile (e.g. `gym(scheme: 'Example')`)
1. Environment variable (e.g. `GYM_SCHEME`)
1. Tool specific config file (e.g. `Gymfile` containing `scheme 'Example'`)
1. Default value (which might be taken from the `Appfile`, e.g. `app_identifier` from the `Appfile`)
1. If this value is required, you'll be asked for it (e.g. you have multiple schemes, you'll be asked for it)

## Importing another Fastfile

Within your `Fastfile` you can import another `Fastfile` using 2 methods:

### `import`

Import a `Fastfile` from a local path

```ruby
import "../GeneralFastfile"

override_lane :from_general do
  ...
end
```

### `import_from_git`

Import from another git repository, which you can use to have one git repo with a default `Fastfile` for all your project


```ruby
import_from_git(url: 'https://github.com/fastlane/fastlane/tree/master/fastlane')
# or
import_from_git(url: 'git@github.com:MyAwesomeRepo/MyAwesomeFastlaneStandardSetup.git',
               path: 'fastlane/Fastfile')

lane :new_main_lane do
  ...
end
```

This will also automatically import all the local actions from this repo.

### Note

You should import the other `Fastfile` on the top above your lane declarations. When defining a new lane `fastlane` will make sure to not run into any name conflicts. If you want to overwrite an existing lane (from the imported one), use the `override_lane` keyword. 


## Environment Variables
You can define environment variables in a `.env` or `.env.default` file in the same directory as your `Fastfile`. Environment variables are loading using [dotenv](https://github.com/bkeepers/dotenv). Here's an example.

```
WORKSPACE=YourApp.xcworkspace
HOCKEYAPP_API_TOKEN=your-hockey-api-token
```

`fastlane` also has a `--env` option that allows loading of environment specific `dotenv` files. `.env` and `.env.default` will be loaded before environment specific `dotenv` files are loaded. The naming convention for environment specific `dotenv` files is `.env.<environment>`

For example, `fastlane <lane-name> --env development` will load `.env`, `.env.default`, and `.env.development`

## Lane Context

The different actions can *communicate* with each other using a shared hash. You can access them in your lanes with the following code.

Replace `VARIABLE_NAME_HERE` with any of the following.

```ruby
lane_context[SharedValues::LANE_NAME]                 # The name of the current lane (stays the same when switching lanes)
lane_context[SharedValues::BUILD_NUMBER]              # Generated by `increment_build_number`
lane_context[SharedValues::VERSION_NUMBER]            # Generated by `increment_version_number`
lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] # Generated by `snapshot`
lane_context[SharedValues::PRODUCE_APPLE_ID]          # The Apple ID of the newly created app
lane_context[SharedValues::IPA_OUTPUT_PATH]           # Generated by `gym`
lane_context[SharedValues::DSYM_OUTPUT_PATH]          # Generated by `gym`
lane_context[SharedValues::SIGH_PROFILE_PATH]         # Generated by `sigh`
lane_context[SharedValues::SIGH_UUID]                 # The UUID of the generated provisioning profile by `sigh`
lane_context[SharedValues::SIGH_UDID]                 # Deprecated see `SharedValues::SIGH_UUID`
lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK]      # Generated by `hockey`
````

To get information about the available lane variables, run `fastlane action [action_name]`.

## Private lanes

Sometimes you might have a lane that is used from different lanes, for example:

```ruby
lane :production do
  ...
  build(release: true)
  appstore # Deploy to the AppStore
  ...
end

lane :beta do
  ...
  build(release: false)
  crashlytics # Distribute to testers
  ...
end

lane :build do |options|
  ...
  ipa
  ...
end
```

It probably doesn't make sense to execute the `build` lane directly using `fastlane build`. You can hide this lane using

```ruby
private_lane :build do |options|
  ...
end
```

This will hide the lane from:

- `fastlane lanes`
- `fastlane list`
- `fastlane docs`

And also, you can't call the private lane using `fastlane build`.

The resulting private lane can only be called from another lane using the lane switching technology.

## Hide the `fastlane` folder

Just rename the folder to `.fastlane` in case you don't want it to be visible in the Finder.

## Load own actions from external folder

Add this to the top of your `Fastfile`.

```ruby
actions_path '../custom_actions_folder/'
```

## The Appfile

The documentation was moved to [Appfile.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Appfile.md).

## Skip update check when launching `fastlane`

You can set the environment variable `FASTLANE_SKIP_UPDATE_CHECK` to skip the update check.

## Adding Credentials

You can add credentials for use by `fastlane` to your keychain using the [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) command line interface. This is useful for situations like CI environments.

**Adding a Credential**
```
fastlane-credentials add --username felix@krausefx.com
Password: *********
Credential felix@krausefx.com:********* added to keychain.
```

**Removing a Credential**
```
fastlane-credentials remove --username felix@krausefx.com
password has been deleted.
```

## Gitignore

The documentation was moved to [Gitignore.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Gitignore.md).
