# Support for multiple platforms

`fastlane` can handle multiple app platforms in one `Fastfile`. This is super useful for projects supporting iPhone, macOS and Android apps.

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
    gym
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
