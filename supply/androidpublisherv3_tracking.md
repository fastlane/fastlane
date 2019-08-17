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
  | Checking in other tracks if specified, when production track doesn't have any version | https://tinyurl.com/yxkse6rq | Aug 17, 2019 |

<br>

## Notes

  * Have to pass version flag when running `supply init`
    * https://github.com/scorpion35/fastlane/commit/b873f8bedbf53f9002b2a696bbe16dcf56bc61e2#commitcomment-34563014
    * https://github.com/scorpion35/fastlane/blob/69522c83403095877d5f45d0b413dc44783b7e5a/supply/lib/supply/setup.rb#L18
