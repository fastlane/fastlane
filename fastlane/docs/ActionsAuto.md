# fastlane actions

This page contains a list of all built-in fastlane actions and their available options.

To get the most up-to-date information from the command line on your current version you can also run

```sh
fastlane actions # list all available fastlane actions
fastlane action [action_name] # more information for a specific action
```

You can import another `Fastfile` by using the `import` action. This is useful if you have shared lanes across multiple apps and you want to store a `Fastfile` in a separate folder. The path must be relative to the `Fastfile` this is called from.

```ruby
import './path/to/other/Fastfile'
```

- [Testing](#testing)
- [Building](#building)
- [Screenshots](#screenshots)
- [Project](#project)
- [Beta](#beta)
- [Releasing your app](#releasing-your-app)
- [Source Control](#source-control)
- [Notifications](#notifications)
- [Misc](#misc)




# Testing

### appium

Run UI test by Appium with RSpec

> 

appium | 
-----|----
Supported platforms | ios
Author | @yonekawa



<details>
<summary>1 Example</summary>

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


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `platform` | Appium platform name
  `spec_path` | Path to Appium spec directory
  `app_path` | Path to Appium target app file
  `invoke_appium_server` | Use local Appium server with invoke automatically
  `host` | Hostname of Appium server
  `port` | HTTP port of Appium server
  `appium_path` | Path to Appium executable
  `caps` | Hash of caps for Appium::Driver

</details>






# Building

### adb

Run ADB Actions

> see adb --help for more details

adb | 
-----|----
Supported platforms | android
Author | @hjanuschka
Returns | The output of the adb command



<details>
<summary>1 Example</summary>

```ruby
adb(
  command: "shell ls"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `serial` | Android serial, which device should be used for this command
  `command` | All commands you want to pass to the adb command, e.g. `kill-server`
  `adb_path` | The path to your `adb` binary

</details>






# Screenshots


# Project


# Beta

### appaloosa

Upload your app to Appaloosa Store

> Appaloosa is a private mobile application store. This action 
offers a quick deployment on the platform. You can create an 
account, push to your existing account, or manage your user 
groups. We accept iOS and Android applications.

appaloosa | 
-----|----
Supported platforms | ios, android, mac
Author | @Appaloosa



<details>
<summary>1 Example</summary>

```ruby
appaloosa(
  # Path tor your IPA or APK
  binary: '/path/to/binary.ipa',
  # You can find your store’s id at the bottom of the “Settings” page of your store
  store_id: 'your_store_id',
  # You can find your api_token at the bottom of the “Settings” page of your store
  api_token: 'your_api_key',
  # User group_ids visibility, if it's not specified we'll publish the app for all users in your store'
  group_ids: '112, 232, 387',
  # You can use fastlane/snapshot or specify your own screenshots folder.
  # If you use snapshot please specify a local and a device to upload your screenshots from.
  # When multiple values are specified in the Snapfile, we default to 'en-US'
  locale: 'en-US',
  # By default, the screenshots from the last device will be used
  device: 'iPhone6',
  # Screenshots' filenames should start with device's name like 'iphone6-s1.png' if device specified
  screenshots: '/path/to_your/screenshots'
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `binary` | Binary path. Optional for ipa if you use the `ipa` or `xcodebuild` action
  `api_token` | Your API token
  `store_id` | Your Store id
  `group_ids` | Your app is limited to special users? Give us the group ids
  `screenshots` | Add some screenshots application to your store or hit [enter]
  `locale` | Select the folder locale for yours screenshots
  `device` | Select the device format for yours screenshots
  `description` | Your app description

</details>





### appetize

Upload your app to Appetize.io to stream it in the browser

> If you provide a `public_key`, this will overwrite an existing application. If you want to have this build as a new app version, you shouldn't provide this value.
To integrate appetize into your GitHub workflow check out the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md)

appetize | 
-----|----
Supported platforms | ios, android
Author | @klundberg, @giginet



<details>
<summary>1 Example</summary>

```ruby
appetize(
  path: "./MyApp.zip",
  api_token: "yourapitoken", # get it from https://appetize.io/docs#request-api-token
  public_key: "your_public_key" # get it from https://appetize.io/dashboard
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `api_token` | Appetize.io API Token
  `url` | URL from which the ipa file can be fetched. Alternative to :path
  `platform` | Platform. Either `ios` or `android`. Default is `ios`
  `path` | Path to zipped build on the local filesystem. Either this or `url` must be specified
  `public_key` | If not provided, a new app will be created. If provided, the existing build will be overwritten
  `note` | Notes you wish to add to the uploaded app

</details>





### apteligent

Upload dSYM file to Apteligent (Crittercism)

> 

apteligent | 
-----|----
Supported platforms | ios
Author | @Mo7amedFouad



<details>
<summary>1 Example</summary>

```ruby
apteligent(
  app_id: "...",
  api_key: "..."
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `dsym` | dSYM.zip file to upload to Apteligent
  `app_id` | Apteligent App ID key e.g. 569f5c87cb99e10e00c7xxxx
  `api_key` | Apteligent App API key e.g. IXPQIi8yCbHaLliqzRoo065tH0lxxxxx

</details>






# Releasing your app


# Source Control

### add_git_tag

This will add an annotated git tag to the current branch

> This will automatically tag your build with the following format: `<grouping>/<lane>/<prefix><build_number>`, where:
- `grouping` is just to keep your tags organised under one 'folder', defaults to 'builds'
- `lane` is the name of the current fastlane lane
- `prefix` is anything you want to stick in front of the version number, e.g. 'v'
- `build_number` is the build number, which defaults to the value emitted by the `increment_build_number` action
For example for build 1234 in the 'appstore' lane it will tag the commit with `builds/appstore/1234`

add_git_tag | 
-----|----
Supported platforms | ios, android, mac
Author | @lmirosevic, @maschall



<details>
<summary>3 Examples</summary>

```ruby
add_git_tag # simple tag with default values
```

```ruby
add_git_tag(
  grouping: "fastlane-builds",
  prefix: "v",
  build_number: 123
)
```

```ruby
# Alternatively, you can specify your own tag. Note that if you do specify a tag, all other arguments are ignored.
add_git_tag(
  tag: "my_custom_tag"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `tag` | Define your own tag text. This will replace all other parameters
  `grouping` | Is used to keep your tags organised under one 'folder'. Defaults to 'builds'
  `prefix` | Anything you want to put in front of the version number (e.g. 'v')
  `build_number` | The build number. Defaults to the result of increment_build_number if you're using it
  `message` | The tag message. Defaults to the tag's name
  `commit` | The commit or object where the tag will be set. Defaults to the current HEAD
  `force` | Force adding the tag

</details>






# Notifications

### twitter

Post a tweet on Twitter.com

> Post a tweet on twitter. Requires you to setup an app on twitter.com and obtain consumer and access_token.

twitter | 
-----|----
Supported platforms | ios, android, mac
Author | @hjanuschka



<details>
<summary>1 Example</summary>

```ruby
twitter(
  message: "You rock!",
  access_token: "XXXX",
  access_token_secret: "xxx",
  consumer_key: "xxx",
  consumer_secret: "xxx"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `consumer_key` | Consumer Key
  `consumer_secret` | Consumer Secret
  `access_token` | Access Token
  `access_token_secret` | Access Token Secret
  `message` | The tweet

</details>






# Misc

### adb_devices

Get an Array of Connected android device serials

> Fetches device list via adb, e.g. run an adb command on all connected devices.

adb_devices | 
-----|----
Supported platforms | android
Author | @hjanuschka
Returns | Returns an array of all currently connected android devices



<details>
<summary>1 Example</summary>

```ruby
adb_devices.each  do |device|
  model = adb(command: "shell getprop ro.product.model",
    serial: device.serial
   ).strip

  puts "Model #{model} is connected"
end
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `adb_path` | The path to your `adb` binary

</details>





### appetize_viewing_url_generator

Generate an URL for appetize simulator

> Check out the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md) for more information

appetize_viewing_url_generator | 
-----|----
Supported platforms | ios
Author | @KrauseFx
Returns | The URL to preview the iPhone app


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `public_key` | Public key of the app you wish to update
  `device` | Device type: iphone4s, iphone5s, iphone6, iphone6plus, ipadair, iphone6s, iphone6splus, ipadair2, nexus5, nexus7 or nexus9
  `scale` | Scale of the simulator
  `orientation` | Device orientation
  `language` | Device language in ISO 639-1 language code, e.g. 'de'
  `color` | Color of the device
  `launch_url` | Specify a deep link to open when your app is launched

</details>





### appledoc

Generate Apple-like source code documentation from specially formatted source code comments.

> Runs `appledoc [OPTIONS] <paths to source dirs or files>` for the project

appledoc | 
-----|----
Supported platforms | ios, mac
Author | @alexmx



<details>
<summary>1 Example</summary>

```ruby
appledoc(
  project_name: "MyProjectName",
  project_company: "Company Name",
  input: "MyProjectSources",
  ignore: [
    "ignore/path/1",
    "ingore/path/2"
  ],
  options: "--keep-intermediate-files --search-undocumented-doc",
  warnings: "--warn-missing-output-path --warn-missing-company-id"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `input` | Path to source files
  `output` | Output path
  `templates` | Template files path
  `docset_install_path` | DocSet installation path
  `include` | Include static doc(s) at path
  `ignore` | Ignore given path
  `exclude_output` | Exclude given path from output
  `index_desc` | File including main index description
  `project_name` | Project name
  `project_version` | Project version
  `project_company` | Project company
  `company_id` | Company UTI (i.e. reverse DNS name)
  `create_html` | Create HTML
  `create_docset` | Create documentation set
  `install_docset` | Install documentation set to Xcode
  `publish_docset` | Prepare DocSet for publishing
  `html_anchors` | The html anchor format to use in DocSet HTML
  `clean_output` | Remove contents of output path before starting
  `docset_bundle_id` | DocSet bundle identifier
  `docset_bundle_name` | DocSet bundle name
  `docset_desc` | DocSet description
  `docset_copyright` | DocSet copyright message
  `docset_feed_name` | DocSet feed name
  `docset_feed_url` | DocSet feed URL
  `docset_feed_formats` | DocSet feed formats. Separated by a comma [atom,xml]
  `docset_package_url` | DocSet package (.xar) URL
  `docset_fallback_url` | DocSet fallback URL
  `docset_publisher_id` | DocSet publisher identifier
  `docset_publisher_name` | DocSet publisher name
  `docset_min_xcode_version` | DocSet min. Xcode version
  `docset_platform_family` | DocSet platform familiy
  `docset_cert_issuer` | DocSet certificate issuer
  `docset_cert_signer` | DocSet certificate signer
  `docset_bundle_filename` | DocSet bundle filename
  `docset_atom_filename` | DocSet atom feed filename
  `docset_xml_filename` | DocSet xml feed filename
  `docset_package_filename` | DocSet package (.xar,.tgz) filename
  `options` | Documentation generation options
  `crossref_format` | Cross reference template regex
  `exit_threshold` | Exit code threshold below which 0 is returned
  `docs_section_title` | Title of the documentation section (defaults to "Programming Guides"
  `warnings` | Documentation generation warnings
  `logformat` | Log format [0-3]
  `verbose` | Log verbosity level [0-6,xcode]

</details>





### artifactory

This action uploads an artifact to artifactory

> 

artifactory | 
-----|----
Supported platforms | ios, android, mac
Author | @koglinjg



<details>
<summary>1 Example</summary>

```ruby
artifactory(
  username: "username",
  password: "password",
  endpoint: "https://artifactory.example.com/artifactory/",
  file: "example.ipa",  # File to upload
  repo: "mobile_artifacts",       # Artifactory repo
  repo_path: "/ios/appname/example-major.minor.ipa"   # Path to place the artifact including its filename
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `file` | File to be uploaded to artifactory
  `repo` | Artifactory repo to put the file in
  `repo_path` | Path to deploy within the repo, including filename
  `endpoint` | Artifactory endpoint
  `username` | Artifactory username
  `password` | Artifactory password
  `properties` | Artifact properties hash
  `ssl_pem_file` | Location of pem file to use for ssl verification
  `ssl_verify` | Verify SSL
  `proxy_username` | Proxy username
  `proxy_password` | Proxy password
  `proxy_address` | Proxy address
  `proxy_port` | Proxy port

</details>





### backup_file

This action backs up your file to "[path].back"

> 

backup_file | 
-----|----
Supported platforms | ios, android, mac
Author | @gin0606



<details>
<summary>1 Example</summary>

```ruby
backup_file(path: "/path/to/file")
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `path` | Path to the file you want to backup

</details>





### backup_xcarchive

Save your [zipped] xcarchive elsewhere from default path

> 

backup_xcarchive | 
-----|----
Supported platforms | ios, mac
Author | @dral3x



<details>
<summary>1 Example</summary>

```ruby
backup_xcarchive(
  xcarchive: "/path/to/file.xcarchive", # Optional if you use the `xcodebuild` action
  destination: "/somewhere/else/file.xcarchive", # Where the backup should be created
  zip: false, # Enable compression of the archive. Defaults to `true`.
  versioned: true # Create a versioned (date and app version) subfolder where to put the archive. Default value `true`
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `xcarchive` | Path to your xcarchive file. Optional if you use the `xcodebuild` action
  `destination` | Where your archive will be placed
  `zip` | Enable compression of the archive. Default value `true`
  `versioned` | Create a versioned (date and app version) subfolder where to put the archive. Default value `true`

</details>





### badge

Automatically add a badge to your iOS app icon

> This action will add a light/dark badge onto your app icon.
You can also provide your custom badge/overlay or add an shield for more customization more info:
https://github.com/HazAT/badge
**Note** If you want to reset the badge back to default you can use `sh 'git checkout -- <path>/Assets.xcassets/'`

badge | 
-----|----
Supported platforms | ios, android, mac
Author | @DanielGri



<details>
<summary>4 Examples</summary>

```ruby
badge(dark: true)
```

```ruby
badge(alpha: true)
```

```ruby
badge(custom: "/Users/xxx/Desktop/badge.png")
```

```ruby
badge(shield: "Version-0.0.3-blue", no_badge: true)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `dark` | Adds a dark flavored badge ontop of your icon
  `custom` | Add your custom overlay/badge image
  `no_badge` | Hides the beta badge
  `shield` | Add a shield to your app icon from shield.io
  `alpha` | Adds and alpha badge instead of the default beta one
  `path` | Sets the root path to look for AppIcons
  `shield_io_timeout` | Set custom duration for the timeout of the shield.io request in seconds
  `glob` | Glob pattern for finding image files
  `alpha_channel` | Keeps/adds an alpha channel to the icon (useful for android icons)
  `shield_gravity` | Position of shield on icon. Default: North - Choices include: NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast
  `shield_no_resize` | Shield image will no longer be resized to aspect fill the full icon. Instead it will only be shrinked to not exceed the icon graphic

</details>





### build_and_upload_to_appetize

Generate and upload an ipa file to appetize.io

> This should be called from danger
More information in the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md)

build_and_upload_to_appetize | 
-----|----
Supported platforms | ios
Author | @KrauseFx


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `xcodebuild` | Parameters that are passed to the xcodebuild action
  `scheme` | The scheme to build. Can also be passed using the `xcodebuild` parameter
  `api_token` | Appetize.io API Token

</details>





### bundle_install

This action runs `bundle install` (if available)

> 

bundle_install | 
-----|----
Supported platforms | ios, android, mac
Author | @birmacher, @koglinjg


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `binstubs` | Generate bin stubs for bundled gems to ./bin
  `clean` | Run bundle clean automatically after install
  `full_index` | Use the rubygems modern index instead of the API endpoint
  `gemfile` | Use the specified gemfile instead of Gemfile
  `jobs` | Install gems using parallel workers
  `local` | Do not attempt to fetch gems remotely and use the gem cache instead
  `deployment` | Install using defaults tuned for deployment and CI environments
  `no_cache` | Don't update the existing gem cache
  `no_prune` | Don't remove stale gems from the cache
  `path` | Specify a different path than the system default ($BUNDLE_PATH or $GEM_HOME). Bundler will remember this value for future installs on this machine
  `system` | Install to the system location ($BUNDLE_PATH or $GEM_HOME) even if the bundle was previously installed somewhere else for this application
  `quiet` | Only output warnings and errors
  `retry` | Retry network and git requests that have failed
  `shebang` | Specify a different shebang executable name than the default (usually 'ruby')
  `standalone` | Make a bundle that can work without the Bundler runtime
  `trust_policy` | Sets level of security when dealing with signed gems. Accepts `LowSecurity`, `MediumSecurity` and `HighSecurity` as values
  `without` | Exclude gems that are part of the specified named group
  `with` | Include gems that are part of the specified named group

</details>





### zip

Compress a file or folder to a zip

> 

zip | 
-----|----
Supported platforms | ios, android, mac
Author | @KrauseFx
Returns | The path to the output zip file



<details>
<summary>2 Examples</summary>

```ruby
zip
```

```ruby
zip(
  path: "MyApp.app",
  output_path: "Latest.app.zip"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `path` | Path to the directory or file to be zipped
  `output_path` | The name of the resulting zip file

</details>






