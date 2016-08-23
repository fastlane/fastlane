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
[ruby](https://github.com/KrauseFx/fastlane-plugin-ruby) | Useful fastlane actions for Ruby projects | 853
[changelog](https://github.com/pajapro/fastlane-plugin-changelog) | Automate changes to your project CHANGELOG.md | 850
[instrumented_tests](https://github.com/joshrlesch/fastlane-plugin-instrumented_tests) | New action to run instrumented tests for android. This basically creates and boots an emulator before running an gradle commands so that you can run instrumented tests against that emulator. After the gradle command is executed, the avd gets shut down and deleted. This is really helpful on CI services, keeping them clean and always having a fresh avd for testing. | 838
[versioning](https://github.com/SiarheiFedartsou/fastlane-plugin-versioning) | Allows to work set/get app version directly to/from Info.plist | 830
[branding](https://github.com/snatchev/fastlane-branding-plugin) | Add some branding to your fastlane output | 826
[xamarin_build](https://github.com/punksta/fastlane-plugin-xamarin_build) | Build xamarin android\ios projects | 663
[tpa](https://github.com/mbogh/fastlane-plugin-tpa) | TPA gives you advanced user behaviour analytics, app distribution, crash analytics and more | 618
[appicon](https://github.com/neonichu/fastlane-plugin-appicon) | Generate required icon sizes and iconset from a master application icon. | 595
[increment_version_code](https://github.com/Jems22/fastlane-plugin-increment_version_code) | Increment the version code of your android project. | 586
[carthage_cache](https://github.com/thii/fastlane-plugin-carthage_cache) | A Fastlane plugin that allows to cache Carthage/Build folder in Amazon S3. | 554
[upload_folder_to_s3](https://github.com/teriiehina/fastlane-plugin-upload_folder_to_s3) | Upload a folder to S3 | 546
[goodify_info_plist](https://github.com/lyndsey-ferguson/fastlane-plugin-goodify_info_plist) | This plugin will update the plist so that the built application can be deployed and managed within BlackBerry's Good Dynamics Control Center for Enterprise Mobility Management. | 522
[instabug](https://github.com/SiarheiFedartsou/fastlane-plugin-instabug) | Uploads dSYM to Instabug | 518
[no_u](https://github.com/neonichu/fastlane-plugin-no_u) | no u | 486
[apprepo](https://github.com/suculent/fastlane-plugin-apprepo) | experimental fastlane plugin based on https://github.com/suculent/apprepo SFTP uploader | 480
[commit_android_version_bump](https://github.com/Jems22/fastlane-plugin-commit_android_version_bump) | This Android plugins allow you to commit every modification done in your build.gradle file during the execution of a lane. In fast, it do the same as the commit_version_bump action, but for Android | 478
[emoji_fetcher](https://github.com/Themoji/ios/tree/master/fastlane-plugin-emoji_fetcher) | Fetch the emoji font file and copy it to a local directory | 476
[xcake](https://github.com/jcampbell05/xcake/) | Create your Xcode projects automatically using a stupid simple DSL. | 464
[github_status](https://github.com/mfurtak/fastlane-plugin-github_status) | Provides the ability to display and act upon GitHub server status as part of your build | 451
[synx](https://github.com/afonsograca/fastlane-plugin-synx) | Organise your Xcode project folder to match your Xcode groups. | 435
`automated_test_emulator_run` | Allows to wrap gradle task or shell command that runs integrated tests that prepare and starts single AVD before test run. After tests are finished, emulator is killed and deleted. | 425
[clubmate](https://github.com/KrauseFx/fastlane-plugin-clubmate) | Print the Club Mate logo in your build output | 419
[applivery](https://github.com/applivery/fastlane-applivery-plugin) | Upload new build to Applivery | 416
[upload_symbols_to_hockey](https://github.com/justin/fastlane-plugin-upload_symbols_to_hockey) | Upload dSYM symbolication files to Hockey | 412
[ftp](https://github.com/PoissonBallon/fastlane-ftp-plugin) | Simple ftp upload and download for Fastlane | 407
[get_version_code](https://github.com/Jems22/fastlane-plugin-get_version_code) | Get the version code of anAndroid project. This action will return the version code of your project according to the one set in your build.gradle file | 381
[unzip](https://github.com/maxoly/fastlane-plugin-unzip) | Extract compressed files in a ZIP | 379
[jira_transition](https://github.com/valeriomazzeo/fastlane-plugin-jira_transition) | Apply a JIRA transition to issues mentioned in the changelog | 369
[poeditor_export](https://github.com/Supmenow/fastlane-plugin-poeditor_export) | Exports translations from POEditor.com | 369
`version_from_last_tag` | Perform a regex on last (latest) git tag and perform a regex to extract a version number such as Release 1.2.3 | 365
