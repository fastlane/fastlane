# Snapshot Simulator Destination Investigation

Date: 2026-05-29

This file preserves investigation notes for the snapshot change that should make `xcodebuild` use the same simulator UDID that snapshot uses while preparing the simulator.

## Problem

In Flinky CI, snapshot prepared an `iPhone 17 Pro` simulator by UDID, but generated the `xcodebuild` test command with a `platform,name,OS` destination:

```sh
open -a Simulator.app --args -CurrentDeviceUDID F24194FE-5DD3-470D-991D-6A91C456657A
xcrun simctl uninstall F24194FE-5DD3-470D-991D-6A91C456657A com.techprimate.Flinky

xcodebuild \
  -scheme ScreenshotUITests \
  -project ./Flinky.xcodeproj \
  -configuration Debug \
  -derivedDataPath /var/folders/8j/sfr9qqcj73j4p6nhwcfpr0th0000gn/T/snapshot_derived20260529-8330-px2nb \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  FASTLANE_SNAPSHOT=YES \
  FASTLANE_LANGUAGE=en-US \
  build test
```

`xcodebuild` failed because no available destination matched `OS=26.4`:

```text
xcodebuild: error: Unable to find a device matching the provided destination specifier:
		{ platform:iOS Simulator, OS:26.4, name:iPhone 17 Pro }

The requested device could not be found because no available devices matched the request.
```

The available destinations in CI included the same device family with OS values such as `26.4.1` and `26.5`, not `26.4`.

## Root Cause

There are two independent issues that combine into this failure:

1. `simctl list devices` can report devices under a runtime header that does not match the OS version later reported by `xcodebuild`.
2. snapshot used two different simulator selections:
   - simulator preparation calls `TestCommandGenerator.device_udid(device_name)`, which uses `find_device` without the SDK-derived latest OS unless `ios_version` is configured.
   - the modern `TestCommandGenerator.destination` computed `LatestOsVersion.version(os)` and emitted `name=...,OS=...` for `xcodebuild`.

That means preparation can act on one concrete simulator UDID while `xcodebuild` is asked to resolve a separate `name,OS` selector.

## Local Runtime Evidence

The local machine has both iOS 26.4 and iOS 26.4.1 runtimes installed. `simctl list runtimes` shows both entries with the same display runtime name and identifier:

```text
iOS 26.4 (26.4 - 23E244) - com.apple.CoreSimulator.SimRuntime.iOS-26-4
iOS 26.4 (26.4.1 - 23E254a) - com.apple.CoreSimulator.SimRuntime.iOS-26-4
iOS 26.5 (26.5 - 23F77) - com.apple.CoreSimulator.SimRuntime.iOS-26-5
```

`simctl list devices` then prints duplicate `-- iOS 26.4 --` headers. The first local 26.4 section is empty, and the second contains the 26.4.1 devices:

```text
-- iOS 26.4 --
-- iOS 26.4 --
    iPhone 17 Pro (B49A866F-9928-4BE5-B64C-43057EB05198) (Shutdown)
```

But `xcodebuild -showdestinations` reports that same UDID as `OS:26.4.1`:

```text
{ platform:iOS Simulator, arch:arm64, id:B49A866F-9928-4BE5-B64C-43057EB05198, OS:26.4.1, name:iPhone 17 Pro }
{ platform:iOS Simulator, arch:arm64, id:FC42BA48-38ED-4A94-8E96-5512C25BB0F9, OS:26.5, name:iPhone 17 Pro }
```

So snapshot's parsed `simctl` OS version can be `26.4`, while xcodebuild expects `26.4.1` for the same UDID.

## Reproduction Commands

From the Flinky repository:

```sh
xcrun simctl list runtimes
xcrun simctl list devices
```

Observe that iOS 26.4 and iOS 26.4.1 both display under the `iOS 26.4` runtime naming in `simctl`, while xcodebuild reports simulator destinations with `OS:26.4.1`.

List xcodebuild destinations:

```sh
xcodebuild -showdestinations \
  -scheme ScreenshotUITests \
  -project ./Flinky.xcodeproj \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4'
```

This command lists available destinations. It may still exit 0 even though the destination selector is not usable for the actual build/test request.

Use a command that resolves the destination:

