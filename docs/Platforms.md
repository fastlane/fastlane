# Support for multiple platforms

`fastlane` can handle multiple operating systems in one `Fastfile`. This is super useful for projects supporting both iPhone and Mac OS apps.

Watch this magic:

```ruby
before_all do
  puts "This block is executed before every action of all platforms"
end

platform :ios do
  before_all do
    cocoapods
  end

  lane :beta do
    ipa
    hockey
  end

  after_all do
    puts "Finished iOS related work"
  end
end

platform :mac do
  lane :beta do
    xcodebuild
    hockey
  end
end

lane :test do
  puts "this lane is not platform specific"
  xctool
end

after_all do
  puts "Executed after every lane of both Mac and iPhone"
  slack
end

```

Execute lanes just like this:

    fastlane ios beta

    fastlane mac beta

    fastlane test


When running `fastlane ios beta`, both `before_all` blocks will be called: the general one on the top and the platform specific one.

The same is the case for the `after_all` and `error` block: Always both blocks are being executed, the **more specific one first**.

### Future

As you might have guessed, this doesn't only work for `ios` and `mac`, but also for `android`. This not only allows you to automate the deployment process of your Android app, but also enabled developers to maintain both platforms in a single configuration file. Over the next few months, `fastlane` will be extended to also work for Android apps.
