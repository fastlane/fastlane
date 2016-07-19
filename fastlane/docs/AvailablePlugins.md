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
[ruby](https://github.com/KrauseFx/fastlane-plugin-ruby) | Useful fastlane actions for Ruby projects | 731
[versioning](https://github.com/SiarheiFedartsou/fastlane-plugin-versioning) | Allows to work set/get app version directly to/from Info.plist | 698
[branding](https://github.com/snatchev/fastlane-branding-plugin) | Add some branding to your fastlane output | 628
`instrumented_tests` | New action to run instrumented tests for android. This basically creates and boots an emulator before running an gradle commands so that you can run instrumented tests against that emulator. After the gradle command is executed, the avd gets shut down and deleted. This is really helpful on CI services, keeping them clean and always having a fresh avd for testing. | 438
[instabug](https://github.com/SiarheiFedartsou/fastlane-plugin-instabug) | Uploads dSYM to Instabug | 422
[emoji_fetcher](https://github.com/Themoji/ios/tree/master/fastlane-plugin-emoji_fetcher) | Fetch the emoji font file and copy it to a local directory | 414
[apprepo](https://github.com/suculent/fastlane-plugin-apprepo) | experimental fastlane plugin based on https://github.com/suculent/apprepo SFTP uploader | 410
[appicon](https://github.com/neonichu/fastlane-plugin-appicon) | Generate required icon sizes and iconset from a master application icon. | 409
[github_status](https://github.com/mfurtak/fastlane-plugin-github_status) | Provides the ability to display and act upon GitHub server status as part of your build | 389
[no_u](https://github.com/neonichu/fastlane-plugin-no_u) | no u | 381
[xamarin_build](https://github.com/punksta/fastlane-plugin-xamarin_build) | Build xamarin android\ios projects | 362
[goodify_info_plist](https://github.com/lyndsey-ferguson/fastlane-plugin-goodify_info_plist) | This plugin will update the plist so that the built application can be deployed and managed within BlackBerry's Good Dynamics Control Center for Enterprise Mobility Management. | 353
[synx](https://github.com/afonsograca/fastlane-plugin-synx) | Organise your Xcode project folder to match your Xcode groups. | 337
[tpa](https://github.com/mbogh/fastlane-plugin-tpa) | TPA gives you advanced user behaviour analytics, app distribution, crash analytics and more | 319
[changelog](https://github.com/pajapro/fastlane-plugin-changelog) | Automate changes to your project CHANGELOG.md | 315
[xcake](https://github.com/jcampbell05/xcake/) | Create your Xcode projects automatically using a stupid simple DSL. | 314
[clubmate](https://github.com/KrauseFx/fastlane-plugin-clubmate) | Print the Club Mate logo in your build output | 298
[unzip](https://github.com/maxoly/fastlane-plugin-unzip) | Extract compressed files in a ZIP | 296
[ascii_art](https://github.com/neonichu/fastlane-ascii-art) | Add some fun to your fastlane output. | 243
[carthage_cache](https://github.com/thii/fastlane-plugin-carthage_cache) | A Fastlane plugin that allows to cache Carthage/Build folder in Amazon S3. | 231
[sentry](https://github.com/getsentry/sentry-fastlane) | Upload symbols to Sentry | 230
`version_from_last_tag` | Perform a regex on last (latest) git tag and perform a regex to extract a version number such as Release 1.2.3 | 214
[jira_transition](https://github.com/valeriomazzeo/fastlane-plugin-jira_transition) | Apply a JIRA transition to issues mentioned in the changelog | 210
[tunes](https://github.com/neonichu/fastlane-tunes) | Play music using fastlane, because you can. | 201
[upload_folder_to_s3](https://github.com/teriiehina/fastlane-plugin-upload_folder_to_s3) | Upload a folder to S3 | 201
[ya_tu_sabes](https://github.com/neonichu/fastlane-plugin-ya_tu_sabes) | Ya tu sabes. | 199
[upload_symbols_to_hockey](https://github.com/justin/fastlane-plugin-upload_symbols_to_hockey) | Upload dSYM symbolication files to Hockey | 175
[download_file](https://github.com/maxoly/fastlane-plugin-download_file) | This action downloads a file from an HTTP/HTTPS url (e.g. ZIP file) and puts it in a destination path | 151
`figlet` | Wrapper around figlet which makes large ascii text words | 126
