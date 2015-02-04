From manual to fully automatic app deployments
-----------------------------------

This guide will help you set up Continuous Deployment for your iOS project. 

It will help you set up all needed build tools. I tested everything with a fresh Yosemite installation.

-------
<p align="center">
    <a href="#installation">Installation</a> &bull; 
    <a href="#setting-up-fastlane">Setting up</a> &bull; 
    <a href="#jenkins-integration">Jenkins</a> &bull; 
    <a href="#example-project">Example Project</a> &bull; 
    <a href="#help">Help</a>
</p>

-------


#### Notes about this guide
If you don't want to use `sudo`, you can follow the [CocoaPods Guide](http://guides.cocoapods.org/using/getting-started.html#sudo-less-installation) of a *sudo-less installation*.

# Installation

**Requirements**

- Mac OS 10.9 or newer
- Ruby 2.0 or newer (`ruby -v`)
- Xcode

### Xcode
Additionally to an Xcode installation, you also need the Xcode command line tools set up

    xcode-select --install

### [Homebrew](http://brew.sh/)
You don't have to use [homebrew](http://brew.sh/) to install the dependencies. It's the easiest way to get started.

If you don't have [homebrew](http://brew.sh/) already installed, follow the guide on the [bottom of the official page](http://brew.sh/).

#### Init [Homebrew](http://brew.sh/)

    brew doctor && brew update

#### [xctool](https://github.com/facebook/xctool) (optional)

    brew install xctool

### [Nokogiri](http://www.nokogiri.org/)

    sudo gem install nokogiri

This can be a pain sometimes, in case you're running into problems, take a look at the [official installation guide](http://www.nokogiri.org/tutorials/installing_nokogiri.html).


### [fastlane](https://github.com/KrauseFx/fastlane)

Install the gem and all its dependencies (might take a few minutes)

    sudo gem install fastlane

# Setting up `fastlane`

Before changing anything, I recommend commiting everything in `git`, in case something goes wrong.

## Get it up and running
When running the setup commands, please read the instructions shown in the terminal. There is usually a reason they are there.

`fastlane` will create all necessary files and folders for you

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

The setup automatically detects, which tools you're using (e.g. [`deliver`](https://github.com/KrauseFx/deliver), [CocoaPods](http://cocoapods.org/), [xctool](https://github.com/facebook/xctool))

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

#### Update the `Fastfile`
Now it's the time to adapt the `Fastfile` to implement your deployment pipeline. You should use `increment_build_number` when you want to upload builds to iTunes Connect ([Activate incrementing build numbers](https://developer.apple.com/library/ios/qa/qa1827/_index.html))

Add as many lanes as you want and test them by running `fastlane [lane name]`.

### Use your existing build scripts

    sh "./script.sh"

This will execute your existing build script. Everything inside the `"` will be executed in the shell.

### Create your own actions (build steps)
If you want a fancy command (like `snapshot` has), you can build your own extension very easily using [this guide](https://github.com/krausefx/fastlane#extensions).

# [Jenkins](http://jenkins-ci.org/) Integration
(or any other Continuous Integration system)

Deploying from your own computer isn't cool. You know what's cool? Letting a remote server publish app updates for you.

Everything you did in this guide, was stored in the filesystem in configuration files, which means, you have everything you need in version control. Add


    fastlane appstore

as a build step on your server, and you're good to go.

### Even better Jenkins integration
For a more detailed CI-setup, which also shows you test results and the latest screenshots, take a look at the [Jenkins Guide](https://github.com/krausefx/fastlane#jenkins-integration). 


### Deploy strategy
Tips about when to deploy can be found in the [fastlane Jenkins instructions](https://github.com/KrauseFx/fastlane#deploy-strategy).

# Example project
Take a look at a project with `fastlane` already set up: [fastlane-example](https://github.com/krausefx/fastlane-example)


# Help

- If something is unclear or you need help, submit an issue. 
- I'm available for contract work - drop me an email: fastlane@krausefx.com
