DeployKit for iOS apps
============

[ ![Codeship Status for KrauseFx/ios_deploy_kit](https://codeship.io/projects/c9f92850-25fe-0132-5601-76bec1757a7f/status)](https://codeship.io/projects/37295)

Updating your iOS app should not be painful and time consuming. Automate the 
whole process to start with Continuous Deployment.

Follow the developer on Twitter: https://twitter.com/KrauseFx

# Features
- Upload hundreds of screenshots with different languages from different devices
- Upload a new ipa file to iTunesConnect without Xcode
- Update app metadata
- Easily implement a real Continuous Deployment process
- Store the configuration in git to easily deploy from **any** computer, including your Continuous Integration server (e.g. Jenkins)

# Installation

    $ sudo gem install ios_deploy_kit

## Credentials

### Use the Keychain
The first time you use *Deliver* you have to enter your iTunesConnect 
credentials. They will be stored in the Keychain. 

If you decide to remove your
credentials from the Keychain, just open the *Keychain Access*, select 
*All Items* and search for 'itunesconnect.apple.com'.

### Use environment variables
You can use the following environment variables:

    IOS_DEPLOY_KIT_USER
    IOS_DEPLOY_KIT_PASSWORD
    
### Implement something custom to fit your needs
Take a look at *Using the exposed Ruby classes. You

#Usage

## Using a *Deliver* file (recommended)
Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily deploy from any computer.

Name the file *Deliverfile* and store it in your project folder.

Here are a few example files:
#### Upload all screenshots to iTunesConnect
```ruby
app_identifier "net.sunapps.1"
screenshots_path "./screenshots"
```
The screenshots must be grouped by language code (see Available language codes)

#### Upload a new ipa file with a changelog to iTunesConnect
```ruby
ipa "./latest.ipa"
changelog({
    'en-US' => "This update adds cool new features",
    'de-DE' => "Dieses Update ist super"
})
```
#### Set a default language if you are lucky enough to only maintain one language
```ruby
default_language 'en-US'
title 'Only English Title'
```

#### Update the app's keywords
```ruby
default_language 'de-DE'
keywords ["keyword1", "something", "else"]
```

#### Read content from somewhere external (file, web service, ...)
```ruby
description({
    'en-US' => File.read("changelog-en.txt")
    'de-DE' => open("http://example.com/latest-changelog.txt").read
})
```
#### Build and sign the app using Shenzhen (https://github.com/nomad/shenzhen)
```ruby
ipa do
    system("ipa build") # first build it using Shenzhen
    "./AppName.ipa" # Tell 'Deliver' where it can find the finished ipa file
end
```
    
As you can see, the *Deliverfile* is a normal Ruby file, which is executed when
running a deployment. Therefore it's possible to fully customise the behaviour
on a deployment. 

**Some examples:**

- Run your own unit tests or integration tests before a deploy (recommended)
- Ask the script user for a changelog
- Deploy a new version just by starting a Jenkins job
- Post the deployment status on Slack
- Upload the latest screenshots on your server
- Many more things, be creative and let me know :)
    
## Using the CLI (not yet finished)
The documentation will be updated, once this is implemented

## Using the exposed Ruby classes
Some examples
```ruby
app = IosDeployKit::App.new(apple_id)

app.get_app_status # => Waiting for Review
app.create_new_version!('1.4')
app.metadata.update_title({ 'en-US' => "iPhone App Title" })
app.metadata.set_all_screenshots_from_path("./screenshots")
app.upload_metadata!

IosDeployKit::ItunesSearchApi.fetch_by_identifier('net.sunapps.9') # => Fetches public metadata
```    
    

# Tips
## Available language codes
```ruby
["da-DK", "de-DE", "el-GR", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi-FI", "fr-CA", "fr-FR", "id-ID", "it-IT", "ja-JP", "ko-KR", "ms-MY", "nl-NL", "no-NO", "pt-BR", "pt-PT", "ru-RU", "sv-SE", "th-TH", "tr-TR", "vi-VI", "cmn-Hans", "zh_CN", "cmn-Hant"]
```
    


# Contributing

1. Fork it ( https://github.com/KrauseFx/ios_deploy_kit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
