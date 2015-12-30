# Actions

There are lots of predefined `fastlane` actions you can use. If you have ideas for more, please [let me know](https://github.com/KrauseFx/fastlane/issues/new).

To get the most up-to-date information from the command line on your current verion you can also run:

```sh
fastlane actions: List all available fastlane actions
fastlane action [action_name]:
```

You can import another `Fastfile` by using the `import` action. This is useful if you have shared lanes across multiple apps and you want to store a `Fastfile` in a separate folder. The path must be relative to the `Fastfile` this is called from.

```ruby
import './path/to/other/Fastfile'
```

- [Building](#building)
- [Testing](#testing)
- [Deploying](#deploying)
- [Modifying Project](#modifying-project)
- [Developer Portal](#developer-portal)
- [Using git](#using-git)
- [Using mercurial](#using-mercurial)
- [Notifications](#notifications)
- [Misc](#misc)

## Building

### [Bundler](http://bundler.io/)

This will install your Gemfile by executing `bundle install`

```ruby
bundle_install
```

### [CocoaPods](http://cocoapods.org)

If you use [CocoaPods](http://cocoapods.org) you can use the `cocoapods` integration to run `pod install` before building your app.

```ruby
cocoapods # this will run pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

This will execute `carthage bootstrap`

```ruby
carthage
```

More options are available:

```ruby
carthage(
  use_ssh: false,         # Use SSH for downloading GitHub repositories.
  use_submodules: false,  # Add dependencies as Git submodules.
  use_binaries: true,     # Check out dependency repositories even when prebuilt frameworks exist
  platform: "all"         # Define which platform to build for
)
```

### [gym](https://github.com/fastlane/gym)

`gym` builds and packages iOS apps for you. It takes care of all the heavy lifting and makes it super easy to generate a signed `ipa` file.

```ruby
gym(scheme: "MyApp", workspace: "MyApp.xcworkspace")
```

There are many more options available, you can use `gym --help` to get the latest list of available options.

```ruby
gym(
  workspace: "MyApp.xcworkspace",
  configuration: "Debug",
  scheme: "MyApp",
  silent: true,
  clean: true,
  output_directory: "path/to/dir", # Destination directory. Defaults to current directory.
  output_name: "my-app.ipa",       # specify the name of the .ipa file to generate (including file extension)
  sdk: "10.0"                     # use SDK as the name or path of the base SDK when building the project.
)
```

Use `gym --help` to get all available options.

The alternative to `gym` is [`ipa`](#ipa) which uses [shenzhen](https://github.com/nomad/shenzhen) under the hood.

### verify_xcode

Verifies that the Xcode installation is properly signed by Apple. This is relevant after recent [attacks targeting Xcode](http://researchcenter.paloaltonetworks.com/2015/09/novel-malware-xcodeghost-modifies-xcode-infects-apple-ios-apps-and-hits-app-store/).

Add this action to your `appstore` lane. Keep in mind this action might take several minutes to be completed.

```ruby
verify_xcode
```

### [snapshot](https://github.com/KrauseFx/snapshot)

```ruby
snapshot
```

Other options (`snapshot --help`)

```ruby
snapshot(
  skip_open_summary: true,
  clean: true
)
```

Take a look at the [prefilling data guide](https://github.com/KrauseFx/snapshot#prefilling) on the `snapshot` documentation.

### clear_derived_data

Clears the Xcode Derived Data at path `~/Library/Developer/Xcode/DerivedData`

```ruby
clear_derived_data
```

### ipa

Build your app right inside `fastlane` and the path to the resulting ipa is automatically available to all other actions.

You should check out the [code signing guide](https://github.com/KrauseFx/fastlane/blob/master/docs/CodeSigning.md).

```ruby
ipa(
  workspace: "MyApp.xcworkspace",
  configuration: "Debug",
  scheme: "MyApp",
  # (optionals)
  clean: true,                     # This means 'Do Clean'. Cleans project before building (the default if not specified).
  destination: "path/to/dir",      # Destination directory. Defaults to current directory.
  ipa: "my-app.ipa",               # specify the name of the .ipa file to generate (including file extension)
  xcargs: "MY_ADHOC=0",            # pass additional arguments to xcodebuild when building the app.
  embed: "my.mobileprovision",     # Sign .ipa file with .mobileprovision
  identity: "MyIdentity",          # Identity to be used along with --embed
  sdk: "10.0",                     # use SDK as the name or path of the base SDK when building the project.
  archive: true                    # this means 'Do Archive'. Archive project after building (the default if not specified).
)
```

The `ipa` action uses [shenzhen](https://github.com/nomad/shenzhen) under the hood.

The path to the `ipa` is automatically used by `Crashlytics`, `Hockey` and `DeployGate`.


**Important:**

To also use it in `deliver`, update your `Deliverfile` and remove all code in the `Building and Testing` section, in particular all `ipa` and `beta_ipa` blocks.

See how [Product Hunt](https://github.com/fastlane/examples/blob/master/ProductHunt/Fastfile) uses the `ipa` action.


### update_project_provisioning

You should check out the [code signing guide](https://github.com/KrauseFx/fastlane/blob/master/docs/CodeSigning.md) before using this action.

Updates your Xcode project to use a specific provisioning profile for code signing, so that you can properly build and sign the .ipa file using the [ipa](#ipa) action or a CI service.

Since you have to use different provisioning profiles for various targets (WatchKit, Extension, etc.) and configurations (Debug, Release) you can use the `target_filter` and `build_configuration` options:

```ruby
update_project_provisioning(
  xcodeproj: "Project.xcodeproj",
  profile: "./watch_app_store.mobileprovision", # optional if you use sigh
  target_filter: ".*WatchKit Extension.*", # matches name or type of a target
  build_configuration: "Release"
)
```

The `target_filter` and `build_configuration` options use standard regex, so if you want an exact match for a target, use `^MyTargetName$` to prevent a match for the `Pods - MyTargetName` target, for instance.

**[Example Usage at MindNode](https://github.com/fastlane/examples/blob/4fea7d2f16b095e09af409beb4da8a264be2301e/MindNode/Fastfile#L5-L47)**

### update_app_group_identifiers
Updates the App Group Identifiers in the given Entitlements file, so you can have app groups for the app store build and app groups for an enterprise build.

```ruby
update_app_group_identifiers(
	entitlements_file: '/path/to/entitlements_file.entitlements',
	app_group_identifiers: ['group.your.app.group.identifier'])
```

### [xcode_install](https://github.com/neonichu/xcode-install)

Makes sure a specific version of Xcode is installed. If that's not the case, it will automatically be downloaded by the [xcode_install](https://github.com/neonichu/xcode-install) gem.

This will make sure to use the correct Xcode for later actions.

```ruby
xcode_install(version: "7.1")
```

### [xcode_select](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcode-select.1.html)
Use this command if you are supporting multiple versions of Xcode

```ruby
xcode_select "/Applications/Xcode6.1.app"
```

### [Xcake](https://github.com/jcampbell05/xcake/)

If you use [Xcake](https://github.com/jcampbell05/xcake/) you can use the `xcake` integration to run `xcake` before building your app.

```ruby
xcake
```

### [resign](https://github.com/krausefx/sigh#resign)
This will resign an ipa with another signing identity and provisioning profile.

If you have used the `ipa` and `sigh` actions, then this action automatically gets the `ipa` and `provisioning_profile` values respectively from those actions and you don't need to manually set them (although you can always override them).

```ruby
resign(
  ipa: 'path/to/ipa', # can omit if using the `ipa` action
  signing_identity: 'iPhone Distribution: Luka Mirosevic (0123456789)',
  provisioning_profile: 'path/to/profile', # can omit if using the `sigh` action
)
```

You may provide multiple provisioning profiles if the application contains nested applications or app extensions, which need their own provisioning profile. You can do so by passing an array of provisiong profile strings or a hash that associates provisioning profile values to bundle identifier keys.

```ruby
resign(
  ipa: 'path/to/ipa', # can omit if using the `ipa` action
  signing_identity: 'iPhone Distribution: Luka Mirosevic (0123456789)',
  provisioning_profile: {
  	'com.example.awesome-app' => 'path/to/profile',
  	'com.example.awesome-app.app-extension' => 'path/to/app-extension/profile'
  }
)
```

### `create_keychain`

Create a new keychain, which can then be used to import certificates.

```ruby
create_keychain(
  name: "KeychainName",
  default_keychain: true,
  unlock: true,
  timeout: 3600,
  lock_when_sleeps: true
)
```

### `unlock_keychain`

Unlock an existing keychain and add it to the keychain search list.

```ruby
unlock_keychain(
  path: "/path/to/KeychainName.keychain",
  password: "mysecret"
)
```

If the keychain file is located in the standard location `~/Library/Keychains`, then it is sufficient to provide the keychain file name, or file name with its suffix.

```ruby
unlock_keychain(
  path: "KeychainName",
  password: "mysecret"
)
```

### `delete_keychain`

Delete a keychain, can be used after creating one with `create_keychain`.

```ruby
delete_keychain(name: "KeychainName")
```

### `import_certificate`

Import certificates into the current default keychain. Use `create_keychain` to create a new keychain.

```ruby
import_certificate certificate_path: "certs/AppleWWDRCA.cer"
import_certificate certificate_path: "certs/dist.p12", certificate_password: ENV['CERT_PASSWORD']
```

### [xcodebuild](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html)
Enables the use of the `xcodebuild` tool within fastlane to perform xcode tasks
such as; archive, build, clean, test, export & more.

You should check out the [code signing guide](https://github.com/KrauseFx/fastlane/blob/master/docs/CodeSigning.md).

```ruby
# Create an archive. (./build-dir/MyApp.xcarchive)
xcodebuild(
  archive: true,
  archive_path: './build-dir/MyApp.xcarchive',
  scheme: 'MyApp',
  workspace: 'MyApp.xcworkspace'
)
```

`build_settings` are variables which are exposed inside the build process as ENV variables, and can be used to override project settings, or dynamically set values inside a Plist.

`output_style` sets the output format of the console output. Supported options are: 1) `:standard`, this is the default and will output pretty colored UTF8, and 2) `:basic`, which will output monochrome ASCII, useful for a CI environment like TeamCity that doesn't support color/UTF8.

```ruby
xcodebuild(
  workspace: "...",
  scheme: "...",
  build_settings: {
    "CODE_SIGN_IDENTITY" => "iPhone Developer: ...",
    "PROVISIONING_PROFILE" => "...",
    "JOBS" => 16
  },
  output_style: :basic
)
```

To keep your Fastfile lightweight, there are also alias actions available for
the most common `xcodebuild` operations: `xcarchive`, `xcbuild`, `xcclean`, `xctest` & `xcexport`.

Environment variables may be added to a .env file in place of some parameters:

```
XCODE_PROJECT="./MyApp.xcodeproj"
XCODE_WORKSPACE="./MyApp.xcworkspace"
XCODE_SCHEME="MyApp"
XCODE_BUILD_PATH="./build"
```

More usage examples (assumes the above .env setup is being used):
```ruby
  # Clean the project
  xcclean

  # Build the project
  xcbuild

  # Run tests in given simulator
  xctest(
    destination: "name=iPhone 5s,OS=8.1"
  )

  # Create an archive (./build-dir/MyApp.xcarchive)
  xcarchive

  # Export a signed binary (./build-dir/MyApp.ipa)
  xcexport
```

See how [Wikipedia](https://github.com/fastlane/examples/blob/master/Wikipedia/Fastfile) uses the `xctest` action to test their app.

### copy_artifacts
This action copies artifacs to a target directory. It's useful if you have a CI that will pick up these artifacts and attach them to the build. Useful e.g. for storing your `.ipa`s, `.dSYM.zip`s, `.mobileprovision`s, `.cert`s

Make sure your target_path is gitignored, and if you use `reset_git_repo`, make sure the artifacts are added to the exclude list

Example in conjunction with reset_git_repo
```ruby
# Move our artifacts to a safe location so TeamCity can pick them up
copy_artifacts(
  target_path: 'artifacts',
  artifacts: ['*.cer', '*.mobileprovision', '*.ipa', '*.dSYM.zip']
)

# Reset the git repo to a clean state, but leave our artifacts in place
reset_git_repo(
  exclude: 'artifacts'
)
```

### clean_build_artifacts
This action deletes the files that get created in your repo as a result of running the `ipa` and `sigh` commands. It doesn't delete the `fastlane/report.xml` though, this is probably more suited for the .gitignore.

Useful if you quickly want to send out a test build by dropping down to the command line and typing something like `fastlane beta`, without leaving your repo in a messy state afterwards.

```ruby
clean_build_artifacts
```

See how [Artsy](https://github.com/fastlane/examples/blob/master/Artsy/eidolon/Fastfile) cleans their build artifacts after building and distributing their app.

### [frameit](https://github.com/KrauseFx/frameit)
By default, the device color will be black
```ruby
frameit
```

To use white (sorry, silver) device frames
```ruby
frameit :silver
```

See how [MindNode](https://github.com/fastlane/examples/blob/master/MindNode/Fastfile) uses `frameit` to not only frame the screenshots, but also add a title and a background around the screenshots. More information available in their [Fastfile](https://github.com/fastlane/examples/blob/master/MindNode/Fastfile) and the [screenshots folder](https://github.com/fastlane/examples/tree/master/MindNode/screenshots) ([Framefile.json](https://github.com/fastlane/examples/blob/master/MindNode/screenshots/Framefile.json))

### dsym_zip

Create a zipped dSYM file from your `.xcarchive`, useful if you use the `xcodebuild` action in combination with `crashlytics` or `hockey`.

```ruby
dsym_zip
```

You can manually specify the path to the xcarchive (not needed if you use `xcodebuild`/`xcarchive` to build your archive):

```ruby
dsym_zip(
  archive_path: 'MyApp.xcarchive'
)
```

### splunkmint

Uploads dSYM.zip file to [Splunk MINT](https://mint.splunk.com) for crash symbolication.

```ruby
splunkmint(
	dsym: "My.app.dSYM.zip",
	api_key: "43564d3a",
	api_token: "e05456234c4869fb7e0b61"
)
```

If you use `gym` the `dsym` parameter is optional.

### recreate_schemes

Recreate shared Xcode project schemes if the `Shared` checkbox was not enabled.

```ruby
recreate_schemes(
  project: './path/to/MyApp.xcodeproj'
)
```

## Testing

### [scan](https://github.com/KrauseFx/scan)

`scan` makes it super easy to run tests of your iOS and Mac applications

```ruby
scan
```

You can define all options that are available in `scan --help`

```ruby
scan(
  workspace: "App.xcworkspace",
  scheme: "MyTests",
  clean: false
)
```

### xctest

Use the `xctest` command to run unit tests.

When running tests, coverage reports can be generated via [xcpretty](https://github.com/supermarin/xcpretty) reporters:
```ruby
  # Run tests in given simulator
  xctest(
    destination: "name=iPhone 5s,OS=8.1",
    destination_timeout: 120, # increase device/simulator timeout, usually used on slow CI boxes
    reports: [{
      report: 'html',
      output: './build-dir/test-report.html',  # will use XCODE_BUILD_PATH/report, if output is not provided
      screenshots: 1
    },
    {
      report: 'junit',
      output: './build-dir/test-report.xml'
    }]
  )
```

### [xctool](https://github.com/facebook/xctool)

You can run any `xctool` action. This will require having [xctool](https://github.com/facebook/xctool) installed through [homebrew](http://brew.sh/).

```ruby
xctool :test
```

It is recommended to have the `xctool` configuration stored in a [`.xctool-args`](https://github.com/facebook/xctool#configuration-xctool-args) file.

If you prefer to have the build configuration stored in the `Fastfile`:

```ruby
xctool :test, [
      "--workspace", "'AwesomeApp.xcworkspace'",
      "--scheme", "'Schema Name'",
      "--configuration", "Debug",
      "--sdk", "iphonesimulator",
      "--arch", "i386"
    ].join(" ")
```

### [slather](https://github.com/venmo/slather)

> Generate test coverage reports for Xcode projects & hook it into CI.

```ruby
slather(
  build_directory: 'foo',
  input_format: 'bah',
  scheme: 'Foo',
  proj: 'foo.xcodeproj'
)
```

### [gcovr](http://gcovr.com/)
Generate summarized code coverage reports.

```ruby
gcovr(
  html: true,
  html_details: true,
  output: "./code-coverage/report.html"
)
```

### [lcov](http://ltp.sourceforge.net/coverage/lcov.php)
Generate code coverage reports based on lcov.

```ruby
lcov(
  project_name: "yourProjectName",
  scheme: "yourScheme",
  output_dir: "cov_reports" # This value is optional. Default is coverage_reports
)
```

### [OCLint](http://oclint.org)
Run the static analyzer tool [OCLint](http://oclint.org) for your project. You need to have a `compile_commands.json` file in your `fastlane` directory or pass a path to your file.

```
oclint(
  compile_commands: 'commands.json', # The json compilation database, use xctool reporter 'json-compilation-database'
  select_reqex: /ViewController.m/,  # Select all files matching this reqex
  report_type: 'pmd',                # The type of the report (default: html)
  max_priority_1: 10,                # The max allowed number of priority 1 violations
  max_priority_2: 100,               # The max allowed number of priority 2 violations
  max_priority_3: 1000,              # The max allowed number of priority 3 violations
  rc: 'LONG_LINE=200'                # Override the default behavior of rules
)  
```

### [SwiftLint](https://github.com/realm/SwiftLint)
Run SwiftLint for your project.

```
swiftlint(
  output_file: 'swiftlint.result.json', # The path of the output file (optional)
  config_file: '.swiftlint-ci.yml'      # The path of the configuration file (optional)
)
```

### `ensure_no_debug_code`

You don't want any debug code to slip into production. You can use the `ensure_no_debug_code` action to make sure no debug code is in your code base before deploying it:

```ruby
ensure_no_debug_code(text: "// TODO")
```

```ruby
ensure_no_debug_code(text: "NSLog",
                     path: "./lib",
                extension: "m")
```

### [Appium](http://appium.io/)

Run UI testing by `Appium::Driver` with RSpec.

```ruby
appium(
  app_path:  "appium/apps/TargetApp.app",
  spec_path: "appium/spec",
  platform:  "iOS",
  caps: {
    versionNumber: "9.1",
    deviceName:    "iPhone 6"
  }
)
```

## Deploying

### [pilot](https://github.com/fastlane/pilot)

```ruby
pilot(username: "felix@krausefx.com",
      app_identifier: "com.krausefx.app")
```

More information about the available options `fastlane action pilot` and a more detailed description on the [pilot project page](https://github.com/fastlane/pilot).

### [deliver](https://github.com/KrauseFx/deliver)
```ruby
deliver
```

To upload a new build to TestFlight use `pilot` instead.

If you don't want a PDF report for App Store builds, append ```:force``` to the command. This is useful when running ```fastlane``` on your Continuous Integration server: `deliver(force: true)`

Other options

```ruby
deliver(
  force: true, # Set to true to skip PDF verification
  email: "itunes@connect.com" # different Apple ID than the dev portal
)
```

See how [Product Hunt](https://github.com/fastlane/examples/blob/master/ProductHunt/Fastfile) automated the building and distributing of a beta version over TestFlight in their [Fastfile](https://github.com/fastlane/examples/blob/master/ProductHunt/Fastfile).

**Note:** There is an action named `appstore` which is a convenince alias to `deliver`.

### TestFlight

To upload a new binary to Apple TestFlight use the `testflight` action:

```ruby
testflight
```

This will use [deliver](https://github.com/KrauseFx/deliver) under the hood.

Additionally you can skip the submission of the new binary to the testers to only upload the build:

```ruby
testflight(skip_deploy: true)
```

### [HockeyApp](http://hockeyapp.net)
```ruby
hockey(
  api_token: '...',
  ipa: './app.ipa',
  notes: "Changelog"
)
```

Symbols will also be uploaded automatically if a `app.dSYM.zip` file is found next to `app.ipa`. In case it is located in a different place you can specify the path explicitly in `:dsym` parameter.

More information about the available options can be found in the [HockeyApp Docs](http://support.hockeyapp.net/kb/api/api-versions#upload-version).

See how [Artsy](https://github.com/fastlane/examples/blob/master/Artsy/eidolon/Fastfile) distributes new builds via Hockey in their [Fastfile](https://github.com/fastlane/examples/blob/master/Artsy/eidolon/Fastfile).

### [Crashlytics Beta](http://try.crashlytics.com/beta/)
```ruby
crashlytics(
  crashlytics_path: './Crashlytics.framework', # path to your 'Crashlytics.framework'
  api_token: '...',
  build_secret: '...',
  ipa_path: './app.ipa'
)
```
Additionally you can specify `notes`, `emails`, `groups` and `notifications`.

The following environment variables may be used in place of parameters: `CRASHLYTICS_API_TOKEN`, `CRASHLYTICS_BUILD_SECRET`, and `CRASHLYTICS_FRAMEWORK_PATH`.

### AWS S3 Distribution

Upload a new build to Amazon S3 to distribute the build to beta testers. Works for both Ad Hoc and Enterprise signed applications. This step will generate the necessary HTML, plist, and version files for you.

Add the `s3` action after the `ipa` step:

```ruby
s3
```

You can also customize a lot of options:
```ruby
s3(
  # All of these are used to make Shenzhen's `ipa distribute:s3` command
  access_key: ENV['S3_ACCESS_KEY'],               # Required from user.
  secret_access_key: ENV['S3_SECRET_ACCESS_KEY'], # Required from user.
  bucket: ENV['S3_BUCKET'],                       # Required from user.
  ipa: 'AppName.ipa',                             # Optional is you use `ipa` to build
  dsym: 'AppName.app.dSYM.zip',                   # Optional is you use `ipa` to build
  path: 'v{CFBundleShortVersionString}_b{CFBundleVersion}/', # This is actually the default.
  upload_metadata: true,                          # Upload version.json, plist and HTML. Set to false to skip uploading of these files.
  version_file_name: 'app_version.json',          # Name of the file to upload to S3. Defaults to 'version.json'
  version_template_path: 'path/to/erb'            # Path to an ERB to configure the structure of the version JSON file
)
```

It is recommended to **not** store the AWS access keys in the `Fastfile`.

The uploaded `version.json` file provides an easy way for apps to poll if a new update is available. The JSON looks like:

```json
{
    "latestVersion": "<%= full_version %>",
    "updateUrl": "itms-services://?action=download-manifest&url=<%= url %>"
}
```

### [DeployGate](https://deploygate.com/)

You can retrieve your username and API token on [your settings page](https://deploygate.com/settings).

```ruby
deploygate(
  api_token: '...',
  user: 'target username or organization name',
  ipa: './ipa_file.ipa',
  message: "Build #{lane_context[SharedValues::BUILD_NUMBER]}",
)
```

If you put `deploygate` after `ipa` action, you don't have to specify IPA file path, as it is extracted from the lane context automatically.

More information about the available options can be found in the [DeployGate Push API document](https://deploygate.com/docs/api).

### [Xcode Server](https://www.apple.com/uk/support/osxserver/xcodeserver/)

This action retrieves integration assets (`.xcarchive`, logs etc) from your Xcode Server instance over HTTPS.

```ruby
xcode_server_get_assets(
    host: '10.99.0.59', # Specify Xcode Server's Host or IP Address
    bot_name: 'release-1.3.4' # Specify the particular Bot
  )
```

This allows you to use Xcode Server for building and testing, which can be useful when your build takes a long time and requires connected iOS devices for testing. This action only requires you specify the `host` and the `bot_name` and it will go and download, unzip and return a path to the downloaded folder. Then you can export an IPA from the archive and upload it with `deliver`.

Run `fastlane action xcode_server_get_assets` for the full list of options.

### set_changelog

To easily set the changelog of an app on iTunes Connect for all languages

```ruby
set_changelog(app_identifier: "com.krausefx.app", version: "1.0", changelog: "All Languages")
```

You can store the changelog in `./fastlane/changelog.txt` and it will automatically get loaded from there. This integration is useful if you support e.g. 10 languages and want to use the same "What's new"-text for all languages.

### [GitHub Releases](https://github.com)

This action creates a new release for your repository on GitHub and can also upload specified assets like `.ipa`s and `.app`s, binary files, changelogs etc.

```ruby
github_release = set_github_release(
  repository_name: "krausefx/fastlane",
  api_token: ENV['GITHUB_TOKEN'],
  name: "Super New actions",
  tag_name: "v1.22.0",
  description: File.read("changelog"),
  commitish: "master",
  upload_assets: ["example_integration.ipa", "./pkg/built.gem"]
)
```

### [artifactory](http://www.jfrog.com/artifactory/)

This allows you to upload your ipa, or any other file you want, to artifactory.

```ruby
artifactory(
  username: "username",
  password: "password",
  endpoint: "https://artifactory.example.com/artifactory/",
  file: 'example.ipa',                                # File to upload
  repo: 'mobile_artifacts',                           # Artifactory repo
  repo_path: '/ios/appname/example-major.minor.ipa'   # Path to place the artifact including its filename
)
```

To get a list of all available parameters run `fastlane action artifactory`

### [nexus_upload](http://www.sonatype.com/nexus/)

Upload your ipa, or any other file you want, to Sonatype Nexus platform.

```ruby
nexus_upload(
  file: "/path/to/file.ipa",
  repo_id: "artefacts",
  repo_group_id: "com.fastlane",
  repo_project_name: "ipa",
  repo_project_version: "1.13",
  endpoint: "http://localhost:8081",
  username: "admin",
  password: "admin123"
)
```

### [Appetize.io](https://appetize.io/)

Upload your zipped app to Appetize.io

```ruby
appetize(
  api_token: 'yourapitoken',
  url: 'https://example.com/your/zipped/app.zip',
  private_key: 'yourprivatekey'
)
```

### [appaloosa](https://www.appaloosa-store.com)
​
Upload your ipa or apk to your private store on Appaloosa.
​
Add the `appaloosa` action after the `gym` step or use it with your existing `apk`.
​
You can add some options:
```ruby
appaloosa(
  binary: '/path/to/binary.ipa', # path tor your IPA or APK
  store_id: 'your_store_id', # you'll be asked for your email if you are not already registered 
  api_token: 'your_api_key', # only if already registered
  group_ids: '112, 232, 387', # User group_ids visibility, if it's not specified we 'll publish the app for all users in your store'
  # screenshots: after snapshot step:
  locale: 'en-US', # When multiple values are specified in the Snapfile, we default to 'en-US'.
  device: 'iPhone6', # By default, the screenshots from the last device will be used.
  # or you can specify your own screenshots folder :
  screenshots: '/path/to_your/screenshots' # path to the screenshots folder of your choice
  )
```

### [Tryouts.io](https://tryouts.io/)

Upload your Android or iOS build to [Tryouts.io](https://tryouts.io/)

```ruby
tryouts(
  api_token: "...",
  app_id: "application-id",
  build_file: "test.ipa",
)
```

For more information about the available options, run `fastlane action tryouts` or check out the [Tryouts Documentation](http://tryouts.readthedocs.org/en/latest/releases.html#create-release).

### [Installr](https://www.installrapp.com)

Upload your iOS build to [Installr](https://www.installrapp.com)

```ruby
installr(
  api_token: "...",
  ipa: "test.ipa",
  notes: "The next great version of the app!",
  notify: "dev,qa"
  add: "exec,ops"
)
```

For more information about the available options, run `fastlane action installr` or check out the [Installr Documentation](http://help.installrapp.com/api/).

### [TestFairy](https://testfairy.com/)

Upload your iOS build to [TestFairy](https://testfairy.com/)

You can retrieve your API key on [your settings page](https://free.testfairy.com/settings/).

```ruby
testfairy(
  api_key: '...',
  ipa: './ipa_file.ipa',
  comment: "Build #{lane_context[SharedValues::BUILD_NUMBER]}",
)
```

## Modifying Project

### [increment_build_number](https://developer.apple.com/library/ios/qa/qa1827/_index.html)
This method will increment the **build number**, not the app version. Usually this is just an auto incremented number. You first have to [set up your Xcode project](https://developer.apple.com/library/ios/qa/qa1827/_index.html), if you haven't done it already.

```ruby
increment_build_number # automatically increment by one
increment_build_number(
  build_number: '75' # set a specific number
)

increment_build_number(
  build_number: 75, # specify specific build number (optional, omitting it increments by one)
  xcodeproj: './path/to/MyApp.xcodeproj' # (optional, you must specify the path to your main Xcode project if it is not in the project root directory)
)
```

See how [Wikpedia](https://github.com/fastlane/examples/blob/master/Wikipedia/Fastfile) uses the `increment_build_number` action.

You can also only receive the build number without modifying it

```ruby
build_number = get_build_number(xcodeproj: "Project.xcodeproj")
```

### [increment_version_number](https://developer.apple.com/library/ios/qa/qa1827/_index.html)
This action will increment the **version number**. You first have to [set up your Xcode project](https://developer.apple.com/library/ios/qa/qa1827/_index.html), if you haven't done it already.

```ruby
increment_version_number # Automatically increment patch version number.
increment_version_number(
  bump_type: "patch" # Automatically increment patch version number
)
increment_version_number(
  bump_type: "minor" # Automatically increment minor version number
)
increment_version_number(
  bump_type: "major" # Automatically increment major version number
)
increment_version_number(
  version_number: '2.1.1' # Set a specific version number
)

increment_version_number(
  version_number: '2.1.1',                # specify specific version number (optional, omitting it increments patch version number)
  xcodeproj: './path/to/MyApp.xcodeproj'  # (optional, you must specify the path to your main Xcode project if it is not in the project root directory)
)
```

See how [Wikpedia](https://github.com/fastlane/examples/blob/master/Wikipedia/Fastfile) uses the `increment_version_number` action.

You can also only receive the version number without modifying it

```ruby
version = get_version_number(xcodeproj: "Project.xcodeproj")
```

### set_build_number_repository
```ruby
set_build_number_repository
```

This action will set the **build number** according to what the SCM HEAD reports.
Currently supported SCMs are svn (uses root revision), git-svn (uses svn revision) and git (uses short hash).

There are no options currently available for this action.

### update_project_team
This action allows you to modify the developer team. This may be useful if you want to use a different team for alpha, beta or distribution.

```ruby
update_project_team(
  path: "Example.xcodeproj",
  teamid: "A3ZZVJ7CNY"
)
```

## update_info_plist

This action allows you to modify your `Info.plist` file before building. This may be useful if you want a separate build for alpha, beta or nightly builds, but don't want a separate target.

```ruby
# update app identifier string
update_info_plist(
  plist_path: "path/to/Info.plist",
  app_identifier: "com.example.newappidentifier"
)

# Change the Display Name of your app
update_info_plist(
  plist_path: "path/to/Info.plist",
  display_name: "MyApp-Beta"
)

# Target a specific `xcodeproj` rather than finding the first available one
update_info_plist(
  xcodeproj: "path/to/Example.proj",
  plist_path: "path/to/Info.plist",
  display_name: "MyApp-Beta"
)
```

## update_url_schemes

This action allows you to update the URL schemes of the app before building it.
For example, you can use this to set a different url scheme for the alpha
or beta version of the app.

```ruby
update_url_schemes(path: "path/to/Info.plist",
            url_schemes: ["com.myapp"])
```

### update_app_identifier

Update an app identifier by either setting `CFBundleIdentifier` or `PRODUCT_BUNDLE_IDENTIFIER`, depending on which is already in use.

```ruby
update_app_identifier(
  xcodeproj: 'Example.xcodeproj', # Optional path to xcodeproj, will use the first .xcodeproj if not set
  plist_path: 'Example/Info.plist', # Path to info plist file, relative to xcodeproj
  app_identifier: 'com.test.example' # The App Identifier
)
```

## Developer Portal

### [match](https://github.com/fastlane/match)

Check out [codesigning.guide](https://codesigning.guide) for more information about the concept of [match](https://github.com/fastlane/match).

`match` allows you to easily sync your certificates and profiles across your team using git. More information on [GitHub](https://github.com/fastlane/match).

```ruby
match(type: "appstore", app_identifier: "tools.fastlane.app")
match(type: "development", readonly: true)
```

### [sigh](https://github.com/KrauseFx/sigh)
This will generate and download your App Store provisioning profile. `sigh` will store the generated profile in the current folder.

```ruby
sigh
```

You can pass all options listed in `sigh --help` in `fastlane`:

```ruby
sigh(
  adhoc: true,
  force: true,
  filename: "myFile.mobileprovision"
)
```

See how [Wikpedia](https://github.com/fastlane/examples/blob/master/Wikipedia/Fastfile) uses `sigh` to automatically retrieve the latest provisioning profile.

### [PEM](https://github.com/KrauseFx/PEM)

This will generate a new push profile if necessary (the old one is about to expire).

Use it like this:

```ruby
pem
```

```ruby
pem(
  force: true, # create a new profile, even if the old one is still valid
  app_identifier: 'net.sunapps.9', # optional app identifier,
  save_private_key: true,
  new_profile: proc do |profile_path| # this block gets called when a new profile was generated
    puts profile_path # the absolute path to the new PEM file
    # insert the code to upload the PEM file to the server
  end
)
```

Use the `fastlane action pem` command to view all available options.

[Product Hunt](https://github.com/fastlane/examples/blob/master/ProductHunt/Fastfile) uses `PEM` to automatically create a new push profile for Parse.com if necessary before a release.

### [cert](https://github.com/KrauseFx/cert)

The `cert` action can be used to make sure to have the latest signing certificate installed. More information on the [`cert` project page](https://github.com/KrauseFx/cert).

```ruby
cert
```

`fastlane` will automatically pass the signing certificate to use to `sigh`.

You can pass all options listed in `sigh --help` in `fastlane`:

```ruby
cert(
  development: true,
  username: "user@email.com"
)
```

### [produce](https://github.com/KrauseFx/produce)

Create new apps on iTunes Connect and Apple Developer Portal. If the app already exists, `produce` will not do anything.

```ruby
produce(
  username: 'felix@krausefx.com',
  app_identifier: 'com.krausefx.app',
  app_name: 'MyApp',
  language: 'English',
  version: '1.0',
  sku: 123,
  team_name: 'SunApps GmbH' # Only necessary when in multiple teams.
)
```

[SunApps](https://github.com/fastlane/examples/blob/master/SunApps/Fastfile#L41-L49) uses `produce` to automatically generate new apps for new customers.

### register_devices
This will register iOS devices with the Developer Portal so that you can include them in your provisioning profiles.

This is an optimistic action, in that it will only ever add new devices to the member center, and never remove devices. If a device which has already been registered within the member center is not passed to this action, it will be left alone in the member center and continue to work.

The action will connect to the Apple Developer Portal using the username you specified in your `Appfile` with `apple_id`, but you can override it using the `username` option, or by setting the env variable `ENV['DELIVER_USER']`.

```ruby
# Simply provide a list of devices as a Hash
register_devices(
  devices: {
    'Luka iPhone 6' => '1234567890123456789012345678901234567890',
    'Felix iPad Air 2' => 'abcdefghijklmnopqrstvuwxyzabcdefghijklmn',
  }
)

# Alternatively provide a standard UDID export .txt file, see the Apple Sample (https://devimages.apple.com.edgekey.net/downloads/devices/Multiple-Upload-Samples.zip)
register_devices(
  devices_file: './devices.txt'
)

# Advanced
register_devices(
  devices_file: './devices.txt', # You must pass in either `devices_file` or `devices`.
  team_id: 'XXXXXXXXXX',         # Optional, if you're a member of multiple teams, then you need to pass the team ID here.
  username: 'luka@goonbee.com'   # Optional, lets you override the Apple Member Center username.
)
```

## Using git

### changelog_from_git_commits
This action turns your git commit history into formatted changelog text.

```ruby
# Collects commits since your last tag and returns a concatenation of their subjects and bodies
changelog_from_git_commits 

# Advanced options
changelog_from_git_commits(
  between: ['7b092b3', 'HEAD'], # Optional, lets you specify a revision/tag range between which to collect commit info
  pretty: '- (%ae) %s', # Optional, lets you provide a custom format to apply to each commit when generating the changelog text
  match_lightweight_tag: false # Optional, lets you ignore lightweight (non-annotated) tags when searching for the last tag
)
```

### ensure_git_branch
This action will check if your git repo is checked out to a specific branch. You may only want to make releases from a specific branch, so `ensure_git_branch` will stop a lane if it was accidentally executed on an incorrect branch.

```ruby
ensure_git_branch # defaults to `master` branch

ensure_git_branch(
  branch: 'develop'
)
```

### last_git_tag

Simple action to get the latest git tag

```ruby
last_git_tag
```

### git_branch

Quickly get the name of the branch you're currently in

```ruby
git_branch
```

### git_commit

To simply commit one file with a certain commit message use

```ruby
git_commit(path: "./version.txt",
        message: "Version Bump")
```

To commit several files with a certain commit message use

```ruby
git_commit(path: ["./version.txt", "./changelog.txt"]
        message: "Version Bump")
```

### ensure_git_status_clean
A sanity check to make sure you are working in a repo that is clean. Especially useful to put at the beginning of your Fastfile in the `before_all` block, if some of your other actions will touch your filesystem, do things to your git repo, or just as a general reminder to save your work. Also needed as a prerequisite for some other actions like `reset_git_repo`.

```ruby
ensure_git_status_clean
```

[Wikipedia](https://github.com/fastlane/examples/blob/master/Wikipedia/Fastfile) uses `ensure_git_status_clean` to make sure, no uncommited changes are deployed by `fastlane.

### commit_version_bump
This action will create a "Version Bump" commit in your repo. Useful in conjunction with `increment_build_number`.

It checks the repo to make sure that only the relevant files have changed, these are the files that `increment_build_number` (`agvtool`) touches:
- All .plist files
- The `.xcodeproj/project.pbxproj` file

Then commits those files to the repo.

Customise the message with the `:message` option, defaults to "Version Bump"

If you have other uncommitted changes in your repo, this action will fail. If you started off in a clean repo, and used the `ipa` and or `sigh` actions, then you can use the `clean_build_artifacts` action to clean those temporary files up before running this action.

```ruby
commit_version_bump

commit_version_bump(
  message: 'Version Bump',                    # create a commit with a custom message
  xcodeproj: './path/to/MyProject.xcodeproj', # optional, if you have multiple Xcode project files, you must specify your main project here
)
```

[Artsy](https://github.com/fastlane/examples/blob/master/Artsy/eidolon/Fastfile) uses `fastlane` to automatically commit the version bump, add a new git tag and push everything back to `master`.

### number_of_commits

You can use this action to get the number of commits of this repo. This is useful if you want to set the build number to the number of commits.

```ruby
build_number = number_of_commits
increment_build_number(build_number: build_number)
```

### add_git_tag
This will automatically tag your build with the following format: `<grouping>/<lane>/<prefix><build_number>`, where:

- `grouping` is just to keep your tags organised under one "folder", defaults to 'builds'
- `lane` is the name of the current fastlane lane
- `prefix` is anything you want to stick in front of the version number, e.g. "v"
- `build_number` is the build number, which defaults to the value emitted by the `increment_build_number` action

For example for build 1234 in the "appstore" lane it will tag the commit with `builds/appstore/1234`

```ruby
add_git_tag # simple tag with default values

add_git_tag(
  grouping: 'fastlane-builds',
  prefix: 'v',
  build_number: 123
)
```

Alternatively, you can specify your own tag. Note that if you do specify a tag, all other arguments are ignored.

```ruby
add_git_tag(
  tag: 'my_custom_tag',
)
```

[Artsy](https://github.com/fastlane/examples/blob/master/Artsy/eidolon/Fastfile) uses `fastlane` to automatically commit the version bump, add a new git tag and push everything back to `master`.

### git_pull

Executes a simple `git pull --tags` command

### push_to_git_remote
Lets you push your local commits to a remote git repo. Useful if you make local changes such as adding a version bump commit (using `commit_version_bump`) or a git tag (using 'add_git_tag') on a CI server, and you want to push those changes back to your canonical/main repo.

Tags will be pushed as well.

```ruby
push_to_git_remote # simple version. pushes 'master' branch to 'origin' remote

push_to_git_remote(
  remote: 'origin',         # optional, default: 'origin'
  local_branch: 'develop',  # optional, aliased by 'branch', default: 'master'
  remote_branch: 'develop', # optional, default is set to local_branch
  force: true,              # optional, default: false
)
```

[Artsy](https://github.com/fastlane/examples/blob/master/Artsy/eidolon/Fastfile) uses `fastlane` to automatically commit the version bump, add a new git tag and push everything back to `master`.

### push_git_tags

If you only want to push the tags and nothing else, you can use the `push_git_tags` action:

```ruby
push_git_tags
```

### reset_git_repo
This action will reset your git repo to a clean state, discarding any uncommitted and untracked changes. Useful in case you need to revert the repo back to a clean state, e.g. after the fastlane run.
Untracked files like `.env` will also be deleted, unless `:skip_clean` is true.

It's a pretty drastic action so it comes with a sort of safety latch. It will only proceed with the reset if either of these conditions are met:

- You have called the `ensure_git_status_clean` action prior to calling this action. This ensures that your repo started off in a clean state, so the only things that will get destroyed by this action are files that are created as a byproduct of the fastlane run.
- You call it with the `force: true` option, in which case "you have been warned".

Also useful for putting in your `error` block, to bring things back to a pristine state (again with the caveat that you have called `ensure_git_status_clean` before)

```ruby
reset_git_repo
reset_git_repo(force: true) # If you don't care about warnings and are absolutely sure that you want to discard all changes. This will reset the repo even if you have valuable uncommitted changes, so use with care!
reset_git_repo(skip_clean: true) # If you want 'git clean' to be skipped, thus NOT deleting untracked files like '.env'. Optional, defaults to false.

# You can also specify a list of files that should be resetted.
reset_git_repo(
  force: true,
  files: [
    "./file.txt"
  ])
```

[MindNode](https://github.com/fastlane/examples/blob/master/MindNode/Fastfile) uses this action to reset temporary changes of the project configuration after successfully building it.

### get_github_release

You can easily receive information about a specific release from GitHub.com

```ruby
release = get_github_release(url: "KrauseFx/fastlane", version: "1.0.0")
puts release['name']
```

To get a list of all available values run `fastlane action get_github_release`.

### import_from_git

Import another Fastfile from a remote git repository to use its lanes.

This is useful if you have shared lanes across multiple apps and you want to store the Fastfile in a remote git repository.

```ruby
import_from_git(
  url: 'git@github.com:KrauseFx/fastlane.git', # The url of the repository to import the Fastfile from.
  branch: 'HEAD', # The branch to checkout on the repository. Defaults to `HEAD`.
  path: 'fastlane/Fastfile' # The path of the Fastfile in the repository. Defaults to `fastlane/Fastfile`.
)
```

### last_git_commit

Get information about the last git commit, returns the author and the git message.

```ruby
commit = last_git_commit
crashlytics(notes: commit[:message])
puts commit[:author]
```

### create_pull_request

Create a new pull request. 

```ruby
create_pull_request(
  api_token: ENV['GITHUB_TOKEN'],
  repo: 'fastlane/fastlane',
  title: 'Amazing new feature',
  head: 'my-feature',           # optional, defaults to current branch name.
  base: 'master',               # optional, defaults to 'master'.
  body: 'Please pull this in!'  # optional
)
```

## Using mercurial

### hg_ensure_clean_status
Along the same lines as the [`ensure_git_status_clean`](#ensure_git_status_clean) action, this is a sanity check to ensure the working mercurial repo is clean. Especially useful to put at the beginning of your Fastfile in the `before_all` block.

```ruby
hg_ensure_clean_status
```

### hg_commit_version_bump
The mercurial equivalent of the [`commit_version_bump`](#commit_version_bump) git action. Like the git version, it is useful in conjunction with [`increment_build_number`](#increment_build_number).

It checks the repo to make sure that only the relevant files have changed, these are the files that `increment_build_number` (`agvtool`) touches:
- All .plist files
- The `.xcodeproj/project.pbxproj` file

Then commits those files to the repo.

Customise the message with the `:message` option, defaults to "Version Bump"

If you have other uncommitted changes in your repo, this action will fail. If you started off in a clean repo, and used the `ipa` and or `sigh` actions, then you can use the [`clean_build_artifacts`](#clean_build_artifacts) action to clean those temporary files up before running this action.

```ruby
hg_commit_version_bump

hg_commit_version_bump(
  message: 'Version Bump',                    # create a commit with a custom message
  xcodeproj: './path/to/MyProject.xcodeproj', # optional, if you have multiple Xcode project files, you must specify your main project here
)
```

### hg_add_tag
A simplified version of git action [`add_git_tag`](#add_git_tag). It adds a given tag to the mercurial repo.

Specify the tag name with the `:tag` option.

```ruby
hg_add_tag tag: version_number
```

### hg_push
The mercurial equivalent of [`push_to_git_remote`](#push_to_git_remote) — pushes your local commits to a remote mercurial repo. Useful when local changes such as adding a version bump commit or adding a tag are part of your lane’s actions.

```ruby
hg_push # simple version. pushes commits from current branch to default destination

hg_push(
  destination: 'ssh://hg@repohost.com/owner/repo', # optional
  force: true,                                     # optional, default: false
)
```

## Notifications

### [Slack](http://slack.com)
Create an Incoming WebHook and export this as `SLACK_URL`. Can send a message to **#channel** (by default), a direct message to **@username** or a message to a private group **group** with success (green) or failure (red) status.

```ruby
slack(
  message: "App successfully released!"
)

slack(
  message: "App successfully released!",
  channel: "#channel",  # Optional, by default will post to the default channel configured for the POST URL.
  success: true,        # Optional, defaults to true.
  payload: {            # Optional, lets you specify any number of your own Slack attachments.
    'Build Date' => Time.new.to_s,
    'Built by' => 'Jenkins',
  },
  default_payloads: [:git_branch, :git_author], # Optional, lets you specify a whitelist of default payloads to include. Pass an empty array to suppress all the default payloads. Don't add this key, or pass nil, if you want all the default payloads. The available default payloads are: `lane`, `test_result`, `git_branch`, `git_author`, `last_git_commit`.
  attachment_properties: { # Optional, lets you specify any other properties available for attachments in the slack API (see https://api.slack.com/docs/attachments). This hash is deep merged with the existing properties set using the other properties above. This allows your own fields properties to be appended to the existings fields that were created using the `payload` property for instance.
    thumb_url: 'http://example.com/path/to/thumb.png',
    fields: [{
      title: 'My Field',
      value: 'My Value',
      short: true
    }]
  }
)
```

Take a look at the [example projects](https://github.com/fastlane/examples) of how you can use the slack action, for example the [MindNode configuration](https://github.com/fastlane/examples/blob/master/MindNode/Fastfile).

### [Mailgun](http://www.mailgun.com)
Send email notifications right from `fastlane` using [Mailgun](http://www.mailgun.com).

```ruby
ENV['MAILGUN_SANDBOX_POSTMASTER'] ||= "MY_POSTMASTER"
ENV['MAILGUN_APIKEY'] = "MY_API_KEY"
ENV['MAILGUN_APP_LINK'] = "MY_APP_LINK"

mailgun(
  to: "fastlane@krausefx.com",
  success: true,
  message: "This is the mail's content"
)

or

mailgun(
  postmaster: "MY_POSTMASTER",
  apikey: "MY_API_KEY",
  to: "DESTINATION_EMAIL",
  success: true,
  message: "Mail Body",
  app_link: "http://www.myapplink.com",
  ci_build_link: "http://www.mycibuildlink.com"
)
```

### [HipChat](http://www.hipchat.com/)
Send a message to **room** (by default) or a direct message to **@username** with success (green) or failure (red) status.

```ruby
  ENV["HIPCHAT_API_TOKEN"] = "Your API token"
  ENV["HIPCHAT_API_VERSION"] = "1 for API version 1 or 2 for API version 2"

  hipchat(
    message: "App successfully released!",
    message_format: "html", # or "text", defaults to "html"
    channel: "Room or @username",
    from: "sender name", defaults to "fastlane"
    success: true
  )
```

### [Typetalk](https://typetalk.in/)
Send a message to **topic** with success (:smile:) or failure (:rage:) status.
[Using Bot's Typetalk Token](https://developer.nulab-inc.com/docs/typetalk/auth#tttoken)

```ruby
  typetalk(
    message: "App successfully released!",
    note_path: 'ChangeLog.md',
    topicId: 1,
    success: true,
    typetalk_token: 'Your Typetalk Token'
  )
```


### [ChatWork](http://www.chatwork.com/)
Post a message to a **group chat**.

[How to authenticate ChatWork API](http://developer.chatwork.com/ja/authenticate.html)

```ruby
  ENV["CHATWORK_API_TOKEN"] = "Your API token"

  chatwork(
    message: "App successfully released!",
    roomid: 12345,
    success: true
  )
```

### Notification
Display a notification using the OS X notification centre. Uses [terminal-notifier](https://github.com/alloy/terminal-notifier).

```ruby
  notification(subtitle: "Finished Building", message: "Ready to upload...")
```

[ByMyEyes](https://github.com/fastlane/examples/blob/master/BeMyEyes/Fastfile) uses the `notify` action to show a success message after `fastlane` finished executing.

### [Testmunk](http://testmunk.com)
Run your functional tests on real iOS devices over the cloud (for free on an iPod). With this simple [testcase](https://github.com/testmunk/TMSample/blob/master/testcases/smoke/smoke_features.zip) you can ensure your app launches and there is no crash at launch. Tests can be extended with [Testmunk's library](http://docs.testmunk.com/en/latest/steps.html) or custom steps. More details about this action can be found in [`testmunk.rb`](https://github.com/KrauseFx/fastlane/blob/master/lib/fastlane/actions/testmunk.rb).

```ruby
ENV['TESTMUNK_EMAIL'] = 'email@email.com'
# Additionally, you have to set TESTMUNK_API, TESTMUNK_APP and TESTMUNK_IPA
testmunk
```

### [Podio](http://podio.com)
Creates an item within your Podio app. In case an item with the given identifying value already exists within your Podio app, it updates that item. To find out how to get your authentication credentials see [Podio API documentation](https://developers.podio.com). To find out how to get your identifying field (external ID) and general info about Podio item see [tutorials](https://developers.podio.com/examples/items). 

```ruby
ENV["PODIO_ITEM_IDENTIFYING_FIELD"] = "String specifying the field key used for identification of an item"

podio_item(
  identifying_value: "Your unique value",
  other_fields: {
    "field1" => "fieldValue",
    "field2" => "fieldValue2"
  }
)
```
To see all environment values, please run ```fastlane action podio_item```.

## Other

### update_fastlane

This action will look at all installed fastlane tools and update them to the next available minor version - major version updates will not be performed automatically, as they might include breaking changes. If an update was performed, fastlane will be restarted before the run continues.

If you are using rbenv or rvm, everything should be good to go. However, if you are using the system's default ruby, some additional setup is needed for this action to work correctly. In short, fastlane needs to be able to access your gem library without running in `sudo` mode.

The simplest possible fix for this is putting the following lines into your `~/.bashrc` or `~/.zshrc` file:

```bash
export GEM_HOME=~/.gems
export PATH=$PATH:~/.gems/bin
```

After the above changes, restart your terminal, then run `mkdir $GEM_HOME` to create the new gem directory. After this, you're good to go!

Recommended usage of the `update_fastlane` action is at the top of the `before_all` block, before running any other action:

```ruby
before_all do
  update_fastlane

  cocoapods
  increment_build_number
  ...
end
```

### sonar

This action will execute `sonar-runner` to run SonarQube analysis on your source code. 

```ruby
sonar(
  project_key: "name.gretzki.awesomeApp",
  project_version: "1.0",
  project_name: "iOS - AwesomeApp",
  sources_path: File.expand_path("../AwesomeApp")
)
```
It can process unit test results if formatted as junit report as shown in [xctest](#xctest) action. It can also integrate coverage reports in Cobertura format, which can be transformed into by [slather](#slather) action.

## Misc

### appledoc

Generate Apple-like source code documentation from specially formatted source code comments.

```ruby
appledoc(
  project_name: "MyProjectName",
  project_company: "Company Name",
  input: "MyProjectSources",
  ignore: [
    'ignore/path/1',
    'ingore/path/2'
  ],
  options: "--keep-intermediate-files --search-undocumented-doc",
  warnings: "--warn-missing-output-path --warn-missing-company-id"
)
```
Use `appledoc --help` to see the list of all command line options.

### download

Download a file from a remote server (e.g. JSON file)

```ruby
data = download(url: "https://host.com/api.json")

# Print information
puts data["users"].first["name"]

# Iterate
data["users"].each do |user|
  puts user["name"]
end
```

### version_get_podspec

To receive the current version number from your `.podspec` file use

```ruby
version = version_get_podspec(path: "TSMessages.podspec")
```

### version_bump_podspec

To increment the version number of your `.podspec` use

```ruby
version = version_bump_podspec(path: "TSMessages.podspec", bump_type: "patch")
# or
version = version_bump_podspec(path: "TSMessages.podspec", version_number: "1.4")
```

### get_info_plist_value

Get a value from a plist file, which can be used to fetch the app identifier and more information about your app

```ruby
identifier = get_info_plist_value(path: './Info.plist', key: 'CFBundleIdentifier')
puts identifier # => com.krausefx.app
```

### set_info_plist_value

Set a value of a plist file. You can use this action to update the bundle identifier of your app

```ruby
set_info_plist_value(path: './Info.plist', key: 'CFBundleIdentifier', value: "com.krausefx.app.beta")
```

### say

To speak out a text

```ruby
say "I can speak"
```

### clipboard

You can store a string in the clipboard running

```ruby
clipboard(value: "https://github.com/KrauseFx/fastlane")
```

This can be used to store some generated URL or value for easy copy & paste (e.g. the download link):

```ruby
clipboard(value: lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK])
```

### is_ci?

Is the current run being executed on a CI system, like Jenkins or Travis?

```ruby
if is_ci?
  puts "I'm a computer"
else
  say "Hi Human!"
end
```

### verify_pod_keys

Runs a check against all keys specified in your Podfile to make sure they're more than a single character long. This is to ensure you don't deploy with stubbed keys.

```ruby
verify_pod_keys
```

Will raise an error if any key is empty or a single character.

### read_podspec

Loads the specified (or the first found) podspec in the folder as JSON, so that you can inspect its `version`, `files` etc. This can be useful when basing your release process on the version string only stored in one place - in the podspec. As one of the first steps you'd read the podspec and its version and the rest of the workflow can use that version string (when e.g. creating a new git tag or a GitHub Release).

```ruby
spec = read_podspec
version = spec['version']
puts "Using Version #{version}"
```

This will find the first podspec in the folder. You can also pass in the specific podspec path.

```ruby
spec = read_podspec(path: "./XcodeServerSDK.podspec")
```

### pod_push

Push a Podspec to Trunk or a private repository

```ruby
# If no path is supplied then Trunk will attempt to find the first Podspec in the current directory.
pod_push

# Alternatively, supply the Podspec file path
pod_push(path: 'TSMessages.podspec')

# You may also push to a private repo instead of Trunk
pod_push(path: 'TSMessages.podspec', repo: 'MyRepo')
```

### clean_cocoapods_cache

Cleanup the Cocoapods cache.

```ruby
# Clean entire cocoapods cache.
clean_cocoapods_cache

# Alternatively, supply the name of pod to be removed from cache.
clean_cocoapods_cache(name: 'CACHED POD')
```

### prompt

You can use `prompt` to ask the user for a value or to just let the user confirm the next step.
This action also supports multi-line inputs using the `multi_line_end_keyword` option.

```ruby
changelog = prompt(text: "Changelog: ")
```

```ruby
changelog = prompt(
  text: "Changelog: ",
  multi_line_end_keyword: "END"
)

hockey(notes: changelog)
```

### backup_file

This action backs up your file to `[path].back`.

```ruby
# copies `file` to `/path/to/file.back`
backup_file(path: '/path/to/file')
```

### restore_file

This action restores a file previously backed up by the `backup_file` action.

```ruby
# copies `file.back` to '/path/to/file'
restore_file(path: '/path/to/file')
```

### backup_xcarchive

Save your [zipped] xcarchive elsewhere from default path.

```ruby
backup_xcarchive(
  xcarchive: '/path/to/file.xcarchive', # Optional if you use the `xcodebuild` action
  destination: '/somewhere/else/file.xcarchive', # Where the backup should be created
  zip: false, # Enable compression of the archive. Defaults to `true`.
  versioned: true # Create a versioned (date and app version) subfolder where to put the archive. Default value `true`
)
```

### debug

Print out an overview of the lane context values.

```ruby
debug
```

### dotgpg_environment

Reads in production secrets set in a dotgpg file and puts them in ENV.

```ruby
dotgpg_environment(dotgpg_file: './path/to/gpgfile')
```

### update_info_plist

Update an `Info.plist` with a bundle identifier and display name.

```ruby
update_info_plist(
  xcodeproj: '/path/to/Project.xcodeproj', # Optional. Will pick the first `xcodeproj` in the directory if left blank
  plist_path: '/path/to/Info.plist', # Path to the info plist file
  app_identifier: 'com.example.newapp', # Optional. The new App Identifier of your app
  display_name: 'MyNewApp' # Optional. The new Display Name of your app
)
```

### install_xcode_plugin

Install an Xcode plugin for the current user

```ruby
install_xcode_plugin(url: 'https://github.com/contentful/ContentfulXcodePlugin/releases/download/0.5/ContentfulPlugin.xcplugin.zip')
```
