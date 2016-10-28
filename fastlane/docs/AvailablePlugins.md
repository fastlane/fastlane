### Available Plugins

To get an up to date list of all available plugins run

```
fastlane search_plugins
```

To search for a specific plugin

```
fastlane search_plugins [search_query]
```

You can find more information about how to start using plugins in [Plugins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

#### List of plugins

| Plugin Name | Description | Downloads
--------------|-------------|----------|----------
[sharethemeal](https://github.com/hjanuschka/fastlane-plugin-aws_device_farm) | ShareTheMeal for _fastlane_ | 1877
[changelog](https://github.com/pajapro/fastlane-plugin-changelog) | Automate changes to your project CHANGELOG.md | 1733
`polidea` | Polidea's fastlane action | 1596
`automated_test_emulator_run` | Allows to wrap gradle task or shell command that runs integrated tests that prepare and starts single AVD before test run. After tests are finished, emulator is killed and deleted. | 1256
[xcake](https://github.com/jcampbell05/xcake/) | Create your Xcode projects automatically using a stupid simple DSL. | 1148
[instrumented_tests](https://github.com/joshrlesch/fastlane-plugin-instrumented_tests) | New action to run instrumented tests for android. This basically creates and boots an emulator before running an gradle commands so that you can run instrumented tests against that emulator. After the gradle command is executed, the avd gets shut down and deleted. This is really helpful on CI services, keeping them clean and always having a fresh avd for testing. | 1077
[branding](https://github.com/snatchev/fastlane-branding-plugin) | Add some branding to your fastlane output | 1022
[versioning](https://github.com/SiarheiFedartsou/fastlane-plugin-versioning) | Allows to work set/get app version directly to/from Info.plist | 1005
[ruby](https://github.com/KrauseFx/fastlane-plugin-ruby) | Useful fastlane actions for Ruby projects | 1000
[increment_version_code](https://github.com/Jems22/fastlane-plugin-increment_version_code) | Increment the version code of your android project. | 859
[tpa](https://github.com/mbogh/fastlane-plugin-tpa) | TPA gives you advanced user behaviour analytics, app distribution, crash analytics and more | 856
[xamarin_build](https://github.com/punksta/fastlane-plugin-xamarin_build) | Build xamarin android\ios projects | 820
[appicon](https://github.com/neonichu/fastlane-plugin-appicon) | Generate required icon sizes and iconset from a master application icon. | 768
[applivery](https://github.com/applivery/fastlane-applivery-plugin) | Upload new build to Applivery | 753
[carthage_cache](https://github.com/thii/fastlane-plugin-carthage_cache) | A Fastlane plugin that allows to cache Carthage/Build folder in Amazon S3. | 744
[commit_android_version_bump](https://github.com/Jems22/fastlane-plugin-commit_android_version_bump) | This Android plugins allow you to commit every modification done in your build.gradle file during the execution of a lane. In fast, it do the same as the commit_version_bump action, but for Android | 699
[trainer](https://github.com/KrauseFx/trainer) | Convert xcodebuild plist files to JUnit reports | 694
[upload_folder_to_s3](https://github.com/teriiehina/fastlane-plugin-upload_folder_to_s3) | Upload a folder to S3 | 655
[goodify_info_plist](https://github.com/lyndsey-ferguson/fastlane-plugin-goodify_info_plist) | This plugin will update the plist so that the built application can be deployed and managed within BlackBerry's Good Dynamics Control Center for Enterprise Mobility Management. | 650
[synx](https://github.com/afonsograca/fastlane-plugin-synx) | Organise your Xcode project folder to match your Xcode groups. | 628
[instabug](https://github.com/SiarheiFedartsou/fastlane-plugin-instabug) | Uploads dSYM to Instabug | 615
[no_u](https://github.com/neonichu/fastlane-plugin-no_u) | no u | 587
[get_version_code](https://github.com/Jems22/fastlane-plugin-get_version_code) | Get the version code of anAndroid project. This action will return the version code of your project according to the one set in your build.gradle file | 565
[apprepo](https://github.com/suculent/fastlane-plugin-apprepo) | experimental fastlane plugin based on https://github.com/suculent/apprepo SFTP uploader | 559
[emoji_fetcher](https://github.com/Themoji/ios/tree/master/fastlane-plugin-emoji_fetcher) | Fetch the emoji font file and copy it to a local directory | 550
[upload_symbols_to_hockey](https://github.com/justin/fastlane-plugin-upload_symbols_to_hockey) | Upload dSYM symbolication files to Hockey | 549
[clubmate](https://github.com/KrauseFx/fastlane-plugin-clubmate) | Print the Club Mate logo in your build output | 529
[ftp](https://github.com/PoissonBallon/fastlane-ftp-plugin) | Simple ftp upload and download for Fastlane | 526
[github_status](https://github.com/mfurtak/fastlane-plugin-github_status) | Provides the ability to display and act upon GitHub server status as part of your build | 526
[aws_device_farm](https://github.com/hjanuschka/fastlane-plugin-aws_device_farm) | Run Android-Instrumentation or iOS XCUI-Tests on AWS Device Farm | 509
[poeditor_export](https://github.com/Supmenow/fastlane-plugin-poeditor_export) | Exports translations from POEditor.com | 506
`version_from_last_tag` | Perform a regex on last (latest) git tag and perform a regex to extract a version number such as Release 1.2.3 | 477
[jira_transition](https://github.com/valeriomazzeo/fastlane-plugin-jira_transition) | Apply a JIRA transition to issues mentioned in the changelog | 469
[unzip](https://github.com/maxoly/fastlane-plugin-unzip) | Extract compressed files in a ZIP | 459
[ascii_art](https://github.com/neonichu/fastlane-ascii-art) | Add some fun to your fastlane output. | 428
[upload_to_onesky](https://github.com/joshrlesch/fastlane-plugin-upload_to_onesky) | Upload a strings file to OneSky | 427
[localization](https://github.com/vmalyi/fastlane-plugin-localization) | Export/import app localizations with help of xcodebuild -exportLocalizations/-importLocalizations tool | 414
[get_version_name](https://github.com/Jems22/fastlane-plugin-get-version-name) | Get the version name of an Android project. | 404
[remove_provisioning_profile](https://github.com/Antondomashnev/fastlane-plugin-remove-provisioning-profile) | Remove provision profile from your local machine | 386
[sentry](https://github.com/getsentry/sentry-fastlane) | Upload symbols to Sentry | 344
[facelift](https://github.com/richardszalay/fastlane-plugin-facelift) | Deprecated in favor of 'fastlane-plugin-act' | 336
[giffy](https://github.com/SiarheiFedartsou/fastlane-plugin-giffy) | Fastlane plugin for Giffy.com API | 307
[tunes](https://github.com/neonichu/fastlane-tunes) | Play music using fastlane, because you can. | 304
`figlet` | Wrapper around figlet which makes large ascii text words | 266
[ya_tu_sabes](https://github.com/neonichu/fastlane-plugin-ya_tu_sabes) | Ya tu sabes. | 249
[download_file](https://github.com/maxoly/fastlane-plugin-download_file) | This action downloads a file from an HTTP/HTTPS url (e.g. ZIP file) and puts it in a destination path | 221
[latest_hockeyapp_version_number](https://github.com/tpalmer/fastlane-plugin-latest_hockeyapp_version_number) | Easily fetch the most recent HockeyApp version number for your app | 207
[check_good_version](https://github.com/lyndsey-ferguson/fastlane-plugin-check_good_version) | Checks the version of the installed Good framework | 198
[xcode_log_parser](https://github.com/KrauseFx/xcode_log_parser) | Convert the Xcode plist log to a JUnit report | 176
[act](https://github.com/richardszalay/fastlane-plugin-act) | Applies changes to plists and app icons inside a compiled IPA | 167
[coreos](https://github.com/icuisine-pos/fastlane-plugin-coreos) | Deploy docker services to CoreOS hosts | 124
[framer](https://github.com/spreaker/fastlane-framer-plugin) | Create images combining app screenshots with templates to make nice pictures for the App Store | 102
[firim](https://github.com/whlsxl/firim) | Upload ipa to fir.im | 1
