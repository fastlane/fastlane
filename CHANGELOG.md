# _fastlane_ CHANGELOG

---

When contributing to fastlane, don't forget to add an entry to this CHANGELOG.md file by copy/pasting and adapting this entry template:

```
* Describe your change here. End it with a full-stop and 2 spaces.  
  [Put Your Name Here](https://github.com/yourGitHubHandle)
  [#nn](https://github.com/fastlane/fastlane/pull/nn)
```

---

## Master

* None.  

## 2.13.0 User management and update pem for new Dev Portal

* Add user management to spaceship.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7993](https://github.com/fastlane/fastlane/pull/7993)
* Update _pem_ to work with the new Apple Developer Portal.  
  [KrauseFx](https://github.com/KrauseFx)
  [#8049](https://github.com/fastlane/fastlane/pull/8049)
* Fix `git_branch` task for Jenkins Pipeline jobs as they set `BRANCH_NAME` instead of `GIT_BRANCH`.  
  [anton-matosov](https://github.com/anton-matosov)
  [#8024](https://github.com/fastlane/fastlane/pull/8024)

## 2.12.0 Apple ID user role handling, improve spaceship stability and more

* Show appropriate spaceship error message when having insufficient permissions.  
  [KrauseFx](https://github.com/KrauseFx)
  [#8014](https://github.com/fastlane/fastlane/pull/8014)
* Add support for new and existing groups for iTC testers in spaceship.  
  [KrauseFx](https://github.com/KrauseFx)
  [#8005](https://github.com/fastlane/fastlane/pull/8005)
* Automatically retry failed requests on an internal server error for iTunesConnect (#8017 and #8006).  
* Fix `spaceauth` YAML spaceship cookie loading.  
  [hjanuschka](https://github.com/hjanuschka)
  [#8012](https://github.com/fastlane/fastlane/pull/8012)
* Simplify spaceship requests for account user information.  
  [KrauseFx](https://github.com/KrauseFx)
  [#8013](https://github.com/fastlane/fastlane/pull/8013)
* Improve error output when pilot can’t register new testers.  
  [KrauseFx](https://github.com/KrauseFx)
  [#8008](https://github.com/fastlane/fastlane/pull/8008)
* Improve scan error message for bad `SLACK_URL`.  
  [mfurtak](https://github.com/mfurtak)
  [#8004](https://github.com/fastlane/fastlane/pull/8004)
* Add `skip_testing`, `only_testing` options to scan.  
  [mfurtak](https://github.com/mfurtak)
  [#8002](https://github.com/fastlane/fastlane/pull/8002)
* Improve docs and code samples (#7986, #7985).  
* snapshot support for iPhone SE.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7995](https://github.com/fastlane/fastlane/pull/7995)
* Fastlane require format non plugins with dash.  
  [joshdholtz](https://github.com/joshdholtz)
  [#7998](https://github.com/fastlane/fastlane/pull/7998)
* Add Automatic Release Date for Tunes Submission in _spaceship_.  
  [enozero](https://github.com/enozero)
  [#7151](https://github.com/fastlane/fastlane/pull/7151)
* Fix _screengrab_ to doesn’t exit if the app could not be uninstalled.  
  [gersonmendes](https://github.com/gersonmendes)
  [#7994](https://github.com/fastlane/fastlane/pull/7994)
* Update homebrew update messaging.  

## 2.11.0 Improvements and territories support in spaceship

* [sigh] Fix 'No such file or directory' error in sigh resign.  
  [mgrebenets](https://github.com/mgrebenets)
  [#7975](https://github.com/fastlane/fastlane/pull/7975)
* [sigh] Fix shell script quoting issue - follow up.  
  [mgrebenets](https://github.com/mgrebenets)
  [#7982](https://github.com/fastlane/fastlane/pull/7982)
* Add support for --quiet option for swiftlint action.  
  [mgrebenets](https://github.com/mgrebenets)
  [#7953](https://github.com/fastlane/fastlane/pull/7953)
* Make `exit_on_test_failure` have `is_string: false`.  
  [mfurtak](https://github.com/mfurtak)
  [#7981](https://github.com/fastlane/fastlane/pull/7981)
* [spaceship] Get and set territories.  
  [enozero](https://github.com/enozero)
  [#6601](https://github.com/fastlane/fastlane/pull/6601)
* ensure `xcode-install` gem is installed when using the action.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7972](https://github.com/fastlane/fastlane/pull/7972)
* Update match README template installation instructions.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7967](https://github.com/fastlane/fastlane/pull/7967)
* Removed potential warnings for duplicate module constants.  
* Support loading multiple dotenvs.  
  [lacostej](https://github.com/lacostej)
  [#7943](https://github.com/fastlane/fastlane/pull/7943)
* _produce_: fix `data_protection` in enabled features.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7955](https://github.com/fastlane/fastlane/pull/7955)
* Update bundler dependency to be more flexible.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7964](https://github.com/fastlane/fastlane/pull/7964)
* Fix the type of option `reinstall_app` in _screengrab_ tool.  
  [gersonmendes](https://github.com/gersonmendes)
  [#7980](https://github.com/fastlane/fastlane/pull/7980)

## 2.10.0 Improvements

* Add sensitive ConfigItem for `sonar_login` action.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7939](https://github.com/fastlane/fastlane/pull/7939)
* Reword the missing reference error to handle variables.  
  [lacostej](https://github.com/lacostej)
  [#7915](https://github.com/fastlane/fastlane/pull/7915)
* Load dotenv from either fastlane folder or parent, instead of fastlane folder or current.  
* Added support for providing utf flag to xcpretty via gym/xcodebuild.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7891](https://github.com/fastlane/fastlane/pull/7891)
* Make cert checker output look better.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7796](https://github.com/fastlane/fastlane/pull/7796)
* Mask all sensitive options by default when printing summary table.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7881](https://github.com/fastlane/fastlane/pull/7881)
* [cert, sigh] Add `platform` param support.  
  [kdubb](https://github.com/kdubb)
  [#7730](https://github.com/fastlane/fastlane/pull/7730)
* [scan] Add support for thread sanitizer.  
  [mgrebenets](https://github.com/mgrebenets)
  [#7946](https://github.com/fastlane/fastlane/pull/7946)
* [screengrab] Add `reinstall_app` option to uninstall the APKs before run tests for each locale configured.  
  [gersonmendes](https://github.com/gersonmendes)
  [#7923](https://github.com/fastlane/fastlane/pull/7923)
* [screengrab] Add support for custom `launch_arguments`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7911](https://github.com/fastlane/fastlane/pull/7911)
* [sigh] #7330 - Ignore blacklisted keys when using --use-app-entitlements option for sign resign.  
  [mgrebenets](https://github.com/mgrebenets)
  [#7916](https://github.com/fastlane/fastlane/pull/7916)
* [snapshot] Allow GeofencingIcon + LocationTracking Icon.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7940](https://github.com/fastlane/fastlane/pull/7940)
* [snapshot] Add `output_simulator_logs` option to export simulator device logs.  
  [lyndsey-ferguson](https://github.com/lyndsey-ferguson)
  [#7906](https://github.com/fastlane/fastlane/pull/7906)
* [spaceship] Add option `xcode` that stops the filtering of Xcode managed profiles.  
  [Ashton-W](https://github.com/Ashton-W)
  [#7886](https://github.com/fastlane/fastlane/pull/7886)

## 2.9.0 Improvements

* fix `hockey` action without `dsa_signature`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7875](https://github.com/fastlane/fastlane/pull/7875)
* `for_lane`, `for_platform` blocks in configurations.  
  [mfurtak](https://github.com/mfurtak)
  [#7859](https://github.com/fastlane/fastlane/pull/7859)
* Search for dotenvs in either fastlane's or current dir.  
  [lacostej](https://github.com/lacostej)
  [#7872](https://github.com/fastlane/fastlane/pull/7872)
* Add spinning fastlane wheel.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7477](https://github.com/fastlane/fastlane/pull/7477)
* Enable `--verbose` during `--capture_output`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7851](https://github.com/fastlane/fastlane/pull/7851)
* Deprecated actions will display deprecated notes in actions list, action info, while running, and in docs.  
  [joshdholtz](https://github.com/joshdholtz)
  [#7609](https://github.com/fastlane/fastlane/pull/7609)
* Reveal underlying error when decoding provisioning profile fails due to broken keychain environment.  
  [lacostej](https://github.com/lacostej)
  [#7558](https://github.com/fastlane/fastlane/pull/7558)
* Escape title of application for .plist and .plist url in `s3` action.  
  [simonvaucher](https://github.com/simonvaucher)
  [#7565](https://github.com/fastlane/fastlane/pull/7565)
* Print a message explaining how to quickly open links on macOS.  
  [0xced](https://github.com/0xced)
  [#7832](https://github.com/fastlane/fastlane/pull/7832)
* Add `xcodeproj` param to `set_build_number_repository` action.  
  [mfurtak](https://github.com/mfurtak)
  [#7860](https://github.com/fastlane/fastlane/pull/7860)
* Fix for multiple tasks in single command in `gradle` action.  
  [araratispiroglu](https://github.com/araratispiroglu)
  [#7845](https://github.com/fastlane/fastlane/pull/7845)
* mark `keychain_password` as sensitive in `setup_jenkins` action.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7880](https://github.com/fastlane/fastlane/pull/7880)
* Add json file validation to supply and deliver.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7878](https://github.com/fastlane/fastlane/pull/7878)
* [scan] Add support to copy simulator device logs to output directory.  
  [lyndsey-ferguson](https://github.com/lyndsey-ferguson)
  [#7804](https://github.com/fastlane/fastlane/pull/7804)
* [screengrab] AAR version bump.  
  [mfurtak](https://github.com/mfurtak)
  [#7840](https://github.com/fastlane/fastlane/pull/7840)
* [sigh] If the "force" option is specified, delete and recreate any matching profiles (even invalid ones).  
  [icecrystal23](https://github.com/icecrystal23)
  [#6518](https://github.com/fastlane/fastlane/pull/6518)

## 2.8.0 Improvements

* Prevent users on Android N from attempting to use internal storage.  
  [mfurtak](https://github.com/mfurtak)
  [#7838](https://github.com/fastlane/fastlane/pull/7838)
* produce - `enabled_features` feature.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7641](https://github.com/fastlane/fastlane/pull/7641)
* Make .env Dir.glob much less greedy.  
  [reidab](https://github.com/reidab)
  [#7810](https://github.com/fastlane/fastlane/pull/7810)
* Update screengrab aar version.  
  [asfalcone](https://github.com/asfalcone)
  [#7824](https://github.com/fastlane/fastlane/pull/7824)
* Revert "Scan Support for connected devices".  
  [mpirri](https://github.com/mpirri)
  [#7808](https://github.com/fastlane/fastlane/pull/7808)
* Scan Support for connected devices.  
  [matthewellis](https://github.com/matthewellis)
  [#5159](https://github.com/fastlane/fastlane/pull/5159)
* Consistent support for `DELIVER_USER` and `DELIVER_USERNAME` env variables.  
  [asfalcone](https://github.com/asfalcone)
  [#7806](https://github.com/fastlane/fastlane/pull/7806)
* Skip printing of empty lane context.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7799](https://github.com/fastlane/fastlane/pull/7799)
* add `register_device` to register a single ios device more easily.  
  [pvinis](https://github.com/pvinis)
  [#7800](https://github.com/fastlane/fastlane/pull/7800)
* Fix syntax error in code sample.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7792](https://github.com/fastlane/fastlane/pull/7792)
* Fix frameit for Mac screenshots.  
  [mfurtak](https://github.com/mfurtak)
  [#7790](https://github.com/fastlane/fastlane/pull/7790)

## 2.7.0 Improvements

* Fix `fastlane_core` method not available in _spaceship_.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7789](https://github.com/fastlane/fastlane/pull/7789)
* Fix gradle apk search path to make directory under project option..  
  [marcferna](https://github.com/marcferna)
  [#7786](https://github.com/fastlane/fastlane/pull/7786)
* Fix non-interactive shell `password_ask` loop in _match_.  
  [lacostej](https://github.com/lacostej)
  [#7561](https://github.com/fastlane/fastlane/pull/7561)
* Add `verbose` flag to `zip` action with a default value of 'true'.  
  [rbaumbach](https://github.com/rbaumbach)
  [#7777](https://github.com/fastlane/fastlane/pull/7777)
* Add `dsa_signature` to hockey action for mac apps.  
  [overtake](https://github.com/overtake)
  [#7753](https://github.com/fastlane/fastlane/pull/7753)
* `PkgUploadPackageBuilder` accepts platform parameter..  
  [hjanuschka](https://github.com/hjanuschka)
  [#7779](https://github.com/fastlane/fastlane/pull/7779)
* Update commands in commander to work with mono gem.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7701](https://github.com/fastlane/fastlane/pull/7701)

## 2.6.0 More stable spaceship, improved frameit, other improvements

* Make waiting for build processing more stable by retrying failed requests.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7762](https://github.com/fastlane/fastlane/pull/7762)
* Fix `FastlaneRequire#gem_installed?` to handle already-loaded libs.  
  [reidab](https://github.com/reidab)
  [#7771](https://github.com/fastlane/fastlane/pull/7771)
* [supply] Added support for google service account credentials via environment variable.  
  [VenkataMutyala](https://github.com/VenkataMutyala)
  [#7748](https://github.com/fastlane/fastlane/pull/7748)
* Update in-code documentation tool calls to use new fastlane syntax.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7751](https://github.com/fastlane/fastlane/pull/7751)
* Update screengrab tooling and dependency versions.  
  [mfurtak](https://github.com/mfurtak)
  [#7766](https://github.com/fastlane/fastlane/pull/7766)
* Update gemspec to require correct version of Play API.  
  [tmtrademarked](https://github.com/tmtrademarked)
  [#7763](https://github.com/fastlane/fastlane/pull/7763)
* Fix frameit 'easy mode' problem in landscape.  
  [mfurtak](https://github.com/mfurtak)
  [#7759](https://github.com/fastlane/fastlane/pull/7759)
* frameit: support resuming of interrupted downloads of frames.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7750](https://github.com/fastlane/fastlane/pull/7750)
* Store spaceship and frameit config in ~/.fastlane.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7743](https://github.com/fastlane/fastlane/pull/7743)
* Detect if session was set via env variable if session is invalid, and show appropriate error message.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7742](https://github.com/fastlane/fastlane/pull/7742)

## 2.5.0 2-factor improvements

* Improve support for 2-factor and 2-step verification a lot.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7738](https://github.com/fastlane/fastlane/pull/7738)
* Add support for application specific passwords using environment variables.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7738](https://github.com/fastlane/fastlane/pull/7738)
* Improved wording and documentation for 2-factor and 2-step.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7738](https://github.com/fastlane/fastlane/pull/7738)
* Update checker ensures valid RubyGems source for fastlane updates.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7734](https://github.com/fastlane/fastlane/pull/7734)
* Print fastlane path when running `fastlane -v`.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7733](https://github.com/fastlane/fastlane/pull/7733)
* Fix crash in _deliver_ when using the new `live` option.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7726](https://github.com/fastlane/fastlane/pull/7726)
* Fix USB device discovery to account for USB hubs.  
  [mfurtak](https://github.com/mfurtak)
  [#7727](https://github.com/fastlane/fastlane/pull/7727)
* Fix USB data parsing problem for DeviceManager.  
  [mfurtak](https://github.com/mfurtak)
  [#7725](https://github.com/fastlane/fastlane/pull/7725)
* Skip installing plugins when running `fastlane -v`.  
  [ohwutup](https://github.com/ohwutup)
  [#7722](https://github.com/fastlane/fastlane/pull/7722)
* Add support for uploading proguard mapping files.  
  [tmtrademarked](https://github.com/tmtrademarked)
  [#7721](https://github.com/fastlane/fastlane/pull/7721)

## 2.4.0 Fix for bundled fastlane

* **Important**: Temporarily breaks support for Ruby 2.4 due to `json` and `activesupport` dependency via `xcodeproj`, more information [here](https://github.com/fastlane/fastlane/pull/7719). For now, please downgrade to pre-2.4 to use the latest release of _fastlane_.  
* Add `exit_on_test_failure` option to allow copying screenshots after test failure.  
  [lalunamel](https://github.com/lalunamel)
  [#6606](https://github.com/fastlane/fastlane/pull/6606)
* Add `platform` option to `sigh`..  
  [fabiomassimo](https://github.com/fabiomassimo)
  [#6169](https://github.com/fastlane/fastlane/pull/6169)
* deliver: respect the '--platform' command-line setting.  
  [elliot-nelson](https://github.com/elliot-nelson)
  [#7648](https://github.com/fastlane/fastlane/pull/7648)
* Add sign option to `add_git_tag` action.  
  [Vratislav](https://github.com/Vratislav)
  [#7714](https://github.com/fastlane/fastlane/pull/7714)
* credentials-manager: Fetch port, path, protocol for new internet passwords.  
  [olegoid](https://github.com/olegoid)
  [#7628](https://github.com/fastlane/fastlane/pull/7628)
* Fix issue with launch arguments during copy of screenshots.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7670](https://github.com/fastlane/fastlane/pull/7670)
* Fixed snapshot reset simulators versions handling.  
  [bartoszj](https://github.com/bartoszj)
  [#7681](https://github.com/fastlane/fastlane/pull/7681)
* Add Android support to DeployGate action.  
  [tomorrowkey](https://github.com/tomorrowkey)
  [#6166](https://github.com/fastlane/fastlane/pull/6166)
* Add new param `disable_notify`  to deploygate-action.  
  [laiso](https://github.com/laiso)
  [#7698](https://github.com/fastlane/fastlane/pull/7698)
* Add `Spaceship::Portal::App#update_name`.  
  [cpunion](https://github.com/cpunion)
  [#7688](https://github.com/fastlane/fastlane/pull/7688)
* FileWritingScreenshotCallback: moved code that returns a file to write to to a separate method to allow extension & customization..  
  [yanchenko](https://github.com/yanchenko)
  [#6732](https://github.com/fastlane/fastlane/pull/6732)

## 2.3.1 Ruby 2.4 and more

* Add support for Ruby 2.4.  
* Improve error message when Xcode isn't installed.  
* Fix an optional property in _deliver_.  
* Improve documentation.  
* Add prefix index with zeroes for JUnit reports.  

## 2.3.0 Improvements

* Removed redundant check in `reset_git_repo`, fixes #7650.  
  [schung7](https://github.com/schung7)
  [#7649](https://github.com/fastlane/fastlane/pull/7649)
* Allow `commit_version_bump` to find the Settings.bundle in the project.  
  [jdee](https://github.com/jdee)
  [#6997](https://github.com/fastlane/fastlane/pull/6997)
* Updates credential manager docs for execution with monogem.  
  [joshdholtz](https://github.com/joshdholtz)
  [#7640](https://github.com/fastlane/fastlane/pull/7640)
* Fix broken docs links in ToolsAndDebugging.md.  
  [milch](https://github.com/milch)
  [#7637](https://github.com/fastlane/fastlane/pull/7637)
* Updated test path for post-monogem times.  
  [milch](https://github.com/milch)
  [#7638](https://github.com/fastlane/fastlane/pull/7638)
* [docs] Update Jenkins integration link to link to new docs page.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7566](https://github.com/fastlane/fastlane/pull/7566)
* Update Jenkins integration link in fastlane sub-dir.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7567](https://github.com/fastlane/fastlane/pull/7567)
* [docs] Improve docs around how to test code.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7553](https://github.com/fastlane/fastlane/pull/7553)
* [snapshot] Add xcargs option to pass additional parameters to xcodebuild, fixes #7255.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7261](https://github.com/fastlane/fastlane/pull/7261)
* [docs] More diagnostics & docs on the DEBUG env during testing.  
  [lacostej](https://github.com/lacostej)
  [#7560](https://github.com/fastlane/fastlane/pull/7560)
* [README] spaceauth - adopt to monogem changes.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7615](https://github.com/fastlane/fastlane/pull/7615)
* [deliver] support metdata update of `live_version`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7172](https://github.com/fastlane/fastlane/pull/7172)
* Remove imagemagick check, fixes #6904.  
  [hjanuschka](https://github.com/hjanuschka)
  [#6905](https://github.com/fastlane/fastlane/pull/6905)
* Jenkins doc improvements.  
  [lacostej](https://github.com/lacostej)
  [#7608](https://github.com/fastlane/fastlane/pull/7608)
* Use Dir.mktmpdir internal cleanup mechanism to remove tmp folder.  
  [lacostej](https://github.com/lacostej)
  [#7635](https://github.com/fastlane/fastlane/pull/7635)
* Update `CORE_CONTRIBUTOR.md`.  
  [lacostej](https://github.com/lacostej)
  [#7634](https://github.com/fastlane/fastlane/pull/7634)
* Preventing actions called from another action to show in summary.  
  [marcelofabri](https://github.com/marcelofabri)
  [#6322](https://github.com/fastlane/fastlane/pull/6322)

## 2.2.0 Add mailgun options, more iPad options for snapshot, bugfixes & more...

* [gym] Revert library support, fixes #7630.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7631](https://github.com/fastlane/fastlane/pull/7631)
* [spaceship] Fix path to referenced fastfile.  
  [ohwutup](https://github.com/ohwutup)
  [#7604](https://github.com/fastlane/fastlane/pull/7604)
* [fastlane action] Support mailgun `reply_to`.  
  [ohwutup](https://github.com/ohwutup)
  [#7605](https://github.com/fastlane/fastlane/pull/7605)
* [fastlane] Anonymize sensitive options for `captured_output`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7335](https://github.com/fastlane/fastlane/pull/7335)
* [snapshot] Add additional ipad classifiers..  
  [hjanuschka](https://github.com/hjanuschka)
  [#7570](https://github.com/fastlane/fastlane/pull/7570)

## 2.1.3 Two-factor auth fix and other improvements

* spaceship: API fixes for Apple's two-factor auth.  
* spaceship: limit which cookies are stored to avoid bad datatypes.  
* Hockey action: add option to bypass CDN.  

## 2.1.2 Fix gym builds

* Fix gym build failure.  
* Fixed parallel upload locked due to temp file in `ipa_file_analyser`.  
  [philipp-heyse](https://github.com/philipp-heyse)
  [#7359](https://github.com/fastlane/fastlane/pull/7359)
* Refactor `IpaFileAnalyser`.  
  [milch](https://github.com/milch)
  [#7587](https://github.com/fastlane/fastlane/pull/7587)

## 2.1.1 Hotfix

Dependencies fix for bundler

## 2.1.0 Avoid showing Snapfile twice, fix not showing lanes, improvements & more

* Update README.md.  
  [mdarnall](https://github.com/mdarnall)
  [#7385](https://github.com/fastlane/fastlane/pull/7385)
* Fix not showing the lane list and selection when not passing any arguments.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7549](https://github.com/fastlane/fastlane/pull/7549)
* Add "--fail-on-errors" support to Danger action.  
  [nikolaykasyanov](https://github.com/nikolaykasyanov)
  [#7487](https://github.com/fastlane/fastlane/pull/7487)
* Updated docs description for pilot/testflight action.  
  [RishabhTayal](https://github.com/RishabhTayal)
  [#7550](https://github.com/fastlane/fastlane/pull/7550)
* fix platform.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7360](https://github.com/fastlane/fastlane/pull/7360)
* [gym] Remove promotion for `use_legacy_build_api`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7379](https://github.com/fastlane/fastlane/pull/7379)
* `user_error` if plist error.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7547](https://github.com/fastlane/fastlane/pull/7547)
* more tests for aliases.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7546](https://github.com/fastlane/fastlane/pull/7546)

## 2.0.5 Improvements and bugfixes

* Improved support for app icons in _deliver_.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7398](https://github.com/fastlane/fastlane/pull/7398)
* Update auto-install and messaging when gem is missing while using bundler.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7527](https://github.com/fastlane/fastlane/pull/7527)
* Support for Android for testfairy.  
* Add missing require statement.  
* Fix crash when resetting iOS simulators.  

## 2.0.4 Hotfix

* Fix _gym_ not properly building iOS applications.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7526](https://github.com/fastlane/fastlane/pull/7526)
* Loosen up rubyzip dependency.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7525](https://github.com/fastlane/fastlane/pull/7525)

## 2.0.3 Hotfix

* Add fastlane/version imports, fixes #7518.  
  [milch](https://github.com/milch)
  [#7520](https://github.com/fastlane/fastlane/pull/7520)
* Show git command on verbose mode when deploying fastlane.  
  [KrauseFx](https://github.com/KrauseFx)
  [#7516](https://github.com/fastlane/fastlane/pull/7516)

## 2.0.2 Hotfix

Hotfix

## fastlane 2.0

From now on, all of _fastlane_ is inside the _fastlane_ gem :tada: This enables us and all contributors to be a lot faster and more efficient in the future :rocket:

#### What changes for you? :warning:
* If you run some tools directly without _fastlane_, please run `fastlane [tool]` instead of `[tool]` (e.g. `fastlane gym ...`). If you don't prefix your commands, the old version of the tool will be used. Using the tool's name directly is now deprecated.  
* If you have a `Gemfile`, update it to just include `gem "fastlane"`, and not any of the other tools any more.  
* As a plugin maintainer, make sure to remove dependencies to _spaceship_ and _fastlane_core_ (I submitted PRs to all public plugins for that this was the case).  

#### Why a mono gem? :white_check_mark:
* It makes releases much simpler, just one gem to ship.  
* No more internal dependency updates.  
* No more version conflicts if we add some methods to some sub-gems.  
* 1 PR could modify multiple tools and tests are still passing (does not mean we have to, but we can for example to update _spaceship_ and _deliver_ at the same time if necessary).  
* Easier to test changes locally.  

## 1.111.0 Improvements

* Update internal dependencies.  
  [asfalcone](https://github.com/asfalcone)
  [#7208](https://github.com/fastlane/fastlane/pull/7208)
* Update message when `sonar-runner` isn't installed.  
  [Palleas](https://github.com/Palleas)
  [#7214](https://github.com/fastlane/fastlane/pull/7214)
* Fix call `set_info_plist_value` resulting in binary plist file.  
  [sainttail](https://github.com/sainttail)
  [#7188](https://github.com/fastlane/fastlane/pull/7188)
* Refactor `ensure_xcode_version` to do more work in Ruby.  
  [mfurtak](https://github.com/mfurtak)
  [#7205](https://github.com/fastlane/fastlane/pull/7205)
* Improve unexpected output in `ensure_xcode_version` action.  
  [danielbowden](https://github.com/danielbowden)
  [#7171](https://github.com/fastlane/fastlane/pull/7171)
* Use HTTPS for root certificate in `update_project_provisioning` action.  
  [noahsark769](https://github.com/noahsark769)
  [#6970](https://github.com/fastlane/fastlane/pull/6970)
* Add `reporter` option to `swiftlint` action.  
  [guidomb](https://github.com/guidomb)
  [#7126](https://github.com/fastlane/fastlane/pull/7126)
* Fix `unlock_keychain` action on macOS Sierra.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7077](https://github.com/fastlane/fastlane/pull/7077)
* Add `verbose` option to `pod_push` action.  
  [ungacy](https://github.com/ungacy)
  [#7078](https://github.com/fastlane/fastlane/pull/7078)
* Ensure `live` option of `latest_testflight_build_number` is a boolean.  
  [hjanuschka](https://github.com/hjanuschka)
  [#7082](https://github.com/fastlane/fastlane/pull/7082)
* Anonymize paths in `fastlane env` output.  
  [0xced](https://github.com/0xced)
  [#7037](https://github.com/fastlane/fastlane/pull/7037)

## 1.110.0 Improvements

* Deprecate `SIGH_UDID` in favor of corrected `SIGH_UUID`.  
* Remove .positive? to support ruby < 2.3.  
* Clarify version number error messaging when Xcode project is not set up correctly.  
* Ignore CocoaPods paths.  
* Update `fastlane_version` action to show new update message.  
* Set `fail_build` to expect a string.  
* Add bitrise.io `git_branch` ENV variable check.  
* Add option to provide -framework option for archive Carthage command.  
* Update dependency to latest `fastlane_core` to fix app-specific password prompting.  
* Unit tests run on Sierra.  

## 1.109.0 Improvements

* Update all tools to latest `fastlane_core`.  
  [asfalcone](https://github.com/asfalcone)
  [#7026](https://github.com/fastlane/fastlane/pull/7026)
* Pass generated Fastfile ID through to enhancer.  
  [mfurtak](https://github.com/mfurtak)
  [#7022](https://github.com/fastlane/fastlane/pull/7022)
* Add `troubleshoot` option.  
  [hjanuschka](https://github.com/hjanuschka)
  [#6889](https://github.com/fastlane/fastlane/pull/6889)
* Improvements to 'fastlane env' (#6871, #6955, #6950).  

## 1.108.0 New `update_fastlane` command, `fastlane_require` to auto-install gems & more

* Implement `fastlane_require` to automatically install gems into bundle.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6858](https://github.com/fastlane/fastlane/pull/6858)
* Add new `fastlane update_fastlane` action.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6896](https://github.com/fastlane/fastlane/pull/6896)
* Support keychains in custom paths and fix non-existing default keychain crash 🔐.  
  [hjanuschka](https://github.com/hjanuschka)
  [#6887](https://github.com/fastlane/fastlane/pull/6887)
* Hide options with no description in docs.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6919](https://github.com/fastlane/fastlane/pull/6919)
* Fix `commit_version_bump` could not find a `.xcodeproj`.  
  [WANGjieJacques](https://github.com/WANGjieJacques)
  [#6676](https://github.com/fastlane/fastlane/pull/6676)

## 1.107.0 New actions, enhanced debugging features & more

* Add error message on `fastlane init` when fastlane directory or file already exists.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6849](https://github.com/fastlane/fastlane/pull/6849)
* Update error message when using `fastlane_version` with bundle.  
  [juli1quere](https://github.com/juli1quere)
  [#6831](https://github.com/fastlane/fastlane/pull/6831)
* Automatically use `GITHUB_API_TOKEN` for create pull request action.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6841](https://github.com/fastlane/fastlane/pull/6841)
* Add `app_store_build_number action`.  
  [hjanuschka](https://github.com/hjanuschka)
  [#6790](https://github.com/fastlane/fastlane/pull/6790)
* Honor system proxy settings when downloading crashlytics.jar.  
  [timothy-volvo](https://github.com/timothy-volvo)
  [#6817](https://github.com/fastlane/fastlane/pull/6817)
* enhance env printing + add  `--capture_output`  option.  
* Move Actions.md to docs.fastlane.tools.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6809](https://github.com/fastlane/fastlane/pull/6809)
* Improve `fastlane init` already exists error message.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6798](https://github.com/fastlane/fastlane/pull/6798)
* Fix slack action error when passing a custom payload option.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6792](https://github.com/fastlane/fastlane/pull/6792)
* Don’t ask for clipboard on non-interactive shell.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6782](https://github.com/fastlane/fastlane/pull/6782)
* Update dependencies.  

## 1.106.2 Updated dependencies

Update internal dependencies to support new iTunes Connect team selection (#6724)

## 1.106.1 Update frameit dependency

* Losen up _frameit_ dependency.  
* Add `env` to `black_list` for valid lane names.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6693](https://github.com/fastlane/fastlane/pull/6693)
* Markdown docs generator: only print on verbose.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6694](https://github.com/fastlane/fastlane/pull/6694)

## 1.106.0 New `fastlane env` command

* New `fastlane env` command to print out the fastlane environment.  
* Docs: describe using next to stop executing a lane.  
  [mfurtak](https://github.com/mfurtak)
  [#6674](https://github.com/fastlane/fastlane/pull/6674)
* Update dependencies.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6682](https://github.com/fastlane/fastlane/pull/6682)
* Remove old crash reporter code from fastlane.  
  [KrauseFx](https://github.com/KrauseFx)
  [#6623](https://github.com/fastlane/fastlane/pull/6623)
