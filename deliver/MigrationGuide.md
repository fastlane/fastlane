## deliver migration guide to 1.0

### Why breaking changes?

Originally `deliver` was designed to be "The Continuous Delivery tool for iOS". With the introduction of [fastlane](https://fastlane.tools) many things have changed. It was time for a big rewrite for `deliver`, which is one of the most popular tools of the [fastlane toolchain](https://fastlane.tools).

### What do I have to do to get my setup working again?

In general, check out the latest documentation for the [Deliverfile](https://docs.fastlane.tools/actions/deliver/).

With 1.0 the app will not be submitted to Review by default. You can use the `fastlane deliver --submit_for_review` to submit after the upload.

#### Standard Setups (one app)

The easiest way is to remove the existing `Deliverfile` (which is probably almost empty anyway) and clear the `metadata` folder and run `deliver init`, so that `deliver` creates everything in the new format for you.

#### Advanced Setups

To manually migrate setups (especially if you make heavy use of the `Deliverfile`):

Make sure to adapt the paths to include the `fastlane` directory (if necessary).

**The following options have been removed from the `Deliverfile`:**

Removed     | Use instead              | Note
---------|-----------------|------------------------------------------------------------
`beta_ipa` | |
`success`| [fastlane](https://fastlane.tools) |
`error` | [fastlane](https://fastlane.tools) |
`email` | `username` |
`apple_id` |  `app` | use `app_identifier` to specify the bundle identifier instead
`version` | `app_version` | is usually automatically detected
`default_language` | | 
`config_json_folder` | | No more support for JSON based configuration
`hide_transporter` | | This might be implemented at a later point
`primary_subcategories` | `primary_first_sub_category` and `primary_second_sub_category` |
`secondary_subcategories` | `secondary_first_sub_category` and `secondary_second_sub_category` |

**The following options have been changed:**

From     | To              | Note
---------|-----------------|------------------------------------------------------------
`title`  | `name` | requires `name({ "en-US" => "App name" })`
`changelog` | `release_notes`
`keywords` |   | requires a simple string instead of arrays
`ratings_config_path` | `app_rating_config_path` | [New Format](https://docs.fastlane.tools/actions/deliver/#editing-the-deliverfile)
`submit_further_information` | `submission_information` | [New Format](https://docs.fastlane.tools/actions/deliver/#editing-the-deliverfile)

**The following commands have been removed:**

Removed                   | Use instead
--------------------------|------------------------------------------------------------
`deliver testflight` | [pilot](https://docs.fastlane.tools/actions/pilot/)
`testflight` | [pilot](https://docs.fastlane.tools/actions/pilot/)

**The following codes/values have been changed:**

Changed                   | &nbsp;
--------------------------|------------------------
Language Codes | [Reference.md](https://docs.fastlane.tools/actions/deliver/#reference)
Age Rating | [Reference.md](https://docs.fastlane.tools/actions/deliver/#reference)
App Categories | [Reference.md](https://docs.fastlane.tools/actions/deliver/#reference)

### What's different now? :recycle: 

<img width="154" alt="screenshot 2015-09-26 21 47 35" src="https://cloud.githubusercontent.com/assets/869950/10121262/38e52e02-6498-11e5-8269-bf5d63ca698a.png">


- `deliver` now uses [spaceship](https://spaceship.airforce) to communicate with . This has *huge* advantages over the old way, which means `deliver` is now much faster and more stable :rocket: 
- Removed a lot of legacy code. Did you know `deliver` is now one year old? A lot of things have changed since then
- Improved the selection of the newly uploaded build and waiting for processing to be finished, which is possible thanks to `spaceship`
- Updating the app metadata and uploading of the screenshots now happen using `spaceship` instead of the iTunes Transporter, which means changes will immediately visible after running `deliver` :sparkles: 
- Removed the `deliver beta` and `testflight` commands, as there is now a dedicated tool called [pilot](https://docs.fastlane.tools/actions/pilot/)
- All parameters are now in the config system, which means you can pass values using the `Deliverfile`, from within your `Fastfile` or as command line parameter
<img width="500" alt="screenshot 2015-09-26 21 57 15" src="https://cloud.githubusercontent.com/assets/869950/10121297/c6ea1c7a-6499-11e5-8d2b-301f86faacf0.png">
- The preview doesn't highlight changes with blue any more
- Screenshot are uploaded every time. This is on the [next-tasks list](https://github.com/fastlane/fastlane/issues/2212)

If you run into any issues with the new version of `deliver` please submit an issue on GitHub.
