This guide will help you get started with `fastlane` in no time :rocket:

-------
<p align="center">
    <a href="#installation">Installation</a> &bull;
    <a href="#setting-up-fastlane">Setting up</a> &bull;
    <a href="#example-projects">Example Projects</a> &bull;
    <a href="#help">Help</a>
</p>
-------

## Notes about this guide
If you don't want to use `sudo`, you can follow the [CocoaPods Guide](http://guides.cocoapods.org/using/getting-started.html#sudo-less-installation) of a *sudo-less installation*.

See how [Wikipedia](https://github.com/fastlane/examples#wikipedia-by-wikimedia-foundation), [Product Hunt](https://github.com/fastlane/examples#product-hunt) and [MindNode](https://github.com/fastlane/examples#mindnode) use `fastlane` to automate their iOS submission process.

## Installation

Requirements:

- Mac OS 10.9 or newer
- Ruby 2.0 or newer (`ruby -v`)
- Xcode

Additionally, to an Xcode installation, you also need the Xcode command line tools set up

    xcode-select --install

If you have not used the command line tools before, you'll need to accept the terms of service.

    sudo xcodebuild -license accept

### [fastlane](https://github.com/fastlane/fastlane/tree/master/fastlane)

Install the gem and all its dependencies (this might take a few minutes).

    sudo gem install fastlane --verbose

## Setting up `fastlane`

Before making any modifications to your project, it's always recommended to commit your current directory in `git`.

When running the setup commands, please read the instructions shown in the terminal. There is usually a reason they are there.

`fastlane` will create all necessary files and folders for you with the following command. It will use values detected from the project in the working directory.

    fastlane init

This will prompt you for your _Apple ID_ in order to verify that your application already exists on both iTunes Connect and the Apple Developer Portal. If that's not the case, `fastlane` will ask you if it should be created automatically.

That's it, you should have received a success message.

What did this setup do?

- Created a `fastlane` folder
- Moved existing [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver) and [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot) configuration into the `fastlane` folder (if they existed).
- Created `fastlane/Appfile`, which stores your *Apple ID* and *Bundle Identifier*.
- Created `fastlane/Fastfile`, which stores your lanes.

The setup automatically detects, which tools you're using (e.g. [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver), [CocoaPods](https://cocoapods.org/) and more).

### Individual Tools

Before running `fastlane`, make sure, all tools are correctly set up.

For example, try running the following (depending on what you plan on using):

- [deliver](https://github.com/fastlane/fastlane/tree/master/deliver)
- [snapshot](https://github.com/fastlane/fastlane/tree/master/snapshot)
- [sigh](https://github.com/fastlane/fastlane/tree/master/sigh)

All those tools have detailed instructions on how to set them up. It's easier to set them up now, than later.

### Configure the `Fastfile`

First, think about what different builds you'll need. Some ideas:

- New App Store releases
- Beta Builds for TestFlight or [HockeyApp](http://hockeyapp.net/)
- Run tests
- In House distribution

Open the `fastlane/Fastfile` in your preferred text editor and change the syntax highlighting to `Ruby`.

Depending on your existing setup, it looks similar to this:

```ruby
before_all do
  # increment_build_number
  cocoapods
end

lane :test do
  snapshot
end

lane :beta do
  sigh
  gym
  pilot
  # sh "your_script.sh"
end

lane :deploy do
  snapshot
  sigh
  gym
  deliver(force: true)
  # frameit
end

after_all do |lane|
  # This block is called, only if the executed lane was successful
end

error do |lane, exception|
  # Something bad happened
end
```

You can quickly try running `fastlane` by copying and pasting the following to your `fastlane/Fastfile`:

```ruby
lane :example do
  say "It works"
end
```

And then run the following from your Terminal

    fastlane example

If you're successful, you should hear your computer speaking to you!

A list of available actions can be found in the [Actions documentation](https://docs.fastlane.tools/actions).

Automating the deployment process is a great next step. You should use the `increment_build_number` action when you want to upload builds to iTunes Connect ([Activate incrementing build numbers](https://developer.apple.com/library/ios/qa/qa1827/_index.html)).

### Use your existing build scripts

    sh "./script.sh"

This will execute your existing build script. Everything inside the `"` will be executed in the shell.

### Create your own actions (build steps)

If you want a fancy command (like `snapshot` has), you can build your own extension very easily using [fastlane new_action](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/README.md#extensions).

# Example projects

See how [Wikipedia](https://github.com/fastlane/examples#wikipedia-by-wikimedia-foundation), [Product Hunt](https://github.com/fastlane/examples#product-hunt) and [MindNode](https://github.com/fastlane/examples#mindnode) use `fastlane` to automate their iOS submission process.

Check out the [Actions documentation](https://docs.fastlane.tools/actions) to see a list of available integrations and options.

# Help

If something is unclear or you need help, [open an issue](https://github.com/fastlane/fastlane/issues/new).