```sh
xcodebuild -showBuildSettings \
  -scheme ScreenshotUITests \
  -project ./Flinky.xcodeproj \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4'
```

Observed local result:

```text
xcodebuild: error: Could not configure request to show build settings: Unable to find a device matching the provided destination specifier:
		{ platform:iOS Simulator, OS:26.4, name:iPhone 17 Pro }
```

The same command succeeds when addressed by concrete UDID:

```sh
xcodebuild -showBuildSettings \
  -scheme ScreenshotUITests \
  -project ./Flinky.xcodeproj \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=FC42BA48-38ED-4A94-8E96-5512C25BB0F9'
```

Observed local result includes:

```text
TARGET_DEVICE_IDENTIFIER = FC42BA48-38ED-4A94-8E96-5512C25BB0F9
TARGET_DEVICE_OS_VERSION = 26.5
```

## Current Patch Direction

The modern snapshot generator should emit a UDID destination:

```text
-destination 'platform=iOS Simulator,id=<resolved simulator UDID>'
```

It should also use the same simulator lookup as the preparation steps. In other words, unless `ios_version` is explicitly configured, `destination` should not separately apply `LatestOsVersion.version(os)` and select a different simulator than `device_udid`.

The subtle part is that changing only the xcodebuild destination format from `name=...,OS=...` to `id=...` is not enough. If `destination` still resolves the simulator with `Snapshot::LatestOsVersion.version(os)` while preparation resolves the simulator without that SDK-derived version, snapshot can still prepare one UDID and run tests on another UDID.

Before the patch:

```ruby
# Simulator preparation
device_udid(device_name) # uses Snapshot.config[:ios_version], usually nil

# xcodebuild destination
find_device(device_name, Snapshot.config[:ios_version] || Snapshot::LatestOsVersion.version(os))
```

The patch keeps explicit `ios_version` behavior, but removes the implicit SDK-version lookup from the default `destination` path so it uses the same default lookup contract as preparation.

An alternative would be to make preparation also use the SDK-derived lookup and pass the selected simulator object through all preparation methods. That would preserve the previous default target-OS preference, but it is a wider launcher-level change because each preparation method currently resolves the UDID independently from the device name.

Files currently touched:

```text
snapshot/lib/snapshot/test_command_generator.rb
snapshot/spec/test_command_generator_spec.rb
```

The existing Xcode 8 generator already uses a UDID destination, so this change aligns the modern generator with the older generator's approach.

## Regression Tests Added

Focused tests in `snapshot/spec/test_command_generator_spec.rb` cover:

1. destinations use `id=<udid>` instead of `name=<name>,OS=<version>`.
2. the generated `xcodebuild` destination uses the same UDID as `TestCommandGenerator.device_udid`.
3. iOS, tvOS, and watchOS generated command expectations use UDID destinations.

Useful verification commands:

```sh
/Users/philip/.rbenv/versions/3.4.7/bin/bundle exec rspec \
  snapshot/spec/test_command_generator_spec.rb:31 \
  snapshot/spec/test_command_generator_spec.rb:42 \
  snapshot/spec/test_command_generator_spec.rb:52
```

```sh
env -u NO_COLOR -u FASTLANE_DISABLE_COLORS \
  /Users/philip/.rbenv/versions/3.4.7/bin/bundle exec rspec \
  snapshot/spec/test_command_generator_spec.rb \
  snapshot/spec/test_command_generator_xcode_8_spec.rb
```

The `NO_COLOR` environment variable affects unrelated `xcpretty --no-color` expectations in these specs. Unsetting it keeps the spec environment aligned with the existing expectations.

## Verification So Far

Focused destination regression specs passed:

```text
3 examples, 0 failures
```

Broader command-generator specs passed with colors enabled:

```text
66 examples, 0 failures
```

## Open Notes

- `xcodebuild -showdestinations` is useful evidence for available destination metadata, but it did not fail locally for the bad `OS=26.4` selector. `xcodebuild -showBuildSettings` did fail and is a better lightweight reproduction for destination resolution.
- If a user explicitly configures `ios_version`, snapshot should still pass a UDID destination. Even if `simctl` labels a 26.4.1 runtime as `26.4`, using the selected UDID avoids xcodebuild's string-version mismatch.
