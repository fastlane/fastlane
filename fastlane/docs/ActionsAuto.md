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
- [Code Signing](#code-signing)
- [Documentation](#documentation)
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





### carthage

Runs `carthage` for your project

> 

carthage | 
-----|----
Supported platforms | ios, mac
Author | @bassrock, @petester42, @jschmid, @JaviSoto, @uny, @phatblat, @bfcrampton



<details>
<summary>2 Examples</summary>

```ruby
carthage
```

```ruby
carthage(
  command: "bootstrap"        # One of: build, bootstrap, update, archive. (default: bootstrap)
  dependencies: ["Alamofire", "Notice"],# Specify which dependencies to update (only for the update command)
  use_ssh: false,   # Use SSH for downloading GitHub repositories.
  use_submodules: false,      # Add dependencies as Git submodules.
  use_binaries: true,         # Check out dependency repositories even when prebuilt frameworks exist
  no_build: false,  # When bootstrapping Carthage do not build
  no_skip_current: false,     # Don't skip building the current project (only for frameworks)
  verbose: false,   # Print xcodebuild output inline
  platform: "all",  # Define which platform to build for (one of ‘all’, ‘Mac’, ‘iOS’, ‘watchOS’, ‘tvOS‘, or comma-separated values of the formers except for ‘all’)
  configuration: "Release",   # Build configuration to use when building
  toolchain: "com.apple.dt.toolchain.Swift_2_3"   # Specify the xcodebuild toolchain
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `command` | Carthage command (one of: build, bootstrap, update, archive)
  `dependencies` | Carthage dependencies to update
  `use_ssh` | Use SSH for downloading GitHub repositories
  `use_submodules` | Add dependencies as Git submodules
  `use_binaries` | Check out dependency repositories even when prebuilt frameworks exist
  `no_build` | When bootstrapping Carthage do not build
  `no_skip_current` | Don't skip building the Carthage project (in addition to its dependencies)
  `derived_data` | Use derived data folder at path
  `verbose` | Print xcodebuild output inline
  `platform` | Define which platform to build for
  `configuration` | Define which build configuration to use when building
  `toolchain` | Define which xcodebuild toolchain to use when building

</details>





### clean_cocoapods_cache

Remove the cache for pods

> 

clean_cocoapods_cache | 
-----|----
Supported platforms | ios, mac
Author | @alexmx



<details>
<summary>2 Examples</summary>

```ruby
clean_cocoapods_cache
```

```ruby
clean_cocoapods_cache(name: "CACHED_POD")
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `name` | Pod name to be removed from cache

</details>





### clear_derived_data

Deletes the Xcode Derived Data

> Deletes the Derived Data from '~/Library/Developer/Xcode/DerivedData' or a supplied path

clear_derived_data | 
-----|----
Supported platforms | ios, mac
Author | @KrauseFx



<details>
<summary>2 Examples</summary>

```ruby
clear_derived_data
```

```ruby
clear_derived_data(derived_data_path: "/custom/")
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `derived_data_path` | Custom path for derivedData

</details>





### cocoapods

Runs `pod install` for the project

> If you use [CocoaPods](http://cocoapods.org) you can use the `cocoapods` integration to run `pod install` before building your app.

cocoapods | 
-----|----
Supported platforms | ios, mac
Author | @KrauseFx, @tadpol, @birmacher, @Liquidsoul



<details>
<summary>2 Examples</summary>

```ruby
cocoapods
```

```ruby
cocoapods(
  clean: true,
  podfile: "./CustomPodfile"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `clean` | Remove SCM directories
  `integrate` | Integrate the Pods libraries into the Xcode project(s)
  `repo_update` | Run `pod repo update` before install
  `silent` | Show nothing
  `verbose` | Show more debugging information
  `ansi` | Show output with ANSI codes
  `use_bundle_exec` | Use bundle exec when there is a Gemfile presented
  `podfile` | Explicitly specify the path to the Cocoapods' Podfile. You can either set it to the Podfile's path or to the folder containing the Podfile file

</details>






# Screenshots


# Project


# Code Signing

### cert

Fetch or generate the latest available code signing identity

> **Important**: It is recommended to use [match](https://github.com/fastlane/fastlane/tree/master/match) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your certificates. Use `cert` directly only if you want full control over what's going on and know more about codesigning.
Use this action to download the latest code signing identity

cert | 
-----|----
Supported platforms | ios
Author | @KrauseFx



<details>
<summary>2 Examples</summary>

```ruby
cert
```

```ruby
cert(
  development: true,
  username: "user@email.com"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `development` | Create a development certificate instead of a distribution one
  `force` | Create a certificate even if an existing certificate exists
  `username` | Your Apple ID Username
  `team_id` | The ID of your team if you're in multiple teams
  `team_name` | The name of your team if you're in multiple teams
  `output_path` | The path to a directory in which all certificates and private keys should be stored
  `keychain_path` | Path to a custom keychain

</details>






# Documentation

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





### crashlytics

Upload a new build to Crashlytics Beta

> Additionally you can specify `notes`, `emails`, `groups` and `notifications`.
#### Distributing to Groups
When using the `groups` parameter, it's important to use the group **alias** names for each group you'd like to distribute to. A group's alias can be found in the web UI. If you're viewing the Beta page, you can open the groups dialog here:

crashlytics | 
-----|----
Supported platforms | ios, android, mac
Author | @KrauseFx, @pedrogimenez



<details>
<summary>2 Examples</summary>

```ruby
crashlytics
```

```ruby
crashlytics(
  crashlytics_path: "./Pods/Crashlytics/", # path to your Crashlytics submit binary.
  api_token: "...",
  build_secret: "...",
  ipa_path: "./app.ipa"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `ipa_path` | Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action
  `apk_path` | Path to your APK file
  `crashlytics_path` | Path to the submit binary in the Crashlytics bundle (iOS) or `crashlytics-devtools.jar` file (Android)
  `api_token` | Crashlytics Beta API Token
  `build_secret` | Crashlytics Build Secret
  `notes_path` | Path to the release notes
  `notes` | The release notes as string - uses :notes_path under the hood
  `groups` | The groups used for distribution, separated by commas
  `emails` | Pass email addresses of testers, separated by commas
  `notifications` | Crashlytics notification option (true/false)
  `debug` | Crashlytics debug option (true/false)

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





### changelog_from_git_commits

Collect git commit messages into a changelog

> By default, messages will be collected back to the last tag, but the range can be controlled

changelog_from_git_commits | 
-----|----
Supported platforms | ios, android, mac
Author | @mfurtak, @asfalcone, @SiarheiFedartsou
Returns | Returns a String containing your formatted git commits



<details>
<summary>2 Examples</summary>

```ruby
changelog_from_git_commits
```

```ruby
changelog_from_git_commits(
  between: ["7b092b3", "HEAD"], # Optional, lets you specify a revision/tag range between which to collect commit info
  pretty: "- (%ae) %s", # Optional, lets you provide a custom format to apply to each commit when generating the changelog text
  tag_match_pattern: nil, # Optional, lets you search for a tag name that matches a glob(7) pattern
  match_lightweight_tag: false, # Optional, lets you ignore lightweight (non-annotated) tags when searching for the last tag
  include_merges: true # Optional, lets you filter out merge commits
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `between` | Array containing two Git revision values between which to collect messages, you mustn't use it with :commits_count key at the same time
  `commits_count` | Number of commits to include in changelog, you mustn't use it with :between key at the same time
  `pretty` | The format applied to each commit while generating the collected value
  `tag_match_pattern` | A glob(7) pattern to match against when finding the last git tag
  `match_lightweight_tag` | Whether or not to match a lightweight tag when searching for the last one
  `include_merges` | Whether or not to include any commits that are merges
[31m(DEPRECATED - use :merge_commit_filtering)[0m
  `merge_commit_filtering` | Controls inclusion of merge commits when collecting the changelog.
Valid values: 'include_merges', 'exclude_merges', 'only_include_merges'

</details>





### create_pull_request

This will create a new pull request on GitHub

> 

create_pull_request | 
-----|----
Supported platforms | ios, android, mac
Author | @seei



<details>
<summary>1 Example</summary>

```ruby
create_pull_request(
  api_token: ENV["GITHUB_TOKEN"],
  repo: "fastlane/fastlane",
  title: "Amazing new feature",
  head: "my-feature",       # optional, defaults to current branch name
  base: "master", # optional, defaults to "master"
  body: "Please pull this in!",       # optional
  api_url: "http://yourdomain/api/v3" # optional, for Github Enterprise, defaults to "https://api.github.com"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `api_token` | Personal API Token for GitHub - generate one at https://github.com/settings/tokens
  `repo` | The name of the repository you want to submit the pull request to
  `title` | The title of the pull request
  `body` | The contents of the pull request
  `head` | The name of the branch where your changes are implemented (defaults to the current branch name)
  `base` | The name of the branch you want your changes pulled into (defaults to `master`)
  `api_url` | The URL of Github API - used when the Enterprise (default to `https://api.github.com`)

</details>






# Notifications

### chatwork

Send a success/error message to ChatWork

> Information on how to obtain an API token: http://developer.chatwork.com/ja/authenticate.html

chatwork | 
-----|----
Supported platforms | ios, android, mac
Author | @astronaughts



<details>
<summary>1 Example</summary>

```ruby
chatwork(
  message: "App successfully released!",
  roomid: 12345,
  success: true,
  api_token: "Your Token"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `api_token` | ChatWork API Token
  `message` | The message to post on ChatWork
  `roomid` | The room ID
  `success` | Was this build successful? (true/false)

</details>





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





### clean_build_artifacts

Deletes files created as result of running ipa, cert, sigh or download_dsyms

> This action deletes the files that get created in your repo as a result of running the `ipa` and `sigh` commands. It doesn't delete the `fastlane/report.xml` though, this is probably more suited for the .gitignore.
Useful if you quickly want to send out a test build by dropping down to the command line and typing something like `fastlane beta`, without leaving your repo in a messy state afterwards.

clean_build_artifacts | 
-----|----
Supported platforms | ios, mac
Author | @lmirosevic



<details>
<summary>1 Example</summary>

```ruby
clean_build_artifacts
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `exclude_pattern` | Exclude all files from clearing that match the given Regex pattern: e.g. '.*.mobileprovision'

</details>





### clipboard

Copies a given string into the clipboard. Works only on macOS

> 

clipboard | 
-----|----
Supported platforms | ios, android, mac
Author | @KrauseFx



<details>
<summary>2 Examples</summary>

```ruby
clipboard(value: "https://github.com/fastlane/fastlane/tree/master/fastlane")
```

```ruby
clipboard(value: lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK])
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `value` | The string that should be copied into the clipboard

</details>





### cloc

Generates a Code Count that can be read by Jenkins (xml format)

> This action will run cloc to generate a SLOC report that the Jenkins SLOCCount plugin can read.
See https://wiki.jenkins-ci.org/display/JENKINS/SLOCCount+Plugin and https://github.com/AlDanial/cloc for more information.

cloc | 
-----|----
Supported platforms | ios, mac
Author | @intere



<details>
<summary>1 Example</summary>

```ruby
cloc(
   exclude_dir: "ThirdParty,Resources",
   output_directory: "reports",
   source_directory: "MyCoolApp"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `binary_path` | Where the cloc binary lives on your system (full path including 'cloc')
  `exclude_dir` | Comma separated list of directories to exclude
  `output_directory` | Where to put the generated report file
  `source_directory` | Where to look for the source code (relative to the project root folder)
  `xml` | Should we generate an XML File (if false, it will generate a plain text file)?

</details>





### copy_artifacts

Small action to save your build artifacts. Useful when you use reset_git_repo

> This action copies artifacs to a target directory. It's useful if you have a CI that will pick up these artifacts and attach them to the build. Useful e.g. for storing your `.ipa`s, `.dSYM.zip`s, `.mobileprovision`s, `.cert`s
Make sure your target_path is gitignored, and if you use `reset_git_repo`, make sure the artifacts are added to the exclude list

copy_artifacts | 
-----|----
Supported platforms | ios, android, mac
Author | @lmirosevic



<details>
<summary>1 Example</summary>

```ruby
copy_artifacts(
  target_path: "artifacts",
  artifacts: ["*.cer", "*.mobileprovision", "*.ipa", "*.dSYM.zip"]
)

# Reset the git repo to a clean state, but leave our artifacts in place
reset_git_repo(
  exclude: "artifacts"
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `keep_original` | Set this to true if you want copy, rather than move, semantics
  `target_path` | The directory in which you want your artifacts placed
  `artifacts` | An array of file patterns of the files/folders you want to preserve
  `fail_on_missing` | Fail when a source file isn't found

</details>





### create_keychain

Create a new Keychain

> 

create_keychain | 
-----|----
Supported platforms | ios, android, mac
Author | @gin0606



<details>
<summary>1 Example</summary>

```ruby
create_keychain(
  name: "KeychainName",
  default_keychain: true,
  unlock: true,
  timeout: 3600,
  lock_when_sleeps: true
)
```


</details>


<details>
<summary>Parameters</summary>

Key | Description
----|------------
  `name` | Keychain name
  `password` | Password for the keychain
  `default_keychain` | Set the default keychain
  `unlock` | Unlock keychain after create
  `timeout` | timeout interval in seconds. Set `false` if you want to specify "no time-out"
  `lock_when_sleeps` | Lock keychain when the system sleeps
  `lock_after_timeout` | Lock keychain after timeout interval
  `add_to_search_list` | Add keychain to search list

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






