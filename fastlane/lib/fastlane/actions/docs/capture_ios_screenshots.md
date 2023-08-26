<p align="center">
  <img src="/img/actions/snapshot.png" width="250">
</p>

###### Automate taking localized screenshots of your iOS, tvOS, and watchOS apps on every device

<hr />
<h4 align="center">
  Check out the new <a href="https://docs.fastlane.tools/getting-started/ios/screenshots/">fastlane documentation</a> on how to generate screenshots
</h4>
<hr />

_snapshot_ generates localized iOS, tvOS, and watchOS screenshots for different device types and languages for the App Store and can be uploaded using ([_deliver_](https://docs.fastlane.tools/actions/deliver/)).

You have to manually create 20 (languages) x 6 (devices) x 5 (screenshots) = **600 screenshots**.

It's hard to get everything right!

- New screenshots with every (design) update
- No loading indicators
- Same content / screens
- [Clean Status Bar](#use-a-clean-status-bar)
- Uploading screenshots ([_deliver_](https://docs.fastlane.tools/actions/deliver/) is your friend)

More information about [creating perfect screenshots](https://krausefx.com/blog/creating-perfect-app-store-screenshots-of-your-ios-app).

_snapshot_ runs completely in the background - you can do something else, while your computer takes the screenshots for you.

-------

<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#ui-tests">UI Tests</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#how-does-it-work">How?</a>
</p>

-------

# Features
- Create hundreds of screenshots in multiple languages on all simulators
- Take screenshots in multiple device simulators concurrently to cut down execution time (Xcode 9 only)
- Configure it once, store the configuration in git
- Do something else, while the computer takes the screenshots for you
- Integrates with [_fastlane_](https://fastlane.tools) and [_deliver_](https://docs.fastlane.tools/actions/deliver/)
- Generates a beautiful web page, which shows all screenshots on all devices. This is perfect to send to QA or the marketing team
- _snapshot_ automatically waits for network requests to be finished before taking a screenshot (we don't want loading images in the App Store screenshots)

After _snapshot_ successfully created new screenshots, it will generate a beautiful HTML file to get a quick overview of all screens:

![img/actions/htmlPagePreviewFade.jpg](/img/actions/htmlPagePreviewFade.jpg)

## Why?

This tool automatically switches the language and device type and runs UI Tests for every combination.

### Why should I automate this process?

- It takes **hours** to take screenshots
- You get a great overview of all your screens, running on all available simulators without the need to manually start it hundreds of times
- Easy verification for translators (without an iDevice) that translations do make sense in real App context
- Easy verification that localizations fit into labels on all screen dimensions
- It is an integration test: You can test for UI elements and other things inside your scripts
- Be so nice, and provide new screenshots with every App Store update. Your customers deserve it
- You realize, there is a spelling mistake in one of the screens? Well, just correct it and re-run the script

# UI Tests

## Getting started
This project uses Apple's newly announced UI Tests. We will not go into detail on how to write scripts.

Here a few links to get started:

- [WWDC 2015 Introduction to UI Tests](https://developer.apple.com/videos/play/wwdc2015-406/)
- [A first look into UI Tests](http://www.mokacoding.com/blog/xcode-7-ui-testing/)
- [UI Testing in Xcode 7](http://masilotti.com/ui-testing-xcode-7/)
- [HSTestingBackchannel : ‘Cheat’ by communicating directly with your app](https://github.com/ConfusedVorlon/HSTestingBackchannel)
- [Automating App Store screenshots using fastlane snapshot and frameit](https://tisunov.github.io/2015/11/06/automating-app-store-screenshots-generation-with-fastlane-snapshot-and-sketch.html)

# Quick Start

- Create a new UI Test target in your Xcode project ([top part of this article](https://krausefx.com/blog/run-xcode-7-ui-tests-from-the-command-line))
- Run `fastlane snapshot init` in your project folder
- Add the ./SnapshotHelper.swift to your UI Test target (You can move the file anywhere you want)
  - (Xcode 8 only) add the ./SnapshotHelperXcode8.swift to your UI Test target
- (Objective C only) add the bridging header to your test class:
  - `#import "MYUITests-Swift.h"`  
    (The bridging header is named after your test target with `-Swift.h` appended.)
- In your UI Test class, click the `Record` button on the bottom left and record your interaction
- To take a snapshot, call the following between interactions
  -  Swift: `snapshot("01LoginScreen")`
  -  Objective C: `[Snapshot snapshot:@"01LoginScreen" timeWaitingForIdle:10];`
- Add the following code to your `setUp()` method:

**Swift:**

```swift
let app = XCUIApplication()
setupSnapshot(app)
app.launch()
```

**Objective C:**

```objective-c
XCUIApplication *app = [[XCUIApplication alloc] init];
[Snapshot setupSnapshot:app waitForAnimations:NO];
[app launch];
```

_Make sure you only have one `launch` call in your test class, as Xcode adds one automatically on new test files._

![img/actions/snapshot.gif](/img/actions/snapshot.gif)

You can try the _snapshot_ [example project](https://github.com/fastlane/fastlane/tree/master/snapshot/example) by cloning this repo.

To quick start your UI tests, you can use the UI Test recorder. You only have to interact with the simulator, and Xcode will generate the UI Test code for you. You can find the red record button on the bottom of the screen (more information in [this blog post](https://krausefx.com/blog/run-xcode-7-ui-tests-from-the-command-line))

# Usage

```no-highlight
fastlane snapshot
```

Your screenshots will be stored in the `./screenshots/` folder by default (or `./fastlane/screenshots` if you're using [_fastlane_](https://fastlane.tools))

New with Xcode 9, *snapshot* can run multiple simulators concurrently. This is the default behavior in order to take your screenshots as quickly as possible. This can be disabled to run each device, one at a time, by setting the `:concurrent_simulators` option to `false`.

**Note:** While running *snapshot* with Xcode 9, the simulators will not be visibly spawned. So, while you won't see the simulators running your tests, they will, in fact, be taking your screenshots.

If any error occurs while running the snapshot script on a device, that device will not have any screenshots, and _snapshot_ will continue with the next device or language. To stop the flow after the first error, run

```no-highlight
fastlane snapshot --stop_after_first_error
```

Also by default, _snapshot_ will open the HTML after all is done. This can be skipped with the following command


```no-highlight
fastlane snapshot --stop_after_first_error --skip_open_summary
```

There are a lot of options available that define how to build your app, for example

```no-highlight
fastlane snapshot --scheme "UITests" --configuration "Release"  --sdk "iphonesimulator"
```

Reinstall the app before running _snapshot_

```no-highlight
fastlane snapshot --reinstall_app --app_identifier "tools.fastlane.app"
```

By default _snapshot_ automatically retries running UI Tests if they fail. This is due to randomly failing UI Tests (e.g. [#2517](https://github.com/fastlane/fastlane/issues/2517)). You can adapt this number using

```no-highlight
fastlane snapshot --number_of_retries 3
```

Add photos and/or videos to the simulator before running _snapshot_

```no-highlight
fastlane snapshot --add_photos MyTestApp/Assets/demo.jpg --add_videos MyTestApp/Assets/demo.mp4
```

For a list for all available options run

```no-highlight
fastlane action snapshot
```

After running _snapshot_ you will get a nice summary:

<img src="/img/actions/testSummary.png" width="500">

## Snapfile

All of the available options can also be stored in a configuration file called the `Snapfile`. Since most values will not change often for your project, it is recommended to store them there:

First make sure to have a `Snapfile` (you get it for free when running `fastlane snapshot init`)

The `Snapfile` can contain all the options that are also available on `fastlane action snapshot`


```ruby-skip-tests
scheme("UITests")

devices([
  "iPad (7th generation)",
  "iPad Air (3rd generation)",
  "iPad Pro (11-inch)",
  "iPad Pro (12.9-inch) (3rd generation)",
  "iPad Pro (9.7-inch)",
  "iPhone 11",
  "iPhone 11 Pro",
  "iPhone 11 Pro Max",
  "iPhone 8",
  "iPhone 8 Plus"
])

languages([
  "en-US",
  "de-DE",
  "es-ES",
  ["pt", "pt_BR"] # Portuguese with Brazilian locale
])

launch_arguments(["-username Felix"])

# The directory in which the screenshots should be stored
output_directory('./screenshots')

clear_previous_screenshots(true)

override_status_bar(true)

add_photos(["MyTestApp/Assets/demo.jpg"])
```

### Completely reset all simulators

You can run this command in the terminal to delete and re-create all iOS and tvOS simulators:

```no-highlight
fastlane snapshot reset_simulators
```

**Warning**: This will delete **all** your simulators and replace by new ones! This is useful, if you run into weird problems when running _snapshot_.

You can use the environment variable `SNAPSHOT_FORCE_DELETE` to stop asking for confirmation before deleting.

```no-highlight
SNAPSHOT_FORCE_DELETE=1 fastlane snapshot reset_simulators
```

## Update snapshot helpers

Some updates require the helper files to be updated. _snapshot_ will automatically warn you and tell you how to update.

Basically you can run

```no-highlight
fastlane snapshot update
```

to update your `SnapshotHelper.swift` files. In case you modified your `SnapshotHelper.swift` and want to manually update the file, check out [SnapshotHelper.swift](https://github.com/fastlane/fastlane/blob/master/snapshot/lib/assets/SnapshotHelper.swift).

## Launch Arguments

You can provide additional arguments to your app on launch. These strings will be available in your app (e.g. not in the testing target) through `ProcessInfo.processInfo.arguments`. Alternatively, use user-default syntax (`-key value`) and they will be available as key-value pairs in `UserDefaults.standard`.

```ruby-skip-tests
launch_arguments([
  "-firstName Felix -lastName Krause"
])
```

```swift
name.text = UserDefaults.standard.string(forKey: "firstName")
// name.text = "Felix"
```

_snapshot_ includes `-FASTLANE_SNAPSHOT YES`, which will set a temporary user default for the key `FASTLANE_SNAPSHOT`, you may use this to detect when the app is run by _snapshot_.

```swift
if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
    // runtime check that we are in snapshot mode
}
```

Specify multiple argument strings and _snapshot_ will generate screenshots for each combination of arguments, devices, and languages. This is useful for comparing the same screenshots with different feature flags, dynamic text sizes, and different data sets.

```ruby-skip-tests
# Snapfile for A/B Test Comparison
launch_arguments([
  "-secretFeatureEnabled YES",
  "-secretFeatureEnabled NO"
])
```

## Xcode Environment Variables

_snapshot_ includes `FASTLANE_SNAPSHOT=YES` and `FASTLANE_LANGUAGE=<language>` as arguments when executing `xcodebuild`. This means you may use these environment variables in a custom build phase run script to do any additional configuration.

# How does it work?

The easiest solution would be to just render the UIWindow into a file. That's not possible because UI Tests don't run on a main thread. So _snapshot_ uses a different approach:

When you run unit tests in Xcode, the reporter generates a plist file, documenting all events that occurred during the tests ([More Information](http://michele.io/test-logs-in-xcode)). Additionally, Xcode generates screenshots before, during and after each of these events. There is no way to manually trigger a screenshot event. The screenshots and the plist files are stored in the DerivedData directory, which _snapshot_ stores in a temporary folder.

When the user calls `snapshot(...)` in the UI Tests (Swift or Objective C) the script actually does a rotation to `.Unknown` which doesn't have any effect on the actual app, but is enough to trigger a screenshot. It has no effect to the application and is not something you would do in your tests. The goal was to find *some* event that a user would never trigger, so that we know it's from _snapshot_. On tvOS, there is no orientation so we ask for a count of app views with type "Browser" (which should never exist on tvOS).

_snapshot_ then iterates through all test events and check where we either did this weird rotation (on iOS) or searched for browsers (on tvOS). Once _snapshot_ has all events triggered by _snapshot_ it collects a ordered list of all the file names of the actual screenshots of the application.

In the test output, the Swift _snapshot_ function will print out something like this

> snapshot: [some random text here]

_snapshot_ finds all these entries using a regex. The number of _snapshot_ outputs in the terminal and the number of _snapshot_ events in the plist file should be the same. Knowing that, _snapshot_ automatically matches these 2 lists to identify the name of each of these screenshots. They are then copied over to the output directory and separated by language and device.

2 thing have to be passed on from _snapshot_ to the `xcodebuild` command line tool:

- The device type is passed via the `destination` parameter of the `xcodebuild` parameter
- The language is passed via a temporary file which is written by _snapshot_ before running the tests and read by the UI Tests when launching the application

If you find a better way to do any of this, please submit an issue on GitHub or even a pull request :+1:

Radar [23062925](https://openradar.appspot.com/radar?id=5056366381105152) has been resolved with Xcode 8.3, so it's now possible to actually take screenshots from the simulator. We'll keep using the old approach for now, since many of you still want to use older versions of Xcode.

# Tips

<hr />
<h4 align="center">
  Check out the new <a href="https://docs.fastlane.tools/getting-started/ios/screenshots/">fastlane documentation</a> on how to generate screenshots
</h4>
<hr />

## Frame the screenshots

If you want to add frames around the screenshots and even put a title on top, check out [_frameit_](https://docs.fastlane.tools/actions/frameit/).

## Available language codes
```ruby
ALL_LANGUAGES = ["da", "de-DE", "el", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi", "fr-CA", "fr-FR", "id", "it", "ja", "ko", "ms", "nl-NL", "no", "pt-BR", "pt-PT", "ru", "sv", "th", "tr", "vi", "zh-Hans", "zh-Hant"]
```

To get more information about language and locale codes please read [Internationalization and Localization Guide](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html).

## Use a clean status bar

You can set `override_status_bar` to `true` to set the status bar to Tuesday January 9th at 9:41AM with full battery and reception. If you need more granular customization, to set a Carrier name for example, also set `override_status_bar_arguments` to the specific arguments to be passed to the `xcrun simctl status_bar override` command. Run `xcrun simctl status_bar --help` to see the options available.

## Editing the `Snapfile`

Change syntax highlighting to *Ruby*.

### Simulator doesn't launch the application

When the app dies directly after the application is launched there might be 2 problems

- The simulator is somehow in a broken state and you need to re-create it. You can use `snapshot reset_simulators` to reset all simulators (this will remove all installed apps)
- A restart helps very often

## Determine language

To detect the currently used localization in your tests, access the `deviceLanguage` variable from `SnapshotHelper.swift`.

## Speed up snapshots

A lot of time in UI tests is spent waiting for animations.

You can disable `UIView` animations in your app to make the tests faster:

```swift
if ProcessInfo().arguments.contains("SKIP_ANIMATIONS") {
    UIView.setAnimationsEnabled(false)
}
```

This requires you to pass the launch argument like so:

```ruby
snapshot(launch_arguments: ["SKIP_ANIMATIONS"])
```

By default, _snapshot_ will wait for a short time for the animations to finish.
If you're skipping the animations, this wait time is unnecessary and can be skipped:

```swift
setupSnapshot(app, waitForAnimations: false)
```
