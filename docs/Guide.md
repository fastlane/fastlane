This guide will help you set up Continuous Delivery for your iOS project. 

It will help you set up all needed build tools. I tested everything with a fresh Yosemite installation.

-------
<p align="center">
    <a href="#installation">Installation</a> &bull; 
    <a href="#setting-up-fastlane">Setting up</a> &bull; 
    <a href="#example-project">Example Project</a> &bull; 
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
    
If you have not used the command line tools before (which is likely if you just installed it), you'll need to accept the terms of service.  

    sudo xcodebuild -license accept

### [fastlane](https://github.com/KrauseFx/fastlane)

Install the gem and all its dependencies (this might take a few minutes).

    sudo gem install fastlane --verbose

## Setting up `fastlane`

Before changing anything, I recommend committing everything in `git` (in case something goes wrong).

When running the setup commands, please read the instructions shown in the terminal. There is usually a reason they are there.

`fastlane` will create all necessary files and folders for you with the following command.

    fastlane init
    
1. Confirm until you get asked for your *App Identifier*.
1. Enter the *App Identifier* (*Bundle Identifier*) of your project.
1. Enter your *Apple ID*: The username, you enter when you login on iTunes Connect.
1. If you haven't already used [`deliver`](https://github.com/KrauseFx/deliver):
   - Confirm with `y` to start the setup for [`deliver`](https://github.com/KrauseFx/deliver).
   - If your app is already in the App Store, confirm with `y` to automatically create a configuration for you. If it's not yet in the store, enter `n`.
1. If you haven't already used [`snapshot`](https://github.com/KrauseFx/snapshot), confirm with `y` if you want your screenshots to be created automatically.
1. If you want to [`sigh`](https://github.com/KrauseFx/sigh) to download, renew or create your provisioning profiles, confirm with `y`.

That's it, you should have received a success message. 

What did this setup do? 

- Created a `fastlane` folder
- Moved existing [`deliver`](https://github.com/KrauseFx/deliver) and [`snapshot`](https://github.com/KrauseFx/snapshot) configuration into the `fastlane` folder (if they existed).
- Created `fastlane/Appfile`, which stores your *Apple ID* and *Bundle Identifier*.
- Created `fastlane/Fastfile`, which stores your deployment pipelines.

The setup automatically detects, which tools you're using (e.g. [`deliver`](https://github.com/KrauseFx/deliver), [CocoaPods](http://cocoapods.org/), [xctool](https://github.com/facebook/xctool)).

### Individual Tools

Before running `fastlane`, make sure, all tools are correctly set up. 

For example, try running the following (depending on what you plan on using):

- [deliver](https://github.com/KrauseFx/deliver)
- [snapshot](https://github.com/KrauseFx/snapshot)
- [sigh](https://github.com/KrauseFx/sigh)
- [frameit](https://github.com/KrauseFx/frameit)
- [xctool](https://github.com/facebook/xctool) (which you should [configure correctly](https://github.com/krausefx/fastlane#xctool))

All those tools have detailed instructions on how to set them up. It's easier to set them up now, than later.

### Enable `Instruments` CLI

If you want to use [snapshot](https://github.com/KrauseFx/snapshot#run-in-continuous-integration), please follow [this step](https://github.com/KrauseFx/snapshot#run-in-continuous-integration), to authorize snapshot running using [`fastlane`](https://github.com/KrauseFx/fastlane).

### Configure the `Fastfile`

First, think about what different builds you'll need. Some ideas:

- New App Store releases
- Beta Builds for TestFlight or [HockeyApp](http://hockeyapp.net/)
- Only testing (unit and integration tests)
- In House distribution

Open the `fastlane/Fastfile` in your preferred text editor and change the syntax highlighting to `Ruby`.

Depending on your existing setup, it looks similar to this (I removed some lines):

```ruby
before_all do
  # increment_build_number
  cocoapods
  xctool "test"
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

lane :inhouse do
  # insert your code here
end

after_all do |lane|
  # This block is called, only if the executed lane was successful
end

error do |lane, exception|
  # Something bad happened
end
```

You can already try running it, put a line (`say "It works"`) to the `:inhouse` lane and run

    fastlane inhouse

You should hear your computer speaking to you, which is great!

A list of available actions can be found in the [Actions documentation](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md).

Automating the deployment process is a great next step. You should use `increment_build_number` when you want to upload builds to iTunes Connect ([Activate incrementing build numbers](https://developer.apple.com/library/ios/qa/qa1827/_index.html)).


### Use your existing build scripts

    sh "./script.sh"

This will execute your existing build script. Everything inside the `"` will be executed in the shell.

### Create your own actions (build steps)

If you want a fancy command (like `snapshot` has), you can build your own extension very easily using [fastlane new_action](https://github.com/KrauseFx/fastlane/blob/master/docs/README.md#extensions).

# Example projects

See how [Wikipedia](https://github.com/fastlane/examples#wikipedia-by-wikimedia-foundation), [Product Hunt](https://github.com/fastlane/examples#product-hunt) and [MindNode](https://github.com/fastlane/examples#mindnode) use `fastlane` to automate their iOS submission process.

For all those projects you get all required configuration files, which help you get a sense of how you can use `fastlane`.

Also, check out the [Actions documentation](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md) to see a list of available integrations and options.

# Help

If something is unclear or you need help, [open an issue](https://github.com/KrauseFx/fastlane/issues/new). 
