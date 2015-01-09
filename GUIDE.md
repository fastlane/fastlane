From 0 to 100% automatic Deployment
-----------------------------------

This guide will help you set up Continuous Deployment for your iOS project.

# Notes about this guide
By default, the listed commands will use `sudo`. If you don't want this, you can follow the [CocoaPods Guide](http://guides.cocoapods.org/using/getting-started.html#sudo-less-installation) of a *sudo-less installation*.

# Installation

**Requirements**

- Ruby 2.0 or newer
- Mac OS 10.9 or newer

Install the gem and all its dependencies
      sudo gem install fastlane

# Setting up `fastlane`

## Before you start

- Before changing anything, I recommend commiting everything in `version control` (e.g. git), in case something goes wrong.

## Start
When running the setup commands, please read the instructions shown in the terminal. There is usually a reason they are there.

`fastlane` can create all necessary files and folders for you

    fastlane init
    
- Confirm until you get asked for your *App Identifier*
- Enter the *App Identifier* (*Bundle Identifier*) of your project
- Enter your *Apple ID*: The username, you enter when you login on iTunes Connect
- If you haven't already used [`deliver`](https://github.com/KrauseFx/deliver):
 - Confirm with `y` to start the setup for [`deliver`](https://github.com/KrauseFx/deliver)
 - If your app is already in the App Store, confirm with `y` to automatically create a configuration for you. If it's not yet in the store, enter `n`
- If you haven't already used [`snapshot`](https://github.com/KrauseFx/snapshot):
 - Confirm with `y` if you want your screenshots to be created automatically
- If you want to [`sigh`](https://github.com/KrauseFx/sigh) to download, renew or create your provisioning profiles, confirm with `y`

That's it, you should have received a success message. 

What did this setup do? 

- Created a `fastlane` folder
- Moved existing [`deliver`](https://github.com/KrauseFx/deliver) and [`snapshot`](https://github.com/KrauseFx/snapshot) configuration into the `fastlane` folder
- Created `fastlane/Appfile`, which stores your *Apple ID* and *Bundle Identifier*
- Created `fastlane/Fastfile`, which stores your deployment pipelines

The setup automatically detected, which tools you're using (e.g. [`deliver`](https://github.com/KrauseFx/deliver), [CocoaPods](http://cocoapods.org/), [xctool](https://github.com/facebook/xctool))

## Individual Tools
Before getting to the big picture, make sure, all tools are correctly set up. 

For example, try running the following (depending on what you plan on using):

- [deliver](https://github.com/KrauseFx/deliver)
- [snapshot](https://github.com/KrauseFx/snapshot)
- [sigh](https://github.com/KrauseFx/sigh)
- [frameit](https://github.com/KrauseFx/frameit)
- [xctool](https://github.com/facebook/xctool) (which you should [configure correctly](https://github.com/krausefx/fastlane#xctool))

All those tools have detailed instructions on how to set them up. It's easier to set them up now, then later.

## Configure the `Fastfile`

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
  snapshot
  sigh
  deliver :skip_deploy, :beta
  # sh "your_script.sh"
end

lane :deploy do
  snapshot
  sigh
  deliver :skip_deploy, :force
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

A list of available actions can be found on the [`fastlane` project page](https://github.com/KrauseFx/fastlane#actions).

## Use your existing build scripts

    sh "./script.sh"

This will execute your existing build script. Everything inside the `"` will be executed in your shell.

## Create your own actions (build steps)
If you want a fancy command (like `snapshot` has), you can build your own extension very easily using [this guide](https://github.com/krausefx/fastlane#extensions).

## [Jenkins](http://jenkins-ci.org/) Integration
(or any other Continuous Integration system)

Deploying from your own computer isn't cool. You know what's cool? Letting a remote server publish app updates for you.

Everything you did in this guide, was stored in the filesystem in configuration files, which means, you have everything you need in version control. Add


    fastlane appstore

as a build step, and you're done.

If you're using [snapshot](https://github.com/KrauseFx/snapshot), please follow [this step](https://github.com/KrauseFx/snapshot#run-in-continuous-integration), to authorize snapshot running.

### Even better Jenkins integration
For a more detailed CI-setup, which also shows you test results and the latest screenshots, take a look at the [Jenkins Guide](https://github.com/krausefx/fastlane#jenkins-integration). 


## Deploy strategy
Is described in the [fastlane instructions](https://github.com/KrauseFx/fastlane#deploy-strategy).


