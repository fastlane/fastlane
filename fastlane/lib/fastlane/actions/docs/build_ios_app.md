<p align="center">
  <img src="/img/actions/gym.png" width="250">
</p>

-------

<p align="center">
    <a href="#whats-gym">Features</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a>
</p>

-------

<h5 align="center"><code>gym</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

# What's gym?

_gym_ builds and packages iOS apps for you. It takes care of all the heavy lifting and makes it super easy to generate a signed `ipa` or `app` file 💪

_gym_ is a replacement for [shenzhen](https://github.com/nomad/shenzhen).

### Before _gym_

```no-highlight
xcodebuild clean archive -archivePath build/MyApp \
                         -scheme MyApp
xcodebuild -exportArchive \
           -exportFormat ipa \
           -archivePath "build/MyApp.xcarchive" \
           -exportPath "build/MyApp.ipa" \
           -exportProvisioningProfile "ProvisioningProfileName"
```

### With _gym_

```no-highlight
fastlane gym
```

### Why _gym_?

_gym_ uses the latest APIs to build and sign your application which results in much faster build times.

|          |  Gym Features  |
|----------|----------------|
🚀            | _gym_ builds 30% faster than other build tools like [shenzhen](https://github.com/nomad/shenzhen)
🏁 | Beautiful inline build output
📖    | Helps you resolve common build errors like code signing issues
🚠 | Sensible defaults: Automatically detect the project, its schemes and more
🔗  | Works perfectly with [fastlane](https://fastlane.tools) and other tools
📦 | Automatically generates an `ipa` and a compressed `dSYM` file
🚅 | Don't remember any complicated build commands, just _gym_
🔧  | Easy and dynamic configuration using parameters and environment variables
💾   | Store common build settings in a `Gymfile`
📤 | All archives are stored and accessible in the Xcode Organizer
💻 | Supports both iOS and Mac applications

![/img/actions/gymScreenshot.png](/img/actions/gymScreenshot.png)

-----

![/img/actions/gym.gif](/img/actions/gym.gif)

# Usage

```no-highlight
fastlane gym
```

That's all you need to build your application. If you want more control, here are some available parameters:

```no-highlight
fastlane gym --workspace "Example.xcworkspace" --scheme "AppName" --clean
```

If you need to use a different Xcode installation, use `xcode-select` or define `DEVELOPER_DIR`:

```no-highlight
DEVELOPER_DIR="/Applications/Xcode6.2.app" fastlane gym
```

For a list of all available parameters use

```no-highlight
fastlane action gym
```

If you run into any issues, use the `verbose` mode to get more information

```no-highlight
fastlane gym --verbose
```

Set the right export method if you're not uploading to App Store or TestFlight:

```no-highlight
fastlane gym --export_method ad-hoc
```

To pass boolean parameters make sure to use _gym_ like this:

```no-highlight
fastlane gym --include_bitcode true --include_symbols false
```

To access the raw `xcodebuild` output open `~/Library/Logs/gym`

# Gymfile

Since you might want to manually trigger a new build but don't want to specify all the parameters every time, you can store your defaults in a so called `Gymfile`.

Run `fastlane gym init` to create a new configuration file. Example:

```ruby-skip-tests
scheme "Example"

sdk "iphoneos9.0"

clean true

output_directory "./build"    # store the ipa in this folder
output_name "MyApp"           # the name of the ipa file
```

## Export options

Since Xcode 7, _gym_ is using new Xcode API which allows us to specify export options using `plist` file. By default _gym_ creates this file for you and you are able to modify some parameters by using `export_method`, `export_team_id`, `include_symbols` or `include_bitcode`. If you want to have more options, like creating manifest file for app thinning, you can provide your own `plist` file:

```ruby-skip-tests
export_options "./ExportOptions.plist"
```

or you can provide hash of values directly in the `Gymfile`:

```ruby-skip-tests
export_options(
  method: "ad-hoc",
  manifest: {
    appURL: "https://example.com/My App.ipa",
  },
  thinning: "<thin-for-all-variants>"
)
```

Optional: If _gym_ can't automatically detect the provisioning profiles to use, you can pass a mapping of bundle identifiers to provisioning profiles:

```ruby-skip-tests
export_options(
  method: "app-store",
  provisioningProfiles: { 
    "com.example.bundleid" => "Provisioning Profile Name",
    "com.example.bundleid2" => "Provisioning Profile Name 2"
  }
)
```

**Note**: If you use [fastlane](https://fastlane.tools) with [match](https://fastlane.tools/match) you don't need to provide those values manually.

For the list of available options run `xcodebuild -help`.

## Setup code signing

- [More information on how to get started with codesigning](https://docs.fastlane.tools/codesigning/getting-started/)
- [Docs on how to set up your Xcode project](https://docs.fastlane.tools/codesigning/xcode-project/)

## Automating the whole process

_gym_ works great together with [fastlane](https://fastlane.tools), which connects all deployment tools into one streamlined workflow.

Using _fastlane_ you can define a configuration like

```ruby
lane :beta do
  scan
  gym(scheme: "MyApp")
  crashlytics
end

# error block is executed when a error occurs
error do |lane, exception|
  slack(
    # message with short human friendly message
    message: exception.to_s, 
    success: false, 
    # Output containing extended log output
    payload: { "Output" => exception.error_info.to_s } 
  )
end
```

When _gym_ raises an error the `error_info` property will contain the process output
in case you want to display the error in 3rd party tools such as Slack.

You can then easily switch between the beta provider (e.g. `testflight`, `hockey`, `s3` and more).

# How does it work?

_gym_ uses the latest APIs to build and sign your application. The 2 main components are

- `xcodebuild`
- [xcpretty](https://github.com/supermarin/xcpretty)

When you run _gym_ without the `--silent` mode it will print out every command it executes.

To build the archive _gym_ uses the following command:

```no-highlight
set -o pipefail && \
xcodebuild -scheme 'Example' \
-project './Example.xcodeproj' \
-configuration 'Release' \
-destination 'generic/platform=iOS' \
-archivePath '/Users/felixkrause/Library/Developer/Xcode/Archives/2015-08-11/ExampleProductName 2015-08-11 18.15.30.xcarchive' \
archive | xcpretty
```

After building the archive it is being checked by _gym_. If it's valid, it gets packaged up and signed into an `ipa` file.

_gym_ automatically chooses a different packaging method depending on the version of Xcode you're using.

### Xcode 7 and above

```no-highlight
/usr/bin/xcrun path/to/xcbuild-safe.sh -exportArchive \
-exportOptionsPlist '/tmp/gym_config_1442852529.plist' \
-archivePath '/Users/fkrause/Library/Developer/Xcode/Archives/2015-09-21/App 2015-09-21 09.21.56.xcarchive' \
-exportPath '/tmp/1442852529'
```

_gym_ makes use of the new Xcode 7 API which allows us to specify the export options using a `plist` file. You can find more information about the available options by running `xcodebuild --help`.

Using this method there are no workarounds for WatchKit or Swift required, as it uses the same technique Xcode uses when exporting your binary.

Note: the [xcbuild-safe.sh script](https://github.com/fastlane/fastlane/blob/master/gym/lib/assets/wrap_xcodebuild/xcbuild-safe.sh) wraps around xcodebuild to workaround some incompatibilities.

## Use the 'Provisioning Quicklook plugin'
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).
