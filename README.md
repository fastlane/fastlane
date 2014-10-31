<p align="center">
    <img src="assets/deliver.png">
</p>

Deliver - Continuous Deployment for iOS
============

[ ![Codeship Status for KrauseFx/deliver](https://codeship.io/projects/685c3d40-39e2-0132-238b-56fe17215915/status?branch=master)](https://codeship.io/projects/42273)

Updating your iOS app should not be painful and time consuming. Automate the 
whole process to start with Continuous Deployment.

```Deliver``` **can upload ipa files, app screenshots and more to the iTunesConnect backend**, which means, you can deploy new iPhone app updates just by using the command line.


Follow the developer on Twitter: https://twitter.com/KrauseFx

# Features
- Upload hundreds of screenshots with different languages from different devices
- Upload a new ipa file to iTunesConnect without Xcode from any computer
- Update app metadata
- Easily implement a real Continuous Deployment process
- Store the configuration in git to easily deploy from **any** computer, including your Continuous Integration server (e.g. Jenkins)

# Installation

    sudo gem install deliver

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

Install phantomjs (this is needed to control the iTunesConnect frontend)

    brew update && brew install phantomjs

If you don't have homebrew installed already, do it here: http://brew.sh/

# Quick Start


The guide will create all the necessary files for you, using the existing app metadata from iTunesConnect.

- ```cd [your_project_folder]```
- ```deliver init```
- When your app is already in the AppStore: ```y```
 - Enter your iTunesConnect credentials
 - Enter your app identifier
 - Enjoy a good drink, while the computer does all the work for you
- When it's a new app: ```n```

From now on, you can run ```deliver``` to deploy a new update, or just upload new app metadata and screenshots.

### Customize the ```Deliverfile```
Open the ```Deliverfile``` using a text editor and customize it even further. Take a look at the following settings:

- ```ipa```: You can either pass a static path to an ipa file, or add your custom build script.
- ```unit_tests```: Uncomment the code to run tests using *xctool*.

# Usage

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily deploy from any computer.

Run ```deliver init``` to create a new ```Deliverfile```. You can either let the wizard generate a file based on the metadata from iTunesConnect or create one from a template.

Once you created your configuration, just run ```deliver```.

Here are a few example files:
#### Upload all screenshots to iTunesConnect
```ruby
app_identifier "net.sunapps.1"
screenshots_path "./screenshots"
```
The screenshots folder must include one subfolder per language (see Available language codes)

#### Upload a new ipa file with a changelog to the AppStore
This will submit a new update to Apple
```ruby
ipa "./latest.ipa"
changelog({
    "en-US" => "This update adds cool new features",
    "de-DE" => "Dieses Update ist super"
})
```


#### Implement blocks to run unit tests
```ruby
unit_tests do
    system("xctool test")
end

success do
    notifier = Slack::Notifier.new("SlackTeam", "SlackToken")
    notifier.ping "Successfully deployed new version"
end

error do |exception|
    # custom exception handling here
    raise "Something went wrong: #{exception}"    
end
```
For this example I used https://github.com/stevenosloan/slack-notifier


#### Set a default language if you are lucky enough to only maintain one language
```ruby
default_language "en-US"
version "1.2"

title "Only English Title"
```
If you do not pass an ipa file, you have to specify the app version you want to edit.

#### Update the app's keywords
```ruby
default_language "de-DE"
version "1.2"

keywords ["keyword1", "something", "else"]
```

#### Read content from somewhere external (file, web service, ...)
```ruby
description({
    "en-US" => File.read("changelog-en.txt")
    "de-DE" => open("http://example.com/latest-changelog.txt").read
})
```

#### Build and sign the app using Shenzhen (https://github.com/nomad/shenzhen)
```ruby
ipa do
    # Add any code you want, like incrementing the build 
    # number or changing the app identifier
  
    system("ipa build") # build your project using Shenzhen
    "./AppName.ipa" # Tell 'Deliver' where it can find the finished ipa file
end
```

##### What is the ```Deliverfile```?
As you can see, the ```Deliverfile``` is a normal Ruby file, which is executed when
running a deployment. Therefore it's possible to fully customise the behaviour
on a deployment. 

All available commands with a short description can be found in the wiki: https://github.com/KrauseFx/deliver/wiki/All-available-commands-of-the-Deliverfile

**Some examples:**

- Run your own unit tests or integration tests before a deploy (recommended)
- Ask the script user for a changelog
- Deploy a new version just by starting a Jenkins job
- Post the deployment status on Slack
- Upload the latest screenshots on your server
- Many more things, be creative and let me know :)
    
## You can also use the exposed Ruby classes to have full control:
Some examples
```ruby
require 'deliver'

app = Deliver::App.new(apple_id)

app.get_app_status # => Waiting for Review
app.create_new_version!("1.4")
app.metadata.update_title({ "en-US" => "iPhone App Title" })
app.metadata.set_all_screenshots_from_path("./screenshots")
app.upload_metadata!
app.submit_for_review!

Deliver::ItunesSearchApi.fetch_by_identifier("net.sunapps.9") # => Fetches public metadata
```
This project is well documented, check it out here: http://www.rubydoc.info/github/KrauseFx/deliver/frames


## Credentials

### Use the Keychain
The first time you use *Deliver* you have to enter your iTunesConnect 
credentials. They will be stored in the Keychain. 

If you decide to remove your
credentials from the Keychain, just open the *Keychain Access*, select 
*All Items* and search for 'itunesconnect.apple.com'.

### Use environment variables
You can use the following environment variables:

    DELIVER_USER
    DELIVER_PASSWORD
    
### Implement something custom to fit your needs
Take a look at *Using the exposed Ruby classes. You


# Can I trust *Deliver*? 
###How does this thing even work? Is magic involved? 🎩###

*Deliver* is fully open source, you can take a look at it. It will only modify the content you want to modify using the ```Deliverfile```. Your password will be stored in the Mac OS X keychain, but can also be passed using environment variables.

*Deliver* uses the following techniques under the hood:

- The iTMSTransporter tool is used to fetch the latest app metadata from iTunesConnect and upload the updated app metadata back to Apple. iTMSTransporter is a command line tool provided by Apple.
- With the iTMSTransporter you can not create new version on iTunesConnect or actually publish the newly uploaded ipa file. This is why there is some browser scripting involved, using Capybara (https://github.com/jnicklas/capybara) and Poltergeist (https://github.com/teampoltergeist/poltergeist)
- The iTunes search API to find missing information about a certain app, like the *apple_id* when you only pass the *bundle_identifier*. 

# Tips
## Available language codes
```ruby
["da-DK", "de-DE", "el-GR", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi-FI", "fr-CA", "fr-FR", "id-ID", "it-IT", "ja-JP", "ko-KR", "ms-MY", "nl-NL", "no-NO", "pt-BR", "pt-PT", "ru-RU", "sv-SE", "th-TH", "tr-TR", "vi-VI", "cmn-Hans", "zh_CN", "cmn-Hant"]
```

## Use a clean status bar
You can use SimulatorStatusMagic(https://github.com/shinydevelopment/SimulatorStatusMagic) to clean up the status bar.

## Automatically create screenshots
There is no optimal solution out there (yet).

Some open source tools I found helpful:

- **Subliminal** (https://github.com/inkling/Subliminal): Write your app interaction (e.g. taps) in Objective C. Is based on UIAutomation and is well documented. Currently there are some issues with the latest release of Xcode, which are partly solved in the Xcode6 branch.
- **ui-screen-shooter** (https://github.com/jonathanpenn/ui-screen-shooter): Makes use of the normal UIAutomation code based on Javascript. The script basically helps you switching the device type and simulator language. It is based on AppleScript.
- **rScreenshooter** (https://github.com/KrauseFx/rScreenshooter): Similar to ui-screen-shooter, but based on Ruby. 

*Deliver* automatically detects the device type of each screenshot based on its resolution. All you have to do is to group the screenshots by their language. Make sure you use the correct language codes.

## Editing the ```Deliverfile```
Change syntax highlighting to *Ruby*.

## In progress
These are features, which are implemented, but not yet fully tested and production ready. You can try it on your own risk.

#### Distribute an ipa file to your TestFlight beta testers
```ruby
beta_ipa "./latest.ipa"
```
This will upload the ipa file to iTunesConnect and mark the uploaded build as Beta build.

# Need help?
- If there is a technical problem with *Deliver*, submit an issue
- I'm available for contract work - drop me an email: deliver@felixkrause.at

# License
GNU v3.0. See LICENSE file.

# Contributing

1. Fork it (https://github.com/KrauseFx/deliver/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
