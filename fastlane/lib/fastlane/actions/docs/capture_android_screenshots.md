<p align="center">
  <img src="/img/actions/screengrab.png" width="250">
</p>

###### Automated localized screenshots of your Android app on every device

_screengrab_ generates localized screenshots of your Android app for different device types and languages for Google Play and can be uploaded using [_supply_](https://fastlane.tools/supply).

<img src="/img/actions/running-screengrab.gif" width="640">

### Why should I automate this process?

- Create hundreds of screenshots in multiple languages on emulators or real devices, saving you hours
- Easily verify that localizations fit into labels on all screen dimensions to find UI mistakes before you ship
- You only need to configure it once for anyone on your team to run it
- Keep your screenshots perfectly up-to-date with every app update. Your customers deserve it!
- Fully integrates with [_fastlane_](https://fastlane.tools) and [_supply_](https://fastlane.tools/supply)

# Installation

Install the gem

```no-highlight
gem install fastlane
```

##### Gradle dependency

```java
androidTestImplementation 'tools.fastlane:screengrab:x.x.x'
```

The latest version is [ ![Download](https://maven-badges.herokuapp.com/maven-central/tools.fastlane/screengrab/badge.svg)](https://search.maven.org/artifact/tools.fastlane/screengrab)

As of _screengrab_ version 2.0.0, all Android test dependencies are AndroidX dependencies. This means a device with API 18+, Android 4.3 or greater is required. If you wish to capture screenshots with an older Android OS, then you must use a 1.x.x version.

##### Configuring your Manifest Permissions

Ensure that the following permissions exist in your **src/debug/AndroidManifest.xml**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools">

    <!-- Allows storing screenshots on external storage, where it can be accessed by ADB -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="18" />

    <!-- Allows changing locales -->
    <uses-permission
            android:name="android.permission.CHANGE_CONFIGURATION"
            tools:ignore="ProtectedPermissions" />

    <!-- Allows changing SystemUI demo mode -->
    <uses-permission
            android:name="android.permission.DUMP"
            tools:ignore="ProtectedPermissions" />

</manifest>
```

##### Configuring your <a href="#ui-tests">UI Tests</a> for Screenshots

1. Add `LocaleTestRule` to your tests class to handle automatic switching of locales.

   If you're using Java use:

   ```java
   @ClassRule
   public static final LocaleTestRule localeTestRule = new LocaleTestRule();
   ```

   If you're using Kotlin use:

   ```kotlin
   @Rule @JvmField
   val localeTestRule = LocaleTestRule()
   ```

   The `@JvmField` annotation is important. It won't work like this:

   ```kotlin
   companion object {
       @get:ClassRule
       val localeTestRule = LocaleTestRule()
   }
   ```

2. To capture screenshots, add the following to your tests `Screengrab.screenshot("name_of_screenshot_here");` on the appropriate screens

# Generating Screenshots with _screengrab_
- Then, before running `fastlane screengrab` you'll need a debug and test apk
  - You can create your APKs manually with `./gradlew assembleDebug assembleAndroidTest`
  - You can also create a lane and use `build_android_app`:

    ```ruby
    desc "Build debug and test APK for screenshots"
    lane :build_and_screengrab do
      build_android_app(
        task: 'assemble',
        build_type: 'Debug'
      )
      build_android_app(
        task: 'assemble',
        build_type: 'AndroidTest'
      )
      screengrab()
    end
    ```
- Once complete run `fastlane screengrab` in your app project directory to generate screenshots
  - You will be prompted to provide any required parameters which are not in your **Screengrabfile** or provided as command line arguments
- Your screenshots will be saved to `fastlane/metadata/android` in the directory where you ran _screengrab_

## Improved screenshot capture with UI Automator

As of _screengrab_ 0.5.0, you can specify different strategies to control the way _screengrab_ captures screenshots. The newer strategy delegates to [UI Automator](https://developer.android.com/topic/libraries/testing-support-library/index.html#UIAutomator) which fixes a number of problems compared to the original strategy:

* Shadows/elevation are correctly captured for Material UI
* Multi-window situations are correctly captured (dialogs, etc.)
* Works on Android N

UI Automator is the default strategy. However, UI Automator requires a device with **API level >= 18**. If you need to grab screenshots on an older Android version, use the latest 1.x.x version of this library and set the DecorView ScreenshotStrategy.

```java
Screengrab.setDefaultScreenshotStrategy(new DecorViewScreenshotStrategy());
```

## Improved screenshot capture with Falcon

As of _screengrab_ 1.2.0, you can specify a new strategy to delegate to [Falcon](https://github.com/jraska/Falcon). Falcon may work better than UI Automator in some situations and also provides similar benefits as UI Automator:

* Multi-window situations are correctly captured (dialogs, etc.)
* Works on Android N

Falcon requires a device with **API level >= 10**. To enable it for all screenshots by default, make the following call before your tests run:

```java
Screengrab.setDefaultScreenshotStrategy(new FalconScreenshotStrategy(activityRule.getActivity()));
```

## Advanced Screengrabfile Configuration

Running `fastlane screengrab init` generated a Screengrabfile which can store all of your configuration options. Since most values will not change often for your project, it is recommended to store them there.

The `Screengrabfile` is written in Ruby, so you may find it helpful to use an editor that highlights Ruby syntax to modify this file.

```ruby-skip-tests
# remove the leading '#' to uncomment lines

# app_package_name('your.app.package')
# use_tests_in_packages(['your.screenshot.tests.package'])

# app_apk_path('path/to/your/app.apk')
# tests_apk_path('path/to/your/tests.apk')

locales(['en-US', 'fr-FR', 'it-IT'])

# clear all previously generated screenshots in your local output directory before creating new ones
clear_previous_screenshots(true)
```

For more information about all available options run

```no-highlight
fastlane action screengrab
```

# Tips

## UI Tests

Check out [Testing UI for a Single App](http://developer.android.com/training/testing/ui-testing/espresso-testing.html) for an introduction to using Espresso for UI testing.

##### Example UI Test Class (Using JUnit4)

Java:

```java
@RunWith(JUnit4.class)
public class JUnit4StyleTests {
    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityScenarioRule<MainActivity> activityRule = new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void testTakeScreenshot() {
        Screengrab.screenshot("before_button_click");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot("after_button_click");
    }
}
```

Kotlin:

```kotlin
@RunWith(JUnit4.class)
class JUnit4StyleTests {
    @get:Rule
    var activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Rule @JvmField
    val localeTestRule = LocaleTestRule()

    @Test
    fun testTakeScreenshot() {
        Screengrab.screenshot("before_button_click")

        onView(withId(R.id.fab)).perform(click())

        Screengrab.screenshot("after_button_click")
    }
}
```

There is an [example project](https://github.com/fastlane/fastlane/tree/master/screengrab/example/src/androidTest/java/tools/fastlane/localetester) showing how to use JUnit 3 or 4 and Espresso with the screengrab Java library to capture screenshots during a UI test run.

Using JUnit 4 is preferable because of its ability to perform actions before and after the entire test class is run. This means you will change the device's locale far fewer times when compared with JUnit 3 running those commands before and after each test method.

When using JUnit 3 you'll need to add a bit more code:

- Use `LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());` in `setUp()`
- Use `LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());` in `tearDown()`
- Use `Screengrab.screenshot("name_of_screenshot_here");` to capture screenshots at the appropriate points in your tests

## Clean Status Bar

_screengrab_ can clean your status bar to make your screenshots even more beautiful.
It is simply a wrapper that allows configuring SystemUI DemoMode in your code.
Note: the clean status bar feature is only supported on devices with *API level >= 23*.

You can enable and disable the clean status bar at any moment during your tests.
In most cases you probably want to do this in the @BeforeClass and @AfterClass methods.

```java
@BeforeClass
public static void beforeAll() {
    CleanStatusBar.enableWithDefaults();
}

@AfterClass
public static void afterAll() {
    CleanStatusBar.disable();
}
```

Have a look at the methods of the `CleanStatusBar` class to customize the status bar even more.
You could for example show the Bluetooth icon and the LTE text.

```java
new CleanStatusBar()
    .setBluetoothState(BluetoothState.DISCONNECTED)
    .setMobileNetworkDataType(MobileDataType.LTE)
    .enable();
```

# Advanced _screengrab_

<details markdown="1">
<summary>Launch Arguments</summary>

You can provide additional arguments to your test cases on launch. These strings will be available in your tests through `InstrumentationRegistry.getArguments()`.

```ruby
screengrab(
  launch_arguments: [
    "username hjanuschka",
    "build_number 201"
  ]
)
```

```java
Bundle extras = InstrumentationRegistry.getArguments();
String peerID = null;
if (extras != null) {
  if (extras.containsKey("username")) {
    username = extras.getString("username");
    System.out.println("Username: " + username);
  } else {
    System.out.println("No username in extras");
  }
} else {
  System.out.println("No extras");
}
```
</details>

<details markdown="1">
<summary>Detecting screengrab at runtime</summary>

For some apps, it is helpful to know when _screengrab_ is running so that you can display specific data for your screenshots. For iOS fastlane users, this is much like "FASTLANE_SNAPSHOT". In order to do this, you'll need to have at least two product flavors of your app.

Add two product flavors to the app-level build.gradle file:

```
android {
...
    flavorDimensions "mode"
    productFlavors {
        screengrab {
            dimension "mode"
        }
        regular {
            dimension "mode"
        }
    }
...
}
```

Check for the existence of that flavor (i.e screengrab) in your app code as follows in order to use mock data or customize data for screenshots:

```
if (BuildConfig.FLAVOR == "screengrab") {
    System.out.println("screengrab is running!");
}
```

When running _screengrab_, do the following to build the flavor you want as well as the test apk. Note that you use "assembleFlavor_name" where Flavor_name is the flavor name, capitalized (i.e. Screengrab).

```
./gradlew assembleScreengrab assembleAndroidTest
```

Run _screengrab_:

```
fastlane screengrab
```

_screengrab_ will ask you to select the debug and test apps (which you can then add to your Screengrabfile to skip this step later).

The debug apk should be somewhere like this:

`app/build/outputs/apk/screengrab/debug/app-screengrab-debug.apk`

The test apk should be somewhere like this:

`app/build/outputs/apk/androidTest/screengrab/debug/app-screengrab-debug-androidTest.apk`

Sit back and enjoy your new screenshots!

Note: while this could also be done by creating a new build variant (i.e. debug, release and creating a new one called screengrab), [Android only allows one build type to be tested](http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Testing) which defaults to debug. That's why we use product flavors.

</details>
