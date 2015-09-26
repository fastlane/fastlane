## Available options

##### default_language
If specified, this will use the given default language, whenever you only pass one value. Must be on the top of the file.

##### email
The email address of your Apple ID account. If you do not specify one, you will be asked for one when you run `deliver`.

##### app_identifier
The bundle identifier (e.g. com.krausefx.app), if not passed, the one inside the `ipa` file will be used.

##### apple_id
The Apple ID of the app (not your email address), which can be found on iTunesConnect. This will automatically be fetched based on the app_identifer, if the app is already publicly available in the US App Store.

##### version
The app version you want to submit. Is used to create a new version on iTunesConnect. This will be fetched from the `ipa` file, if given.

##### ipa
A path to a signed ipa file, which will be uploaded. If you don't provide this value, only app metadata will be uploaded. After the upload was successful, it will wait until iTunesConnect processing is finished and submit the update.

##### beta_ipa
A path to a signed ipa file, which will be uploaded and used for Apple TestFlight. After the upload was successful, it will wait until iTunesConnect processing is finished and submit the update to the testers. You have to add `--beta` to your `deliver` call to use `beta_ipa` instead of `ipa`.

##### description
The description of the app

##### title
The title of the app

##### changelog
The changelog (What's new?) of the latest version

##### support_url, marketing_url, privacy_url
These URLs are shown in the AppStore

##### keywords
An array of keywords
```ruby
keywords(
  "en-US" => ["Keyword1", "Keyword2"]
)
```

##### screenshots_path
A path to a folder containing subfolders for each language. This will automatically detect the device type based on the image resolution. Also includes  Watch Support.

##### skip_pdf
If set to `true`, no PDF report will be generated before the actual deployment. You can also pass `--force` when calling `deliver`.

##### price_tier
Pass the price tier as number. This will be active from the current day.
```ruby
price_tier 0
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

##### copyright
The up to date copyright information.
```ruby
copyright "#{Time.now.year} Felix Krause"
```

##### primary_category
The english name of the category you want to set (e.g. `Business`, `Books`)

##### secondary_category
The english name of the secondary category you want to set

##### primary_subcategories
The array of english names of the primary sub categories you want to set

##### secondary_subcategories
The array of english names of the secondary sub categories you want to set

##### automatic_release
Should the app be released to all users once Apple approves it? If set to `false`, you'll have to manually release the update once it got approved.

##### app_review_information
Contact information for the app review team. Available options: `first_name`, `last_name`, `phone_number`, `email_address`, `demo_user`, `demo_password`, `notes`. Check out the [example](#example-deliverfile).


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

##### ratings_config_path
You can set the app age ratings using `deliver`. You'll have to create and store a `JSON` configuration file. Copy the [template](https://github.com/KrauseFx/deliver/blob/master/assets/example_rating_config.json) to your project folder and pass the path to the `JSON` file using the `ratings_config_path` option. 

The `comment` in the `JSON` file is just for your convenience, it will not be used by `deliver`. You can now replace the `level` values to have the value `1` for `mild` and `2` for `intense`. 

The `boolean` values on the bottom can only have the value `0` or `1`.

##### submit_further_information 
should be a hash. This is used as the last step for the deployment process, where you define if you use third party content or use encryption. Here is a screenshot of the available options: [iTunesConnect Screenshot](https://github.com/krausefx/deliver/blob/master/assets/SubmitForReviewInformation.png?raw=1)
```ruby
submit_further_information({
  export_compliance: {
    encryption_updated: false,
    cryptography_enabled: false,
    is_exempt: false
  },
  third_party_content: {
    contains_third_party_content: false,
    has_rights: false
  },
  advertising_identifier: {
    use_idfa: false,
    serve_advertisement: false,
    attribute_advertisement: false,
    attribute_actions: false,
    limit_ad_tracking: false
  }
})
```

##### More options for TestFlight Builds

You can pass the "What to Test" value using the environment variable `DELIVER_WHAT_TO_TEST`:

`DELIVER_WHAT_TO_TEST="Try the brand new project button" deliver`
Additional environment variables: `DELIVER_BETA_DESCRIPTION`, `DELIVER_BETA_FEEDBACK_EMAIL`.

The latest commands can always be found inside [deliverer.rb](https://github.com/KrauseFx/deliver/blob/master/lib/deliver/deliverer.rb) in the `ValKey` module.

## Example Deliverfile

```ruby
screenshots_path "./screenshots"

title(
  "en-US" => "Your App Name"
)

# changelog(
#   "en-US" => "iPhone 6 (Plus) Support" 
# )

copyright "#{Time.now.year} Felix Krause"

automatic_release false

app_review_information(
  first_name: "Felix",
  last_name: "Krause",
  phone_number: "+44 844 209 0611",
  email_address: "github@krausefx.com",
  demo_user: "demoUser",
  demo_password: "demoPass",
  notes: "such notes, very text"
)

primary_category "Business"
secondary_category "Games"
secondary_subcategories ["Educational", "Puzzle"]

ratings_config_path "~/Downloads/config.json"

price_tier 5

# it is recommended to remove that part and use fastlane instead for building
ipa do
    system("cd ..; ipa build") # build your project using Shenzhen
    "../fastlane.ipa" # Tell 'deliver' where it can find the finished ipa file
end

beta_ipa do
  system("cd ..; ipa build") # build your project using Shenzhen
  "../fastlane.ipa" # Tell 'deliver' where it can find the finished ipa file
end

success do
  system("say 'Successfully submitted a new version.'")
end
```
