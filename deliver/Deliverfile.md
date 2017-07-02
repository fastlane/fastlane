## Available options

All the options below can easily be added to your `Deliverfile`. The great thing: if you use `fastlane` you can use all these options from your `Fastfile` too, for example:

```ruby
deliver(
  submit_for_review: true,
  metadata_path: "../folder"
)
```

##### app_identifier
The bundle identifier (e.g. "com.krausefx.app")

##### username
Your Apple ID email address

##### ipa
A path to a signed ipa file, which will be uploaded. If you don't provide this value, only app metadata will be uploaded. If you want to submit the app for review make sure to either use `fastlane deliver --submit_for_review` or add `submit_for_review true` to your `Deliverfile`

```ruby
ipa "App.ipa"
```

if you use [fastlane](https://fastlane.tools) the ipa file will automatically be detected.

##### pkg
A path to a signed pkg file, which will be uploaded. Submission logic of ipa applies to pkg files.
```ruby
pkg "MacApp.pkg"
```

##### app_version

Optional, as it is usually automatically detected. Specify the version that should be created / edited on iTunes Connect:

```ruby
app_version "2.0"
```

##### skip_app_version_update

In the case if `deliver` uploads your application to iTunes Connect it will automatically update "Prepare for submission" app version (which could be found on iTunes Connect->My Apps->App Store page)

The option allows uploading your app without updating "Prepare for submission" version. 

This could be useful in the case if you are generating a lot of uploads while not submitting the latest build for Apple review.

The default value is false.

```ruby
skip_app_version_update true
```

##### submit_for_review

Add this to your `Deliverfile` to automatically submit the app for review after uploading metadata/binary. This will select the latest build.

```ruby
submit_for_review true
```

##### screenshots_path
A path to a folder containing subfolders for each language. This will automatically detect the device type based on the image resolution. Also includes  Watch Support.

![assets/screenshots.png](assets/screenshots.png)

##### metadata_path
Path to the metadata you want to use. The folder has to be structured like this

![assets/metadata.png](assets/metadata.png)

If you run `deliver init` this will automatically be created for you.

##### force

```ruby
force true
```
If set to `true`, no HTML report will be generated before the actual upload. You can also pass `--force` when calling `deliver`.


##### price_tier
Pass the price tier as number. This will be active from the current day.
```ruby
price_tier 0
```
##### trade_representative_contact_information
Trade Representative Contact information for Korean App Store. Available options: `first_name`, `last_name`, `address_line1`, `address_line2`, `address_line3`, `city_name`, `state`, `country`, `postal_code`, `phone_number`, `email_address`, `is_displayed_on_app_store`.


```ruby
trade_representative_contact_information(
  first_name: "Felix",
  last_name: "Krause",
  address_line1: "1 Infinite Loop",
  address_line2: "",
  address_line3: null,
  city_name: "Cupertino",
  state: "California",
  country: "United States",
  postal_code: "95014",
  phone_number: "+43 123123123",
  email_address: "github@krausefx.com",
)
```

You can also provide these values by creating files in a `metadata/trade_representative_contact_information/` directory. The file names must match the pattern `<key>.txt` (e.g. `first_name.txt`, `address_line1.txt` etc.). The contents of each file will be used as the value for the matching key. Values provided in the `Deliverfile` or `Fastfile` will be take priority over values from these files.

`is_displayed_on_app_store` is the option on iTunes Connect described as: `Display Trade Representative Contact Information on the Korean App Store`

##### app_review_information
Contact information for the app review team. Available options: `first_name`, `last_name`, `phone_number`, `email_address`, `demo_user`, `demo_password`, `notes`. 


```ruby
app_review_information(
  first_name: "Felix",
  last_name: "Krause",
  phone_number: "+43 123123123",
  email_address: "github@krausefx.com",
  demo_user: "demoUser",
  demo_password: "demoPass",
  notes: "such notes, very text"
)
```

You can also provide these values by creating files in a `metadata/review_information/` directory. The file names must match the pattern `<key>.txt` (e.g. `first_name.txt`, `notes.txt` etc.). The contents of each file will be used as the value for the matching key. Values provided in the `Deliverfile` or `Fastfile` will be take priority over values from these files.

##### submission_information 
Must be a hash. This is used as the last step for the deployment process, where you define if you use third party content or use encryption. [A list of available options](https://github.com/fastlane/fastlane/blob/master/spaceship/lib/spaceship/tunes/app_submission.rb#L18-L69).

```ruby
submission_information({
  add_id_info_serves_ads: true,
  ...
})
```

##### automatic_release
Should the app be released to all users once Apple approves it? If set to `false`, you'll have to manually release the update once it got approved.

```ruby
automatic_release true
# or 
automatic_release false
```

##### phased_release

Enable or disable the phased releases feature of iTunes Connect. If set to `true`, the update will be released over a 7 day period. Default behavior is to leave whatever you defined on iTunes Connect.

```ruby
phased_release true
# or 
phased_release false
```

##### app_rating_config_path
You can set the app age ratings using `deliver`. You'll have to create and store a `JSON` configuration file. Copy the [template](https://github.com/fastlane/fastlane/blob/master/deliver/assets/example_rating_config.json) to your project folder and pass the path to the `JSON` file using the `app_rating_config_path` option. 

The keys/values on the top allow values from 0-2, and the items on the bottom allow only 0 or 1. More information in the [Reference.md](https://github.com/fastlane/fastlane/blob/master/deliver/Reference.md).






## Metadata

All options below are useful if you want to specify certain app metadata in your `Deliverfile` or `Fastfile`

### Localised

Localised values should be set like this

```ruby
description({
  'en-US' => "English Description here",
  'de-DE' => "Deutsche Beschreibung hier"
})
```

##### name
The title/name of the app

##### subtitle

Localised subtitle of the app

```ruby
subtitle(
  "en-US" => "Awesome English subtitle here",
  "de-DE" => "Jetzt mit deutschen Untertiteln!"
)
```

##### description
The description of the app

##### release_notes
The release_notes (What's new / Changelog) of the latest version

##### support_url, marketing_url, privacy_url
These URLs are shown in the AppStore

##### keywords

Keywords separated using a comma.

```ruby
keywords(
  "en-US" => "Keyword1, Keyword2"
)
```

##### promotional_text

Localised promotional text

```ruby
promotional_text(
  "en-US" => "Hey, you should totally buy our app, it's the best",
  "de-DE" => "App kaufen bitte"
)
```

##### app_icon
A path to a new app icon, which must be exactly 1024x1024px
```ruby
app_icon './AppIcon.png'
```

##### apple_watch_app_icon
A path to a new app icon for the  Watch, which must be exactly 1024x1024px
```ruby
apple_watch_app_icon './AppleWatchAppIcon.png'
```

##### platform

The platform of your application (a.e. ios, osx). 

This option is optional. The default value is "ios" and deliver should be able to figure out the platform from your binary.

However, in the case if multiple binaries present, you can specify a platform which you want to deliver explicitly.

The available options: 

- 'ios'
- 'appletvos'
- 'osx'


### Non-Localised

##### copyright
The up to date copyright information.
```ruby
copyright "#{Time.now.year} Felix Krause"
```

##### primary_category
The english name of the category you want to set (e.g. `Business`, `Books`)

See [Reference.md](https://github.com/fastlane/fastlane/blob/master/deliver/Reference.md) for a list of available categories

##### secondary_category
The english name of the secondary category you want to set

##### primary_first_sub_category
The english name of the primary first sub category you want to set

##### primary_second_sub_category
The english name of the primary second sub category you want to set

##### secondary_first_sub_category
The english name of the secondary first sub category you want to set

##### secondary_second_sub_category
The english name of the secondary second sub category you want to set
