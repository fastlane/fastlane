# Change Log

## [Unreleased](https://github.com/KrauseFx/fastlane/tree/HEAD)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.2.1...HEAD)

**Closed issues:**

- build number version [\#131](https://github.com/KrauseFx/fastlane/issues/131)

- \[Feature\] xcodebuild action build settings [\#130](https://github.com/KrauseFx/fastlane/issues/130)

- \[Feature\] Specify minimum version number in Fastfile [\#120](https://github.com/KrauseFx/fastlane/issues/120)

- xcodebuild WORKSPACE environment var conflicts with Jenkins WORKSPACE env var [\#119](https://github.com/KrauseFx/fastlane/issues/119)

- Document that xctool can also be used to archive as an alternative to 'ipa' \(Shenzhen\) [\#115](https://github.com/KrauseFx/fastlane/issues/115)

- Allow Shenzhen Crashlytics ENV vars [\#101](https://github.com/KrauseFx/fastlane/issues/101)

- Increment Build Number Git [\#35](https://github.com/KrauseFx/fastlane/issues/35)

**Merged pull requests:**

- Added build settings to xcodebuild command [\#132](https://github.com/KrauseFx/fastlane/pull/132) ([joshdholtz](https://github.com/joshdholtz))

- Crashlytics action can take groups param as Array or String [\#129](https://github.com/KrauseFx/fastlane/pull/129) ([lmirosevic](https://github.com/lmirosevic))

- Adds more options to the `slack` command [\#128](https://github.com/KrauseFx/fastlane/pull/128) ([lmirosevic](https://github.com/lmirosevic))

- Fix name collision with ActiveSupport [\#125](https://github.com/KrauseFx/fastlane/pull/125) ([milch](https://github.com/milch))

- Xcodebuild reports [\#124](https://github.com/KrauseFx/fastlane/pull/124) ([dtrenz](https://github.com/dtrenz))

- \[Resolves \#101\] Pass-thru Shenzhen Crashlytics ENV vars [\#122](https://github.com/KrauseFx/fastlane/pull/122) ([dtrenz](https://github.com/dtrenz))

- \[Resolves \#119\] Namespacing xcodebuild ENV vars [\#121](https://github.com/KrauseFx/fastlane/pull/121) ([dtrenz](https://github.com/dtrenz))

## [0.2.1](https://github.com/KrauseFx/fastlane/tree/0.2.1) (2015-03-10)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.2.0...0.2.1)

**Closed issues:**

- \[Feature\] xcpretty integration [\#102](https://github.com/KrauseFx/fastlane/issues/102)

**Merged pull requests:**

- Relaxed dependency on xcodeproj [\#117](https://github.com/KrauseFx/fastlane/pull/117) ([lmirosevic](https://github.com/lmirosevic))

- Xcodebuild action documentation [\#114](https://github.com/KrauseFx/fastlane/pull/114) ([dtrenz](https://github.com/dtrenz))

- Added missing important alias: xcexport [\#113](https://github.com/KrauseFx/fastlane/pull/113) ([dtrenz](https://github.com/dtrenz))

## [0.2.0](https://github.com/KrauseFx/fastlane/tree/0.2.0) (2015-03-09)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.19...0.2.0)

**Closed issues:**

- fastlane crashes with gem conflcit [\#109](https://github.com/KrauseFx/fastlane/issues/109)

**Merged pull requests:**

- Docu fix [\#112](https://github.com/KrauseFx/fastlane/pull/112) ([lmirosevic](https://github.com/lmirosevic))

- Push to git remote [\#111](https://github.com/KrauseFx/fastlane/pull/111) ([lmirosevic](https://github.com/lmirosevic))

- Add notify action that uses OS X notification center [\#110](https://github.com/KrauseFx/fastlane/pull/110) ([champo](https://github.com/champo))

- xcodebuild action [\#104](https://github.com/KrauseFx/fastlane/pull/104) ([dtrenz](https://github.com/dtrenz))

## [0.1.19](https://github.com/KrauseFx/fastlane/tree/0.1.19) (2015-03-09)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.18...0.1.19)

**Merged pull requests:**

- Updated README [\#100](https://github.com/KrauseFx/fastlane/pull/100) ([lmirosevic](https://github.com/lmirosevic))

## [0.1.18](https://github.com/KrauseFx/fastlane/tree/0.1.18) (2015-03-09)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.17...0.1.18)

**Closed issues:**

- Issues with password [\#39](https://github.com/KrauseFx/fastlane/issues/39)

- Reference XCode variable in actions [\#27](https://github.com/KrauseFx/fastlane/issues/27)

**Merged pull requests:**

- add note\_path option to typetalk action for appending message like a change log [\#108](https://github.com/KrauseFx/fastlane/pull/108) ([dataich](https://github.com/dataich))

## [0.1.17](https://github.com/KrauseFx/fastlane/tree/0.1.17) (2015-03-08)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.16...0.1.17)

**Closed issues:**

- fastlane xctool call with system\(\) [\#105](https://github.com/KrauseFx/fastlane/issues/105)

- Unable to activate sigh-0.4.1 [\#103](https://github.com/KrauseFx/fastlane/issues/103)

- Fastlane init: password starting with a dash is interpreted as a command option [\#9](https://github.com/KrauseFx/fastlane/issues/9)

**Merged pull requests:**

- Added `commit\_version\_bump` action [\#99](https://github.com/KrauseFx/fastlane/pull/99) ([lmirosevic](https://github.com/lmirosevic))

## [0.1.16](https://github.com/KrauseFx/fastlane/tree/0.1.16) (2015-03-06)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.15...0.1.16)

**Closed issues:**

- Can't find release 0.1.15 from Rubygems [\#93](https://github.com/KrauseFx/fastlane/issues/93)

- Support the resign command of Sigh [\#58](https://github.com/KrauseFx/fastlane/issues/58)

**Merged pull requests:**

- Add `add\_git\_tag` action [\#98](https://github.com/KrauseFx/fastlane/pull/98) ([lmirosevic](https://github.com/lmirosevic))

- Added `reset\_git\_repo` action [\#97](https://github.com/KrauseFx/fastlane/pull/97) ([lmirosevic](https://github.com/lmirosevic))

- Adds `ensure\_git\_status\_clean` action [\#96](https://github.com/KrauseFx/fastlane/pull/96) ([lmirosevic](https://github.com/lmirosevic))

- Adds `clean\_build\_artifacts` action [\#95](https://github.com/KrauseFx/fastlane/pull/95) ([lmirosevic](https://github.com/lmirosevic))

- Adds `resign` action [\#94](https://github.com/KrauseFx/fastlane/pull/94) ([lmirosevic](https://github.com/lmirosevic))

- Added support for setting Crashlytics' notifications option [\#86](https://github.com/KrauseFx/fastlane/pull/86) ([lmirosevic](https://github.com/lmirosevic))

- Using new sigh that extends fastlane\_core classes [\#92](https://github.com/KrauseFx/fastlane/pull/92) ([joshdholtz](https://github.com/joshdholtz))

## [0.1.15](https://github.com/KrauseFx/fastlane/tree/0.1.15) (2015-03-04)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.14...0.1.15)

**Implemented enhancements:**

- Flexible bundle id config [\#40](https://github.com/KrauseFx/fastlane/issues/40)

**Closed issues:**

- Execution fails on fastlane-0.1.14 [\#79](https://github.com/KrauseFx/fastlane/issues/79)

- \[Feature\] pass provisioning profile ID from sigh to ipa action [\#69](https://github.com/KrauseFx/fastlane/issues/69)

- Promo codes [\#66](https://github.com/KrauseFx/fastlane/issues/66)

- Deploy to Crashlytics Beta fails. [\#62](https://github.com/KrauseFx/fastlane/issues/62)

- Hockey upload fails to find dSYM.zip file if there is a space in the filename [\#41](https://github.com/KrauseFx/fastlane/issues/41)

- Missing parameters for snapshot action in fastlane [\#37](https://github.com/KrauseFx/fastlane/issues/37)

- Multiple target support [\#8](https://github.com/KrauseFx/fastlane/issues/8)

**Merged pull requests:**

- Added xcode\_select action [\#84](https://github.com/KrauseFx/fastlane/pull/84) ([dtrenz](https://github.com/dtrenz))

- S3 - fixes for bucket region and IPA file path [\#83](https://github.com/KrauseFx/fastlane/pull/83) ([joshdholtz](https://github.com/joshdholtz))

- Add verbose parameter to ipa action [\#82](https://github.com/KrauseFx/fastlane/pull/82) ([gabu](https://github.com/gabu))

- S3 action [\#81](https://github.com/KrauseFx/fastlane/pull/81) ([joshdholtz](https://github.com/joshdholtz))

- Fix for \_options [\#80](https://github.com/KrauseFx/fastlane/pull/80) ([joshdholtz](https://github.com/joshdholtz))

## [0.1.14](https://github.com/KrauseFx/fastlane/tree/0.1.14) (2015-02-27)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.13...0.1.14)

**Closed issues:**

- Extension Support [\#76](https://github.com/KrauseFx/fastlane/issues/76)

**Merged pull requests:**

- Added gcovr action for code coverage generation. [\#78](https://github.com/KrauseFx/fastlane/pull/78) ([dtrenz](https://github.com/dtrenz))

- Add Typetalk messaging action [\#77](https://github.com/KrauseFx/fastlane/pull/77) ([dataich](https://github.com/dataich))

## [0.1.13](https://github.com/KrauseFx/fastlane/tree/0.1.13) (2015-02-24)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.12...0.1.13)

**Implemented enhancements:**

- \[Feature\] Add dependencies between actions [\#67](https://github.com/KrauseFx/fastlane/issues/67)

**Closed issues:**

- Documentation - ipa vs. ipa \(shenzhen\)? [\#72](https://github.com/KrauseFx/fastlane/issues/72)

**Merged pull requests:**

- Add 'codes' to README + update mailing list text [\#70](https://github.com/KrauseFx/fastlane/pull/70) ([milch](https://github.com/milch))

- Fix file copy in setup [\#71](https://github.com/KrauseFx/fastlane/pull/71) ([powtac](https://github.com/powtac))

## [0.1.12](https://github.com/KrauseFx/fastlane/tree/0.1.12) (2015-02-19)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.11...0.1.12)

**Closed issues:**

- "Complex Fastfile example" omits creation of an \*.ipa [\#65](https://github.com/KrauseFx/fastlane/issues/65)

## [0.1.11](https://github.com/KrauseFx/fastlane/tree/0.1.11) (2015-02-19)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.10...0.1.11)

**Merged pull requests:**

- Made crashlytics\_path docs less ambiguous. [\#63](https://github.com/KrauseFx/fastlane/pull/63) ([dtrenz](https://github.com/dtrenz))

## [0.1.10](https://github.com/KrauseFx/fastlane/tree/0.1.10) (2015-02-18)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.9...0.1.10)

**Closed issues:**

- undefined method `classify' for custom action [\#59](https://github.com/KrauseFx/fastlane/issues/59)

**Merged pull requests:**

- houndci - Prefer single quoted strings [\#61](https://github.com/KrauseFx/fastlane/pull/61) ([JaniJegoroff](https://github.com/JaniJegoroff))

- use SIGH\_USERNAME from environment if provided [\#60](https://github.com/KrauseFx/fastlane/pull/60) ([jonklein](https://github.com/jonklein))

## [0.1.9](https://github.com/KrauseFx/fastlane/tree/0.1.9) (2015-02-18)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.8...0.1.9)

**Closed issues:**

- lane must fail if ipa action fails [\#55](https://github.com/KrauseFx/fastlane/issues/55)

- Reduce size of HipChat icon image. [\#52](https://github.com/KrauseFx/fastlane/issues/52)

- Select Xcode Version [\#50](https://github.com/KrauseFx/fastlane/issues/50)

- Move out all shared code [\#46](https://github.com/KrauseFx/fastlane/issues/46)

- Wrong new lines on ipa action [\#42](https://github.com/KrauseFx/fastlane/issues/42)

**Merged pull requests:**

- Custom config file for houndci [\#57](https://github.com/KrauseFx/fastlane/pull/57) ([JaniJegoroff](https://github.com/JaniJegoroff))

- Use IO.popen instead of PTY \(fix \#42\) [\#54](https://github.com/KrauseFx/fastlane/pull/54) ([milch](https://github.com/milch))

- Replace style section of img tag in HipChat messages. [\#53](https://github.com/KrauseFx/fastlane/pull/53) ([dfranzi](https://github.com/dfranzi))

- Correct function name for HipChat APIv1 response check. [\#51](https://github.com/KrauseFx/fastlane/pull/51) ([dfranzi](https://github.com/dfranzi))

- Rubocop static code analysis [\#44](https://github.com/KrauseFx/fastlane/pull/44) ([JaniJegoroff](https://github.com/JaniJegoroff))

- Fixed unit test deprecation warnings [\#43](https://github.com/KrauseFx/fastlane/pull/43) ([JaniJegoroff](https://github.com/JaniJegoroff))

## [0.1.8](https://github.com/KrauseFx/fastlane/tree/0.1.8) (2015-02-12)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.7...0.1.8)

**Closed issues:**

- Fastlane init: snapshots directory is messed probably [\#32](https://github.com/KrauseFx/fastlane/issues/32)

- Fastlane init: it should ask if I need to enable cocapods [\#31](https://github.com/KrauseFx/fastlane/issues/31)

- sigh 0.2.2 update breaks fastlane [\#30](https://github.com/KrauseFx/fastlane/issues/30)

**Merged pull requests:**

- Add DeployGate Action [\#38](https://github.com/KrauseFx/fastlane/pull/38) ([tnj](https://github.com/tnj))

- IPA Action - Order files by newest to oldest [\#36](https://github.com/KrauseFx/fastlane/pull/36) ([joshdholtz](https://github.com/joshdholtz))

- IPA Action \(using Shenzhen\) [\#33](https://github.com/KrauseFx/fastlane/pull/33) ([joshdholtz](https://github.com/joshdholtz))

- HipChat improvements [\#29](https://github.com/KrauseFx/fastlane/pull/29) ([jingx23](https://github.com/jingx23))

## [0.1.7](https://github.com/KrauseFx/fastlane/tree/0.1.7) (2015-02-04)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.6...0.1.7)

**Closed issues:**

- Error in  json-1.8.2.gem building [\#26](https://github.com/KrauseFx/fastlane/issues/26)

- Where should I keep sensitive data? [\#25](https://github.com/KrauseFx/fastlane/issues/25)

## [0.1.6](https://github.com/KrauseFx/fastlane/tree/0.1.6) (2015-02-01)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.5...0.1.6)

**Merged pull requests:**

- Added hipchat messaging support [\#24](https://github.com/KrauseFx/fastlane/pull/24) ([jingx23](https://github.com/jingx23))

## [0.1.5](https://github.com/KrauseFx/fastlane/tree/0.1.5) (2015-01-31)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.4...0.1.5)

## [0.1.4](https://github.com/KrauseFx/fastlane/tree/0.1.4) (2015-01-30)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.3...0.1.4)

**Merged pull requests:**

- Refactor [\#23](https://github.com/KrauseFx/fastlane/pull/23) ([pedrogimenez](https://github.com/pedrogimenez))

## [0.1.3](https://github.com/KrauseFx/fastlane/tree/0.1.3) (2015-01-30)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.2...0.1.3)

**Closed issues:**

- undefined method `\[\]' for nil:NilClass [\#22](https://github.com/KrauseFx/fastlane/issues/22)

- fastlane init might be missing dependency multi\_json \(?\) [\#20](https://github.com/KrauseFx/fastlane/issues/20)

**Merged pull requests:**

- Add Crashlytics [\#21](https://github.com/KrauseFx/fastlane/pull/21) ([pedrogimenez](https://github.com/pedrogimenez))

## [0.1.2](https://github.com/KrauseFx/fastlane/tree/0.1.2) (2015-01-28)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.1...0.1.2)

**Closed issues:**

- Appfile template [\#19](https://github.com/KrauseFx/fastlane/issues/19)

- sigh timeout [\#17](https://github.com/KrauseFx/fastlane/issues/17)

- sigh action ignores :skip\_install parameter [\#14](https://github.com/KrauseFx/fastlane/issues/14)

- deliver cannot generate ipa due to wrong path [\#11](https://github.com/KrauseFx/fastlane/issues/11)

- Failed to build gem native extension / libiconv is missing [\#10](https://github.com/KrauseFx/fastlane/issues/10)

**Merged pull requests:**

- Slack direct message [\#16](https://github.com/KrauseFx/fastlane/pull/16) ([patoroco](https://github.com/patoroco))

- added ability to skip opening of profile [\#15](https://github.com/KrauseFx/fastlane/pull/15) ([crylico](https://github.com/crylico))

- Upload dSYM file with build [\#12](https://github.com/KrauseFx/fastlane/pull/12) ([vytis](https://github.com/vytis))

- Typo [\#7](https://github.com/KrauseFx/fastlane/pull/7) ([dkhamsing](https://github.com/dkhamsing))

- Slack direct message [\#13](https://github.com/KrauseFx/fastlane/pull/13) ([patoroco](https://github.com/patoroco))

## [0.1.1](https://github.com/KrauseFx/fastlane/tree/0.1.1) (2015-01-16)

[Full Changelog](https://github.com/KrauseFx/fastlane/compare/0.1.0...0.1.1)

**Closed issues:**

-  Failed to build gem native extension. [\#6](https://github.com/KrauseFx/fastlane/issues/6)

**Merged pull requests:**

- Fix typo in README [\#5](https://github.com/KrauseFx/fastlane/pull/5) ([ertemplin](https://github.com/ertemplin))

- Fixed typo in README [\#4](https://github.com/KrauseFx/fastlane/pull/4) ([neonichu](https://github.com/neonichu))

## [0.1.0](https://github.com/KrauseFx/fastlane/tree/0.1.0) (2015-01-15)

**Merged pull requests:**

- testmunk intro text [\#3](https://github.com/KrauseFx/fastlane/pull/3) ([mposchen](https://github.com/mposchen))

- Remove need to manually change line 58 of fast\_file.rb [\#2](https://github.com/KrauseFx/fastlane/pull/2) ([jasonsilberman](https://github.com/jasonsilberman))

- Improve Beta Setup [\#1](https://github.com/KrauseFx/fastlane/pull/1) ([jasonsilberman](https://github.com/jasonsilberman))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*