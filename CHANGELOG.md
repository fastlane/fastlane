# Fastlane CHANGELOG

## 2.13.0 User management and update pem for new Dev Portal

* Add user management to spaceship (#7993)
* Update _pem_ to work with the new Apple Developer Portal (#8049)
* Fix git_branch task for Jenkins Pipeline jobs as they set BRANCH_NAME instead of GIT_BRANCH (#8024)

## 2.12.0 Apple ID user role handling, improve spaceship stability and more

* Show appropriate spaceship error message when having insufficient permissions (#8014)
* Add support for new and existing groups for iTC testers in spaceship (#8005)
* Automatically retry failed requests on an internal server error for iTunesConnect (#8017 and #8006)
* Fix `spaceauth` YAML spaceship cookie loading (#8012)
* Simplify spaceship requests for account user information (#8013)
* Improve error output when pilot can’t register new testers (#8008)
* Improve scan error message for bad `SLACK_URL` (#8004)
* Add `skip_testing`, `only_testing` options to scan (#8002)
* Improve docs and code samples (#7986, #7985)
* snapshot support for iPhone SE (#7995)
* Fastlane require format non plugins with dash (#7998)
* Add Automatic Release Date for Tunes Submission in _spaceship_ (#7151)
* Fix _screengrab_ to doesn’t exit if the app could not be uninstalled (#7994)
* Update homebrew update messaging

## 2.11.0 Improvements and territories support in spaceship

* [sigh] Fix 'No such file or directory' error in sigh resign (#7975)
* [sigh] Fix shell script quoting issue - follow up (#7982)
* Add support for --quiet option for swiftlint action (#7953)
* Make exit_on_test_failure have `is_string: false` (#7981)
* [spaceship] Get and set territories (#6601)
* ensure `xcode-install` gem is installed when using the action (#7972)
* Update match README template installation instructions (#7967)
* Removed potential warnings for duplicate module constants
* Support loading multiple dotenvs (#7943)
* _produce_: fix data_protection in enabled features (#7955)
* Update bundler dependency to be more flexible (#7964)
* Fix the type of option reinstall_app in _screengrab_ tool (#7980)

## 2.10.0 Improvements

* Add sensitive ConfigItem for `sonar_login` action (#7939)
* Reword the missing reference error to handle variables (#7915)
* Load dotenv from either fastlane folder or parent, instead of fastlane folder or current.
* Added support for providing utf flag to xcpretty via gym/xcodebuild (#7891)
* Make cert checker output look better (#7796)
* Mask all sensitive options by default when printing summary table (#7881)
* [cert, sigh] Add `platform` param support (#7730)
* [scan] Add support for thread sanitizer (#7946)
* [screengrab] Add `reinstall_app` option to uninstall the APKs before run tests for each locale configured (#7923)
* [screengrab] Add support for custom `launch_arguments` (#7911)
* [sigh] #7330 - Ignore blacklisted keys when using --use-app-entitlements option for sign resign (#7916)
* [snapshot] Allow GeofencingIcon + LocationTracking Icon (#7940)
* [snapshot] Add `output_simulator_logs` option to export simulator device logs (#7906)
* [spaceship] Add option `xcode` that stops the filtering of Xcode managed profiles (#7886)

## 2.9.0 Improvements

- fix `hockey` action without `dsa_signature` (#7875)
- for_lane, for_platform blocks in configurations (#7859)
- Search for dotenvs in either fastlane's or current dir (#7872)
- Add spinning fastlane wheel (#7477)
- Enable --verbose during --capture_output (#7851)
- Deprecated actions will display deprecated notes in actions list, action info, while running, and in docs (#7609)
- Reveal underlying error when decoding provisioning profile fails due to broken keychain environment (#7558)
- Escape title of application for .plist and .plist url in `s3` action (#7565)
- Print a message explaining how to quickly open links on macOS (#7832)
- Add `xcodeproj` param to `set_build_number_repository` action (#7860)
- Fix for multiple tasks in single command in `gradle` action (#7845)
- mark `keychain_password` as sensitive in `setup_jenkins` action (#7880)
- Add json file validation to supply and deliver (#7878)
- [scan] Add support to copy simulator device logs to output directory (#7804)
- [screengrab] AAR version bump (#7840)
- [sigh] If the "force" option is specified, delete and recreate any matching profiles (even invalid ones) (#6518)

## 2.8.0 Improvements

- Prevent users on Android N from attempting to use internal storage (#7838)
- produce - enabled_features feature (#7641)
- Make .env Dir.glob much less greedy (#7810)
- Update screengrab aar version (#7824)
- Revert "Scan Support for connected devices" (#7808)
- Scan Support for connected devices (#5159)
- Consistent support for DELIVER_USER and DELIVER_USERNAME env variables (#7806)
- Skip printing of empty lane context (#7799)
- add register_device to register a single ios device more easily (#7800)
- Fix syntax error in code sample (#7792)
- Fix frameit for Mac screenshots (#7790)

## 2.7.0 Improvements

- Fix `fastlane_core` method not available in _spaceship_ (#7789)
- Fix gradle apk search path to make directory under project option. (#7786)
- Fix non-interactive shell password_ask loop in match (#7561)
- Add `verbose` flag to `zip` action with a default value of 'true' (#7777)
- Add `dsa_signature` to hockey action for mac apps (#7753)
- `PkgUploadPackageBuilder` accepts platform parameter. (#7779)
- Update commands in commander to work with mono gem (#7701)

## 2.6.0 More stable spaceship, improved frameit, other improvements

- Make waiting for build processing more stable by retrying failed requests (#7762)
- Fix FastlaneRequire#gem_installed? to handle already-loaded libs (#7771)
- [supply] Added support for google service account credentials via environment variable (#7748)
- Update in-code documentation tool calls to use new fastlane syntax (#7751)
- Update screengrab tooling and dependency versions (#7766)
- Update gemspec to require correct version of Play API (#7763)
- Fix frameit 'easy mode' problem in landscape (#7759)
- frameit: support resuming of interrupted downloads of frames (#7750)
- Store spaceship and frameit config in ~/.fastlane (#7743)
- Detect if session was set via env variable if session is invalid, and show appropriate error message (#7742)

## 2.5.0 2-factor improvements

- Improve support for 2-factor and 2-step verification a lot (#7738)
- Add support for application specific passwords using environment variables (#7738)
- Improved wording and documentation for 2-factor and 2-step (#7738)
- Update checker ensures valid RubyGems source for fastlane updates (#7734)
- Print fastlane path when running `fastlane -v` (#7733)
- Fix crash in _deliver_ when using the new `live` option (#7726)
- Fix USB device discovery to account for USB hubs (#7727)
- Fix USB data parsing problem for DeviceManager (#7725)
- Skip installing plugins when running `fastlane -v` (#7722)
- Add support for uploading proguard mapping files (#7721)

## 2.4.0 Fix for bundled fastlane

- **Important**: Temporarily breaks support for Ruby 2.4 due to `json` and `activesupport` dependency via `xcodeproj`, more information [here](https://github.com/fastlane/fastlane/pull/7719). For now, please downgrade to pre-2.4 to use the latest release of _fastlane_
- Add `exit_on_test_failure` option to allow copying screenshots after test failure (#6606)
- Add `platform` option to `sigh`. (#6169)
- deliver: respect the '--platform' command-line setting (#7648)
- Add sign option to add_git_tag action (#7714)
- credentials-manager: Fetch port, path, protocol for new internet passwords (#7628)
- Fix issue with launch arguments during copy of screenshots (#7670)
- Fixed snapshot reset simulators versions handling. (#7681)
- Add Android support to DeployGate action (#6166)
- Add new param 'disable_notify'  to deploygate-action (#7698)
- Add Spaceship::Portal::App#update_name (#7688)
- FileWritingScreenshotCallback: moved code that returns a file to write to to a separate method to allow extension & customization. (#6732)

## 2.3.1 Ruby 2.4 and more

- Add support for Ruby 2.4
- Improve error message when Xcode isn't installed
- Fix an optional property in _deliver_
- Improve documentation
- Add prefix index with zeroes for JUnit reports

## 2.3.0 Improvements

- Removed redundant check in reset_git_repo, fixes #7650 (#7649)
- Allow commit_version_bump to find the Settings.bundle in the project (#6997)
- Updates credential manager docs for execution with monogem (#7640)
- Fix broken docs links in ToolsAndDebugging.md (#7637)
- Updated test path for post-monogem times (#7638)
- [docs] Update Jenkins integration link to link to new docs page (#7566)
- Update Jenkins integration link in fastlane sub-dir (#7567)
- [docs] Improve docs around how to test code (#7553)
- [snapshot] Add xcargs option to pass additional parameters to xcodebuild, fixes #7255 (#7261)
- [docs] More diagnostics & docs on the DEBUG env during testing (#7560)
- [README] spaceauth - adopt to monogem changes (#7615)
- [deliver] support metdata update of live_version (#7172)
- Remove imagemagick check, fixes #6904 (#6905)
- Jenkins doc improvements (#7608)
- Use Dir.mktmpdir internal cleanup mechanism to remove tmp folder (#7635)
- Update CORE_CONTRIBUTOR.md (#7634)
- Preventing actions called from another action to show in summary (#6322)

## 2.2.0 Add mailgun options, more iPad options for snapshot, bugfixes & more...

- [gym] Revert library support, fixes #7630 (#7631)
- [spaceship] Fix path to referenced fastfile (#7604)
- [fastlane action] Support mailgun reply_to (#7605)
- [fastlane] Anonymize sensitive options for captured_output (#7335)
- [snapshot] Add additional ipad classifiers. (#7570)

## 2.1.3 Two-factor auth fix and other improvements

- spaceship: API fixes for Apple's two-factor auth
- spaceship: limit which cookies are stored to avoid bad datatypes
- Hockey action: add option to bypass CDN

## 2.1.2 Fix gym builds

- Fix gym build failure
- Fixed parallel upload locked due to temp file in ipa_file_analyser (#7359)
- Refactor `IpaFileAnalyser` (#7587)

## 2.1.1 Hotfix

Dependencies fix for bundler

## 2.1.0 Avoid showing Snapfile twice, fix not showing lanes, improvements & more

- Update README.md (#7385)
- Fix not showing the lane list and selection when not passing any arguments (#7549)
- Add "--fail-on-errors" support to Danger action (#7487)
- Updated docs description for pilot/testflight action (#7550)
- fix platform (#7360)
- [gym] Remove promotion for use_legacy_build_api (#7379)
- user_error if plist error (#7547)
- more tests for aliases (#7546)

## 2.0.5 Improvements and bugfixes

- Improved support for app icons in _deliver_ (#7398)
- Update auto-install and messaging when gem is missing while using bundler (#7527)
- Support for Android for testfairy
- Add missing require statement
- Fix crash when resetting iOS simulators

## 2.0.4 Hotfix

- Fix _gym_ not properly building iOS applications (#7526)
- Loosen up rubyzip dependency (#7525)

## 2.0.3 Hotfix

- Add fastlane/version imports, fixes #7518 (#7520)
- Show git command on verbose mode when deploying fastlane (#7516)

## 2.0.2 Hotfix

Hotfix

## fastlane 2.0

From now on, all of _fastlane_ is inside the _fastlane_ gem :tada: This enables us and all contributors to be a lot faster and more efficient in the future :rocket:

#### What changes for you? :warning:
- If you run some tools directly without _fastlane_, please run `fastlane [tool]` instead of `[tool]` (e.g. `fastlane gym ...`). If you don't prefix your commands, the old version of the tool will be used. Using the tool's name directly is now deprecated.
- If you have a `Gemfile`, update it to just include `gem "fastlane"`, and not any of the other tools any more
- As a plugin maintainer, make sure to remove dependencies to _spaceship_ and _fastlane_core_ (I submitted PRs to all public plugins for that this was the case)

#### Why a mono gem? :white_check_mark:
- It makes releases much simpler, just one gem to ship
- No more internal dependency updates
- No more version conflicts if we add some methods to some sub-gems
- 1 PR could modify multiple tools and tests are still passing (does not mean we have to, but we can for example to update _spaceship_ and _deliver_ at the same time if necessary)
- Easier to test changes locally

## 1.111.0 Improvements

- Update internal dependencies (#7208)
- Update message when `sonar-runner` isn't installed (#7214)
- Fix call `set_info_plist_value` resulting in binary plist file (#7188)
- Refactor `ensure_xcode_version` to do more work in Ruby (#7205)
- Improve unexpected output in `ensure_xcode_version` action (#7171)
- Use HTTPS for root certificate in `update_project_provisioning` action (#6970)
- Add `reporter` option to `swiftlint` action (#7126)
- Fix `unlock_keychain` action on macOS Sierra (#7077)
- Add `verbose` option to `pod_push` action (#7078)
- Ensure `live` option of `latest_testflight_build_number` is a boolean (#7082)
- Anonymize paths in `fastlane env` output (#7037)

## 1.110.0 Improvements

- Deprecate SIGH_UDID in favor of corrected SIGH_UUID
- Remove .positive? to support ruby < 2.3
- Clarify version number error messaging when Xcode project is not set up correctly
- Ignore CocoaPods paths
- Update `fastlane_version` action to show new update message
- Set fail_build to expect a string
- Add bitrise.io git_branch ENV variable check
- Add option to provide -framework option for archive Carthage command
- Update dependency to latest `fastlane_core` to fix app-specific password prompting
- Unit tests run on Sierra

## 1.109.0 Improvements

- Update all tools to latest fastlane_core (#7026)
- Pass generated Fastfile ID through to enhancer (#7022)
- Add `troubleshoot` option (#6889)
- Improvements to 'fastlane env' (#6871, #6955, #6950)

## 1.108.0 New update_fastlane command, fastlane_require to auto-install gems & more

- Implement `fastlane_require` to automatically install gems into bundle (#6858)
- Add new `fastlane update_fastlane` action (#6896)
- Support keychains in custom paths and fix non-existing default keychain crash 🔐 (#6887)
- Hide options with no description in docs (#6919)
- Fix commit_version_bump could not find a .xcodeproj (#6676)

## 1.107.0 New actions, enhanced debugging features & more

- Add error message on `fastlane init` when fastlane directory or file already exists (#6849)
- Update error message when using fastlane_version with bundle (#6831)
- Automatically use GITHUB_API_TOKEN for create pull request action (#6841)
- Add app_store_build_number action (#6790)
- Honor system proxy settings when downloading crashlytics.jar (#6817)
- enhance env printing + add  `--capture_output`  option
- Move Actions.md to docs.fastlane.tools (#6809)
- Improve `fastlane init` already exists error message (#6798)
- Fix slack action error when passing a custom payload option (#6792)
- Don’t ask for clipboard on non-interactive shell (#6782)
- Update dependencies

## 1.106.2 Updated dependencies

Update internal dependencies to support new iTunes Connect team selection (#6724)

## 1.106.1 Update frameit dependency

- Losen up _frameit_ dependency
- Add `env` to black_list for valid lane names (#6693)
- Markdown docs generator: only print on verbose (#6694)

## 1.106.0 New `fastlane env` command

- New `fastlane env` command to print out the fastlane environment
- Docs: describe using next to stop executing a lane (#6674)
- Update dependencies (#6682)
- Remove old crash reporter code from fastlane (#6623)
