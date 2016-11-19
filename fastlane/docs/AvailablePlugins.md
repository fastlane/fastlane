### Available Plugins

To get an up to date list of all available plugins run

```no-highlight
fastlane search_plugins
```

To search for a specific plugin

```no-highlight
fastlane search_plugins [search_query]
```

You can find more information about how to start using plugins in [Plugins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

#### List of plugins

| Plugin Name | Description | Downloads
--------------|-------------|----------|----------
`polidea` | Polidea's fastlane action | 6074
[changelog](https://github.com/pajapro/fastlane-plugin-changelog) | Automate changes to your project CHANGELOG.md | 5092
[automated_test_emulator_run](https://github.com/AzimoLabs/fastlane-plugin-automated-test-emulator-run) | Starts n AVDs based on JSON file config. AVDs are created and configured according to user liking before instrumentation test process (started either via shell command or gradle) and killed/deleted after test process finishes. | 4988
[versioning](https://github.com/SiarheiFedartsou/fastlane-plugin-versioning) | Allows to set/get app version and build number directly to/from Info.plist | 3388
[update_project_codesigning](https://github.com/hjanuschka/fastlane-plugin-update_project_codesigning) | Updates the Xcode 8 Automatic Codesigning Flag | 3201
[sharethemeal](https://github.com/hjanuschka/fastlane-plugin-sharethemeal) | ShareTheMeal | 3051
[xcake](https://github.com/jcampbell05/xcake/) | Create your Xcode projects automatically using a stupid simple DSL. | 2955
`deploy_file_provider` | Prepares metadata files with structure ready for AppStore, PlayStore deploy | 2364
[increment_version_code](https://github.com/Jems22/fastlane-plugin-increment_version_code) | Increment the version code of your android project. | 2118
[tpa](https://github.com/mbogh/fastlane-plugin-tpa) | TPA gives you advanced user behaviour analytics, app distribution, crash analytics and more | 1972
[instrumented_tests](https://github.com/joshrlesch/fastlane-plugin-instrumented_tests) | New action to run instrumented tests for android. This plugin creates and boots an emulator before running a gradle command so that you can run instrumented tests against that emulator. After the gradle command is executed, the avd gets shut down and deleted. This is really helpful on CI services, keeping them clean and always having a fresh avd for testing. | 1864
[applivery](https://github.com/applivery/fastlane-applivery-plugin) | Upload new build to Applivery | 1675
[goodify_info_plist](https://github.com/lyndsey-ferguson/fastlane_plugins) | This plugin will update the plist so that the built application can be deployed and managed within BlackBerry's Good Dynamics Control Center for Enterprise Mobility Management. | 1672
[upload_folder_to_s3](https://github.com/teriiehina/fastlane-plugin-upload_folder_to_s3) | Upload a folder to S3 | 1616
[carthage_cache](https://github.com/thii/fastlane-plugin-carthage_cache) | A Fastlane plugin that allows to cache Carthage/Build folder in Amazon S3. | 1520
[branding](https://github.com/snatchev/fastlane-branding-plugin) | Add some branding to your fastlane output | 1451
[appicon](https://github.com/neonichu/fastlane-plugin-appicon) | Generate required icon sizes and iconset from a master application icon. | 1431
[synx](https://github.com/afonsograca/fastlane-plugin-synx) | Organise your Xcode project folder to match your Xcode groups. | 1423
[ruby](https://github.com/KrauseFx/fastlane-plugin-ruby) | Useful fastlane actions for Ruby projects | 1402
[commit_android_version_bump](https://github.com/Jems22/fastlane-plugin-commit_android_version_bump) | This Android plugins allow you to commit every modification done in your build.gradle file during the execution of a lane. In fast, it do the same as the commit_version_bump action, but for Android | 1361
[xamarin_build](https://github.com/punksta/fastlane-plugin-xamarin_build) | Build xamarin android\ios projects | 1185
[trainer](https://github.com/KrauseFx/trainer) | Convert xcodebuild plist files to JUnit reports | 1154
[get_version_code](https://github.com/Jems22/fastlane-plugin-get_version_code) | Get the version code of anAndroid project. This action will return the version code of your project according to the one set in your build.gradle file | 1148
[aws_device_farm](https://github.com/hjanuschka/fastlane-plugin-aws_device_farm) | Run UI Tests on AWS Devicefarm | 949
[upload_symbols_to_hockey](https://github.com/justin/fastlane-plugin-upload_symbols_to_hockey) | Upload dSYM symbolication files to Hockey | 930
[instabug](https://github.com/SiarheiFedartsou/fastlane-plugin-instabug) | Uploads dSYM to Instabug | 909
[clubmate](https://github.com/KrauseFx/fastlane-plugin-clubmate) | Print the Club Mate logo in your build output | 892
[emoji_fetcher](https://github.com/Themoji/ios/tree/master/fastlane-plugin-emoji_fetcher) | Fetch the emoji font file and copy it to a local directory | 891
[get_android_version](https://github.com/MaximusMcCann/fastlane-plugin-get_android_version) | gets the android versionName and versionCode from the `AndroidManifest.xml` file located in the provided apk | 865
[no_u](https://github.com/neonichu/fastlane-plugin-no_u) | no u | 860
`version_from_last_tag` | Perform a regex on last (latest) git tag and perform a regex to extract a version number such as Release 1.2.3 | 811
[poeditor_export](https://github.com/Supmenow/fastlane-plugin-poeditor_export) | Exports translations from POEditor.com | 801
[jira_versions](https://github.com/SandyChapman/fastlane-plugin-jira_versions) | Manage your JIRA project's releases/versions with this plugin. | 793
[remove_provisioning_profile](https://github.com/Antondomashnev/fastlane-plugin-remove-provisioning-profile) | Remove provision profile from your local machine | 778
[apprepo](https://github.com/suculent/fastlane-plugin-apprepo) | experimental fastlane plugin based on https://github.com/suculent/apprepo SFTP uploader | 755
[localization](https://github.com/vmalyi/fastlane-plugin-localization) | Export/import app localizations with help of xcodebuild -exportLocalizations/-importLocalizations tool | 742
[get_version_name](https://github.com/Jems22/fastlane-plugin-get-version-name) | Get the version name of an Android project. | 736
[upload_to_onesky](https://github.com/joshrlesch/fastlane-plugin-upload_to_onesky) | Upload a strings file to OneSky | 733
[github_status](https://github.com/mfurtak/fastlane-plugin-github_status) | Provides the ability to display and act upon GitHub server status as part of your build | 722
[ftp](https://github.com/PoissonBallon/fastlane-ftp-plugin) | Simple ftp upload and download for Fastlane | 721
[check_good_version](https://github.com/lyndsey-ferguson/fastlane_plugins) | Checks the version of the installed Good framework | 684
[jira_transition](https://github.com/valeriomazzeo/fastlane-plugin-jira_transition) | Apply a JIRA transition to issues mentioned in the changelog | 684
[unzip](https://github.com/maxoly/fastlane-plugin-unzip) | Extract compressed files in a ZIP | 681
[ascii_art](https://github.com/neonichu/fastlane-ascii-art) | Add some fun to your fastlane output. | 673
[ensure_xcode_build_version](https://github.com/nafu/fastlane-plugin-ensure_xcode_build_version) | Ensure Xcode Build Version for working with Beta, GM and Release | 672
[update_provisioning_profile_specifier](https://github.com/faithfracture/update_provisioning_profile_specifier) | Update the provisioning profile in the Xcode Project file for a specified target | 670
[coreos](https://github.com/icuisine-pos/fastlane-plugin-coreos) | Deploy docker services to CoreOS hosts | 641
[sentry](https://github.com/getsentry/sentry-fastlane) | Upload symbols to Sentry | 630
[facelift](https://github.com/richardszalay/fastlane-plugin-facelift) | Deprecated in favor of 'fastlane-plugin-act' | 551
[giffy](https://github.com/SiarheiFedartsou/fastlane-plugin-giffy) | Fastlane plugin for Giffy.com API | 537
[update_xcodeproj](https://github.com/nafu/fastlane-plugin-update_xcodeproj) | Update Xcode projects | 526
[droidicon](https://github.com/chrhsmt/fastlane-plugin-droidicon) | Generate required icon sizes and iconset from a master application icon | 508
[certificate_expirydate](https://github.com/lyndsey-ferguson/fastlane_plugins/) | Retrieves the expiry date of the given p12 certificate file | 501
[pretty_junit](https://github.com/leandog/fastlane-plugin-pretty_junit) | Pretty JUnit test results for your Android projects. | 494
`pixie` | Show your build status on PIXIE! | 464
`intentconfirmation` | Halts the lane invocation, asks user to confirm if he wants to continue, may require password or key. | 460
[act](https://github.com/richardszalay/fastlane-plugin-act) | Applies changes to plists and app icons inside a compiled IPA | 442
`figlet` | Wrapper around figlet which makes large ascii text words | 419
[latest_hockeyapp_version_number](https://github.com/tpalmer/fastlane-plugin-latest_hockeyapp_version_number) | Easily fetch the most recent HockeyApp version number for your app | 417
[prepare_build_resources](https://github.com/CodeReaper/fastlane-plugin-prepare_build_resources) | Prepares certificates and provisioning profiles for building and removes them afterwards. | 388
[tunes](https://github.com/neonichu/fastlane-tunes) | Play music using fastlane, because you can. | 380
`upload_symbols_to_new_relic` | Uploads dSym to New Relic | 356
[get_unprovisioned_devices_from_hockey](https://github.com/leandog/fastlane-plugin-get_unprovisioned_devices_from_hockey) | Retrieves a list of unprovisioned devices from Hockey which can be passed directly into register_devices. | 335
[delete_files](https://github.com/leandog/fastlane-plugin-delete_files) | Deletes a file, folder or multiple files using shell glob pattern. | 331
[ya_tu_sabes](https://github.com/neonichu/fastlane-plugin-ya_tu_sabes) | Ya tu sabes. | 321
[download_file](https://github.com/maxoly/fastlane-plugin-download_file) | This action downloads a file from an HTTP/HTTPS url (e.g. ZIP file) and puts it in a destination path | 309
`android_change_app_name` | Changes the manifest's label attribute (appName).  Stores the original name for revertinng. | 304
[docker](https://github.com/milch/fastlane-plugin-docker) | fastlane Actions to support building images, logging into Docker Hub, and pushing those images to the Hub | 282
[gs_versioning](https://github.com/SAVeselovskiy/gs_versioning) | Plugin for GradoService versioning system | 272
[xcode_log_parser](https://github.com/KrauseFx/xcode_log_parser) | Convert the Xcode plist log to a JUnit report | 254
[framer](https://github.com/spreaker/fastlane-framer-plugin) | Create images combining app screenshots with templates to make nice pictures for the App Store | 251
[android_change_string_app_name](https://github.com/MaximusMcCann/fastlane-plugin-android_change_string_app_name) | Change the app_name in the strings.xml file &amp; revert method | 247
[rocket_chat](https://github.com/thiagofelix/fastlane-plugin-rocket_chat) | Send message to Rocket.Chat right from fastlane | 238
[wait_xcrun](https://github.com/mgrebenets/fastlane-plugin-wait_xcrun) | Wait for Xcode toolchain to come back online after switching Xcode versions. | 209
[clang_analyzer](https://github.com/SiarheiFedartsou/fastlane-plugin-clang_analyzer) | Runs Clang Static Analyzer(http://clang-analyzer.llvm.org/) and generates report | 205
[xcode8_srgb_workaround](https://github.com/SiarheiFiedartsou/fastlane-plugin-xcode8_srgb_workaround) | Converts PNGs and JPEGs in your project to sRGB format to avoid crashes when building with Xcode 8 for iOS 8 and earlier deployment target | 192
[firim](https://github.com/whlsxl/firim/tree/master/fastlane-plugin-firim) | firim | 184
[latest_hockey_build_number](https://github.com/stalniy/fastlane-plugin-latest_hockey_build_number) | Gets latest version number of the app with the bundle id from HockeyApp | 182
[download_github_release_asset](https://github.com/Antondomashnev/fastlane-plugin-download_github_release_asset) | This action downloads a GitHub release's asset using the GitHub API and puts it in a destination path.\nIf the file has been previously downloaded, it will be overrided. | 182
[onesky](https://github.com/danielkiedrowski/fastlane-plugin-onesky) | Helps to update the translations of your app using the OneSky service. | 171
`android_change_package_identifier` | Change the package identifier in the AndroidManifest.xml file. Can revert as well. | 164
[cryptex](https://github.com/hjanuschka/fastlane-plugin-cryptex) | fastlane Crypt Store Git repo | 159
[apperian](https://github.com/tomiblank/fastlane-plugin-apperian) | Allows to upload your IPA file to Apperian | 159
[gen_dev_workspace](https://github.com/AndrewSB/fastlane-plugin-gen_dev_workspace) | Configures an xcworkspace with specified xcodeprojs | 134
[aws_sns](https://github.com/joshdholtz/fastlane-plugin-aws_sns) | Creates AWS SNS platform applications | 128
[aws_s3](https://github.com/joshdholtz/fastlane-plugin-s3) | Upload IPA and APK to S3 | 123
[flurry](https://github.com/flurry/fastlane-plugin-flurry) | Upload dSYM symbolication files to Flurry | 122
