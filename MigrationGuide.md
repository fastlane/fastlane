### deliver migration guide to 1.0

#### Why breaking changes?

 With it there were some breaking changes. Originally `deliver` was designed to be "The Continuous Delivery tool for iOS". With the introduction of fastlane it doesn't make sense any more. Did you know that deliver was able to run tests and post messages to Slack? :wink: All that is now part of [fastlane](https://fastlane.tools).

#### What do I have to do to get my setup working again?

The easiest way for standard setups is to run `deliver init` and `deliver` will generate all configuration files for you.

To manually migrate setups (especially if you make heavy use of the `Deliverfile`):

**The following options have been removed from the `Delivefile`:**

- `beta_ipa`
- `success` (now part of [fastlane](https://fastlane.tools))
- `error` (now part of [fastlane](https://fastlane.tools))
- `email` (use `username` instead)
- `apple_id` (use `app_identifier` to specify the bundle identifier instead). If you want to specify the ID of your app, you can also use the `app` option
- `version` (will automatically be detected)
- `default_language`
- `config_json_folder`

**The following options have been changed:**

From     | To              | Note
---------|-----------------|------------------------------------------------------------
`title`  | `name`
`changelog` | `release_notes`
`keywords` |   | requires a simple string instead of arrays
`ratings_config_path` | `app_rating_config_path` | [New Format](https://github.com/KrauseFx/deliver/blob/master/Deliverfile.md#app_rating_config_path)
`submit_further_information` | `submission_information` | [New Format](https://github.com/KrauseFx/deliver/blob/feature/spaceship/Deliverfile.md#submission_information)

**The following commands have been removed:**

- `deliver testflight`
- `testflight`

Use [pilot](https://github.com/fastlane/pilot) instead.

### What has changed? :recycle: 

<img width="154" alt="screenshot 2015-09-26 21 47 35" src="https://cloud.githubusercontent.com/assets/869950/10121262/38e52e02-6498-11e5-8269-bf5d63ca698a.png">

- `deliver` now uses [spaceship](https://spaceship.airforce) to communicate with . This has *huge* advantages over the old way, which means `deliver` is now much faster and more stable :rocket: 
- Removed a lot of legacy code. Did you know `deliver` is now one year old? A lot of things have changed since then
- Improved the selection of the newly uploaded build and waiting for processing to be finished, which is possible thanks to `spaceship`
- Updating the app metadata and uploading of the screenshots now happen using `spaceship` instead of the iTunes Transporter, which means changes will immediately visible after running `deliver` :sparkles: 
- Removed the `deliver beta` and `testflight` commands, as there is now a dedicated tool called [pilot](https://github.com/fastlane/pilot)
