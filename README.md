<h3 align="center">
  <img src="assets/fastlane_text.png" alt="fastlane Logo" />
</h3>
<p align="center">
  <a href="https://github.com/KrauseFx/deliver">deliver</a> &bull;
  <a href="https://github.com/KrauseFx/snapshot">snapshot</a> &bull;
  <a href="https://github.com/KrauseFx/frameit">frameit</a> &bull;
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull;
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull;
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull;
  <a href="https://github.com/KrauseFx/cert">cert</a> &bull;
  <a href="https://github.com/KrauseFx/codes">codes</a>
</p>
-------

fastlane
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](http://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/travis/KrauseFx/fastlane/master.svg?style=flat)](https://travis-ci.org/KrauseFx/fastlane)

######*fastlane* lets you define and run your deployment pipelines for different environments. It helps you unify your apps release process and automate the whole process. fastlane connects all fastlane tools and third party tools, like [CocoaPods](http://cocoapods.org) and [xctool](https://github.com/facebook/xctool).


Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#customise-the-fastfile">Customise</a> &bull;
    <a href="#extensions">Extensions</a> &bull;
    <a href="#jenkins-integration">Jenkins</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

# Features
- Connect all tools, part of the ```fastlane``` toolchain to work seamlessly together
- Define different ```deployment lanes``` for App Store deployment, beta builds or testing
- Deploy from any computer
- [Jenkins Integration](#jenkins-integration): Show the output directly in the Jenkins test results
- Write your [own actions](#extensions) (extensions) to extend the functionality of `fastlane`
- Store data like the ```Bundle Identifier``` or your ```Apple ID``` once and use it across all tools
- Never remember any difficult commands, just ```fastlane```
- Easy setup, which helps you getting up and running very fast
- Shared context, which is used to let the different deployment steps communicate with each other
- Store **everything** in git. Never lookup the used build commands in the ```Jenkins``` configs
- Saves you **hours** of preparing app submission, uploading screenshots and deploying the app for each update
- Very flexible configuration using a fully customizable `Fastfile`
- Once up and running, you have a fully working **Continuous Deployment** process. Just trigger ```fastlane``` and you're good to go.

##### Take a look at the [fastlane website](https://fastlane.tools) for more information about why and when to use `fastlane`.

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Installation

I recommend following the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/GUIDE.md) to get started.

If you are familiar with the command line and Ruby, install `fastlane` yourself:

    sudo gem install fastlane

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install


If you want to take a look at a project, already using `fastlane`, check out the [fastlane-example project](https://github.com/krausefx/fastlane-example) on GitHub.

# Quick Start


The setup assistent will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- Follow the setup assistent, which will set up ```fastlane``` for you
- Further customise the ```Fastfile``` using the next section

For a more detailed setup, please follow the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/GUIDE.md).

# Customise the ```Fastfile```
Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily deploy from any computer.

Open the ```Fastfile``` using a text editor and customise it even further. (Switch to *Ruby* Syntax Highlighting)

### Lanes
You can define multiple ```lanes``` which are different workflows for a release process.

Examples are: ```appstore```, ```beta``` and ```test```.

You define a ```lane``` like this (more details about the commands in the [Actions](#actions) section):
```ruby
lane :appstore do
  increment_build_number
  cocoapods
  xctool
  snapshot
  sigh
  deliver
  frameit
  sh "./customScript.sh"

  slack
end
```

To launch the ```appstore``` lane run
```
fastlane appstore
```

When one command fails, the execution will be aborted.

### Environment Variables
You can define environment variables in a `.env` or `.env.default` file in the same directory as your `Fastfile`. Environment variables are loading used [dotenv](https://github.com/bkeepers/dotenv)

#### Example using `dotenv`
**Filename:** .env
```
WORKSPACE=YourApp.xcworkspace
HOCKEYAPP_API_TOKEN=your-hockey-api-token
```

#### Environment specific `dotenv` variables
`fastlane` also has a `--env` option that allows loading of environment specific `dotenv` files. `.env` and `.env.default` will be loaded before environment specific `dotenv` files are loaded. The naming convention for environment specific `dotenv` files is `.env.<environment>`

**Example:** `fastlane <lane-name> --env development` will load `.env`, `.env.default`, and `.env.development`

### Actions
There are some predefined actions you can use. If you have ideas for more, please let me know.

#### [CocoaPods](http://cocoapods.org)
Everyone using [CocoaPods](http://cocoapods.org) will probably want to run a ```pod install``` before running tests and building the app.
```ruby
cocoapods # this will run pod install
```


#### [xctool](https://github.com/facebook/xctool)
You can run any xctool action. This will require having [xctool](https://github.com/facebook/xctool) installed through [homebrew](http://brew.sh/).
```ruby
xctool :test
```

It is recommended to have the `xctool` configuration stored in a [`xctool-args`](https://github.com/facebook/xctool#configuration-xctool-args) file.

#### [snapshot](https://github.com/KrauseFx/snapshot)
```ruby
snapshot
```

To make `snapshot` work without user interaction, follow the [CI-Guide of `snapshot`](https://github.com/KrauseFx/snapshot#run-in-continuous-integration).

#### [sigh](https://github.com/KrauseFx/sigh)
This will generate and download your App Store provisioning profile. `sigh` will store the generated profile in the `./fastlane` folder.

```ruby
sigh
```

To use the Ad Hoc profile instead

```ruby
sigh :adhoc
```

To always re-generate the provisioning profile, use `sigh :force`.

#### [cert](https://github.com/KrauseFx/cert)

The `cert` action can be used to make sure to have the latest signing certificate installed. More information on the [`cert` project page](https://github.com/KrauseFx/cert).

```ruby
cert
```

`fastlane` will automatically pass the signing certificate to use to `sigh`.

#### [produce](https://github.com/KrauseFx/produce)

Create new apps on iTunes Connect and Apple Developer Portal. If the app already exists, `produce` will not do anything.

```ruby
produce({
  produce_username: 'felix@krausefx.com',
  produce_app_identifier: 'com.krausefx.app',
  produce_app_name: 'MyApp',
  produce_language: 'English',
  produce_version: '1.0',
  produce_sku: 123,
  produce_team_name: 'SunApps GmbH' # only necessary when in multiple teams
})
```

#### ipa

Build your app right inside `fastlane` and the path to the resulting ipa is automatically available to all other actions.

```ruby
ipa({
  workspace: "MyApp.xcworkspace",
  configuration: "Debug",
  scheme: "MyApp",
})
```

The `ipa` action uses [shenzhen](https://github.com/nomad/shenzhen) under the hood.

The path to the `ipa` is automatically used by `Crashlytics`, `Hockey` and `DeployGate`. To also use it in `deliver` update your `Deliverfile`:


```ruby
ipa ENV["IPA_OUTPUT_PATH"]
beta_ipa ENV["IPA_OUTPUT_PATH"]
```

#### [deliver](https://github.com/KrauseFx/deliver)
```ruby
deliver
```

To upload a new build to TestFlight use ```deliver :beta```.

If you don't want a PDF report for App Store builds, append ```:force``` to the command. This is useful when running ```fastlane``` on your Continuous Integration server: `deliver :force`

Other options

- ```deliver :skip_deploy```: To don't submit the app for review (works with both App Store and beta builds)
- ```deliver :force, :skip_deploy```: Combine options using ```,```

#### [frameit](https://github.com/KrauseFx/frameit)
By default, the device color will be black
```ruby
frameit
```

To use white (sorry, silver) device frames
```ruby
frameit :silver
```

#### [increment_build_number](https://developer.apple.com/library/ios/qa/qa1827/_index.html)
This method will increment the **build number**, not the app version. Usually this is just an auto incremented number. You first have to [set up your Xcode project](https://developer.apple.com/library/ios/qa/qa1827/_index.html), if you haven't done it already.

```ruby
increment_build_number # automatically increment by one
increment_build_number '75' # set a specific number
```

#### [resign]
This will resign an ipa with another signing identity and provisioning profile.

If you have used the `ipa` and `sigh` actions, then this action automatically gets the `ipa` and `provisioning_profile` values respectively from those actions and you don't need to manually set them (althout you can always override them).

```ruby
resign(
  ipa: 'path/to/ipa', # can omit if using the `ipa` action
  signing_identity: 'iPhone Distribution: Luka Mirosevic (0123456789)',
  provisioning_profile: 'path/to/profile', # can omit if using the `sigh` action
)
```

#### [clean_build_artifacts]
This action deletes the files that get created in your repo as a result of running the `ipa` and `sigh` commands. It doesn't delete the `fastlane/report.xml` though, this is probably more suited for the .gitignore.

Useful if you quickly want to send out a test build by dropping down to the command line and typing something like `fastlane beta`, without leaving your repo in a messy state afterwards.

```ruby
clean_build_artifacts
```

#### [ensure_git_status_clean]
A sanity check to make sure you are working in a repo that is clean. Especially useful to put at the beginning of your fastfile in the `before_all` block, if some of your other actions will touch your filesystem, do things to your git repo, or just as a general reminder to save your work. Also needed as a prerequisite for some other actions like `reset_git_repo`.

```ruby
ensure_git_status_clean
```

#### [commit_version_bump]
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
  message: 'New version yo!', # create a commit with a custom message
)
```

#### [add_git_tag]
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

#### [reset_git_repo]
This action will reset your git repo to a clean state, discarding any uncommitted and untracked changes. Useful in case you need to revert the repo back to a clean state, e.g. after the fastlane run.

It's a pretty drastic action so it comes with a sort of safety latch. It will only proceed with the reset if either of these conditions are met:

- You have called the `ensure_git_status_clean` action prior to calling this action. This ensures that your repo started off in a clean state, so the only things that will get destroyed by this action are files that are created as a byproduct of the fastlane run.
- You call it with the `:force` option, in which case "you have been warned".

Also useful for putting in your `error` block, to bring things back to a pristine state (again with the caveat that you have called `ensure_git_status_clean` before)

```ruby
reset_git_repo
reset_git_repo :force # if you don't care about warnings and are absolutely sure that you want to discard all changes. This will reset the repo even if you have valuable uncommitted changes, so use with care!
```

#### [HockeyApp](http://hockeyapp.net)
```ruby
hockey({
  api_token: '...',
  ipa: './app.ipa',
  notes: "Changelog"
})
```

Symbols will also be uploaded automatically if a `app.dSYM.zip` file is found next to `app.ipa`. In case it is located in a different place you can specify the path explicitly in `:dsym` parameter.

More information about the available options can be found in the [HockeyApp Docs](http://support.hockeyapp.net/kb/api/api-versions#upload-version).

#### [Crashlytics Beta](http://try.crashlytics.com/beta/)
```ruby
crashlytics({
  crashlytics_path: './Crashlytics.framework', # path to your 'Crashlytics.framework'
  api_token: '...',
  build_secret: '...',
  ipa_path: './app.ipa'
})
```
Additionally you can specify `notes_path`, `emails`, `groups` and `notifications`.

#### AWS S3 Distribution

Add the `s3` action after the `ipa` step:

```ruby
s3
```

You can also customize a lot of options:
```ruby
s3({
  # All of these are used to make Shenzhen's `ipa distribute:s3` command
  access_key: ENV['S3_ACCESS_KEY'], # Required from user
  secret_access_key: ENV['S3_SECRET_ACCESS_KEY'], # Required from user
  bucket: ENV['S3_BUCKET'], # Required from user
  file: 'AppName.ipa', # This would come from IpaAction
  dsym: 'AppName.app.dSYM.zip', # This would come from IpaAction
  path: 'v{CFBundleShortVersionString}_b{CFBundleVersion}/' # This is actually the default
})
```

It is recommended to **not** store the AWS access keys in the `Fastfile`.

#### [DeployGate](https://deploygate.com/)

You can retrieve your username and API token on [your settings page](https://deploygate.com/settings).

```ruby
deploygate({
  api_token: '...',
  user: 'target username or organization name',
  ipa: './ipa_file.ipa',
  message: "Build #{Actions.lane_context[Actions::SharedValues::BUILD_NUMBER]}",
})
```

If you put `deploygate` after `ipa` action, you don't have to specify IPA file path, as it is extracted from the lane context automatically.

More information about the available options can be found in the [DeployGate Push API document](https://deploygate.com/docs/api).


#### [Slack](http://slack.com)
Send a message to **#channel** (by default) or a direct message to **@username** with success (green) or failure (red) status.

```ruby
  slack({
    message: "App successfully released!",
    channel: "#channel",
    success: true
  })
```

#### [HipChat](http://www.hipchat.com/)
Send a message to **room** (by default) or a direct message to **@username** with success (green) or failure (red) status.

```ruby
  ENV["HIPCHAT_API_TOKEN"] = "Your API token"
  ENV["HIPCHAT_API_VERSION"] = "1 for API version 1 or 2 for API version 2"

  hipchat({
    message: "App successfully released!",
    channel: "Room or @username",
    success: true
  })
```

#### [Typetalk](https://typetalk.in/)
Send a message to **topic** with success (:smile:) or failure (:rage:) status.
[Using Bot's Typetalk Token](https://developer.nulab-inc.com/docs/typetalk/auth#tttoken)

```ruby
  typetalk({
    message: "App successfully released!",
    note_path: 'ChangeLog.md',
    topicId: 1,
    success: true,
    typetalk_token: 'Your Typetalk Token'
  })
```

#### [Testmunk](http://testmunk.com)
Run your functional tests on real iOS devices over the cloud (for free on an iPod). With this simple [testcase](https://github.com/testmunk/TMSample/blob/master/testcases/smoke/smoke_features.zip) you can ensure your app launches and there is no crash at launch. Tests can be extended with [Testmunk's library](http://docs.testmunk.com/en/latest/steps.html) or custom steps. More details about this action can be found in [`testmunk.rb`](https://github.com/KrauseFx/fastlane/blob/master/lib/fastlane/actions/testmunk.rb).
```ruby
ENV['TESTMUNK_EMAIL'] = 'email@email.com'
# Additionally, you have to set TESTMUNK_API, TESTMUNK_APP and TESTMUNK_IPA
testmunk
```

#### [gcovr](http://gcovr.com/)
Generate summarized code coverage reports.

```ruby
gcovr({
  html: true,
  html_details: true,
  output: "./code-coverage/report.html"
})
```

#### [xcode_select](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcode-select.1.html)
Use this command if you are supporting multiple versions of Xcode

```ruby
xcode_select "/Applications/Xcode6.1.app"
```

#### Custom Shell Scripts
```ruby
sh "./your_bash_script.sh"
```

### *before_all* block
This block will get executed *before* running the requested lane. It supports the same actions as lanes.

```ruby
before_all do |lane|
  cocoapods
end
```

### *after_all* block
This block will get executed *after* running the requested lane. It supports the same actions as lanes.

It will only be called, if the selected lane was executed **successfully**.

```ruby
after_all do |lane|
  say "Successfully finished deployment (#{lane})!"
  slack({
    message: "Successfully submitted new App Update"
  })
  sh "./send_screenshots_to_team.sh" # Example
end
```

### *error* block
This block will get executed when an error occurs, in any of the blocks (*before_all*, the lane itself or *after_all*).
```ruby
error do |lane, exception|
  slack({
    message: "Something went wrong with the deployment.",
    success: false
  })
end
```

# Extensions
Why only use the default actions? Create your own to extend the functionality of `fastlane`.

The build step you create will behave exactly like the built in actions.

Just run `fastlane new_action`. Then enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`.

From then on, you can just start using your action in your `Fastfile`.

If you think your extension can be used by other developers as well, let me know, and we can bundle it with `fastlane`.

# Jenkins Integration

`fastlane` automatically generates a JUnit report for you. This allows Continuous Integration systems, like `Jenkins`, access the results of your deployment.

## Installation
The recommended way to install [Jenkins](http://jenkins-ci.org/) is through [homebrew](http://brew.sh/):

```brew update && brew install jenkins```

From now on start ```Jenkins``` by running:
```
jenkins
```

To store the password in the Keychain of your remote machine, I recommend running `sigh` or `deliver` using ssh or remote desktop at least once.

## Deploy Strategy

You should **not** deploy a new App Store update after every commit, since you still have to wait 1-2 weeks for the review. Instead I recommend using Git Tags, or custom triggers to deploy a new update.

You can set up your own ```Release``` job, which is only triggered manually.

## Plugins

I recommend the following plugins:

- **[HTML Publisher Plugin](https://wiki.jenkins-ci.org/display/JENKINS/HTML+Publisher+Plugin):** Can be used to show the generated screenshots right inside Jenkins.
- **[AnsiColor Plugin](https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin):** Used to show the coloured output of the fastlane tools. Dont' forget to enable `Color ANSI Console Output` in the `Build Environment` or your project.
- **[Rebuild Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Rebuild+Plugin):** This plugin will save you a lot of time.

## Build Step
Use the following as your build step:
```
fastlane appstore
```
Replace `appstore` with the lane you want to use.

## Test Results and Screenshtos

To show the **deployment result** right in `Jenkins`

- *Add post-build action*
- *Publish JUnit test result report*
- *Test report XMLs*: `fastlane/report.xml`

To show the **generated screenhots** right in `Jenkins`

- *Add post-build action*
- *Publish HTML reports*
- *HTML directory to archive*: `fastlane/screenshots`
- *Index page*: `screenshots.html`

Save and run. The result should look like this:

![JenkinsIntegration](assets/JenkinsIntegration.png)

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store using a single command
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/KrauseFx/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/KrauseFx/codes): Create promo codes for iOS Apps using the command line

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Advanced
#### Lane Context
The different actions can *communicate* with each other using a shared hash.
Access them in your scrips using:
```ruby
Actions.lane_context[Actions::SharedValues::LANE_NAME] # the name of the current lane
```
Available variables (put that inside the square brackets of the above snippet)
```ruby
Actions::SharedValues::BUILD_NUMBER # generated by `increment_build_number`
Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH # generated by `snapshot`
Actions::SharedValues::PRODUCE_APPLE_ID # the Apple ID of the newly created app
Actions::SharedValues::IPA_OUTPUT_PATH # generated by `ipa`
Actions::SharedValues::SIGH_PROFILE_PATH # generated by `sigh`
Actions::SharedValues::SIGH_UDID # the UDID of the generated provisioning profile
Actions::SharedValues::HOCKEY_DOWNLOAD_LINK #generated by `hockey`
Actions::SharedValues::DEPLOYGATE_URL # generated by `deploygate`
Actions::SharedValues::DEPLOYGATE_APP_REVISION # integer, generated by `deploygate`
Actions::SharedValues::DEPLOYGATE_APP_INFO # Hash, generated by `deploygate`
````

#### Complex Fastfile Example
```ruby
before_all do |lane|
  ENV["SLACK_URL"] = "https://hooks.slack.com/services/..."
  team_id "Q2CBPK58CA"

  ensure_git_status_clean

  increment_build_number

  cocoapods

  xctool :test

  ipa({
    workspace: "MyApp.xcworkspace"
  })
end

lane :beta do
  cert

  sigh :adhoc

  deliver :beta

  hockey({
    api_token: '...',
    ipa: './app.ipa' # optional
  })
end

lane :deploy do
  cert

  sigh

  snapshot

  deliver :force
  
  frameit
end

after_all do |lane|
  clean_build_artifacts

  commit_version_bump

  add_git_tag

  slack({
    message: "Successfully deployed a new version."
  })
  say "My job is done here"
end

error do |lane, exception|
  reset_git_repo

  slack({
    message: "An error occured"
  })
end
```

#### Set Team ID/Name for all tools

To set a team ID for `sigh`, `PEM` and the other tools, add this code to your `before_all` block:

```ruby
team_id "Q2CBPK58CA"

# or

team_name "Felix Krause"
```

Alternatively you can add this information to your `fastlane/Appfile`.

#### Snapshot
To skip cleaning the project on every build:
```ruby
snapshot :noclean
```

To show the output of `UIAutomation`:
```ruby
snapshot :verbose
```

#### Run multiple ```lanes```
You can run multiple ```lanes``` (in the given order) using
```
fastlane test inhouse appstore
````
Keep in mind the ```before_all``` and ```after_all``` block will be executed for each of the ```lanes```.

#### Hide the `fastlane` folder
Just rename the folder to `.fastlane` in case you don't want it to be visible in the Finder.

#### Load own actions from external folder
Add this to the top of your `Fastfile` (*.* is the `fastlane` folder)
```ruby
actions_path '../custom_actions_folder/'
```

# Credentials
A detailed description about your credentials is available on a [separate repo](https://github.com/KrauseFx/CredentialsManager).

# Need help?
- If there is a technical problem with ```fastlane```, submit an issue.
- I'm available for contract work - drop me an email: fastlane@krausefx.com

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/fastlane/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
