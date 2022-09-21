<p align="center">
  <img src="/img/actions/scan.png" width="250">
</p>

###### The easiest way to run tests of your iOS and Mac app

_scan_ makes it easy to run tests of your iOS and Mac app on a simulator or connected device.

-------

<p align="center">
    <a href="#whats-scan">Features</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#scanfile">Scanfile</a>
</p>

-------

# What's scan?

![https://pbs.twimg.com/media/CURcEpuWoAArE3d.png:large](https://pbs.twimg.com/media/CURcEpuWoAArE3d.png:large)

### Before _scan_

```no-highlight
xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme "MyApp" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' \
  test
```

As the output will look like this

```no-highlight
/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/Objects-normal/arm64/main.o Example/main.m normal arm64 objective-c com.apple.compilers.llvm.clang.1_0.compiler
    cd /Users/felixkrause/Developer/fastlane/gym/example/cocoapods
    export LANG=en_US.US-ASCII
    export PATH="/Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:/Applications/Xcode-beta.app/Contents/Developer/usr/bin:/Users/felixkrause/.rvm/gems/ruby-2.2.0/bin:/Users/felixkrause/.rvm/gems/ruby-2.2.0@global/bin:/Users/felixkrause/.rvm/rubies/ruby-2.2.0/bin:/Users/felixkrause/.rvm/bin:/usr/local/heroku/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    /Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x objective-c -arch arm64 -fmessage-length=126 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -fcolor-diagnostics -std=gnu99 -fobjc-arc -fmodules -gmodules -fmodules-cache-path=/Users/felixkrause/Library/Developer/Xcode/DerivedData/ModuleCache -fmodules-prune-interval=86400 -fmodules-prune-after=345600 -fbuild-session-file=/Users/felixkrause/Library/Developer/Xcode/DerivedData/ModuleCache/Session.modulevalidation -fmodules-validate-once-per-build-session -Wnon-modular-include-in-framework-module -Werror=non-modular-include-in-framework-module -Wno-trigraphs -fpascal-strings -Os -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wunreachable-code -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -DCOCOAPODS=1 -DNS_BLOCK_ASSERTIONS=1 -DOBJC_OLD_DISPATCH_PROTOTYPES=0 -isysroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.0.sdk -fstrict-aliasing -Wprotocol -Wdeprecated-declarations -miphoneos-version-min=9.0 -g -fvisibility=hidden -Wno-sign-conversion -fembed-bitcode -iquote /Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/ExampleProductName-generated-files.hmap -I/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/ExampleProductName-own-target-headers.hmap -I/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/ExampleProductName-all-target-headers.hmap -iquote /Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/ExampleProductName-project-headers.hmap -I/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/BuildProductsPath/Release-iphoneos/include -I/Users/felixkrause/Developer/fastlane/gym/example/cocoapods/Pods/Headers/Public -I/Users/felixkrause/Developer/fastlane/gym/example/cocoapods/Pods/Headers/Public/HexColors -I/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/DerivedSources/arm64 -I/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/DerivedSources -F/Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/BuildProductsPath/Release-iphoneos -isystem /Users/felixkrause/Developer/fastlane/gym/example/cocoapods/Pods/Headers/Public -isystem /Users/felixkrause/Developer/fastlane/gym/example/cocoapods/Pods/Headers/Public/HexColors -MMD -MT dependencies -MF /Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/Objects-normal/arm64/main.d --serialize-diagnostics /Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/Objects-normal/arm64/main.dia -c /Users/felixkrause/Developer/fastlane/gym/example/cocoapods/Example/main.m -o /Users/felixkrause/Library/Developer/Xcode/DerivedData/Example-fhlmxikmujknefgidqwqvtbatohi/Build/Intermediates/ArchiveIntermediates/Example/IntermediateBuildFilesPath/Example.build/Release-iphoneos/Example.build/Objects-normal/arm64/main.o
```
you'll probably want to use something like [xcpretty](https://github.com/supermarin/xcpretty), which will look like this:

```no-highlight
set -o pipefail &&
  xcodebuild \
    -workspace MyApp.xcworkspace \
    -scheme "MyApp" \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.1' \
    test \
  | xcpretty \
    -r "html" \
    -o "tests.html"
```

### With _scan_

```no-highlight
fastlane scan
```

### Why _scan_?

_scan_ uses the latest APIs and tools to make running tests plain simple and offer a great integration into your existing workflow, like [_fastlane_](https://fastlane.tools) or Jenkins.

|          |  scan Features  |
|----------|-----------------|
🏁 | Beautiful inline build output while running the tests
🚠 | Sensible defaults: Automatically detect the project, schemes and more
📊 | Support for HTML, JSON and JUnit reports
🔎 | Xcode duplicated your simulators again? _scan_ will handle this for you
🔗 | Works perfectly with [_fastlane_](https://fastlane.tools) and other tools
🚅 | Don't remember any complicated build commands, just _scan_
🔧 | Easy and dynamic configuration using parameters and environment variables
📢 | Beautiful slack notifications of the test results
💾 | Store common build settings in a `Scanfile`
📤 | The raw `xcodebuild` outputs are stored in `~/Library/Logs/scan`
💻 | Supports both iOS and Mac applications
👱 | Automatically switches to the [travis formatter](https://github.com/kattrali/xcpretty-travis-formatter) when running on Travis
📖 | Helps you resolve common test errors like simulator not responding

_scan_ uses a plain `xcodebuild` command, therefore keeping 100% compatible with `xcodebuild`. To generate the nice output, _scan_ uses [xcpretty](https://github.com/supermarin/xcpretty). You can always access the raw output in `~/Library/Logs/scan`.

![img/actions/scanScreenshot.png](/img/actions/scanScreenshot.png)
![img/actions/slack.png](/img/actions/slack.png)
![img/actions/scanHTML.png](/img/actions/scanHTML.png)
![img/actions/scanHTMLFailing.png](/img/actions/scanHTMLFailing.png)

# Usage

```no-highlight
fastlane scan
```

That's all you need to run your tests. If you want more control, here are some available parameters:

```no-highlight
fastlane scan --workspace "Example.xcworkspace" --scheme "AppName" --device "iPhone 6" --clean
```

If you need to use a different Xcode install, use `[xcodes](https://docs.fastlane.tools/actions/xcodes)` or define `DEVELOPER_DIR`:

```no-highlight
DEVELOPER_DIR="/Applications/Xcode6.2.app" scan
```

To run _scan_ on multiple devices via [_fastlane_](https://fastlane.tools), add this to your `Fastfile`:

```ruby
scan(
  workspace: "Example.xcworkspace",
  devices: ["iPhone 6s", "iPad Air"]
)
```

For a list of all available parameters use

```no-highlight
fastlane action scan
```

To access the raw `xcodebuild` output open `~/Library/Logs/scan`

# Scanfile

Since you might want to manually trigger the tests but don't want to specify all the parameters every time, you can store your defaults in a so called `Scanfile`.

Run `fastlane scan init` to create a new configuration file. Example:

```ruby-skip-tests
scheme("Example")
devices(["iPhone 6s", "iPad Air"])

clean(true)

output_types("html")
```

# Automating the whole process

_scan_ works great together with [_fastlane_](https://fastlane.tools), which connects all deployment tools into one streamlined workflow.

Using _fastlane_ you can define a configuration like

```ruby
lane :test do
  scan(scheme: "Example")
end
```
