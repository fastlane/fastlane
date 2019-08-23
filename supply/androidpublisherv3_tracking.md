# Fastlane - AndroidPublisher V3 Migration

* [Links](#links)
* [History](#history)
* [Notes](#notes)

## Links
  | Key    | Value        |
  | :----      |:------------ |
  | Issue      | https://github.com/fastlane/fastlane/issues/14573  |
  | V3 API Documentation        | https://developers.google.com/android-publisher/api-ref/edits   |
  | Local path        | ~/.rbenv/versions/2.5.1/lib/ruby/gems/2.5.0/gems/google-api-client-0.23.7/generated/google/apis/androidpublisher_v3/   |

<br> 

## History
  | Description    | Commit Link        | Date    |
  | :----      |:------------ |:----      |
  | AndroidPublisher V3 Init        | https://tinyurl.com/yy2ywbaw   | Jul 7, 2019        |
  | <h2>`supply init`</h2> |  |  |
  | Added a method to return a list of all tracks      | https://tinyurl.com/yymdof68  | Jul 26, 2019      |
  | Minor bug fix | https://tinyurl.com/y2nvf44a  | Aug 2, 2019 |
  | Updated methods for listing and images | https://tinyurl.com/yxjaof7e  | Aug 2, 2019 |
  | Merged latest from master branch | https://tinyurl.com/yxjaof7e  | Aug 3, 2019 |
  | Part 1: Fetching release listings for given version number | https://tinyurl.com/yxps9cpm  | Aug 4, 2019 |
  | Part 1.1: Added track to ReleaseListing | https://tinyurl.com/y3wmubup  | Aug 4, 2019 |
  | Part 1.2: Properly setting version  number | https://tinyurl.com/y5whn2es | Aug 4, 2019 |
  | Part 2: Supply/setup/store_metadata downloading successfully | https://tinyurl.com/y42zkgk9 | Aug 4, 2019 |
  | Part 2.1: Downloading full size screenshots | https://tinyurl.com/yxoqg9nn | Aug 4, 2019 |
  | Part 2.2: Writing changelogs | https://tinyurl.com/y33ky4us | Aug 4, 2019 |
  | Part 3: Added new flag (-n) to specify version number when running fastlane supply init | <ul><li>https://tinyurl.com/y53tmlct</li><li>https://tinyurl.com/y5sjbmme</li></ul> | Aug 4, 2019 |
  | Part 3.1: Setting track precedence if version is found in more than one track | https://tinyurl.com/y57eo3jh | Aug 4, 2019 |
  | Part 3.2: Made version optional and finding it automatically | https://tinyurl.com/y5h34ejr | Aug 4, 2019 |
  | Returning full resolution screenshots/images from a single source | https://tinyurl.com/y6y53tqj | Aug 4, 2019 |
  | Checking in other tracks if specified, when production track doesn't have any version | <ul><li>https://tinyurl.com/yxkse6rq</li><li>https://tinyurl.com/y4fbebnb</li></ul> | Aug 17, 2019 |
  | <h2>`supply run`</h2> |  |  |
  | Uploading changelogs<ul><li>Added a couple of global variables to avoid hard coding</li><li>Added new option (-e) to specify release status</li></ul> | https://tinyurl.com/y3ldr9jt | Aug 17, 2019 |
  | Validation - Cannot specify rollout percentage when release status is 'draft'  | https://tinyurl.com/y4lsbun4 | Aug 17, 2019 |
  | Fixed lines removed by mistake from previous commit | https://tinyurl.com/y3htwgae | Aug 17, 2019 |
  | Added new option to just upload changelogs (i.e. without touching storefront metadata)<ul><li>`--skip_upload_metadata` only uploads metadata (i.e. without modifying/updating changelogs)</li><li>`--skip_upload_changelogs` only uploads changelogs (i.e. without modifying/updating storefront metadata) </li></ul> | https://tinyurl.com/y6pxy9gw | Aug 18, 2019 |
  | Refactor: Moved upload_changelogs to uploader.rb to just have client methods in client.rb | https://tinyurl.com/yxjpovrr | Aug 18, 2019 |
  | Converting --version_codes_to_retain to numbers | https://tinyurl.com/y2yly5l6 | Aug 18, 2019 |
  | Can now specify version codes to be added to release | https://tinyurl.com/y27gxa4z | Aug 18, 2019 |
  | Uploading apk's first if specified | https://tinyurl.com/y65998b9 | Aug 19, 2019 |
  | Adding rollout percentage to release | https://tinyurl.com/y459rxgs | Aug 20, 2019 |
  | [In progress] Updating rollout for a release | https://tinyurl.com/y6mcnvw7 | Aug 23, 2019 |

<br>

**Notes:**

  - [TODO] Enable update checker after all fixes.
    - File: https://github.com/scorpion35/fastlane/blob/androidpublisherv3/fastlane_core/lib/fastlane_core/update_checker/update_checker.rb#L42
    - Commit disabled in: https://github.com/scorpion35/fastlane/commit/4fed441658a68b31665f1b2003047476b919385a
  - `Supply::AVAILABLE_TRACKS` (`supply.rb`) => `rollout` track can be removed as it has no real use?
    - https://github.com/scorpion35/fastlane/commit/49d8f3f03b61828bcd3a731275262acb371429f1#commitcomment-34562545
  
  
  
