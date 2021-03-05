// Fastlane.swift
// Copyright (c) 2021 FastlaneTools

import Foundation
/**
 Run ADB Actions

 - parameters:
   - serial: Android serial of the device to use for this command
   - command: All commands you want to pass to the adb command, e.g. `kill-server`
   - adbPath: The path to your `adb` binary (can be left blank if the ANDROID_SDK_ROOT, ANDROID_HOME or ANDROID_SDK environment variable is set)

 - returns: The output of the adb command

 see adb --help for more details
 */
@discardableResult public func adb(serial: String = "",
                                   command: String? = nil,
                                   adbPath: String = "adb") -> String
{
    let command = RubyCommand(commandID: "", methodName: "adb", className: nil, args: [RubyCommand.Argument(name: "serial", value: serial),
                                                                                       RubyCommand.Argument(name: "command", value: command),
                                                                                       RubyCommand.Argument(name: "adb_path", value: adbPath)])
    return runner.executeCommand(command)
}

/**
 Get an array of Connected android device serials

 - parameter adbPath: The path to your `adb` binary (can be left blank if the ANDROID_SDK_ROOT environment variable is set)

 - returns: Returns an array of all currently connected android devices. Example: []

 Fetches device list via adb, e.g. run an adb command on all connected devices.
 */
public func adbDevices(adbPath: String = "adb") {
    let command = RubyCommand(commandID: "", methodName: "adb_devices", className: nil, args: [RubyCommand.Argument(name: "adb_path", value: adbPath)])
    _ = runner.executeCommand(command)
}

/**
 Modify the default list of supported platforms

 - parameter platforms: The optional extra platforms to support
 */
public func addExtraPlatforms(platforms: [String] = []) {
    let command = RubyCommand(commandID: "", methodName: "add_extra_platforms", className: nil, args: [RubyCommand.Argument(name: "platforms", value: platforms)])
    _ = runner.executeCommand(command)
}

/**
 This will add an annotated git tag to the current branch

 - parameters:
   - tag: Define your own tag text. This will replace all other parameters
   - grouping: Is used to keep your tags organised under one 'folder'
   - includesLane: Whether the current lane should be included in the tag and message composition, e.g. '<grouping>/<lane>/<prefix><build_number><postfix>'
   - prefix: Anything you want to put in front of the version number (e.g. 'v')
   - postfix: Anything you want to put at the end of the version number (e.g. '-RC1')
   - buildNumber: The build number. Defaults to the result of increment_build_number if you're using it
   - message: The tag message. Defaults to the tag's name
   - commit: The commit or object where the tag will be set. Defaults to the current HEAD
   - force: Force adding the tag
   - sign: Make a GPG-signed tag, using the default e-mail address's key

 This will automatically tag your build with the following format: `<grouping>/<lane>/<prefix><build_number><postfix>`, where:|
 |
 >- `grouping` is just to keep your tags organised under one 'folder', defaults to 'builds'|
 - `lane` is the name of the current fastlane lane, if chosen to be included via 'includes_lane' option, which defaults to 'true'|
 - `prefix` is anything you want to stick in front of the version number, e.g. 'v'|
 - `postfix` is anything you want to stick at the end of the version number, e.g. '-RC1'|
 - `build_number` is the build number, which defaults to the value emitted by the `increment_build_number` action|
 >|
 For example, for build 1234 in the 'appstore' lane, it will tag the commit with `builds/appstore/1234`.
 */
public func addGitTag(tag: String? = nil,
                      grouping: String = "builds",
                      includesLane: Bool = true,
                      prefix: String = "",
                      postfix: String = "",
                      buildNumber: Any? = nil,
                      message: String? = nil,
                      commit: String? = nil,
                      force: Bool = false,
                      sign: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "add_git_tag", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag),
                                                                                               RubyCommand.Argument(name: "grouping", value: grouping),
                                                                                               RubyCommand.Argument(name: "includes_lane", value: includesLane),
                                                                                               RubyCommand.Argument(name: "prefix", value: prefix),
                                                                                               RubyCommand.Argument(name: "postfix", value: postfix),
                                                                                               RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                               RubyCommand.Argument(name: "message", value: message),
                                                                                               RubyCommand.Argument(name: "commit", value: commit),
                                                                                               RubyCommand.Argument(name: "force", value: force),
                                                                                               RubyCommand.Argument(name: "sign", value: sign)])
    _ = runner.executeCommand(command)
}

/**
 Returns the current build_number of either live or edit version

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - initialBuildNumber: sets the build number to given value if no build is in current train
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - live: Query the live version (ready-for-sale)
   - version: The version number whose latest build number we want
   - platform: The platform to use (optional)
   - teamName: The name of your App Store Connect team if you're in multiple teams

 Returns the current build number of either the live or testflight version - it is useful for getting the build_number of the current or ready-for-sale app version, and it also works on non-live testflight version.
 If you need to handle more build-trains please see `latest_testflight_build_number`.
 */
public func appStoreBuildNumber(apiKeyPath: String? = nil,
                                apiKey: [String: Any]? = nil,
                                initialBuildNumber: Any,
                                appIdentifier: String,
                                username: String,
                                teamId: Any? = nil,
                                live: Bool = true,
                                version: String? = nil,
                                platform: String = "ios",
                                teamName: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "app_store_build_number", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                          RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                          RubyCommand.Argument(name: "initial_build_number", value: initialBuildNumber),
                                                                                                          RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                          RubyCommand.Argument(name: "username", value: username),
                                                                                                          RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                          RubyCommand.Argument(name: "live", value: live),
                                                                                                          RubyCommand.Argument(name: "version", value: version),
                                                                                                          RubyCommand.Argument(name: "platform", value: platform),
                                                                                                          RubyCommand.Argument(name: "team_name", value: teamName)])
    _ = runner.executeCommand(command)
}

/**
 Load the App Store Connect API token to use in other fastlane tools and actions

 - parameters:
   - keyId: The key ID
   - issuerId: The issuer ID
   - keyFilepath: The path to the key p8 file
   - keyContent: The content of the key p8 file
   - isKeyContentBase64: Whether :key_content is Base64 encoded or not
   - duration: The token session duration
   - inHouse: Is App Store or Enterprise (in house) team? App Store Connect API cannot not determine this on its own (yet)

 Load the App Store Connect API token to use in other fastlane tools and actions
 */
public func appStoreConnectApiKey(keyId: String,
                                  issuerId: String,
                                  keyFilepath: String? = nil,
                                  keyContent: String? = nil,
                                  isKeyContentBase64: Bool = false,
                                  duration: Int = 1200,
                                  inHouse: Bool? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "app_store_connect_api_key", className: nil, args: [RubyCommand.Argument(name: "key_id", value: keyId),
                                                                                                             RubyCommand.Argument(name: "issuer_id", value: issuerId),
                                                                                                             RubyCommand.Argument(name: "key_filepath", value: keyFilepath),
                                                                                                             RubyCommand.Argument(name: "key_content", value: keyContent),
                                                                                                             RubyCommand.Argument(name: "is_key_content_base64", value: isKeyContentBase64),
                                                                                                             RubyCommand.Argument(name: "duration", value: duration),
                                                                                                             RubyCommand.Argument(name: "in_house", value: inHouse)])
    _ = runner.executeCommand(command)
}

/**
 Upload your app to [Appaloosa Store](https://www.appaloosa-store.com/)

 - parameters:
   - binary: Binary path. Optional for ipa if you use the `ipa` or `xcodebuild` action
   - apiToken: Your API token
   - storeId: Your Store id
   - groupIds: Your app is limited to special users? Give us the group ids
   - screenshots: Add some screenshots application to your store or hit [enter]
   - locale: Select the folder locale for your screenshots
   - device: Select the device format for your screenshots
   - description: Your app description

 Appaloosa is a private mobile application store. This action offers a quick deployment on the platform.
 You can create an account, push to your existing account, or manage your user groups.
 We accept iOS and Android applications.
 */
public func appaloosa(binary: String,
                      apiToken: String,
                      storeId: String,
                      groupIds: String = "",
                      screenshots: String,
                      locale: String = "en-US",
                      device: String? = nil,
                      description: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "appaloosa", className: nil, args: [RubyCommand.Argument(name: "binary", value: binary),
                                                                                             RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                             RubyCommand.Argument(name: "store_id", value: storeId),
                                                                                             RubyCommand.Argument(name: "group_ids", value: groupIds),
                                                                                             RubyCommand.Argument(name: "screenshots", value: screenshots),
                                                                                             RubyCommand.Argument(name: "locale", value: locale),
                                                                                             RubyCommand.Argument(name: "device", value: device),
                                                                                             RubyCommand.Argument(name: "description", value: description)])
    _ = runner.executeCommand(command)
}

/**
 Upload your app to [Appetize.io](https://appetize.io/) to stream it in browser

 - parameters:
   - apiHost: Appetize API host
   - apiToken: Appetize.io API Token
   - url: URL from which the ipa file can be fetched. Alternative to :path
   - platform: Platform. Either `ios` or `android`
   - path: Path to zipped build on the local filesystem. Either this or `url` must be specified
   - publicKey: If not provided, a new app will be created. If provided, the existing build will be overwritten
   - note: Notes you wish to add to the uploaded app
   - timeout: The number of seconds to wait until automatically ending the session due to user inactivity. Must be 30, 60, 90, 120, 180, 300, 600, 1800, 3600 or 7200. Default is 120

 If you provide a `public_key`, this will overwrite an existing application. If you want to have this build as a new app version, you shouldn't provide this value.

 To integrate appetize into your GitHub workflow check out the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md).
 */
public func appetize(apiHost: String = "api.appetize.io",
                     apiToken: String,
                     url: String? = nil,
                     platform: String = "ios",
                     path: String? = nil,
                     publicKey: String? = nil,
                     note: String? = nil,
                     timeout: Int? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "appetize", className: nil, args: [RubyCommand.Argument(name: "api_host", value: apiHost),
                                                                                            RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                            RubyCommand.Argument(name: "url", value: url),
                                                                                            RubyCommand.Argument(name: "platform", value: platform),
                                                                                            RubyCommand.Argument(name: "path", value: path),
                                                                                            RubyCommand.Argument(name: "public_key", value: publicKey),
                                                                                            RubyCommand.Argument(name: "note", value: note),
                                                                                            RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Generate an URL for appetize simulator

 - parameters:
   - publicKey: Public key of the app you wish to update
   - baseUrl: Base URL of Appetize service
   - device: Device type: iphone4s, iphone5s, iphone6, iphone6plus, ipadair, iphone6s, iphone6splus, ipadair2, nexus5, nexus7 or nexus9
   - scale: Scale of the simulator
   - orientation: Device orientation
   - language: Device language in ISO 639-1 language code, e.g. 'de'
   - color: Color of the device
   - launchUrl: Specify a deep link to open when your app is launched
   - osVersion: The operating system version on which to run your app, e.g. 10.3, 8.0
   - params: Specify params value to be passed to Appetize
   - proxy: Specify a HTTP proxy to be passed to Appetize

 - returns: The URL to preview the iPhone app

 Check out the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md) for more information
 */
public func appetizeViewingUrlGenerator(publicKey: String,
                                        baseUrl: String = "https://appetize.io/embed",
                                        device: String = "iphone5s",
                                        scale: String? = nil,
                                        orientation: String = "portrait",
                                        language: String? = nil,
                                        color: String = "black",
                                        launchUrl: String? = nil,
                                        osVersion: String? = nil,
                                        params: String? = nil,
                                        proxy: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "appetize_viewing_url_generator", className: nil, args: [RubyCommand.Argument(name: "public_key", value: publicKey),
                                                                                                                  RubyCommand.Argument(name: "base_url", value: baseUrl),
                                                                                                                  RubyCommand.Argument(name: "device", value: device),
                                                                                                                  RubyCommand.Argument(name: "scale", value: scale),
                                                                                                                  RubyCommand.Argument(name: "orientation", value: orientation),
                                                                                                                  RubyCommand.Argument(name: "language", value: language),
                                                                                                                  RubyCommand.Argument(name: "color", value: color),
                                                                                                                  RubyCommand.Argument(name: "launch_url", value: launchUrl),
                                                                                                                  RubyCommand.Argument(name: "os_version", value: osVersion),
                                                                                                                  RubyCommand.Argument(name: "params", value: params),
                                                                                                                  RubyCommand.Argument(name: "proxy", value: proxy)])
    _ = runner.executeCommand(command)
}

/**
 Run UI test by Appium with RSpec

 - parameters:
   - platform: Appium platform name
   - specPath: Path to Appium spec directory
   - appPath: Path to Appium target app file
   - invokeAppiumServer: Use local Appium server with invoke automatically
   - host: Hostname of Appium server
   - port: HTTP port of Appium server
   - appiumPath: Path to Appium executable
   - caps: Hash of caps for Appium::Driver
   - appiumLib: Hash of appium_lib for Appium::Driver
 */
public func appium(platform: String,
                   specPath: String,
                   appPath: String,
                   invokeAppiumServer: Bool = true,
                   host: String = "0.0.0.0",
                   port: Int = 4723,
                   appiumPath: String? = nil,
                   caps: [String: Any]? = nil,
                   appiumLib: [String: Any]? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "appium", className: nil, args: [RubyCommand.Argument(name: "platform", value: platform),
                                                                                          RubyCommand.Argument(name: "spec_path", value: specPath),
                                                                                          RubyCommand.Argument(name: "app_path", value: appPath),
                                                                                          RubyCommand.Argument(name: "invoke_appium_server", value: invokeAppiumServer),
                                                                                          RubyCommand.Argument(name: "host", value: host),
                                                                                          RubyCommand.Argument(name: "port", value: port),
                                                                                          RubyCommand.Argument(name: "appium_path", value: appiumPath),
                                                                                          RubyCommand.Argument(name: "caps", value: caps),
                                                                                          RubyCommand.Argument(name: "appium_lib", value: appiumLib)])
    _ = runner.executeCommand(command)
}

/**
 Generate Apple-like source code documentation from the source code

 - parameters:
   - input: Path(s) to source file directories or individual source files. Accepts a single path or an array of paths
   - output: Output path
   - templates: Template files path
   - docsetInstallPath: DocSet installation path
   - include: Include static doc(s) at path
   - ignore: Ignore given path
   - excludeOutput: Exclude given path from output
   - indexDesc: File including main index description
   - projectName: Project name
   - projectVersion: Project version
   - projectCompany: Project company
   - companyId: Company UTI (i.e. reverse DNS name)
   - createHtml: Create HTML
   - createDocset: Create documentation set
   - installDocset: Install documentation set to Xcode
   - publishDocset: Prepare DocSet for publishing
   - noCreateDocset: Create HTML and skip creating a DocSet
   - htmlAnchors: The html anchor format to use in DocSet HTML
   - cleanOutput: Remove contents of output path before starting
   - docsetBundleId: DocSet bundle identifier
   - docsetBundleName: DocSet bundle name
   - docsetDesc: DocSet description
   - docsetCopyright: DocSet copyright message
   - docsetFeedName: DocSet feed name
   - docsetFeedUrl: DocSet feed URL
   - docsetFeedFormats: DocSet feed formats. Separated by a comma [atom,xml]
   - docsetPackageUrl: DocSet package (.xar) URL
   - docsetFallbackUrl: DocSet fallback URL
   - docsetPublisherId: DocSet publisher identifier
   - docsetPublisherName: DocSet publisher name
   - docsetMinXcodeVersion: DocSet min. Xcode version
   - docsetPlatformFamily: DocSet platform family
   - docsetCertIssuer: DocSet certificate issuer
   - docsetCertSigner: DocSet certificate signer
   - docsetBundleFilename: DocSet bundle filename
   - docsetAtomFilename: DocSet atom feed filename
   - docsetXmlFilename: DocSet xml feed filename
   - docsetPackageFilename: DocSet package (.xar,.tgz) filename
   - options: Documentation generation options
   - crossrefFormat: Cross reference template regex
   - exitThreshold: Exit code threshold below which 0 is returned
   - docsSectionTitle: Title of the documentation section (defaults to "Programming Guides"
   - warnings: Documentation generation warnings
   - logformat: Log format [0-3]
   - verbose: Log verbosity level [0-6,xcode]

 Runs `appledoc [OPTIONS] <paths to source dirs or files>` for the project
 */
public func appledoc(input: Any,
                     output: String? = nil,
                     templates: String? = nil,
                     docsetInstallPath: String? = nil,
                     include: String? = nil,
                     ignore: Any? = nil,
                     excludeOutput: Any? = nil,
                     indexDesc: String? = nil,
                     projectName: String,
                     projectVersion: String? = nil,
                     projectCompany: String,
                     companyId: String? = nil,
                     createHtml: Bool = false,
                     createDocset: Bool = false,
                     installDocset: Bool = false,
                     publishDocset: Bool = false,
                     noCreateDocset: Bool = false,
                     htmlAnchors: String? = nil,
                     cleanOutput: Bool = false,
                     docsetBundleId: String? = nil,
                     docsetBundleName: String? = nil,
                     docsetDesc: String? = nil,
                     docsetCopyright: String? = nil,
                     docsetFeedName: String? = nil,
                     docsetFeedUrl: String? = nil,
                     docsetFeedFormats: String? = nil,
                     docsetPackageUrl: String? = nil,
                     docsetFallbackUrl: String? = nil,
                     docsetPublisherId: String? = nil,
                     docsetPublisherName: String? = nil,
                     docsetMinXcodeVersion: String? = nil,
                     docsetPlatformFamily: String? = nil,
                     docsetCertIssuer: String? = nil,
                     docsetCertSigner: String? = nil,
                     docsetBundleFilename: String? = nil,
                     docsetAtomFilename: String? = nil,
                     docsetXmlFilename: String? = nil,
                     docsetPackageFilename: String? = nil,
                     options: String? = nil,
                     crossrefFormat: String? = nil,
                     exitThreshold: Int = 2,
                     docsSectionTitle: String? = nil,
                     warnings: String? = nil,
                     logformat: Any? = nil,
                     verbose: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "appledoc", className: nil, args: [RubyCommand.Argument(name: "input", value: input),
                                                                                            RubyCommand.Argument(name: "output", value: output),
                                                                                            RubyCommand.Argument(name: "templates", value: templates),
                                                                                            RubyCommand.Argument(name: "docset_install_path", value: docsetInstallPath),
                                                                                            RubyCommand.Argument(name: "include", value: include),
                                                                                            RubyCommand.Argument(name: "ignore", value: ignore),
                                                                                            RubyCommand.Argument(name: "exclude_output", value: excludeOutput),
                                                                                            RubyCommand.Argument(name: "index_desc", value: indexDesc),
                                                                                            RubyCommand.Argument(name: "project_name", value: projectName),
                                                                                            RubyCommand.Argument(name: "project_version", value: projectVersion),
                                                                                            RubyCommand.Argument(name: "project_company", value: projectCompany),
                                                                                            RubyCommand.Argument(name: "company_id", value: companyId),
                                                                                            RubyCommand.Argument(name: "create_html", value: createHtml),
                                                                                            RubyCommand.Argument(name: "create_docset", value: createDocset),
                                                                                            RubyCommand.Argument(name: "install_docset", value: installDocset),
                                                                                            RubyCommand.Argument(name: "publish_docset", value: publishDocset),
                                                                                            RubyCommand.Argument(name: "no_create_docset", value: noCreateDocset),
                                                                                            RubyCommand.Argument(name: "html_anchors", value: htmlAnchors),
                                                                                            RubyCommand.Argument(name: "clean_output", value: cleanOutput),
                                                                                            RubyCommand.Argument(name: "docset_bundle_id", value: docsetBundleId),
                                                                                            RubyCommand.Argument(name: "docset_bundle_name", value: docsetBundleName),
                                                                                            RubyCommand.Argument(name: "docset_desc", value: docsetDesc),
                                                                                            RubyCommand.Argument(name: "docset_copyright", value: docsetCopyright),
                                                                                            RubyCommand.Argument(name: "docset_feed_name", value: docsetFeedName),
                                                                                            RubyCommand.Argument(name: "docset_feed_url", value: docsetFeedUrl),
                                                                                            RubyCommand.Argument(name: "docset_feed_formats", value: docsetFeedFormats),
                                                                                            RubyCommand.Argument(name: "docset_package_url", value: docsetPackageUrl),
                                                                                            RubyCommand.Argument(name: "docset_fallback_url", value: docsetFallbackUrl),
                                                                                            RubyCommand.Argument(name: "docset_publisher_id", value: docsetPublisherId),
                                                                                            RubyCommand.Argument(name: "docset_publisher_name", value: docsetPublisherName),
                                                                                            RubyCommand.Argument(name: "docset_min_xcode_version", value: docsetMinXcodeVersion),
                                                                                            RubyCommand.Argument(name: "docset_platform_family", value: docsetPlatformFamily),
                                                                                            RubyCommand.Argument(name: "docset_cert_issuer", value: docsetCertIssuer),
                                                                                            RubyCommand.Argument(name: "docset_cert_signer", value: docsetCertSigner),
                                                                                            RubyCommand.Argument(name: "docset_bundle_filename", value: docsetBundleFilename),
                                                                                            RubyCommand.Argument(name: "docset_atom_filename", value: docsetAtomFilename),
                                                                                            RubyCommand.Argument(name: "docset_xml_filename", value: docsetXmlFilename),
                                                                                            RubyCommand.Argument(name: "docset_package_filename", value: docsetPackageFilename),
                                                                                            RubyCommand.Argument(name: "options", value: options),
                                                                                            RubyCommand.Argument(name: "crossref_format", value: crossrefFormat),
                                                                                            RubyCommand.Argument(name: "exit_threshold", value: exitThreshold),
                                                                                            RubyCommand.Argument(name: "docs_section_title", value: docsSectionTitle),
                                                                                            RubyCommand.Argument(name: "warnings", value: warnings),
                                                                                            RubyCommand.Argument(name: "logformat", value: logformat),
                                                                                            RubyCommand.Argument(name: "verbose", value: verbose)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `upload_to_app_store` action

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - appIdentifier: The bundle identifier of your app
   - appVersion: The version that should be edited or created
   - ipa: Path to your ipa file
   - pkg: Path to your pkg file
   - buildNumber: If set the given build number (already uploaded to iTC) will be used instead of the current built one
   - platform: The platform to use (optional)
   - editLive: Modify live metadata, this option disables ipa upload and screenshot upload
   - useLiveVersion: Force usage of live version rather than edit version
   - metadataPath: Path to the folder containing the metadata files
   - screenshotsPath: Path to the folder containing the screenshots
   - skipBinaryUpload: Skip uploading an ipa or pkg to App Store Connect
   - skipScreenshots: Don't upload the screenshots
   - skipMetadata: Don't upload the metadata (e.g. title, description). This will still upload screenshots
   - skipAppVersionUpdate: Don’t create or update the app version that is being prepared for submission
   - force: Skip verification of HTML preview file
   - overwriteScreenshots: Clear all previously uploaded screenshots before uploading the new ones
   - submitForReview: Submit the new version for Review after uploading everything
   - rejectIfPossible: Rejects the previously submitted build if it's in a state where it's possible
   - automaticRelease: Should the app be automatically released once it's approved? (Can not be used together with `auto_release_date`)
   - autoReleaseDate: Date in milliseconds for automatically releasing on pending approval (Can not be used together with `automatic_release`)
   - phasedRelease: Enable the phased release feature of iTC
   - resetRatings: Reset the summary rating when you release a new version of the application
   - priceTier: The price tier of this application
   - appRatingConfigPath: Path to the app rating's config
   - submissionInformation: Extra information for the submission (e.g. compliance specifications, IDFA settings)
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - devPortalTeamId: The short ID of your Developer Portal team, if you're in multiple teams. Different from your iTC team ID!
   - devPortalTeamName: The name of your Developer Portal team if you're in multiple teams
   - itcProvider: The provider short name to be used with the iTMSTransporter to identify your team. This value will override the automatically detected provider short name. To get provider short name run `pathToXcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m provider -u 'USERNAME' -p 'PASSWORD' -account_type itunes_connect -v off`. The short names of providers should be listed in the second column
   - runPrecheckBeforeSubmit: Run precheck before submitting to app review
   - precheckDefaultRuleLevel: The default precheck rule level unless otherwise configured
   - individualMetadataItems: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - An array of localized metadata items to upload individually by language so that errors can be identified. E.g. ['name', 'keywords', 'description']. Note: slow
   - appIcon: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - Metadata: The path to the app icon
   - appleWatchAppIcon: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - Metadata: The path to the Apple Watch app icon
   - copyright: Metadata: The copyright notice
   - primaryCategory: Metadata: The english name of the primary category (e.g. `Business`, `Books`)
   - secondaryCategory: Metadata: The english name of the secondary category (e.g. `Business`, `Books`)
   - primaryFirstSubCategory: Metadata: The english name of the primary first sub category (e.g. `Educational`, `Puzzle`)
   - primarySecondSubCategory: Metadata: The english name of the primary second sub category (e.g. `Educational`, `Puzzle`)
   - secondaryFirstSubCategory: Metadata: The english name of the secondary first sub category (e.g. `Educational`, `Puzzle`)
   - secondarySecondSubCategory: Metadata: The english name of the secondary second sub category (e.g. `Educational`, `Puzzle`)
   - tradeRepresentativeContactInformation: Metadata: A hash containing the trade representative contact information
   - appReviewInformation: Metadata: A hash containing the review information
   - appReviewAttachmentFile: Metadata: Path to the app review attachment file
   - description: Metadata: The localised app description
   - name: Metadata: The localised app name
   - subtitle: Metadata: The localised app subtitle
   - keywords: Metadata: An array of localised keywords
   - promotionalText: Metadata: An array of localised promotional texts
   - releaseNotes: Metadata: Localised release notes for this version
   - privacyUrl: Metadata: Localised privacy url
   - appleTvPrivacyPolicy: Metadata: Localised Apple TV privacy policy text
   - supportUrl: Metadata: Localised support url
   - marketingUrl: Metadata: Localised marketing url
   - languages: Metadata: List of languages to activate
   - ignoreLanguageDirectoryValidation: Ignore errors when invalid languages are found in metadata and screenshot directories
   - precheckIncludeInAppPurchases: Should precheck check in-app purchases?
   - app: The (spaceship) app ID of the app you want to use/modify

 Using _upload_to_app_store_ after _build_app_ and _capture_screenshots_ will automatically upload the latest ipa and screenshots with no other configuration.

 If you don't want to verify an HTML preview for App Store builds, use the `:force` option.
 This is useful when running _fastlane_ on your Continuous Integration server:
 `_upload_to_app_store_(force: true)`
 If your account is on multiple teams and you need to tell the `iTMSTransporter` which 'provider' to use, you can set the `:itc_provider` option to pass this info.
 */
public func appstore(apiKeyPath: String? = nil,
                     apiKey: [String: Any]? = nil,
                     username: String,
                     appIdentifier: String? = nil,
                     appVersion: String? = nil,
                     ipa: String? = nil,
                     pkg: String? = nil,
                     buildNumber: String? = nil,
                     platform: String = "ios",
                     editLive: Bool = false,
                     useLiveVersion: Bool = false,
                     metadataPath: String? = nil,
                     screenshotsPath: String? = nil,
                     skipBinaryUpload: Bool = false,
                     skipScreenshots: Bool = false,
                     skipMetadata: Bool = false,
                     skipAppVersionUpdate: Bool = false,
                     force: Bool = false,
                     overwriteScreenshots: Bool = false,
                     submitForReview: Bool = false,
                     rejectIfPossible: Bool = false,
                     automaticRelease: Bool? = nil,
                     autoReleaseDate: Int? = nil,
                     phasedRelease: Bool = false,
                     resetRatings: Bool = false,
                     priceTier: Any? = nil,
                     appRatingConfigPath: String? = nil,
                     submissionInformation: [String: Any]? = nil,
                     teamId: Any? = nil,
                     teamName: String? = nil,
                     devPortalTeamId: String? = nil,
                     devPortalTeamName: String? = nil,
                     itcProvider: String? = nil,
                     runPrecheckBeforeSubmit: Bool = true,
                     precheckDefaultRuleLevel: Any = "warn",
                     individualMetadataItems: [String]? = nil,
                     appIcon: String? = nil,
                     appleWatchAppIcon: String? = nil,
                     copyright: String? = nil,
                     primaryCategory: String? = nil,
                     secondaryCategory: String? = nil,
                     primaryFirstSubCategory: String? = nil,
                     primarySecondSubCategory: String? = nil,
                     secondaryFirstSubCategory: String? = nil,
                     secondarySecondSubCategory: String? = nil,
                     tradeRepresentativeContactInformation: [String: Any]? = nil,
                     appReviewInformation: [String: Any]? = nil,
                     appReviewAttachmentFile: String? = nil,
                     description: Any? = nil,
                     name: Any? = nil,
                     subtitle: [String: Any]? = nil,
                     keywords: [String: Any]? = nil,
                     promotionalText: [String: Any]? = nil,
                     releaseNotes: Any? = nil,
                     privacyUrl: Any? = nil,
                     appleTvPrivacyPolicy: Any? = nil,
                     supportUrl: Any? = nil,
                     marketingUrl: Any? = nil,
                     languages: [String]? = nil,
                     ignoreLanguageDirectoryValidation: Bool = false,
                     precheckIncludeInAppPurchases: Bool = true,
                     app: Any)
{
    let command = RubyCommand(commandID: "", methodName: "appstore", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                            RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                            RubyCommand.Argument(name: "username", value: username),
                                                                                            RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                            RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                            RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                            RubyCommand.Argument(name: "pkg", value: pkg),
                                                                                            RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                            RubyCommand.Argument(name: "platform", value: platform),
                                                                                            RubyCommand.Argument(name: "edit_live", value: editLive),
                                                                                            RubyCommand.Argument(name: "use_live_version", value: useLiveVersion),
                                                                                            RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                            RubyCommand.Argument(name: "screenshots_path", value: screenshotsPath),
                                                                                            RubyCommand.Argument(name: "skip_binary_upload", value: skipBinaryUpload),
                                                                                            RubyCommand.Argument(name: "skip_screenshots", value: skipScreenshots),
                                                                                            RubyCommand.Argument(name: "skip_metadata", value: skipMetadata),
                                                                                            RubyCommand.Argument(name: "skip_app_version_update", value: skipAppVersionUpdate),
                                                                                            RubyCommand.Argument(name: "force", value: force),
                                                                                            RubyCommand.Argument(name: "overwrite_screenshots", value: overwriteScreenshots),
                                                                                            RubyCommand.Argument(name: "submit_for_review", value: submitForReview),
                                                                                            RubyCommand.Argument(name: "reject_if_possible", value: rejectIfPossible),
                                                                                            RubyCommand.Argument(name: "automatic_release", value: automaticRelease),
                                                                                            RubyCommand.Argument(name: "auto_release_date", value: autoReleaseDate),
                                                                                            RubyCommand.Argument(name: "phased_release", value: phasedRelease),
                                                                                            RubyCommand.Argument(name: "reset_ratings", value: resetRatings),
                                                                                            RubyCommand.Argument(name: "price_tier", value: priceTier),
                                                                                            RubyCommand.Argument(name: "app_rating_config_path", value: appRatingConfigPath),
                                                                                            RubyCommand.Argument(name: "submission_information", value: submissionInformation),
                                                                                            RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                            RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                            RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId),
                                                                                            RubyCommand.Argument(name: "dev_portal_team_name", value: devPortalTeamName),
                                                                                            RubyCommand.Argument(name: "itc_provider", value: itcProvider),
                                                                                            RubyCommand.Argument(name: "run_precheck_before_submit", value: runPrecheckBeforeSubmit),
                                                                                            RubyCommand.Argument(name: "precheck_default_rule_level", value: precheckDefaultRuleLevel),
                                                                                            RubyCommand.Argument(name: "individual_metadata_items", value: individualMetadataItems),
                                                                                            RubyCommand.Argument(name: "app_icon", value: appIcon),
                                                                                            RubyCommand.Argument(name: "apple_watch_app_icon", value: appleWatchAppIcon),
                                                                                            RubyCommand.Argument(name: "copyright", value: copyright),
                                                                                            RubyCommand.Argument(name: "primary_category", value: primaryCategory),
                                                                                            RubyCommand.Argument(name: "secondary_category", value: secondaryCategory),
                                                                                            RubyCommand.Argument(name: "primary_first_sub_category", value: primaryFirstSubCategory),
                                                                                            RubyCommand.Argument(name: "primary_second_sub_category", value: primarySecondSubCategory),
                                                                                            RubyCommand.Argument(name: "secondary_first_sub_category", value: secondaryFirstSubCategory),
                                                                                            RubyCommand.Argument(name: "secondary_second_sub_category", value: secondarySecondSubCategory),
                                                                                            RubyCommand.Argument(name: "trade_representative_contact_information", value: tradeRepresentativeContactInformation),
                                                                                            RubyCommand.Argument(name: "app_review_information", value: appReviewInformation),
                                                                                            RubyCommand.Argument(name: "app_review_attachment_file", value: appReviewAttachmentFile),
                                                                                            RubyCommand.Argument(name: "description", value: description),
                                                                                            RubyCommand.Argument(name: "name", value: name),
                                                                                            RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                            RubyCommand.Argument(name: "keywords", value: keywords),
                                                                                            RubyCommand.Argument(name: "promotional_text", value: promotionalText),
                                                                                            RubyCommand.Argument(name: "release_notes", value: releaseNotes),
                                                                                            RubyCommand.Argument(name: "privacy_url", value: privacyUrl),
                                                                                            RubyCommand.Argument(name: "apple_tv_privacy_policy", value: appleTvPrivacyPolicy),
                                                                                            RubyCommand.Argument(name: "support_url", value: supportUrl),
                                                                                            RubyCommand.Argument(name: "marketing_url", value: marketingUrl),
                                                                                            RubyCommand.Argument(name: "languages", value: languages),
                                                                                            RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation),
                                                                                            RubyCommand.Argument(name: "precheck_include_in_app_purchases", value: precheckIncludeInAppPurchases),
                                                                                            RubyCommand.Argument(name: "app", value: app)])
    _ = runner.executeCommand(command)
}

/**
 Upload dSYM file to [Apteligent (Crittercism)](http://www.apteligent.com/)

 - parameters:
   - dsym: dSYM.zip file to upload to Apteligent
   - appId: Apteligent App ID key e.g. 569f5c87cb99e10e00c7xxxx
   - apiKey: Apteligent App API key e.g. IXPQIi8yCbHaLliqzRoo065tH0lxxxxx
 */
public func apteligent(dsym: String? = nil,
                       appId: String,
                       apiKey: String)
{
    let command = RubyCommand(commandID: "", methodName: "apteligent", className: nil, args: [RubyCommand.Argument(name: "dsym", value: dsym),
                                                                                              RubyCommand.Argument(name: "app_id", value: appId),
                                                                                              RubyCommand.Argument(name: "api_key", value: apiKey)])
    _ = runner.executeCommand(command)
}

/**
 This action uploads an artifact to artifactory

 - parameters:
   - file: File to be uploaded to artifactory
   - repo: Artifactory repo to put the file in
   - repoPath: Path to deploy within the repo, including filename
   - endpoint: Artifactory endpoint
   - username: Artifactory username
   - password: Artifactory password
   - apiKey: Artifactory API key
   - properties: Artifact properties hash
   - sslPemFile: Location of pem file to use for ssl verification
   - sslVerify: Verify SSL
   - proxyUsername: Proxy username
   - proxyPassword: Proxy password
   - proxyAddress: Proxy address
   - proxyPort: Proxy port
   - readTimeout: Read timeout

 Connect to the artifactory server using either a username/password or an api_key
 */
public func artifactory(file: String,
                        repo: String,
                        repoPath: String,
                        endpoint: String,
                        username: String? = nil,
                        password: String? = nil,
                        apiKey: String? = nil,
                        properties: [String: Any] = [:],
                        sslPemFile: String? = nil,
                        sslVerify: Bool = true,
                        proxyUsername: String? = nil,
                        proxyPassword: String? = nil,
                        proxyAddress: String? = nil,
                        proxyPort: String? = nil,
                        readTimeout: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "artifactory", className: nil, args: [RubyCommand.Argument(name: "file", value: file),
                                                                                               RubyCommand.Argument(name: "repo", value: repo),
                                                                                               RubyCommand.Argument(name: "repo_path", value: repoPath),
                                                                                               RubyCommand.Argument(name: "endpoint", value: endpoint),
                                                                                               RubyCommand.Argument(name: "username", value: username),
                                                                                               RubyCommand.Argument(name: "password", value: password),
                                                                                               RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                               RubyCommand.Argument(name: "properties", value: properties),
                                                                                               RubyCommand.Argument(name: "ssl_pem_file", value: sslPemFile),
                                                                                               RubyCommand.Argument(name: "ssl_verify", value: sslVerify),
                                                                                               RubyCommand.Argument(name: "proxy_username", value: proxyUsername),
                                                                                               RubyCommand.Argument(name: "proxy_password", value: proxyPassword),
                                                                                               RubyCommand.Argument(name: "proxy_address", value: proxyAddress),
                                                                                               RubyCommand.Argument(name: "proxy_port", value: proxyPort),
                                                                                               RubyCommand.Argument(name: "read_timeout", value: readTimeout)])
    _ = runner.executeCommand(command)
}

/**
 Configures Xcode's Codesigning options

 - parameters:
   - path: Path to your Xcode project
   - useAutomaticSigning: Defines if project should use automatic signing
   - teamId: Team ID, is used when upgrading project
   - targets: Specify targets you want to toggle the signing mech. (default to all targets)
   - codeSignIdentity: Code signing identity type (iPhone Developer, iPhone Distribution)
   - profileName: Provisioning profile name to use for code signing
   - profileUuid: Provisioning profile UUID to use for code signing
   - bundleIdentifier: Application Product Bundle Identifier

 - returns: The current status (boolean) of codesigning after modification

 Configures Xcode's Codesigning options of all targets in the project
 */
public func automaticCodeSigning(path: String,
                                 useAutomaticSigning: Bool = false,
                                 teamId: String? = nil,
                                 targets: [String]? = nil,
                                 codeSignIdentity: String? = nil,
                                 profileName: String? = nil,
                                 profileUuid: String? = nil,
                                 bundleIdentifier: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "automatic_code_signing", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                          RubyCommand.Argument(name: "use_automatic_signing", value: useAutomaticSigning),
                                                                                                          RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                          RubyCommand.Argument(name: "targets", value: targets),
                                                                                                          RubyCommand.Argument(name: "code_sign_identity", value: codeSignIdentity),
                                                                                                          RubyCommand.Argument(name: "profile_name", value: profileName),
                                                                                                          RubyCommand.Argument(name: "profile_uuid", value: profileUuid),
                                                                                                          RubyCommand.Argument(name: "bundle_identifier", value: bundleIdentifier)])
    _ = runner.executeCommand(command)
}

/**
 This action backs up your file to "[path].back"

 - parameter path: Path to the file you want to backup
 */
public func backupFile(path: String) {
    let command = RubyCommand(commandID: "", methodName: "backup_file", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
    _ = runner.executeCommand(command)
}

/**
 Save your [zipped] xcarchive elsewhere from default path

 - parameters:
   - xcarchive: Path to your xcarchive file. Optional if you use the `xcodebuild` action
   - destination: Where your archive will be placed
   - zip: Enable compression of the archive
   - zipFilename: Filename of the compressed archive. Will be appended by `.xcarchive.zip`. Default value is the output xcarchive filename
   - versioned: Create a versioned (date and app version) subfolder where to put the archive
 */
public func backupXcarchive(xcarchive: String,
                            destination: String,
                            zip: Bool = true,
                            zipFilename: String? = nil,
                            versioned: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "backup_xcarchive", className: nil, args: [RubyCommand.Argument(name: "xcarchive", value: xcarchive),
                                                                                                    RubyCommand.Argument(name: "destination", value: destination),
                                                                                                    RubyCommand.Argument(name: "zip", value: zip),
                                                                                                    RubyCommand.Argument(name: "zip_filename", value: zipFilename),
                                                                                                    RubyCommand.Argument(name: "versioned", value: versioned)])
    _ = runner.executeCommand(command)
}

/**
 Automatically add a badge to your app icon

 - parameters:
   - dark: Adds a dark flavored badge ontop of your icon
   - custom: Add your custom overlay/badge image
   - noBadge: Hides the beta badge
   - shield: Add a shield to your app icon from shields.io
   - alpha: Adds and alpha badge instead of the default beta one
   - path: Sets the root path to look for AppIcons
   - shieldIoTimeout: Set custom duration for the timeout of the shields.io request in seconds
   - glob: Glob pattern for finding image files
   - alphaChannel: Keeps/adds an alpha channel to the icon (useful for android icons)
   - shieldGravity: Position of shield on icon. Default: North - Choices include: NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast
   - shieldNoResize: Shield image will no longer be resized to aspect fill the full icon. Instead it will only be shrunk to not exceed the icon graphic

 Please use the [badge plugin](https://github.com/HazAT/fastlane-plugin-badge) instead.
 This action will add a light/dark badge onto your app icon.
 You can also provide your custom badge/overlay or add a shield for more customization.
 More info: [https://github.com/HazAT/badge](https://github.com/HazAT/badge)
 **Note**: If you want to reset the badge back to default, you can use `sh 'git checkout -- <path>/Assets.xcassets/'`.
 */
public func badge(dark: Any? = nil,
                  custom: String? = nil,
                  noBadge: Any? = nil,
                  shield: String? = nil,
                  alpha: Any? = nil,
                  path: String = ".",
                  shieldIoTimeout: Any? = nil,
                  glob: String? = nil,
                  alphaChannel: Any? = nil,
                  shieldGravity: String? = nil,
                  shieldNoResize: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "badge", className: nil, args: [RubyCommand.Argument(name: "dark", value: dark),
                                                                                         RubyCommand.Argument(name: "custom", value: custom),
                                                                                         RubyCommand.Argument(name: "no_badge", value: noBadge),
                                                                                         RubyCommand.Argument(name: "shield", value: shield),
                                                                                         RubyCommand.Argument(name: "alpha", value: alpha),
                                                                                         RubyCommand.Argument(name: "path", value: path),
                                                                                         RubyCommand.Argument(name: "shield_io_timeout", value: shieldIoTimeout),
                                                                                         RubyCommand.Argument(name: "glob", value: glob),
                                                                                         RubyCommand.Argument(name: "alpha_channel", value: alphaChannel),
                                                                                         RubyCommand.Argument(name: "shield_gravity", value: shieldGravity),
                                                                                         RubyCommand.Argument(name: "shield_no_resize", value: shieldNoResize)])
    _ = runner.executeCommand(command)
}

/**
 Generate and upload an ipa file to appetize.io

 - parameters:
   - xcodebuild: Parameters that are passed to the xcodebuild action
   - scheme: The scheme to build. Can also be passed using the `xcodebuild` parameter
   - apiToken: Appetize.io API Token
   - publicKey: If not provided, a new app will be created. If provided, the existing build will be overwritten
   - note: Notes you wish to add to the uploaded app
   - timeout: The number of seconds to wait until automatically ending the session due to user inactivity. Must be 30, 60, 90, 120, 180, 300, 600, 1800, 3600 or 7200. Default is 120

 This should be called from danger.
 More information in the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md).
 */
public func buildAndUploadToAppetize(xcodebuild: [String: Any] = [:],
                                     scheme: String? = nil,
                                     apiToken: String,
                                     publicKey: String? = nil,
                                     note: String? = nil,
                                     timeout: Int? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "build_and_upload_to_appetize", className: nil, args: [RubyCommand.Argument(name: "xcodebuild", value: xcodebuild),
                                                                                                                RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                                RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                                RubyCommand.Argument(name: "public_key", value: publicKey),
                                                                                                                RubyCommand.Argument(name: "note", value: note),
                                                                                                                RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `gradle` action

 - parameters:
   - task: The gradle task you want to execute, e.g. `assemble`, `bundle` or `test`. For tasks such as `assembleMyFlavorRelease` you should use gradle(task: 'assemble', flavor: 'Myflavor', build_type: 'Release')
   - flavor: The flavor that you want the task for, e.g. `MyFlavor`. If you are running the `assemble` task in a multi-flavor project, and you rely on Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] then you must specify a flavor here or else this value will be undefined
   - buildType: The build type that you want the task for, e.g. `Release`. Useful for some tasks such as `assemble`
   - tasks: The multiple gradle tasks that you want to execute, e.g. `[assembleDebug, bundleDebug]`
   - flags: All parameter flags you want to pass to the gradle command, e.g. `--exitcode --xml file.xml`
   - projectDir: The root directory of the gradle project
   - gradlePath: The path to your `gradlew`. If you specify a relative path, it is assumed to be relative to the `project_dir`
   - properties: Gradle properties to be exposed to the gradle script
   - systemProperties: Gradle system properties to be exposed to the gradle script
   - serial: Android serial, which device should be used for this command
   - printCommand: Control whether the generated Gradle command is printed as output before running it (true/false)
   - printCommandOutput: Control whether the output produced by given Gradle command is printed while running (true/false)

 - returns: The output of running the gradle task

 Run `./gradlew tasks` to get a list of all available gradle tasks for your project
 */
public func buildAndroidApp(task: String? = nil,
                            flavor: String? = nil,
                            buildType: String? = nil,
                            tasks: [String]? = nil,
                            flags: String? = nil,
                            projectDir: String = ".",
                            gradlePath: String? = nil,
                            properties: Any? = nil,
                            systemProperties: Any? = nil,
                            serial: String = "",
                            printCommand: Bool = true,
                            printCommandOutput: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "build_android_app", className: nil, args: [RubyCommand.Argument(name: "task", value: task),
                                                                                                     RubyCommand.Argument(name: "flavor", value: flavor),
                                                                                                     RubyCommand.Argument(name: "build_type", value: buildType),
                                                                                                     RubyCommand.Argument(name: "tasks", value: tasks),
                                                                                                     RubyCommand.Argument(name: "flags", value: flags),
                                                                                                     RubyCommand.Argument(name: "project_dir", value: projectDir),
                                                                                                     RubyCommand.Argument(name: "gradle_path", value: gradlePath),
                                                                                                     RubyCommand.Argument(name: "properties", value: properties),
                                                                                                     RubyCommand.Argument(name: "system_properties", value: systemProperties),
                                                                                                     RubyCommand.Argument(name: "serial", value: serial),
                                                                                                     RubyCommand.Argument(name: "print_command", value: printCommand),
                                                                                                     RubyCommand.Argument(name: "print_command_output", value: printCommandOutput)])
    _ = runner.executeCommand(command)
}

/**
 Easily build and sign your app (via _gym_)

 - parameters:
   - workspace: Path to the workspace file
   - project: Path to the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - clean: Should the project be cleaned before building it?
   - outputDirectory: The directory in which the ipa file should be stored in
   - outputName: The name of the resulting ipa file
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - silent: Hide all information that's not necessary while building
   - codesigningIdentity: The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'
   - skipPackageIpa: Should we skip packaging the ipa?
   - skipPackagePkg: Should we skip packaging the pkg?
   - includeSymbols: Should the ipa file include symbols?
   - includeBitcode: Should the ipa file include bitcode?
   - exportMethod: Method used to export the archive. Valid values are: app-store, validation, ad-hoc, package, enterprise, development, developer-id and mac-application
   - exportOptions: Path to an export options plist or a hash with export options. Use 'xcodebuild -help' to print the full set of available options
   - exportXcargs: Pass additional arguments to xcodebuild for the package phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - skipBuildArchive: Export ipa from previously built xcarchive. Uses archive_path as source
   - skipArchive: After building, don't archive, effectively not including -archivePath param
   - skipCodesigning: Build without codesigning
   - catalystPlatform: Platform to build when using a Catalyst enabled app. Valid values are: ios, macos
   - installerCertName: Full name of 3rd Party Mac Developer Installer or Developer ID Installer certificate. Example: `3rd Party Mac Developer Installer: Your Company (ABC1234XWYZ)`
   - buildPath: The directory in which the archive should be stored in
   - archivePath: The path to the created archive
   - derivedDataPath: The directory where built products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - resultBundlePath: Path to the result bundle directory to create. Ignored if `result_bundle` if false
   - buildlogPath: The directory where to store the build log
   - sdk: The SDK that should be used for building the application
   - toolchain: The toolchain that should be used for building the application (e.g. com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a)
   - destination: Use a custom destination for building the app
   - exportTeamId: Optional: Sometimes you need to specify a team id when exporting the ipa file
   - xcargs: Pass additional arguments to xcodebuild for the build phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - disableXcpretty: Disable xcpretty formatting of build output
   - xcprettyTestFormat: Use the test (RSpec style) format for build output
   - xcprettyFormatter: A custom xcpretty formatter to use
   - xcprettyReportJunit: Have xcpretty create a JUnit-style XML report at the provided path
   - xcprettyReportHtml: Have xcpretty create a simple HTML report at the provided path
   - xcprettyReportJson: Have xcpretty create a JSON compilation database at the provided path
   - analyzeBuildTime: Analyze the project build time and store the output in 'culprits.txt' file
   - xcprettyUtf: Have xcpretty use unicode encoding when reporting builds
   - skipProfileDetection: Do not try to build a profile mapping from the xcodeproj. Match or a manually provided mapping should be used
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - useSystemScm: Lets xcodebuild use system's scm configuration

 - returns: The absolute path to the generated ipa file

 More information: https://fastlane.tools/gym
 */
public func buildApp(workspace: String? = nil,
                     project: String? = nil,
                     scheme: String? = nil,
                     clean: Bool = false,
                     outputDirectory: String = ".",
                     outputName: String? = nil,
                     configuration: String? = nil,
                     silent: Bool = false,
                     codesigningIdentity: String? = nil,
                     skipPackageIpa: Bool = false,
                     skipPackagePkg: Bool = false,
                     includeSymbols: Bool? = nil,
                     includeBitcode: Bool? = nil,
                     exportMethod: String? = nil,
                     exportOptions: [String: Any]? = nil,
                     exportXcargs: String? = nil,
                     skipBuildArchive: Bool? = nil,
                     skipArchive: Bool? = nil,
                     skipCodesigning: Bool? = nil,
                     catalystPlatform: String? = nil,
                     installerCertName: String? = nil,
                     buildPath: String? = nil,
                     archivePath: String? = nil,
                     derivedDataPath: String? = nil,
                     resultBundle: Bool = false,
                     resultBundlePath: String? = nil,
                     buildlogPath: String = "~/Library/Logs/gym",
                     sdk: String? = nil,
                     toolchain: String? = nil,
                     destination: String? = nil,
                     exportTeamId: String? = nil,
                     xcargs: String? = nil,
                     xcconfig: String? = nil,
                     suppressXcodeOutput: Bool? = nil,
                     disableXcpretty: Bool? = nil,
                     xcprettyTestFormat: Bool? = nil,
                     xcprettyFormatter: String? = nil,
                     xcprettyReportJunit: String? = nil,
                     xcprettyReportHtml: String? = nil,
                     xcprettyReportJson: String? = nil,
                     analyzeBuildTime: Bool? = nil,
                     xcprettyUtf: Bool? = nil,
                     skipProfileDetection: Bool = false,
                     clonedSourcePackagesPath: String? = nil,
                     skipPackageDependenciesResolution: Bool = false,
                     disablePackageAutomaticUpdates: Bool = false,
                     useSystemScm: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "build_app", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                             RubyCommand.Argument(name: "project", value: project),
                                                                                             RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                             RubyCommand.Argument(name: "clean", value: clean),
                                                                                             RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                             RubyCommand.Argument(name: "output_name", value: outputName),
                                                                                             RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                             RubyCommand.Argument(name: "silent", value: silent),
                                                                                             RubyCommand.Argument(name: "codesigning_identity", value: codesigningIdentity),
                                                                                             RubyCommand.Argument(name: "skip_package_ipa", value: skipPackageIpa),
                                                                                             RubyCommand.Argument(name: "skip_package_pkg", value: skipPackagePkg),
                                                                                             RubyCommand.Argument(name: "include_symbols", value: includeSymbols),
                                                                                             RubyCommand.Argument(name: "include_bitcode", value: includeBitcode),
                                                                                             RubyCommand.Argument(name: "export_method", value: exportMethod),
                                                                                             RubyCommand.Argument(name: "export_options", value: exportOptions),
                                                                                             RubyCommand.Argument(name: "export_xcargs", value: exportXcargs),
                                                                                             RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive),
                                                                                             RubyCommand.Argument(name: "skip_archive", value: skipArchive),
                                                                                             RubyCommand.Argument(name: "skip_codesigning", value: skipCodesigning),
                                                                                             RubyCommand.Argument(name: "catalyst_platform", value: catalystPlatform),
                                                                                             RubyCommand.Argument(name: "installer_cert_name", value: installerCertName),
                                                                                             RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                             RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                             RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                             RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                             RubyCommand.Argument(name: "result_bundle_path", value: resultBundlePath),
                                                                                             RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                             RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                             RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                             RubyCommand.Argument(name: "destination", value: destination),
                                                                                             RubyCommand.Argument(name: "export_team_id", value: exportTeamId),
                                                                                             RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                             RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                             RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                             RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                             RubyCommand.Argument(name: "xcpretty_test_format", value: xcprettyTestFormat),
                                                                                             RubyCommand.Argument(name: "xcpretty_formatter", value: xcprettyFormatter),
                                                                                             RubyCommand.Argument(name: "xcpretty_report_junit", value: xcprettyReportJunit),
                                                                                             RubyCommand.Argument(name: "xcpretty_report_html", value: xcprettyReportHtml),
                                                                                             RubyCommand.Argument(name: "xcpretty_report_json", value: xcprettyReportJson),
                                                                                             RubyCommand.Argument(name: "analyze_build_time", value: analyzeBuildTime),
                                                                                             RubyCommand.Argument(name: "xcpretty_utf", value: xcprettyUtf),
                                                                                             RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection),
                                                                                             RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                             RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                             RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                             RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `build_app` action but only for iOS

 - parameters:
   - workspace: Path to the workspace file
   - project: Path to the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - clean: Should the project be cleaned before building it?
   - outputDirectory: The directory in which the ipa file should be stored in
   - outputName: The name of the resulting ipa file
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - silent: Hide all information that's not necessary while building
   - codesigningIdentity: The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'
   - skipPackageIpa: Should we skip packaging the ipa?
   - includeSymbols: Should the ipa file include symbols?
   - includeBitcode: Should the ipa file include bitcode?
   - exportMethod: Method used to export the archive. Valid values are: app-store, validation, ad-hoc, package, enterprise, development, developer-id and mac-application
   - exportOptions: Path to an export options plist or a hash with export options. Use 'xcodebuild -help' to print the full set of available options
   - exportXcargs: Pass additional arguments to xcodebuild for the package phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - skipBuildArchive: Export ipa from previously built xcarchive. Uses archive_path as source
   - skipArchive: After building, don't archive, effectively not including -archivePath param
   - skipCodesigning: Build without codesigning
   - buildPath: The directory in which the archive should be stored in
   - archivePath: The path to the created archive
   - derivedDataPath: The directory where built products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - resultBundlePath: Path to the result bundle directory to create. Ignored if `result_bundle` if false
   - buildlogPath: The directory where to store the build log
   - sdk: The SDK that should be used for building the application
   - toolchain: The toolchain that should be used for building the application (e.g. com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a)
   - destination: Use a custom destination for building the app
   - exportTeamId: Optional: Sometimes you need to specify a team id when exporting the ipa file
   - xcargs: Pass additional arguments to xcodebuild for the build phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - disableXcpretty: Disable xcpretty formatting of build output
   - xcprettyTestFormat: Use the test (RSpec style) format for build output
   - xcprettyFormatter: A custom xcpretty formatter to use
   - xcprettyReportJunit: Have xcpretty create a JUnit-style XML report at the provided path
   - xcprettyReportHtml: Have xcpretty create a simple HTML report at the provided path
   - xcprettyReportJson: Have xcpretty create a JSON compilation database at the provided path
   - analyzeBuildTime: Analyze the project build time and store the output in 'culprits.txt' file
   - xcprettyUtf: Have xcpretty use unicode encoding when reporting builds
   - skipProfileDetection: Do not try to build a profile mapping from the xcodeproj. Match or a manually provided mapping should be used
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - useSystemScm: Lets xcodebuild use system's scm configuration

 - returns: The absolute path to the generated ipa file

 More information: https://fastlane.tools/gym
 */
public func buildIosApp(workspace: String? = nil,
                        project: String? = nil,
                        scheme: String? = nil,
                        clean: Bool = false,
                        outputDirectory: String = ".",
                        outputName: String? = nil,
                        configuration: String? = nil,
                        silent: Bool = false,
                        codesigningIdentity: String? = nil,
                        skipPackageIpa: Bool = false,
                        includeSymbols: Bool? = nil,
                        includeBitcode: Bool? = nil,
                        exportMethod: String? = nil,
                        exportOptions: [String: Any]? = nil,
                        exportXcargs: String? = nil,
                        skipBuildArchive: Bool? = nil,
                        skipArchive: Bool? = nil,
                        skipCodesigning: Bool? = nil,
                        buildPath: String? = nil,
                        archivePath: String? = nil,
                        derivedDataPath: String? = nil,
                        resultBundle: Bool = false,
                        resultBundlePath: String? = nil,
                        buildlogPath: String = "~/Library/Logs/gym",
                        sdk: String? = nil,
                        toolchain: String? = nil,
                        destination: String? = nil,
                        exportTeamId: String? = nil,
                        xcargs: String? = nil,
                        xcconfig: String? = nil,
                        suppressXcodeOutput: Bool? = nil,
                        disableXcpretty: Bool? = nil,
                        xcprettyTestFormat: Bool? = nil,
                        xcprettyFormatter: String? = nil,
                        xcprettyReportJunit: String? = nil,
                        xcprettyReportHtml: String? = nil,
                        xcprettyReportJson: String? = nil,
                        analyzeBuildTime: Bool? = nil,
                        xcprettyUtf: Bool? = nil,
                        skipProfileDetection: Bool = false,
                        clonedSourcePackagesPath: String? = nil,
                        skipPackageDependenciesResolution: Bool = false,
                        disablePackageAutomaticUpdates: Bool = false,
                        useSystemScm: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "build_ios_app", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                                 RubyCommand.Argument(name: "project", value: project),
                                                                                                 RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                 RubyCommand.Argument(name: "clean", value: clean),
                                                                                                 RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                 RubyCommand.Argument(name: "output_name", value: outputName),
                                                                                                 RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                                 RubyCommand.Argument(name: "silent", value: silent),
                                                                                                 RubyCommand.Argument(name: "codesigning_identity", value: codesigningIdentity),
                                                                                                 RubyCommand.Argument(name: "skip_package_ipa", value: skipPackageIpa),
                                                                                                 RubyCommand.Argument(name: "include_symbols", value: includeSymbols),
                                                                                                 RubyCommand.Argument(name: "include_bitcode", value: includeBitcode),
                                                                                                 RubyCommand.Argument(name: "export_method", value: exportMethod),
                                                                                                 RubyCommand.Argument(name: "export_options", value: exportOptions),
                                                                                                 RubyCommand.Argument(name: "export_xcargs", value: exportXcargs),
                                                                                                 RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive),
                                                                                                 RubyCommand.Argument(name: "skip_archive", value: skipArchive),
                                                                                                 RubyCommand.Argument(name: "skip_codesigning", value: skipCodesigning),
                                                                                                 RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                                 RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                                 RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                                 RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                                 RubyCommand.Argument(name: "result_bundle_path", value: resultBundlePath),
                                                                                                 RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                                 RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                                 RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                                 RubyCommand.Argument(name: "destination", value: destination),
                                                                                                 RubyCommand.Argument(name: "export_team_id", value: exportTeamId),
                                                                                                 RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                                 RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                                 RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                                 RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                                 RubyCommand.Argument(name: "xcpretty_test_format", value: xcprettyTestFormat),
                                                                                                 RubyCommand.Argument(name: "xcpretty_formatter", value: xcprettyFormatter),
                                                                                                 RubyCommand.Argument(name: "xcpretty_report_junit", value: xcprettyReportJunit),
                                                                                                 RubyCommand.Argument(name: "xcpretty_report_html", value: xcprettyReportHtml),
                                                                                                 RubyCommand.Argument(name: "xcpretty_report_json", value: xcprettyReportJson),
                                                                                                 RubyCommand.Argument(name: "analyze_build_time", value: analyzeBuildTime),
                                                                                                 RubyCommand.Argument(name: "xcpretty_utf", value: xcprettyUtf),
                                                                                                 RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection),
                                                                                                 RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                                 RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                                 RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                                 RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `build_app` action but only for macOS

 - parameters:
   - workspace: Path to the workspace file
   - project: Path to the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - clean: Should the project be cleaned before building it?
   - outputDirectory: The directory in which the ipa file should be stored in
   - outputName: The name of the resulting ipa file
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - silent: Hide all information that's not necessary while building
   - codesigningIdentity: The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'
   - skipPackagePkg: Should we skip packaging the pkg?
   - includeSymbols: Should the ipa file include symbols?
   - includeBitcode: Should the ipa file include bitcode?
   - exportMethod: Method used to export the archive. Valid values are: app-store, validation, ad-hoc, package, enterprise, development, developer-id and mac-application
   - exportOptions: Path to an export options plist or a hash with export options. Use 'xcodebuild -help' to print the full set of available options
   - exportXcargs: Pass additional arguments to xcodebuild for the package phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - skipBuildArchive: Export ipa from previously built xcarchive. Uses archive_path as source
   - skipArchive: After building, don't archive, effectively not including -archivePath param
   - skipCodesigning: Build without codesigning
   - installerCertName: Full name of 3rd Party Mac Developer Installer or Developer ID Installer certificate. Example: `3rd Party Mac Developer Installer: Your Company (ABC1234XWYZ)`
   - buildPath: The directory in which the archive should be stored in
   - archivePath: The path to the created archive
   - derivedDataPath: The directory where built products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - resultBundlePath: Path to the result bundle directory to create. Ignored if `result_bundle` if false
   - buildlogPath: The directory where to store the build log
   - sdk: The SDK that should be used for building the application
   - toolchain: The toolchain that should be used for building the application (e.g. com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a)
   - destination: Use a custom destination for building the app
   - exportTeamId: Optional: Sometimes you need to specify a team id when exporting the ipa file
   - xcargs: Pass additional arguments to xcodebuild for the build phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - disableXcpretty: Disable xcpretty formatting of build output
   - xcprettyTestFormat: Use the test (RSpec style) format for build output
   - xcprettyFormatter: A custom xcpretty formatter to use
   - xcprettyReportJunit: Have xcpretty create a JUnit-style XML report at the provided path
   - xcprettyReportHtml: Have xcpretty create a simple HTML report at the provided path
   - xcprettyReportJson: Have xcpretty create a JSON compilation database at the provided path
   - analyzeBuildTime: Analyze the project build time and store the output in 'culprits.txt' file
   - xcprettyUtf: Have xcpretty use unicode encoding when reporting builds
   - skipProfileDetection: Do not try to build a profile mapping from the xcodeproj. Match or a manually provided mapping should be used
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - useSystemScm: Lets xcodebuild use system's scm configuration

 - returns: The absolute path to the generated ipa file

 More information: https://fastlane.tools/gym
 */
public func buildMacApp(workspace: String? = nil,
                        project: String? = nil,
                        scheme: String? = nil,
                        clean: Bool = false,
                        outputDirectory: String = ".",
                        outputName: String? = nil,
                        configuration: String? = nil,
                        silent: Bool = false,
                        codesigningIdentity: String? = nil,
                        skipPackagePkg: Bool = false,
                        includeSymbols: Bool? = nil,
                        includeBitcode: Bool? = nil,
                        exportMethod: String? = nil,
                        exportOptions: [String: Any]? = nil,
                        exportXcargs: String? = nil,
                        skipBuildArchive: Bool? = nil,
                        skipArchive: Bool? = nil,
                        skipCodesigning: Bool? = nil,
                        installerCertName: String? = nil,
                        buildPath: String? = nil,
                        archivePath: String? = nil,
                        derivedDataPath: String? = nil,
                        resultBundle: Bool = false,
                        resultBundlePath: String? = nil,
                        buildlogPath: String = "~/Library/Logs/gym",
                        sdk: String? = nil,
                        toolchain: String? = nil,
                        destination: String? = nil,
                        exportTeamId: String? = nil,
                        xcargs: String? = nil,
                        xcconfig: String? = nil,
                        suppressXcodeOutput: Bool? = nil,
                        disableXcpretty: Bool? = nil,
                        xcprettyTestFormat: Bool? = nil,
                        xcprettyFormatter: String? = nil,
                        xcprettyReportJunit: String? = nil,
                        xcprettyReportHtml: String? = nil,
                        xcprettyReportJson: String? = nil,
                        analyzeBuildTime: Bool? = nil,
                        xcprettyUtf: Bool? = nil,
                        skipProfileDetection: Bool = false,
                        clonedSourcePackagesPath: String? = nil,
                        skipPackageDependenciesResolution: Bool = false,
                        disablePackageAutomaticUpdates: Bool = false,
                        useSystemScm: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "build_mac_app", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                                 RubyCommand.Argument(name: "project", value: project),
                                                                                                 RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                 RubyCommand.Argument(name: "clean", value: clean),
                                                                                                 RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                 RubyCommand.Argument(name: "output_name", value: outputName),
                                                                                                 RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                                 RubyCommand.Argument(name: "silent", value: silent),
                                                                                                 RubyCommand.Argument(name: "codesigning_identity", value: codesigningIdentity),
                                                                                                 RubyCommand.Argument(name: "skip_package_pkg", value: skipPackagePkg),
                                                                                                 RubyCommand.Argument(name: "include_symbols", value: includeSymbols),
                                                                                                 RubyCommand.Argument(name: "include_bitcode", value: includeBitcode),
                                                                                                 RubyCommand.Argument(name: "export_method", value: exportMethod),
                                                                                                 RubyCommand.Argument(name: "export_options", value: exportOptions),
                                                                                                 RubyCommand.Argument(name: "export_xcargs", value: exportXcargs),
                                                                                                 RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive),
                                                                                                 RubyCommand.Argument(name: "skip_archive", value: skipArchive),
                                                                                                 RubyCommand.Argument(name: "skip_codesigning", value: skipCodesigning),
                                                                                                 RubyCommand.Argument(name: "installer_cert_name", value: installerCertName),
                                                                                                 RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                                 RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                                 RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                                 RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                                 RubyCommand.Argument(name: "result_bundle_path", value: resultBundlePath),
                                                                                                 RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                                 RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                                 RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                                 RubyCommand.Argument(name: "destination", value: destination),
                                                                                                 RubyCommand.Argument(name: "export_team_id", value: exportTeamId),
                                                                                                 RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                                 RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                                 RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                                 RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                                 RubyCommand.Argument(name: "xcpretty_test_format", value: xcprettyTestFormat),
                                                                                                 RubyCommand.Argument(name: "xcpretty_formatter", value: xcprettyFormatter),
                                                                                                 RubyCommand.Argument(name: "xcpretty_report_junit", value: xcprettyReportJunit),
                                                                                                 RubyCommand.Argument(name: "xcpretty_report_html", value: xcprettyReportHtml),
                                                                                                 RubyCommand.Argument(name: "xcpretty_report_json", value: xcprettyReportJson),
                                                                                                 RubyCommand.Argument(name: "analyze_build_time", value: analyzeBuildTime),
                                                                                                 RubyCommand.Argument(name: "xcpretty_utf", value: xcprettyUtf),
                                                                                                 RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection),
                                                                                                 RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                                 RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                                 RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                                 RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 This action runs `bundle install` (if available)

 - parameters:
   - binstubs: Generate bin stubs for bundled gems to ./bin
   - clean: Run bundle clean automatically after install
   - fullIndex: Use the rubygems modern index instead of the API endpoint
   - gemfile: Use the specified gemfile instead of Gemfile
   - jobs: Install gems using parallel workers
   - local: Do not attempt to fetch gems remotely and use the gem cache instead
   - deployment: Install using defaults tuned for deployment and CI environments
   - noCache: Don't update the existing gem cache
   - noPrune: Don't remove stale gems from the cache
   - path: Specify a different path than the system default ($BUNDLE_PATH or $GEM_HOME). Bundler will remember this value for future installs on this machine
   - system: Install to the system location ($BUNDLE_PATH or $GEM_HOME) even if the bundle was previously installed somewhere else for this application
   - quiet: Only output warnings and errors
   - retry: Retry network and git requests that have failed
   - shebang: Specify a different shebang executable name than the default (usually 'ruby')
   - standalone: Make a bundle that can work without the Bundler runtime
   - trustPolicy: Sets level of security when dealing with signed gems. Accepts `LowSecurity`, `MediumSecurity` and `HighSecurity` as values
   - without: Exclude gems that are part of the specified named group
   - with: Include gems that are part of the specified named group
 */
public func bundleInstall(binstubs: String? = nil,
                          clean: Bool = false,
                          fullIndex: Bool = false,
                          gemfile: String? = nil,
                          jobs: Bool? = nil,
                          local: Bool = false,
                          deployment: Bool = false,
                          noCache: Bool = false,
                          noPrune: Bool = false,
                          path: String? = nil,
                          system: Bool = false,
                          quiet: Bool = false,
                          retry: Bool? = nil,
                          shebang: String? = nil,
                          standalone: String? = nil,
                          trustPolicy: String? = nil,
                          without: String? = nil,
                          with: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "bundle_install", className: nil, args: [RubyCommand.Argument(name: "binstubs", value: binstubs),
                                                                                                  RubyCommand.Argument(name: "clean", value: clean),
                                                                                                  RubyCommand.Argument(name: "full_index", value: fullIndex),
                                                                                                  RubyCommand.Argument(name: "gemfile", value: gemfile),
                                                                                                  RubyCommand.Argument(name: "jobs", value: jobs),
                                                                                                  RubyCommand.Argument(name: "local", value: local),
                                                                                                  RubyCommand.Argument(name: "deployment", value: deployment),
                                                                                                  RubyCommand.Argument(name: "no_cache", value: noCache),
                                                                                                  RubyCommand.Argument(name: "no_prune", value: noPrune),
                                                                                                  RubyCommand.Argument(name: "path", value: path),
                                                                                                  RubyCommand.Argument(name: "system", value: system),
                                                                                                  RubyCommand.Argument(name: "quiet", value: quiet),
                                                                                                  RubyCommand.Argument(name: "retry", value: retry),
                                                                                                  RubyCommand.Argument(name: "shebang", value: shebang),
                                                                                                  RubyCommand.Argument(name: "standalone", value: standalone),
                                                                                                  RubyCommand.Argument(name: "trust_policy", value: trustPolicy),
                                                                                                  RubyCommand.Argument(name: "without", value: without),
                                                                                                  RubyCommand.Argument(name: "with", value: with)])
    _ = runner.executeCommand(command)
}

/**
 Automated localized screenshots of your Android app (via _screengrab_)

 - parameters:
   - androidHome: Path to the root of your Android SDK installation, e.g. ~/tools/android-sdk-macosx
   - buildToolsVersion: The Android build tools version to use, e.g. '23.0.2'
   - locales: A list of locales which should be used
   - clearPreviousScreenshots: Enabling this option will automatically clear previously generated screenshots before running screengrab
   - outputDirectory: The directory where to store the screenshots
   - skipOpenSummary: Don't open the summary after running _screengrab_
   - appPackageName: The package name of the app under test (e.g. com.yourcompany.yourapp)
   - testsPackageName: The package name of the tests bundle (e.g. com.yourcompany.yourapp.test)
   - useTestsInPackages: Only run tests in these Java packages
   - useTestsInClasses: Only run tests in these Java classes
   - launchArguments: Additional launch arguments
   - testInstrumentationRunner: The fully qualified class name of your test instrumentation runner
   - endingLocale: Return the device to this locale after running tests
   - useAdbRoot: Restarts the adb daemon using `adb root` to allow access to screenshots directories on device. Use if getting 'Permission denied' errors
   - appApkPath: The path to the APK for the app under test
   - testsApkPath: The path to the APK for the the tests bundle
   - specificDevice: Use the device or emulator with the given serial number or qualifier
   - deviceType: Type of device used for screenshots. Matches Google Play Types (phone, sevenInch, tenInch, tv, wear)
   - exitOnTestFailure: Whether or not to exit Screengrab on test failure. Exiting on failure will not copy sceenshots to local machine nor open sceenshots summary
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - useTimestampSuffix: Add timestamp suffix to screenshot filename
   - adbHost: Configure the host used by adb to connect, allows running on remote devices farm
 */
public func captureAndroidScreenshots(androidHome: String? = nil,
                                      buildToolsVersion: String? = nil,
                                      locales: [String] = ["en-US"],
                                      clearPreviousScreenshots: Bool = false,
                                      outputDirectory: String = "fastlane/metadata/android",
                                      skipOpenSummary: Bool = false,
                                      appPackageName: String,
                                      testsPackageName: String? = nil,
                                      useTestsInPackages: [String]? = nil,
                                      useTestsInClasses: [String]? = nil,
                                      launchArguments: [String]? = nil,
                                      testInstrumentationRunner: String = "androidx.test.runner.AndroidJUnitRunner",
                                      endingLocale: String = "en-US",
                                      useAdbRoot: Bool = false,
                                      appApkPath: String? = nil,
                                      testsApkPath: String? = nil,
                                      specificDevice: String? = nil,
                                      deviceType: String = "phone",
                                      exitOnTestFailure: Bool = true,
                                      reinstallApp: Bool = false,
                                      useTimestampSuffix: Bool = true,
                                      adbHost: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "capture_android_screenshots", className: nil, args: [RubyCommand.Argument(name: "android_home", value: androidHome),
                                                                                                               RubyCommand.Argument(name: "build_tools_version", value: buildToolsVersion),
                                                                                                               RubyCommand.Argument(name: "locales", value: locales),
                                                                                                               RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots),
                                                                                                               RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                               RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary),
                                                                                                               RubyCommand.Argument(name: "app_package_name", value: appPackageName),
                                                                                                               RubyCommand.Argument(name: "tests_package_name", value: testsPackageName),
                                                                                                               RubyCommand.Argument(name: "use_tests_in_packages", value: useTestsInPackages),
                                                                                                               RubyCommand.Argument(name: "use_tests_in_classes", value: useTestsInClasses),
                                                                                                               RubyCommand.Argument(name: "launch_arguments", value: launchArguments),
                                                                                                               RubyCommand.Argument(name: "test_instrumentation_runner", value: testInstrumentationRunner),
                                                                                                               RubyCommand.Argument(name: "ending_locale", value: endingLocale),
                                                                                                               RubyCommand.Argument(name: "use_adb_root", value: useAdbRoot),
                                                                                                               RubyCommand.Argument(name: "app_apk_path", value: appApkPath),
                                                                                                               RubyCommand.Argument(name: "tests_apk_path", value: testsApkPath),
                                                                                                               RubyCommand.Argument(name: "specific_device", value: specificDevice),
                                                                                                               RubyCommand.Argument(name: "device_type", value: deviceType),
                                                                                                               RubyCommand.Argument(name: "exit_on_test_failure", value: exitOnTestFailure),
                                                                                                               RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                                               RubyCommand.Argument(name: "use_timestamp_suffix", value: useTimestampSuffix),
                                                                                                               RubyCommand.Argument(name: "adb_host", value: adbHost)])
    _ = runner.executeCommand(command)
}

/**
 Generate new localized screenshots on multiple devices (via _snapshot_)

 - parameters:
   - workspace: Path the workspace file
   - project: Path the project file
   - xcargs: Pass additional arguments to xcodebuild for the test phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - devices: A list of devices you want to take the screenshots from
   - languages: A list of languages which should be used
   - launchArguments: A list of launch arguments which should be used
   - outputDirectory: The directory where to store the screenshots
   - outputSimulatorLogs: If the logs generated by the app (e.g. using NSLog, perror, etc.) in the Simulator should be written to the output_directory
   - iosVersion: By default, the latest version should be used automatically. If you want to change it, do it here
   - skipOpenSummary: Don't open the HTML summary after running _snapshot_
   - skipHelperVersionCheck: Do not check for most recent SnapshotHelper code
   - clearPreviousScreenshots: Enabling this option will automatically clear previously generated screenshots before running snapshot
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - eraseSimulator: Enabling this option will automatically erase the simulator before running the application
   - headless: Enabling this option will prevent displaying the simulator window
   - overrideStatusBar: Enabling this option will automatically override the status bar to show 9:41 AM, full battery, and full reception
   - localizeSimulator: Enabling this option will configure the Simulator's system language
   - darkMode: Enabling this option will configure the Simulator to be in dark mode (false for light, true for dark)
   - appIdentifier: The bundle identifier of the app to uninstall (only needed when enabling reinstall_app)
   - addPhotos: A list of photos that should be added to the simulator before running the application
   - addVideos: A list of videos that should be added to the simulator before running the application
   - htmlTemplate: A path to screenshots.html template
   - buildlogPath: The directory where to store the build log
   - clean: Should the project be cleaned before building it?
   - testWithoutBuilding: Test without building, requires a derived data path
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - xcprettyArgs: Additional xcpretty arguments
   - sdk: The SDK that should be used for building the application
   - scheme: The scheme you want to use, this must be the scheme for the UI Tests
   - numberOfRetries: The number of times a test can fail before snapshot should stop retrying
   - stopAfterFirstError: Should snapshot stop immediately after the tests completely failed on one device?
   - derivedDataPath: The directory where build products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - testTargetName: The name of the target you want to test (if you desire to override the Target Application from Xcode)
   - namespaceLogFiles: Separate the log files per device and per language
   - concurrentSimulators: Take snapshots on multiple simulators concurrently. Note: This option is only applicable when running against Xcode 9
   - disableSlideToType: Disable the simulator from showing the 'Slide to type' prompt
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - testplan: The testplan associated with the scheme that should be used for testing
   - onlyTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to run
   - skipTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to skip
   - disableXcpretty: Disable xcpretty formatting of build
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - useSystemScm: Lets xcodebuild use system's scm configuration
 */
public func captureIosScreenshots(workspace: String? = nil,
                                  project: String? = nil,
                                  xcargs: String? = nil,
                                  xcconfig: String? = nil,
                                  devices: [String]? = nil,
                                  languages: [String] = ["en-US"],
                                  launchArguments: [String] = [""],
                                  outputDirectory: String = "screenshots",
                                  outputSimulatorLogs: Bool = false,
                                  iosVersion: String? = nil,
                                  skipOpenSummary: Bool = false,
                                  skipHelperVersionCheck: Bool = false,
                                  clearPreviousScreenshots: Bool = false,
                                  reinstallApp: Bool = false,
                                  eraseSimulator: Bool = false,
                                  headless: Bool = true,
                                  overrideStatusBar: Bool = false,
                                  localizeSimulator: Bool = false,
                                  darkMode: Bool? = nil,
                                  appIdentifier: String? = nil,
                                  addPhotos: [String]? = nil,
                                  addVideos: [String]? = nil,
                                  htmlTemplate: String? = nil,
                                  buildlogPath: String = "~/Library/Logs/snapshot",
                                  clean: Bool = false,
                                  testWithoutBuilding: Bool? = nil,
                                  configuration: String? = nil,
                                  xcprettyArgs: String? = nil,
                                  sdk: String? = nil,
                                  scheme: String? = nil,
                                  numberOfRetries: Int = 1,
                                  stopAfterFirstError: Bool = false,
                                  derivedDataPath: String? = nil,
                                  resultBundle: Bool = false,
                                  testTargetName: String? = nil,
                                  namespaceLogFiles: Any? = nil,
                                  concurrentSimulators: Bool = true,
                                  disableSlideToType: Bool = false,
                                  clonedSourcePackagesPath: String? = nil,
                                  skipPackageDependenciesResolution: Bool = false,
                                  disablePackageAutomaticUpdates: Bool = false,
                                  testplan: String? = nil,
                                  onlyTesting: Any? = nil,
                                  skipTesting: Any? = nil,
                                  disableXcpretty: Bool? = nil,
                                  suppressXcodeOutput: Bool? = nil,
                                  useSystemScm: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "capture_ios_screenshots", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                                           RubyCommand.Argument(name: "project", value: project),
                                                                                                           RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                                           RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                                           RubyCommand.Argument(name: "devices", value: devices),
                                                                                                           RubyCommand.Argument(name: "languages", value: languages),
                                                                                                           RubyCommand.Argument(name: "launch_arguments", value: launchArguments),
                                                                                                           RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                           RubyCommand.Argument(name: "output_simulator_logs", value: outputSimulatorLogs),
                                                                                                           RubyCommand.Argument(name: "ios_version", value: iosVersion),
                                                                                                           RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary),
                                                                                                           RubyCommand.Argument(name: "skip_helper_version_check", value: skipHelperVersionCheck),
                                                                                                           RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots),
                                                                                                           RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                                           RubyCommand.Argument(name: "erase_simulator", value: eraseSimulator),
                                                                                                           RubyCommand.Argument(name: "headless", value: headless),
                                                                                                           RubyCommand.Argument(name: "override_status_bar", value: overrideStatusBar),
                                                                                                           RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator),
                                                                                                           RubyCommand.Argument(name: "dark_mode", value: darkMode),
                                                                                                           RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                           RubyCommand.Argument(name: "add_photos", value: addPhotos),
                                                                                                           RubyCommand.Argument(name: "add_videos", value: addVideos),
                                                                                                           RubyCommand.Argument(name: "html_template", value: htmlTemplate),
                                                                                                           RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                                           RubyCommand.Argument(name: "clean", value: clean),
                                                                                                           RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                                           RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                                           RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs),
                                                                                                           RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                                           RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                           RubyCommand.Argument(name: "number_of_retries", value: numberOfRetries),
                                                                                                           RubyCommand.Argument(name: "stop_after_first_error", value: stopAfterFirstError),
                                                                                                           RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                                           RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                                           RubyCommand.Argument(name: "test_target_name", value: testTargetName),
                                                                                                           RubyCommand.Argument(name: "namespace_log_files", value: namespaceLogFiles),
                                                                                                           RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators),
                                                                                                           RubyCommand.Argument(name: "disable_slide_to_type", value: disableSlideToType),
                                                                                                           RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                                           RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                                           RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                                           RubyCommand.Argument(name: "testplan", value: testplan),
                                                                                                           RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                                           RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                                           RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                                           RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                                           RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `capture_ios_screenshots` action

 - parameters:
   - workspace: Path the workspace file
   - project: Path the project file
   - xcargs: Pass additional arguments to xcodebuild for the test phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - devices: A list of devices you want to take the screenshots from
   - languages: A list of languages which should be used
   - launchArguments: A list of launch arguments which should be used
   - outputDirectory: The directory where to store the screenshots
   - outputSimulatorLogs: If the logs generated by the app (e.g. using NSLog, perror, etc.) in the Simulator should be written to the output_directory
   - iosVersion: By default, the latest version should be used automatically. If you want to change it, do it here
   - skipOpenSummary: Don't open the HTML summary after running _snapshot_
   - skipHelperVersionCheck: Do not check for most recent SnapshotHelper code
   - clearPreviousScreenshots: Enabling this option will automatically clear previously generated screenshots before running snapshot
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - eraseSimulator: Enabling this option will automatically erase the simulator before running the application
   - headless: Enabling this option will prevent displaying the simulator window
   - overrideStatusBar: Enabling this option will automatically override the status bar to show 9:41 AM, full battery, and full reception
   - localizeSimulator: Enabling this option will configure the Simulator's system language
   - darkMode: Enabling this option will configure the Simulator to be in dark mode (false for light, true for dark)
   - appIdentifier: The bundle identifier of the app to uninstall (only needed when enabling reinstall_app)
   - addPhotos: A list of photos that should be added to the simulator before running the application
   - addVideos: A list of videos that should be added to the simulator before running the application
   - htmlTemplate: A path to screenshots.html template
   - buildlogPath: The directory where to store the build log
   - clean: Should the project be cleaned before building it?
   - testWithoutBuilding: Test without building, requires a derived data path
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - xcprettyArgs: Additional xcpretty arguments
   - sdk: The SDK that should be used for building the application
   - scheme: The scheme you want to use, this must be the scheme for the UI Tests
   - numberOfRetries: The number of times a test can fail before snapshot should stop retrying
   - stopAfterFirstError: Should snapshot stop immediately after the tests completely failed on one device?
   - derivedDataPath: The directory where build products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - testTargetName: The name of the target you want to test (if you desire to override the Target Application from Xcode)
   - namespaceLogFiles: Separate the log files per device and per language
   - concurrentSimulators: Take snapshots on multiple simulators concurrently. Note: This option is only applicable when running against Xcode 9
   - disableSlideToType: Disable the simulator from showing the 'Slide to type' prompt
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - testplan: The testplan associated with the scheme that should be used for testing
   - onlyTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to run
   - skipTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to skip
   - disableXcpretty: Disable xcpretty formatting of build
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - useSystemScm: Lets xcodebuild use system's scm configuration
 */
public func captureScreenshots(workspace: String? = nil,
                               project: String? = nil,
                               xcargs: String? = nil,
                               xcconfig: String? = nil,
                               devices: [String]? = nil,
                               languages: [String] = ["en-US"],
                               launchArguments: [String] = [""],
                               outputDirectory: String = "screenshots",
                               outputSimulatorLogs: Bool = false,
                               iosVersion: String? = nil,
                               skipOpenSummary: Bool = false,
                               skipHelperVersionCheck: Bool = false,
                               clearPreviousScreenshots: Bool = false,
                               reinstallApp: Bool = false,
                               eraseSimulator: Bool = false,
                               headless: Bool = true,
                               overrideStatusBar: Bool = false,
                               localizeSimulator: Bool = false,
                               darkMode: Bool? = nil,
                               appIdentifier: String? = nil,
                               addPhotos: [String]? = nil,
                               addVideos: [String]? = nil,
                               htmlTemplate: String? = nil,
                               buildlogPath: String = "~/Library/Logs/snapshot",
                               clean: Bool = false,
                               testWithoutBuilding: Bool? = nil,
                               configuration: String? = nil,
                               xcprettyArgs: String? = nil,
                               sdk: String? = nil,
                               scheme: String? = nil,
                               numberOfRetries: Int = 1,
                               stopAfterFirstError: Bool = false,
                               derivedDataPath: String? = nil,
                               resultBundle: Bool = false,
                               testTargetName: String? = nil,
                               namespaceLogFiles: Any? = nil,
                               concurrentSimulators: Bool = true,
                               disableSlideToType: Bool = false,
                               clonedSourcePackagesPath: String? = nil,
                               skipPackageDependenciesResolution: Bool = false,
                               disablePackageAutomaticUpdates: Bool = false,
                               testplan: String? = nil,
                               onlyTesting: Any? = nil,
                               skipTesting: Any? = nil,
                               disableXcpretty: Bool? = nil,
                               suppressXcodeOutput: Bool? = nil,
                               useSystemScm: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "capture_screenshots", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                                       RubyCommand.Argument(name: "project", value: project),
                                                                                                       RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                                       RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                                       RubyCommand.Argument(name: "devices", value: devices),
                                                                                                       RubyCommand.Argument(name: "languages", value: languages),
                                                                                                       RubyCommand.Argument(name: "launch_arguments", value: launchArguments),
                                                                                                       RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                       RubyCommand.Argument(name: "output_simulator_logs", value: outputSimulatorLogs),
                                                                                                       RubyCommand.Argument(name: "ios_version", value: iosVersion),
                                                                                                       RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary),
                                                                                                       RubyCommand.Argument(name: "skip_helper_version_check", value: skipHelperVersionCheck),
                                                                                                       RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots),
                                                                                                       RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                                       RubyCommand.Argument(name: "erase_simulator", value: eraseSimulator),
                                                                                                       RubyCommand.Argument(name: "headless", value: headless),
                                                                                                       RubyCommand.Argument(name: "override_status_bar", value: overrideStatusBar),
                                                                                                       RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator),
                                                                                                       RubyCommand.Argument(name: "dark_mode", value: darkMode),
                                                                                                       RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                       RubyCommand.Argument(name: "add_photos", value: addPhotos),
                                                                                                       RubyCommand.Argument(name: "add_videos", value: addVideos),
                                                                                                       RubyCommand.Argument(name: "html_template", value: htmlTemplate),
                                                                                                       RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                                       RubyCommand.Argument(name: "clean", value: clean),
                                                                                                       RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                                       RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                                       RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs),
                                                                                                       RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                                       RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                       RubyCommand.Argument(name: "number_of_retries", value: numberOfRetries),
                                                                                                       RubyCommand.Argument(name: "stop_after_first_error", value: stopAfterFirstError),
                                                                                                       RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                                       RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                                       RubyCommand.Argument(name: "test_target_name", value: testTargetName),
                                                                                                       RubyCommand.Argument(name: "namespace_log_files", value: namespaceLogFiles),
                                                                                                       RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators),
                                                                                                       RubyCommand.Argument(name: "disable_slide_to_type", value: disableSlideToType),
                                                                                                       RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                                       RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                                       RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                                       RubyCommand.Argument(name: "testplan", value: testplan),
                                                                                                       RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                                       RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                                       RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                                       RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                                       RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 Runs `carthage` for your project

 - parameters:
   - command: Carthage command (one of: build, bootstrap, update, archive)
   - dependencies: Carthage dependencies to update, build or bootstrap
   - useSsh: Use SSH for downloading GitHub repositories
   - useSubmodules: Add dependencies as Git submodules
   - useNetrc: Use .netrc for downloading frameworks
   - useBinaries: Check out dependency repositories even when prebuilt frameworks exist
   - noCheckout: When bootstrapping Carthage do not checkout
   - noBuild: When bootstrapping Carthage do not build
   - noSkipCurrent: Don't skip building the Carthage project (in addition to its dependencies)
   - derivedData: Use derived data folder at path
   - verbose: Print xcodebuild output inline
   - platform: Define which platform to build for
   - cacheBuilds: By default Carthage will rebuild a dependency regardless of whether it's the same resolved version as before. Passing the --cache-builds will cause carthage to avoid rebuilding a dependency if it can
   - frameworks: Framework name or names to archive, could be applied only along with the archive command
   - output: Output name for the archive, could be applied only along with the archive command. Use following format *.framework.zip
   - configuration: Define which build configuration to use when building
   - toolchain: Define which xcodebuild toolchain to use when building
   - projectDirectory: Define the directory containing the Carthage project
   - newResolver: Use new resolver when resolving dependency graph
   - logPath: Path to the xcode build output
   - useXcframeworks: Create xcframework bundles instead of one framework per platform (requires Xcode 12+)
   - archive: Archive built frameworks from the current project
   - executable: Path to the `carthage` executable on your machine
 */
public func carthage(command: String = "bootstrap",
                     dependencies: [String] = [],
                     useSsh: Bool? = nil,
                     useSubmodules: Bool? = nil,
                     useNetrc: Bool? = nil,
                     useBinaries: Bool? = nil,
                     noCheckout: Bool? = nil,
                     noBuild: Bool? = nil,
                     noSkipCurrent: Bool? = nil,
                     derivedData: String? = nil,
                     verbose: Bool? = nil,
                     platform: String? = nil,
                     cacheBuilds: Bool = false,
                     frameworks: [String] = [],
                     output: String? = nil,
                     configuration: String? = nil,
                     toolchain: String? = nil,
                     projectDirectory: String? = nil,
                     newResolver: Bool? = nil,
                     logPath: String? = nil,
                     useXcframeworks: Bool = false,
                     archive: Bool = false,
                     executable: String = "carthage")
{
    let command = RubyCommand(commandID: "", methodName: "carthage", className: nil, args: [RubyCommand.Argument(name: "command", value: command),
                                                                                            RubyCommand.Argument(name: "dependencies", value: dependencies),
                                                                                            RubyCommand.Argument(name: "use_ssh", value: useSsh),
                                                                                            RubyCommand.Argument(name: "use_submodules", value: useSubmodules),
                                                                                            RubyCommand.Argument(name: "use_netrc", value: useNetrc),
                                                                                            RubyCommand.Argument(name: "use_binaries", value: useBinaries),
                                                                                            RubyCommand.Argument(name: "no_checkout", value: noCheckout),
                                                                                            RubyCommand.Argument(name: "no_build", value: noBuild),
                                                                                            RubyCommand.Argument(name: "no_skip_current", value: noSkipCurrent),
                                                                                            RubyCommand.Argument(name: "derived_data", value: derivedData),
                                                                                            RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                            RubyCommand.Argument(name: "platform", value: platform),
                                                                                            RubyCommand.Argument(name: "cache_builds", value: cacheBuilds),
                                                                                            RubyCommand.Argument(name: "frameworks", value: frameworks),
                                                                                            RubyCommand.Argument(name: "output", value: output),
                                                                                            RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                            RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                            RubyCommand.Argument(name: "project_directory", value: projectDirectory),
                                                                                            RubyCommand.Argument(name: "new_resolver", value: newResolver),
                                                                                            RubyCommand.Argument(name: "log_path", value: logPath),
                                                                                            RubyCommand.Argument(name: "use_xcframeworks", value: useXcframeworks),
                                                                                            RubyCommand.Argument(name: "archive", value: archive),
                                                                                            RubyCommand.Argument(name: "executable", value: executable)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `get_certificates` action

 - parameters:
   - development: Create a development certificate instead of a distribution one
   - type: Create specific certificate type (takes precedence over :development)
   - force: Create a certificate even if an existing certificate exists
   - generateAppleCerts: Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - filename: The filename of certificate to store
   - outputPath: The path to a directory in which all certificates and private keys should be stored
   - keychainPath: Path to a custom keychain
   - keychainPassword: This might be required the first time you access certificates on a new mac. For the login/default keychain this is your macOS account password
   - skipSetPartitionList: Skips setting the partition list (which can sometimes take a long time). Setting the partition list is usually needed to prevent Xcode from prompting to allow a cert to be used for signing
   - platform: Set the provisioning profile's platform (ios, macos, tvos)

 **Important**: It is recommended to use [match](https://docs.fastlane.tools/actions/match/) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your certificates. Use _cert_ directly only if you want full control over what's going on and know more about codesigning.
 Use this action to download the latest code signing identity.
 */
public func cert(development: Bool = false,
                 type: String? = nil,
                 force: Bool = false,
                 generateAppleCerts: Bool = true,
                 apiKeyPath: String? = nil,
                 apiKey: [String: Any]? = nil,
                 username: String,
                 teamId: String? = nil,
                 teamName: String? = nil,
                 filename: String? = nil,
                 outputPath: String = ".",
                 keychainPath: String,
                 keychainPassword: String? = nil,
                 skipSetPartitionList: Bool = false,
                 platform: String = "ios")
{
    let command = RubyCommand(commandID: "", methodName: "cert", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
                                                                                        RubyCommand.Argument(name: "type", value: type),
                                                                                        RubyCommand.Argument(name: "force", value: force),
                                                                                        RubyCommand.Argument(name: "generate_apple_certs", value: generateAppleCerts),
                                                                                        RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                        RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                        RubyCommand.Argument(name: "username", value: username),
                                                                                        RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                        RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                        RubyCommand.Argument(name: "filename", value: filename),
                                                                                        RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                        RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                        RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                        RubyCommand.Argument(name: "skip_set_partition_list", value: skipSetPartitionList),
                                                                                        RubyCommand.Argument(name: "platform", value: platform)])
    _ = runner.executeCommand(command)
}

/**
 Collect git commit messages into a changelog

 - parameters:
   - between: Array containing two Git revision values between which to collect messages, you mustn't use it with :commits_count key at the same time
   - commitsCount: Number of commits to include in changelog, you mustn't use it with :between key at the same time
   - path: Path of the git repository
   - pretty: The format applied to each commit while generating the collected value
   - dateFormat: The date format applied to each commit while generating the collected value
   - ancestryPath: Whether or not to use ancestry-path param
   - tagMatchPattern: A glob(7) pattern to match against when finding the last git tag
   - matchLightweightTag: Whether or not to match a lightweight tag when searching for the last one
   - quiet: Whether or not to disable changelog output
   - includeMerges: **DEPRECATED!** Use `:merge_commit_filtering` instead - Whether or not to include any commits that are merges
   - mergeCommitFiltering: Controls inclusion of merge commits when collecting the changelog. Valid values: `:include_merges`, `:exclude_merges`, `:only_include_merges`

 - returns: Returns a String containing your formatted git commits

 By default, messages will be collected back to the last tag, but the range can be controlled
 */
@discardableResult public func changelogFromGitCommits(between: Any? = nil,
                                                       commitsCount: Int? = nil,
                                                       path: String = "./",
                                                       pretty: String = "%B",
                                                       dateFormat: String? = nil,
                                                       ancestryPath: Bool = false,
                                                       tagMatchPattern: String? = nil,
                                                       matchLightweightTag: Bool = true,
                                                       quiet: Bool = false,
                                                       includeMerges: Bool? = nil,
                                                       mergeCommitFiltering: String = "include_merges") -> String
{
    let command = RubyCommand(commandID: "", methodName: "changelog_from_git_commits", className: nil, args: [RubyCommand.Argument(name: "between", value: between),
                                                                                                              RubyCommand.Argument(name: "commits_count", value: commitsCount),
                                                                                                              RubyCommand.Argument(name: "path", value: path),
                                                                                                              RubyCommand.Argument(name: "pretty", value: pretty),
                                                                                                              RubyCommand.Argument(name: "date_format", value: dateFormat),
                                                                                                              RubyCommand.Argument(name: "ancestry_path", value: ancestryPath),
                                                                                                              RubyCommand.Argument(name: "tag_match_pattern", value: tagMatchPattern),
                                                                                                              RubyCommand.Argument(name: "match_lightweight_tag", value: matchLightweightTag),
                                                                                                              RubyCommand.Argument(name: "quiet", value: quiet),
                                                                                                              RubyCommand.Argument(name: "include_merges", value: includeMerges),
                                                                                                              RubyCommand.Argument(name: "merge_commit_filtering", value: mergeCommitFiltering)])
    return runner.executeCommand(command)
}

/**
 Send a success/error message to [ChatWork](https://go.chatwork.com/)

 - parameters:
   - apiToken: ChatWork API Token
   - message: The message to post on ChatWork
   - roomid: The room ID
   - success: Was this build successful? (true/false)

 Information on how to obtain an API token: [http://developer.chatwork.com/ja/authenticate.html](http://developer.chatwork.com/ja/authenticate.html)
 */
public func chatwork(apiToken: String,
                     message: String,
                     roomid: Any,
                     success: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "chatwork", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                            RubyCommand.Argument(name: "message", value: message),
                                                                                            RubyCommand.Argument(name: "roomid", value: roomid),
                                                                                            RubyCommand.Argument(name: "success", value: success)])
    _ = runner.executeCommand(command)
}

/**
 Check your app's metadata before you submit your app to review (via _precheck_)

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - platform: The platform to use (optional)
   - defaultRuleLevel: The default rule level unless otherwise configured
   - includeInAppPurchases: Should check in-app purchases?
   - useLive: Should force check live app?
   - negativeAppleSentiment: mentioning  in a way that could be considered negative
   - placeholderText: using placeholder text (e.g.:"lorem ipsum", "text here", etc...)
   - otherPlatforms: mentioning other platforms, like Android or Blackberry
   - futureFunctionality: mentioning features or content that is not currently available in your app
   - testWords: using text indicating this release is a test
   - curseWords: including words that might be considered objectionable
   - freeStuffInIap: using text indicating that your IAP is free
   - customText: mentioning any of the user-specified words passed to custom_text(data: [words])
   - copyrightDate: using a copyright date that is any different from this current year, or missing a date
   - unreachableUrls: unreachable URLs in app metadata

 - returns: true if precheck passes, else, false

 More information: https://fastlane.tools/precheck
 */
public func checkAppStoreMetadata(apiKeyPath: String? = nil,
                                  apiKey: [String: Any]? = nil,
                                  appIdentifier: String,
                                  username: String,
                                  teamId: String? = nil,
                                  teamName: String? = nil,
                                  platform: String = "ios",
                                  defaultRuleLevel: Any = "error",
                                  includeInAppPurchases: Bool = true,
                                  useLive: Bool = false,
                                  negativeAppleSentiment: Any? = nil,
                                  placeholderText: Any? = nil,
                                  otherPlatforms: Any? = nil,
                                  futureFunctionality: Any? = nil,
                                  testWords: Any? = nil,
                                  curseWords: Any? = nil,
                                  freeStuffInIap: Any? = nil,
                                  customText: Any? = nil,
                                  copyrightDate: Any? = nil,
                                  unreachableUrls: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "check_app_store_metadata", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                            RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                            RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                            RubyCommand.Argument(name: "username", value: username),
                                                                                                            RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                            RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                            RubyCommand.Argument(name: "platform", value: platform),
                                                                                                            RubyCommand.Argument(name: "default_rule_level", value: defaultRuleLevel),
                                                                                                            RubyCommand.Argument(name: "include_in_app_purchases", value: includeInAppPurchases),
                                                                                                            RubyCommand.Argument(name: "use_live", value: useLive),
                                                                                                            RubyCommand.Argument(name: "negative_apple_sentiment", value: negativeAppleSentiment),
                                                                                                            RubyCommand.Argument(name: "placeholder_text", value: placeholderText),
                                                                                                            RubyCommand.Argument(name: "other_platforms", value: otherPlatforms),
                                                                                                            RubyCommand.Argument(name: "future_functionality", value: futureFunctionality),
                                                                                                            RubyCommand.Argument(name: "test_words", value: testWords),
                                                                                                            RubyCommand.Argument(name: "curse_words", value: curseWords),
                                                                                                            RubyCommand.Argument(name: "free_stuff_in_iap", value: freeStuffInIap),
                                                                                                            RubyCommand.Argument(name: "custom_text", value: customText),
                                                                                                            RubyCommand.Argument(name: "copyright_date", value: copyrightDate),
                                                                                                            RubyCommand.Argument(name: "unreachable_urls", value: unreachableUrls)])
    _ = runner.executeCommand(command)
}

/**
 Deletes files created as result of running gym, cert, sigh or download_dsyms

 - parameter excludePattern: Exclude all files from clearing that match the given Regex pattern: e.g. '.*.mobileprovision'

 This action deletes the files that get created in your repo as a result of running the _gym_ and _sigh_ commands. It doesn't delete the `fastlane/report.xml` though, this is probably more suited for the .gitignore.

 Useful if you quickly want to send out a test build by dropping down to the command line and typing something like `fastlane beta`, without leaving your repo in a messy state afterwards.
 */
public func cleanBuildArtifacts(excludePattern: String? = nil) {
    let command = RubyCommand(commandID: "", methodName: "clean_build_artifacts", className: nil, args: [RubyCommand.Argument(name: "exclude_pattern", value: excludePattern)])
    _ = runner.executeCommand(command)
}

/**
 Remove the cache for pods

 - parameter name: Pod name to be removed from cache
 */
public func cleanCocoapodsCache(name: String? = nil) {
    let command = RubyCommand(commandID: "", methodName: "clean_cocoapods_cache", className: nil, args: [RubyCommand.Argument(name: "name", value: name)])
    _ = runner.executeCommand(command)
}

/**
 Deletes the Xcode Derived Data

 - parameter derivedDataPath: Custom path for derivedData

 Deletes the Derived Data from path set on Xcode or a supplied path
 */
public func clearDerivedData(derivedDataPath: String = "~/Library/Developer/Xcode/DerivedData") {
    let command = RubyCommand(commandID: "", methodName: "clear_derived_data", className: nil, args: [RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath)])
    _ = runner.executeCommand(command)
}

/**
 Copies a given string into the clipboard. Works only on macOS

 - parameter value: The string that should be copied into the clipboard
 */
public func clipboard(value: String) {
    let command = RubyCommand(commandID: "", methodName: "clipboard", className: nil, args: [RubyCommand.Argument(name: "value", value: value)])
    _ = runner.executeCommand(command)
}

/**
 Generates a Code Count that can be read by Jenkins (xml format)

 - parameters:
   - binaryPath: Where the cloc binary lives on your system (full path including 'cloc')
   - excludeDir: Comma separated list of directories to exclude
   - outputDirectory: Where to put the generated report file
   - sourceDirectory: Where to look for the source code (relative to the project root folder)
   - xml: Should we generate an XML File (if false, it will generate a plain text file)?

 This action will run cloc to generate a SLOC report that the Jenkins SLOCCount plugin can read.
 See [https://wiki.jenkins-ci.org/display/JENKINS/SLOCCount+Plugin](https://wiki.jenkins-ci.org/display/JENKINS/SLOCCount+Plugin) and [https://github.com/AlDanial/cloc](https://github.com/AlDanial/cloc) for more information.
 */
public func cloc(binaryPath: String = "/usr/local/bin/cloc",
                 excludeDir: String? = nil,
                 outputDirectory: String = "build",
                 sourceDirectory: String = "",
                 xml: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "cloc", className: nil, args: [RubyCommand.Argument(name: "binary_path", value: binaryPath),
                                                                                        RubyCommand.Argument(name: "exclude_dir", value: excludeDir),
                                                                                        RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                        RubyCommand.Argument(name: "source_directory", value: sourceDirectory),
                                                                                        RubyCommand.Argument(name: "xml", value: xml)])
    _ = runner.executeCommand(command)
}

/**
 Print a Club Mate in your build output
 */
public func clubmate() {
    let command = RubyCommand(commandID: "", methodName: "clubmate", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Runs `pod install` for the project

 - parameters:
   - repoUpdate: Add `--repo-update` flag to `pod install` command
   - cleanInstall: Execute a full pod installation ignoring the content of the project cache
   - silent: Execute command without logging output
   - verbose: Show more debugging information
   - ansi: Show output with ANSI codes
   - useBundleExec: Use bundle exec when there is a Gemfile presented
   - podfile: Explicitly specify the path to the Cocoapods' Podfile. You can either set it to the Podfile's path or to the folder containing the Podfile file
   - errorCallback: A callback invoked with the command output if there is a non-zero exit status
   - tryRepoUpdateOnError: Retry with --repo-update if action was finished with error
   - deployment: Disallow any changes to the Podfile or the Podfile.lock during installation
   - allowRoot: Allows CocoaPods to run as root
   - clean: **DEPRECATED!** (Option renamed as clean_install) Remove SCM directories
   - integrate: **DEPRECATED!** (Option removed from cocoapods) Integrate the Pods libraries into the Xcode project(s)

 If you use [CocoaPods](http://cocoapods.org) you can use the `cocoapods` integration to run `pod install` before building your app.
 */
public func cocoapods(repoUpdate: Bool = false,
                      cleanInstall: Bool = false,
                      silent: Bool = false,
                      verbose: Bool = false,
                      ansi: Bool = true,
                      useBundleExec: Bool = true,
                      podfile: String? = nil,
                      errorCallback: ((String) -> Void)? = nil,
                      tryRepoUpdateOnError: Bool = false,
                      deployment: Bool = false,
                      allowRoot: Bool = false,
                      clean: Bool = true,
                      integrate: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "cocoapods", className: nil, args: [RubyCommand.Argument(name: "repo_update", value: repoUpdate),
                                                                                             RubyCommand.Argument(name: "clean_install", value: cleanInstall),
                                                                                             RubyCommand.Argument(name: "silent", value: silent),
                                                                                             RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                             RubyCommand.Argument(name: "ansi", value: ansi),
                                                                                             RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                             RubyCommand.Argument(name: "podfile", value: podfile),
                                                                                             RubyCommand.Argument(name: "error_callback", value: errorCallback, type: .stringClosure),
                                                                                             RubyCommand.Argument(name: "try_repo_update_on_error", value: tryRepoUpdateOnError),
                                                                                             RubyCommand.Argument(name: "deployment", value: deployment),
                                                                                             RubyCommand.Argument(name: "allow_root", value: allowRoot),
                                                                                             RubyCommand.Argument(name: "clean", value: clean),
                                                                                             RubyCommand.Argument(name: "integrate", value: integrate)])
    _ = runner.executeCommand(command)
}

/**
  This will commit a file directly on GitHub via the API

  - parameters:
    - repositoryName: The path to your repo, e.g. 'fastlane/fastlane'
    - serverUrl: The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com')
    - apiToken: Personal API Token for GitHub - generate one at https://github.com/settings/tokens
    - branch: The branch that the file should be committed on (default: master)
    - path: The relative path to your file from project root e.g. assets/my_app.xcarchive
    - message: The commit message. Defaults to the file name
    - secure: Optionally disable secure requests (ssl_verify_peer)

  - returns: A hash containing all relevant information for this commit
 Access things like 'html_url', 'sha', 'message'

  Commits a file directly to GitHub. You must provide your GitHub Personal token (get one from [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new)), the repository name and the relative file path from the root git project.
  Out parameters provide the commit sha created, which can be used for later usage for examples such as releases, the direct download link and the full response JSON.
  Documentation: [https://developer.github.com/v3/repos/contents/#create-a-file](https://developer.github.com/v3/repos/contents/#create-a-file).
 */
@discardableResult public func commitGithubFile(repositoryName: String,
                                                serverUrl: String = "https://api.github.com",
                                                apiToken: String,
                                                branch: String = "master",
                                                path: String,
                                                message: String? = nil,
                                                secure: Bool = true) -> [String: String]
{
    let command = RubyCommand(commandID: "", methodName: "commit_github_file", className: nil, args: [RubyCommand.Argument(name: "repository_name", value: repositoryName),
                                                                                                      RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                                      RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                      RubyCommand.Argument(name: "branch", value: branch),
                                                                                                      RubyCommand.Argument(name: "path", value: path),
                                                                                                      RubyCommand.Argument(name: "message", value: message),
                                                                                                      RubyCommand.Argument(name: "secure", value: secure)])
    return parseDictionary(fromString: runner.executeCommand(command))
}

/**
 Creates a 'Version Bump' commit. Run after `increment_build_number`

 - parameters:
   - message: The commit message when committing the version bump
   - xcodeproj: The path to your project file (Not the workspace). If you have only one, this is optional
   - force: Forces the commit, even if other files than the ones containing the version number have been modified
   - settings: Include Settings.bundle/Root.plist with version bump
   - ignore: A regular expression used to filter matched plist files to be modified
   - include: A list of extra files to be included in the version bump (string array or comma-separated string)
   - noVerify: Whether or not to use --no-verify

 This action will create a 'Version Bump' commit in your repo. Useful in conjunction with `increment_build_number`.
 It checks the repo to make sure that only the relevant files have changed. These are the files that `increment_build_number` (`agvtool`) touches:|
 |
 >- All `.plist` files|
 - The `.xcodeproj/project.pbxproj` file|
 >|
 Then commits those files to the repo.
 Customize the message with the `:message` option. It defaults to 'Version Bump'.
 If you have other uncommitted changes in your repo, this action will fail. If you started off in a clean repo, and used the _ipa_ and or _sigh_ actions, then you can use the [clean_build_artifacts](https://docs.fastlane.tools/actions/clean_build_artifacts/) action to clean those temporary files up before running this action.
 */
public func commitVersionBump(message: String? = nil,
                              xcodeproj: String? = nil,
                              force: Bool = false,
                              settings: Bool = false,
                              ignore: Any? = nil,
                              include: [String] = [],
                              noVerify: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "commit_version_bump", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                                       RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                       RubyCommand.Argument(name: "force", value: force),
                                                                                                       RubyCommand.Argument(name: "settings", value: settings),
                                                                                                       RubyCommand.Argument(name: "ignore", value: ignore),
                                                                                                       RubyCommand.Argument(name: "include", value: include),
                                                                                                       RubyCommand.Argument(name: "no_verify", value: noVerify)])
    _ = runner.executeCommand(command)
}

/**
 Copy and save your build artifacts (useful when you use reset_git_repo)

 - parameters:
   - keepOriginal: Set this to false if you want move, rather than copy, the found artifacts
   - targetPath: The directory in which you want your artifacts placed
   - artifacts: An array of file patterns of the files/folders you want to preserve
   - failOnMissing: Fail when a source file isn't found

 This action copies artifacts to a target directory. It's useful if you have a CI that will pick up these artifacts and attach them to the build. Useful e.g. for storing your `.ipa`s, `.dSYM.zip`s, `.mobileprovision`s, `.cert`s.
 Make sure your `:target_path` is ignored from git, and if you use `reset_git_repo`, make sure the artifacts are added to the exclude list.
 */
public func copyArtifacts(keepOriginal: Bool = true,
                          targetPath: Any = "artifacts",
                          artifacts: [String] = [],
                          failOnMissing: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "copy_artifacts", className: nil, args: [RubyCommand.Argument(name: "keep_original", value: keepOriginal),
                                                                                                  RubyCommand.Argument(name: "target_path", value: targetPath),
                                                                                                  RubyCommand.Argument(name: "artifacts", value: artifacts),
                                                                                                  RubyCommand.Argument(name: "fail_on_missing", value: failOnMissing)])
    _ = runner.executeCommand(command)
}

/**
 Refer to [Firebase App Distribution](https://appdistro.page.link/fastlane-repo)

 - parameters:
   - ipaPath: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action
   - apkPath: Path to your APK file
   - crashlyticsPath: Path to the submit binary in the Crashlytics bundle (iOS) or `crashlytics-devtools.jar` file (Android)
   - apiToken: Crashlytics API Key
   - buildSecret: Crashlytics Build Secret
   - notesPath: Path to the release notes
   - notes: The release notes as string - uses :notes_path under the hood
   - groups: The groups used for distribution, separated by commas
   - emails: Pass email addresses of testers, separated by commas
   - notifications: Crashlytics notification option (true/false)
   - debug: Crashlytics debug option (true/false)

 Additionally, you can specify `notes`, `emails`, `groups` and `notifications`.
 Distributing to Groups: When using the `groups` parameter, it's important to use the group **alias** names for each group you'd like to distribute to. A group's alias can be found in the web UI. If you're viewing the Beta page, you can open the groups dialog by clicking the 'Manage Groups' button.
 This action uses the `submit` binary provided by the Crashlytics framework. If the binary is not found in its usual path, you'll need to specify the path manually by using the `crashlytics_path` option.
 */
public func crashlytics(ipaPath: String? = nil,
                        apkPath: String? = nil,
                        crashlyticsPath: String? = nil,
                        apiToken: String,
                        buildSecret: String,
                        notesPath: String? = nil,
                        notes: String? = nil,
                        groups: Any? = nil,
                        emails: Any? = nil,
                        notifications: Bool = true,
                        debug: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "crashlytics", className: nil, args: [RubyCommand.Argument(name: "ipa_path", value: ipaPath),
                                                                                               RubyCommand.Argument(name: "apk_path", value: apkPath),
                                                                                               RubyCommand.Argument(name: "crashlytics_path", value: crashlyticsPath),
                                                                                               RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                               RubyCommand.Argument(name: "build_secret", value: buildSecret),
                                                                                               RubyCommand.Argument(name: "notes_path", value: notesPath),
                                                                                               RubyCommand.Argument(name: "notes", value: notes),
                                                                                               RubyCommand.Argument(name: "groups", value: groups),
                                                                                               RubyCommand.Argument(name: "emails", value: emails),
                                                                                               RubyCommand.Argument(name: "notifications", value: notifications),
                                                                                               RubyCommand.Argument(name: "debug", value: debug)])
    _ = runner.executeCommand(command)
}

/**
 Create Managed Google Play Apps

 - parameters:
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - developerAccountId: The ID of your Google Play Console account. Can be obtained from the URL when you log in (`https://play.google.com/apps/publish/?account=...` or when you 'Obtain private app publishing rights' (https://developers.google.com/android/work/play/custom-app-api/get-started#retrieve_the_developer_account_id)
   - apk: Path to the APK file to upload
   - appTitle: App Title
   - language: Default app language (e.g. 'en_US')
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - timeout: Timeout for read, open, and send (in seconds)

 Create new apps on Managed Google Play.
 */
public func createAppOnManagedPlayStore(jsonKey: String? = nil,
                                        jsonKeyData: String? = nil,
                                        developerAccountId: String,
                                        apk: String,
                                        appTitle: String,
                                        language: String = "en_US",
                                        rootUrl: String? = nil,
                                        timeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "create_app_on_managed_play_store", className: nil, args: [RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                    RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                                    RubyCommand.Argument(name: "developer_account_id", value: developerAccountId),
                                                                                                                    RubyCommand.Argument(name: "apk", value: apk),
                                                                                                                    RubyCommand.Argument(name: "app_title", value: appTitle),
                                                                                                                    RubyCommand.Argument(name: "language", value: language),
                                                                                                                    RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                                    RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Creates the given application on iTC and the Dev Portal (via _produce_)

 - parameters:
   - username: Your Apple ID Username
   - appIdentifier: App Identifier (Bundle ID, e.g. com.krausefx.app)
   - bundleIdentifierSuffix: App Identifier Suffix (Ignored if App Identifier does not end with .*)
   - appName: App Name
   - appVersion: Initial version number (e.g. '1.0')
   - sku: SKU Number (e.g. '1234')
   - platform: The platform to use (optional)
   - platforms: The platforms to use (optional)
   - language: Primary Language (e.g. 'en-US', 'fr-FR')
   - companyName: The name of your company. Only required if it's the first app you create
   - skipItc: Skip the creation of the app on App Store Connect
   - itcUsers: Array of App Store Connect users. If provided, you can limit access to this newly created app for users with the App Manager, Developer, Marketer or Sales roles
   - enabledFeatures: **DEPRECATED!** Please use `enable_services` instead - Array with Spaceship App Services
   - enableServices: Array with Spaceship App Services (e.g. access_wifi: (on|off), app_group: (on|off), apple_pay: (on|off), associated_domains: (on|off), auto_fill_credential: (on|off), data_protection: (complete|unlessopen|untilfirstauth), game_center: (on|off), health_kit: (on|off), home_kit: (on|off), hotspot: (on|off), icloud: (legacy|cloudkit), in_app_purchase: (on|off), inter_app_audio: (on|off), multipath: (on|off), network_extension: (on|off), nfc_tag_reading: (on|off), personal_vpn: (on|off), passbook: (on|off), push_notification: (on|off), siri_kit: (on|off), vpn_configuration: (on|off), wallet: (on|off), wireless_accessory: (on|off))
   - skipDevcenter: Skip the creation of the app on the Apple Developer Portal
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - itcTeamId: The ID of your App Store Connect team if you're in multiple teams
   - itcTeamName: The name of your App Store Connect team if you're in multiple teams

 Create new apps on App Store Connect and Apple Developer Portal via _produce_.
 If the app already exists, `create_app_online` will not do anything.
 For more information about _produce_, visit its documentation page: [https://docs.fastlane.tools/actions/produce/](https://docs.fastlane.tools/actions/produce/).
 */
public func createAppOnline(username: String,
                            appIdentifier: String,
                            bundleIdentifierSuffix: String? = nil,
                            appName: String,
                            appVersion: String? = nil,
                            sku: String,
                            platform: String = "ios",
                            platforms: [String]? = nil,
                            language: String = "English",
                            companyName: String? = nil,
                            skipItc: Bool = false,
                            itcUsers: [String]? = nil,
                            enabledFeatures: [String: Any] = [:],
                            enableServices: [String: Any] = [:],
                            skipDevcenter: Bool = false,
                            teamId: String? = nil,
                            teamName: String? = nil,
                            itcTeamId: Any? = nil,
                            itcTeamName: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "create_app_online", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                     RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                     RubyCommand.Argument(name: "bundle_identifier_suffix", value: bundleIdentifierSuffix),
                                                                                                     RubyCommand.Argument(name: "app_name", value: appName),
                                                                                                     RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                                     RubyCommand.Argument(name: "sku", value: sku),
                                                                                                     RubyCommand.Argument(name: "platform", value: platform),
                                                                                                     RubyCommand.Argument(name: "platforms", value: platforms),
                                                                                                     RubyCommand.Argument(name: "language", value: language),
                                                                                                     RubyCommand.Argument(name: "company_name", value: companyName),
                                                                                                     RubyCommand.Argument(name: "skip_itc", value: skipItc),
                                                                                                     RubyCommand.Argument(name: "itc_users", value: itcUsers),
                                                                                                     RubyCommand.Argument(name: "enabled_features", value: enabledFeatures),
                                                                                                     RubyCommand.Argument(name: "enable_services", value: enableServices),
                                                                                                     RubyCommand.Argument(name: "skip_devcenter", value: skipDevcenter),
                                                                                                     RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                     RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                     RubyCommand.Argument(name: "itc_team_id", value: itcTeamId),
                                                                                                     RubyCommand.Argument(name: "itc_team_name", value: itcTeamName)])
    _ = runner.executeCommand(command)
}

/**
 Create a new Keychain

 - parameters:
   - name: Keychain name
   - path: Path to keychain
   - password: Password for the keychain
   - defaultKeychain: Should the newly created Keychain be the new system default keychain
   - unlock: Unlock keychain after create
   - timeout: timeout interval in seconds. Set `false` if you want to specify "no time-out"
   - lockWhenSleeps: Lock keychain when the system sleeps
   - lockAfterTimeout: Lock keychain after timeout interval
   - addToSearchList: Add keychain to search list
   - requireCreate: Fail the action if the Keychain already exists
 */
public func createKeychain(name: String? = nil,
                           path: String? = nil,
                           password: String,
                           defaultKeychain: Bool = false,
                           unlock: Bool = false,
                           timeout: Int = 300,
                           lockWhenSleeps: Bool = false,
                           lockAfterTimeout: Bool = false,
                           addToSearchList: Bool = true,
                           requireCreate: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "create_keychain", className: nil, args: [RubyCommand.Argument(name: "name", value: name),
                                                                                                   RubyCommand.Argument(name: "path", value: path),
                                                                                                   RubyCommand.Argument(name: "password", value: password),
                                                                                                   RubyCommand.Argument(name: "default_keychain", value: defaultKeychain),
                                                                                                   RubyCommand.Argument(name: "unlock", value: unlock),
                                                                                                   RubyCommand.Argument(name: "timeout", value: timeout),
                                                                                                   RubyCommand.Argument(name: "lock_when_sleeps", value: lockWhenSleeps),
                                                                                                   RubyCommand.Argument(name: "lock_after_timeout", value: lockAfterTimeout),
                                                                                                   RubyCommand.Argument(name: "add_to_search_list", value: addToSearchList),
                                                                                                   RubyCommand.Argument(name: "require_create", value: requireCreate)])
    _ = runner.executeCommand(command)
}

/**
 This will create a new pull request on GitHub

 - parameters:
   - apiToken: Personal API Token for GitHub - generate one at https://github.com/settings/tokens
   - apiBearer: Use a Bearer authorization token. Usually generated by Github Apps, e.g. GitHub Actions GITHUB_TOKEN environment variable
   - repo: The name of the repository you want to submit the pull request to
   - title: The title of the pull request
   - body: The contents of the pull request
   - draft: Indicates whether the pull request is a draft
   - labels: The labels for the pull request
   - milestone: The milestone ID (Integer) for the pull request
   - head: The name of the branch where your changes are implemented (defaults to the current branch name)
   - base: The name of the branch you want your changes pulled into (defaults to `master`)
   - apiUrl: The URL of GitHub API - used when the Enterprise (default to `https://api.github.com`)
   - assignees: The assignees for the pull request
   - reviewers: The reviewers (slug) for the pull request
   - teamReviewers: The team reviewers (slug) for the pull request

 - returns: The pull request URL when successful
 */
public func createPullRequest(apiToken: String? = nil,
                              apiBearer: String? = nil,
                              repo: String,
                              title: String,
                              body: String? = nil,
                              draft: Bool? = nil,
                              labels: [String]? = nil,
                              milestone: String? = nil,
                              head: String? = nil,
                              base: String = "master",
                              apiUrl: String = "https://api.github.com",
                              assignees: [String]? = nil,
                              reviewers: [String]? = nil,
                              teamReviewers: [String]? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "create_pull_request", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                       RubyCommand.Argument(name: "api_bearer", value: apiBearer),
                                                                                                       RubyCommand.Argument(name: "repo", value: repo),
                                                                                                       RubyCommand.Argument(name: "title", value: title),
                                                                                                       RubyCommand.Argument(name: "body", value: body),
                                                                                                       RubyCommand.Argument(name: "draft", value: draft),
                                                                                                       RubyCommand.Argument(name: "labels", value: labels),
                                                                                                       RubyCommand.Argument(name: "milestone", value: milestone),
                                                                                                       RubyCommand.Argument(name: "head", value: head),
                                                                                                       RubyCommand.Argument(name: "base", value: base),
                                                                                                       RubyCommand.Argument(name: "api_url", value: apiUrl),
                                                                                                       RubyCommand.Argument(name: "assignees", value: assignees),
                                                                                                       RubyCommand.Argument(name: "reviewers", value: reviewers),
                                                                                                       RubyCommand.Argument(name: "team_reviewers", value: teamReviewers)])
    _ = runner.executeCommand(command)
}

/**
 Package multiple build configs of a library/framework into a single xcframework

 - parameters:
   - frameworks: Frameworks to add to the target xcframework
   - libraries: Libraries to add to the target xcframework, with their corresponding headers
   - output: The path to write the xcframework to
   - allowInternalDistribution: Specifies that the created xcframework contains information not suitable for public distribution

 Utility for packaging multiple build configurations of a given library
 or framework into a single xcframework.

 If you want to package several frameworks just provide an array containing
 the list of frameworks to be packaged using the :frameworks parameter.

 If you want to package several libraries with their corresponding headers
 provide a hash containing the library as the key and the directory containing
 its headers as the value (or an empty string if there are no headers associated
 with the provided library).

 Finally specify the location of the xcframework to be generated using the :output
 parameter.

 */
public func createXcframework(frameworks: [String]? = nil,
                              libraries: [String: Any]? = nil,
                              output: String,
                              allowInternalDistribution: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "create_xcframework", className: nil, args: [RubyCommand.Argument(name: "frameworks", value: frameworks),
                                                                                                      RubyCommand.Argument(name: "libraries", value: libraries),
                                                                                                      RubyCommand.Argument(name: "output", value: output),
                                                                                                      RubyCommand.Argument(name: "allow_internal_distribution", value: allowInternalDistribution)])
    _ = runner.executeCommand(command)
}

/**
 Runs `danger` for the project

 - parameters:
   - useBundleExec: Use bundle exec when there is a Gemfile presented
   - verbose: Show more debugging information
   - dangerId: The identifier of this Danger instance
   - dangerfile: The location of your Dangerfile
   - githubApiToken: GitHub API token for danger
   - failOnErrors: Should always fail the build process, defaults to false
   - newComment: Makes Danger post a new comment instead of editing its previous one
   - removePreviousComments: Makes Danger remove all previous comment and create a new one in the end of the list
   - base: A branch/tag/commit to use as the base of the diff. [master|dev|stable]
   - head: A branch/tag/commit to use as the head. [master|dev|stable]
   - pr: Run danger on a specific pull request. e.g. "https://github.com/danger/danger/pull/518"

 Formalize your Pull Request etiquette.
 More information: [https://github.com/danger/danger](https://github.com/danger/danger).
 */
public func danger(useBundleExec: Bool = true,
                   verbose: Bool = false,
                   dangerId: String? = nil,
                   dangerfile: String? = nil,
                   githubApiToken: String? = nil,
                   failOnErrors: Bool = false,
                   newComment: Bool = false,
                   removePreviousComments: Bool = false,
                   base: String? = nil,
                   head: String? = nil,
                   pr: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "danger", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                          RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                          RubyCommand.Argument(name: "danger_id", value: dangerId),
                                                                                          RubyCommand.Argument(name: "dangerfile", value: dangerfile),
                                                                                          RubyCommand.Argument(name: "github_api_token", value: githubApiToken),
                                                                                          RubyCommand.Argument(name: "fail_on_errors", value: failOnErrors),
                                                                                          RubyCommand.Argument(name: "new_comment", value: newComment),
                                                                                          RubyCommand.Argument(name: "remove_previous_comments", value: removePreviousComments),
                                                                                          RubyCommand.Argument(name: "base", value: base),
                                                                                          RubyCommand.Argument(name: "head", value: head),
                                                                                          RubyCommand.Argument(name: "pr", value: pr)])
    _ = runner.executeCommand(command)
}

/**
 Print out an overview of the lane context values
 */
public func debug() {
    let command = RubyCommand(commandID: "", methodName: "debug", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Defines a default platform to not have to specify the platform
 */
public func defaultPlatform() {
    let command = RubyCommand(commandID: "", methodName: "default_platform", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Delete keychains and remove them from the search list

 - parameters:
   - name: Keychain name
   - keychainPath: Keychain path

 Keychains can be deleted after being created with `create_keychain`
 */
public func deleteKeychain(name: String? = nil,
                           keychainPath: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "delete_keychain", className: nil, args: [RubyCommand.Argument(name: "name", value: name),
                                                                                                   RubyCommand.Argument(name: "keychain_path", value: keychainPath)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `upload_to_app_store` action

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - appIdentifier: The bundle identifier of your app
   - appVersion: The version that should be edited or created
   - ipa: Path to your ipa file
   - pkg: Path to your pkg file
   - buildNumber: If set the given build number (already uploaded to iTC) will be used instead of the current built one
   - platform: The platform to use (optional)
   - editLive: Modify live metadata, this option disables ipa upload and screenshot upload
   - useLiveVersion: Force usage of live version rather than edit version
   - metadataPath: Path to the folder containing the metadata files
   - screenshotsPath: Path to the folder containing the screenshots
   - skipBinaryUpload: Skip uploading an ipa or pkg to App Store Connect
   - skipScreenshots: Don't upload the screenshots
   - skipMetadata: Don't upload the metadata (e.g. title, description). This will still upload screenshots
   - skipAppVersionUpdate: Don’t create or update the app version that is being prepared for submission
   - force: Skip verification of HTML preview file
   - overwriteScreenshots: Clear all previously uploaded screenshots before uploading the new ones
   - submitForReview: Submit the new version for Review after uploading everything
   - rejectIfPossible: Rejects the previously submitted build if it's in a state where it's possible
   - automaticRelease: Should the app be automatically released once it's approved? (Can not be used together with `auto_release_date`)
   - autoReleaseDate: Date in milliseconds for automatically releasing on pending approval (Can not be used together with `automatic_release`)
   - phasedRelease: Enable the phased release feature of iTC
   - resetRatings: Reset the summary rating when you release a new version of the application
   - priceTier: The price tier of this application
   - appRatingConfigPath: Path to the app rating's config
   - submissionInformation: Extra information for the submission (e.g. compliance specifications, IDFA settings)
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - devPortalTeamId: The short ID of your Developer Portal team, if you're in multiple teams. Different from your iTC team ID!
   - devPortalTeamName: The name of your Developer Portal team if you're in multiple teams
   - itcProvider: The provider short name to be used with the iTMSTransporter to identify your team. This value will override the automatically detected provider short name. To get provider short name run `pathToXcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m provider -u 'USERNAME' -p 'PASSWORD' -account_type itunes_connect -v off`. The short names of providers should be listed in the second column
   - runPrecheckBeforeSubmit: Run precheck before submitting to app review
   - precheckDefaultRuleLevel: The default precheck rule level unless otherwise configured
   - individualMetadataItems: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - An array of localized metadata items to upload individually by language so that errors can be identified. E.g. ['name', 'keywords', 'description']. Note: slow
   - appIcon: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - Metadata: The path to the app icon
   - appleWatchAppIcon: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - Metadata: The path to the Apple Watch app icon
   - copyright: Metadata: The copyright notice
   - primaryCategory: Metadata: The english name of the primary category (e.g. `Business`, `Books`)
   - secondaryCategory: Metadata: The english name of the secondary category (e.g. `Business`, `Books`)
   - primaryFirstSubCategory: Metadata: The english name of the primary first sub category (e.g. `Educational`, `Puzzle`)
   - primarySecondSubCategory: Metadata: The english name of the primary second sub category (e.g. `Educational`, `Puzzle`)
   - secondaryFirstSubCategory: Metadata: The english name of the secondary first sub category (e.g. `Educational`, `Puzzle`)
   - secondarySecondSubCategory: Metadata: The english name of the secondary second sub category (e.g. `Educational`, `Puzzle`)
   - tradeRepresentativeContactInformation: Metadata: A hash containing the trade representative contact information
   - appReviewInformation: Metadata: A hash containing the review information
   - appReviewAttachmentFile: Metadata: Path to the app review attachment file
   - description: Metadata: The localised app description
   - name: Metadata: The localised app name
   - subtitle: Metadata: The localised app subtitle
   - keywords: Metadata: An array of localised keywords
   - promotionalText: Metadata: An array of localised promotional texts
   - releaseNotes: Metadata: Localised release notes for this version
   - privacyUrl: Metadata: Localised privacy url
   - appleTvPrivacyPolicy: Metadata: Localised Apple TV privacy policy text
   - supportUrl: Metadata: Localised support url
   - marketingUrl: Metadata: Localised marketing url
   - languages: Metadata: List of languages to activate
   - ignoreLanguageDirectoryValidation: Ignore errors when invalid languages are found in metadata and screenshot directories
   - precheckIncludeInAppPurchases: Should precheck check in-app purchases?
   - app: The (spaceship) app ID of the app you want to use/modify

 Using _upload_to_app_store_ after _build_app_ and _capture_screenshots_ will automatically upload the latest ipa and screenshots with no other configuration.

 If you don't want to verify an HTML preview for App Store builds, use the `:force` option.
 This is useful when running _fastlane_ on your Continuous Integration server:
 `_upload_to_app_store_(force: true)`
 If your account is on multiple teams and you need to tell the `iTMSTransporter` which 'provider' to use, you can set the `:itc_provider` option to pass this info.
 */
public func deliver(apiKeyPath: Any? = deliverfile.apiKeyPath,
                    apiKey: [String: Any]? = deliverfile.apiKey,
                    username: Any = deliverfile.username,
                    appIdentifier: Any? = deliverfile.appIdentifier,
                    appVersion: Any? = deliverfile.appVersion,
                    ipa: Any? = deliverfile.ipa,
                    pkg: Any? = deliverfile.pkg,
                    buildNumber: Any? = deliverfile.buildNumber,
                    platform: Any = deliverfile.platform,
                    editLive: Bool = deliverfile.editLive,
                    useLiveVersion: Bool = deliverfile.useLiveVersion,
                    metadataPath: Any? = deliverfile.metadataPath,
                    screenshotsPath: Any? = deliverfile.screenshotsPath,
                    skipBinaryUpload: Bool = deliverfile.skipBinaryUpload,
                    skipScreenshots: Bool = deliverfile.skipScreenshots,
                    skipMetadata: Bool = deliverfile.skipMetadata,
                    skipAppVersionUpdate: Bool = deliverfile.skipAppVersionUpdate,
                    force: Bool = deliverfile.force,
                    overwriteScreenshots: Bool = deliverfile.overwriteScreenshots,
                    submitForReview: Bool = deliverfile.submitForReview,
                    rejectIfPossible: Bool = deliverfile.rejectIfPossible,
                    automaticRelease: Bool? = deliverfile.automaticRelease,
                    autoReleaseDate: Int? = deliverfile.autoReleaseDate,
                    phasedRelease: Bool = deliverfile.phasedRelease,
                    resetRatings: Bool = deliverfile.resetRatings,
                    priceTier: Any? = deliverfile.priceTier,
                    appRatingConfigPath: Any? = deliverfile.appRatingConfigPath,
                    submissionInformation: [String: Any]? = deliverfile.submissionInformation,
                    teamId: Any? = deliverfile.teamId,
                    teamName: Any? = deliverfile.teamName,
                    devPortalTeamId: Any? = deliverfile.devPortalTeamId,
                    devPortalTeamName: Any? = deliverfile.devPortalTeamName,
                    itcProvider: Any? = deliverfile.itcProvider,
                    runPrecheckBeforeSubmit: Bool = deliverfile.runPrecheckBeforeSubmit,
                    precheckDefaultRuleLevel: Any = deliverfile.precheckDefaultRuleLevel,
                    individualMetadataItems: [String]? = deliverfile.individualMetadataItems,
                    appIcon: Any? = deliverfile.appIcon,
                    appleWatchAppIcon: Any? = deliverfile.appleWatchAppIcon,
                    copyright: Any? = deliverfile.copyright,
                    primaryCategory: Any? = deliverfile.primaryCategory,
                    secondaryCategory: Any? = deliverfile.secondaryCategory,
                    primaryFirstSubCategory: Any? = deliverfile.primaryFirstSubCategory,
                    primarySecondSubCategory: Any? = deliverfile.primarySecondSubCategory,
                    secondaryFirstSubCategory: Any? = deliverfile.secondaryFirstSubCategory,
                    secondarySecondSubCategory: Any? = deliverfile.secondarySecondSubCategory,
                    tradeRepresentativeContactInformation: [String: Any]? = deliverfile.tradeRepresentativeContactInformation,
                    appReviewInformation: [String: Any]? = deliverfile.appReviewInformation,
                    appReviewAttachmentFile: Any? = deliverfile.appReviewAttachmentFile,
                    description: Any? = deliverfile.description,
                    name: Any? = deliverfile.name,
                    subtitle: [String: Any]? = deliverfile.subtitle,
                    keywords: [String: Any]? = deliverfile.keywords,
                    promotionalText: [String: Any]? = deliverfile.promotionalText,
                    releaseNotes: Any? = deliverfile.releaseNotes,
                    privacyUrl: Any? = deliverfile.privacyUrl,
                    appleTvPrivacyPolicy: Any? = deliverfile.appleTvPrivacyPolicy,
                    supportUrl: Any? = deliverfile.supportUrl,
                    marketingUrl: Any? = deliverfile.marketingUrl,
                    languages: [String]? = deliverfile.languages,
                    ignoreLanguageDirectoryValidation: Bool = deliverfile.ignoreLanguageDirectoryValidation,
                    precheckIncludeInAppPurchases: Bool = deliverfile.precheckIncludeInAppPurchases,
                    app: Any = deliverfile.app)
{
    let command = RubyCommand(commandID: "", methodName: "deliver", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                           RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                           RubyCommand.Argument(name: "username", value: username),
                                                                                           RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                           RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                           RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                           RubyCommand.Argument(name: "pkg", value: pkg),
                                                                                           RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                           RubyCommand.Argument(name: "platform", value: platform),
                                                                                           RubyCommand.Argument(name: "edit_live", value: editLive),
                                                                                           RubyCommand.Argument(name: "use_live_version", value: useLiveVersion),
                                                                                           RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                           RubyCommand.Argument(name: "screenshots_path", value: screenshotsPath),
                                                                                           RubyCommand.Argument(name: "skip_binary_upload", value: skipBinaryUpload),
                                                                                           RubyCommand.Argument(name: "skip_screenshots", value: skipScreenshots),
                                                                                           RubyCommand.Argument(name: "skip_metadata", value: skipMetadata),
                                                                                           RubyCommand.Argument(name: "skip_app_version_update", value: skipAppVersionUpdate),
                                                                                           RubyCommand.Argument(name: "force", value: force),
                                                                                           RubyCommand.Argument(name: "overwrite_screenshots", value: overwriteScreenshots),
                                                                                           RubyCommand.Argument(name: "submit_for_review", value: submitForReview),
                                                                                           RubyCommand.Argument(name: "reject_if_possible", value: rejectIfPossible),
                                                                                           RubyCommand.Argument(name: "automatic_release", value: automaticRelease),
                                                                                           RubyCommand.Argument(name: "auto_release_date", value: autoReleaseDate),
                                                                                           RubyCommand.Argument(name: "phased_release", value: phasedRelease),
                                                                                           RubyCommand.Argument(name: "reset_ratings", value: resetRatings),
                                                                                           RubyCommand.Argument(name: "price_tier", value: priceTier),
                                                                                           RubyCommand.Argument(name: "app_rating_config_path", value: appRatingConfigPath),
                                                                                           RubyCommand.Argument(name: "submission_information", value: submissionInformation),
                                                                                           RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                           RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                           RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId),
                                                                                           RubyCommand.Argument(name: "dev_portal_team_name", value: devPortalTeamName),
                                                                                           RubyCommand.Argument(name: "itc_provider", value: itcProvider),
                                                                                           RubyCommand.Argument(name: "run_precheck_before_submit", value: runPrecheckBeforeSubmit),
                                                                                           RubyCommand.Argument(name: "precheck_default_rule_level", value: precheckDefaultRuleLevel),
                                                                                           RubyCommand.Argument(name: "individual_metadata_items", value: individualMetadataItems),
                                                                                           RubyCommand.Argument(name: "app_icon", value: appIcon),
                                                                                           RubyCommand.Argument(name: "apple_watch_app_icon", value: appleWatchAppIcon),
                                                                                           RubyCommand.Argument(name: "copyright", value: copyright),
                                                                                           RubyCommand.Argument(name: "primary_category", value: primaryCategory),
                                                                                           RubyCommand.Argument(name: "secondary_category", value: secondaryCategory),
                                                                                           RubyCommand.Argument(name: "primary_first_sub_category", value: primaryFirstSubCategory),
                                                                                           RubyCommand.Argument(name: "primary_second_sub_category", value: primarySecondSubCategory),
                                                                                           RubyCommand.Argument(name: "secondary_first_sub_category", value: secondaryFirstSubCategory),
                                                                                           RubyCommand.Argument(name: "secondary_second_sub_category", value: secondarySecondSubCategory),
                                                                                           RubyCommand.Argument(name: "trade_representative_contact_information", value: tradeRepresentativeContactInformation),
                                                                                           RubyCommand.Argument(name: "app_review_information", value: appReviewInformation),
                                                                                           RubyCommand.Argument(name: "app_review_attachment_file", value: appReviewAttachmentFile),
                                                                                           RubyCommand.Argument(name: "description", value: description),
                                                                                           RubyCommand.Argument(name: "name", value: name),
                                                                                           RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                           RubyCommand.Argument(name: "keywords", value: keywords),
                                                                                           RubyCommand.Argument(name: "promotional_text", value: promotionalText),
                                                                                           RubyCommand.Argument(name: "release_notes", value: releaseNotes),
                                                                                           RubyCommand.Argument(name: "privacy_url", value: privacyUrl),
                                                                                           RubyCommand.Argument(name: "apple_tv_privacy_policy", value: appleTvPrivacyPolicy),
                                                                                           RubyCommand.Argument(name: "support_url", value: supportUrl),
                                                                                           RubyCommand.Argument(name: "marketing_url", value: marketingUrl),
                                                                                           RubyCommand.Argument(name: "languages", value: languages),
                                                                                           RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation),
                                                                                           RubyCommand.Argument(name: "precheck_include_in_app_purchases", value: precheckIncludeInAppPurchases),
                                                                                           RubyCommand.Argument(name: "app", value: app)])
    _ = runner.executeCommand(command)
}

/**
 Upload a new build to [DeployGate](https://deploygate.com/)

 - parameters:
   - apiToken: Deploygate API Token
   - user: Target username or organization name
   - ipa: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action
   - apk: Path to your APK file
   - message: Release Notes
   - distributionKey: Target Distribution Key
   - releaseNote: Release note for distribution page
   - disableNotify: Disables Push notification emails
   - distributionName: Target Distribution Name

 You can retrieve your username and API token on [your settings page](https://deploygate.com/settings).
 More information about the available options can be found in the [DeployGate Push API document](https://deploygate.com/docs/api).
 */
public func deploygate(apiToken: String,
                       user: String,
                       ipa: String? = nil,
                       apk: String? = nil,
                       message: String = "No changelog provided",
                       distributionKey: String? = nil,
                       releaseNote: String? = nil,
                       disableNotify: Bool = false,
                       distributionName: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "deploygate", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                              RubyCommand.Argument(name: "user", value: user),
                                                                                              RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                              RubyCommand.Argument(name: "apk", value: apk),
                                                                                              RubyCommand.Argument(name: "message", value: message),
                                                                                              RubyCommand.Argument(name: "distribution_key", value: distributionKey),
                                                                                              RubyCommand.Argument(name: "release_note", value: releaseNote),
                                                                                              RubyCommand.Argument(name: "disable_notify", value: disableNotify),
                                                                                              RubyCommand.Argument(name: "distribution_name", value: distributionName)])
    _ = runner.executeCommand(command)
}

/**
 Reads in production secrets set in a dotgpg file and puts them in ENV

 - parameter dotgpgFile: Path to your gpg file

 More information about dotgpg can be found at [https://github.com/ConradIrwin/dotgpg](https://github.com/ConradIrwin/dotgpg).
 */
public func dotgpgEnvironment(dotgpgFile: String) {
    let command = RubyCommand(commandID: "", methodName: "dotgpg_environment", className: nil, args: [RubyCommand.Argument(name: "dotgpg_file", value: dotgpgFile)])
    _ = runner.executeCommand(command)
}

/**
 Download a file from a remote server (e.g. JSON file)

 - parameter url: The URL that should be downloaded

 Specify the URL to download and get the content as a return value.
 Automatically parses JSON into a Ruby data structure.
 For more advanced networking code, use the Ruby functions instead: [http://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html](http://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html).
 */
public func download(url: String) {
    let command = RubyCommand(commandID: "", methodName: "download", className: nil, args: [RubyCommand.Argument(name: "url", value: url)])
    _ = runner.executeCommand(command)
}

/**
 Download App Privacy Details from an app in App Store Connect

 - parameters:
   - username: Your Apple ID Username for App Store Connect
   - appIdentifier: The bundle identifier of your app
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - outputJsonPath: Path to the app usage data JSON file generated by interactive questions

 Download App Privacy Details from an app in App Store Connect. For more detail information, view https://docs.fastlane.tools/uploading-app-privacy-details
 */
public func downloadAppPrivacyDetailsFromAppStore(username: String,
                                                  appIdentifier: String,
                                                  teamId: Any? = nil,
                                                  teamName: String? = nil,
                                                  outputJsonPath: String = "./fastlane/app_privacy_details.json")
{
    let command = RubyCommand(commandID: "", methodName: "download_app_privacy_details_from_app_store", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                                               RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                                               RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                                               RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                                               RubyCommand.Argument(name: "output_json_path", value: outputJsonPath)])
    _ = runner.executeCommand(command)
}

/**
 Download dSYM files from App Store Connect for Bitcode apps

 - parameters:
   - username: Your Apple ID Username for App Store Connect
   - appIdentifier: The bundle identifier of your app
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - platform: The app platform for dSYMs you wish to download (ios, appletvos)
   - version: The app version for dSYMs you wish to download, pass in 'latest' to download only the latest build's dSYMs or 'live' to download only the live version dSYMs
   - buildNumber: The app build_number for dSYMs you wish to download
   - minVersion: The minimum app version for dSYMs you wish to download
   - afterUploadedDate: The uploaded date after which you wish to download dSYMs
   - outputDirectory: Where to save the download dSYMs, defaults to the current path
   - waitForDsymProcessing: Wait for dSYMs to process
   - waitTimeout: Number of seconds to wait for dSYMs to process

 This action downloads dSYM files from App Store Connect after the ipa gets re-compiled by Apple. Useful if you have Bitcode enabled.|
 |
 ```ruby|
 lane :refresh_dsyms do|
   download_dsyms                  # Download dSYM files from iTC|
   upload_symbols_to_crashlytics   # Upload them to Crashlytics|
   clean_build_artifacts           # Delete the local dSYM files|
 end|
 ```|
 >|
 */
public func downloadDsyms(username: String,
                          appIdentifier: String,
                          teamId: Any? = nil,
                          teamName: String? = nil,
                          platform: String = "ios",
                          version: String? = nil,
                          buildNumber: Any? = nil,
                          minVersion: String? = nil,
                          afterUploadedDate: String? = nil,
                          outputDirectory: String? = nil,
                          waitForDsymProcessing: Bool = false,
                          waitTimeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "download_dsyms", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                  RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                  RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                  RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                  RubyCommand.Argument(name: "platform", value: platform),
                                                                                                  RubyCommand.Argument(name: "version", value: version),
                                                                                                  RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                                  RubyCommand.Argument(name: "min_version", value: minVersion),
                                                                                                  RubyCommand.Argument(name: "after_uploaded_date", value: afterUploadedDate),
                                                                                                  RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                  RubyCommand.Argument(name: "wait_for_dsym_processing", value: waitForDsymProcessing),
                                                                                                  RubyCommand.Argument(name: "wait_timeout", value: waitTimeout)])
    _ = runner.executeCommand(command)
}

/**
 Download metadata and binaries from Google Play (via _supply_)

 - parameters:
   - packageName: The package name of the application to use
   - versionName: Version name (used when uploading new apks/aabs) - defaults to 'versionName' in build.gradle or AndroidManifest.xml
   - track: The track of the application to use. The default available tracks are: production, beta, alpha, internal
   - metadataPath: Path to the directory containing the metadata files
   - key: **DEPRECATED!** Use `--json_key` instead - The p12 File used to authenticate with Google
   - issuer: **DEPRECATED!** Use `--json_key` instead - The issuer of the p12 file (email address of the service account)
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - timeout: Timeout for read, open, and send (in seconds)

 More information: https://docs.fastlane.tools/actions/download_from_play_store/
 */
public func downloadFromPlayStore(packageName: String,
                                  versionName: String? = nil,
                                  track: String = "production",
                                  metadataPath: String? = nil,
                                  key: String? = nil,
                                  issuer: String? = nil,
                                  jsonKey: String? = nil,
                                  jsonKeyData: String? = nil,
                                  rootUrl: String? = nil,
                                  timeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "download_from_play_store", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                                            RubyCommand.Argument(name: "version_name", value: versionName),
                                                                                                            RubyCommand.Argument(name: "track", value: track),
                                                                                                            RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                                            RubyCommand.Argument(name: "key", value: key),
                                                                                                            RubyCommand.Argument(name: "issuer", value: issuer),
                                                                                                            RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                            RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                            RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                            RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Creates a zipped dSYM in the project root from the .xcarchive

 - parameters:
   - archivePath: Path to your xcarchive file. Optional if you use the `xcodebuild` action
   - dsymPath: Path for generated dsym. Optional, default is your apps root directory
   - all: Whether or not all dSYM files are to be included. Optional, default is false in which only your app dSYM is included

 You can manually specify the path to the xcarchive (not needed if you use `xcodebuild`/`xcarchive` to build your archive)
 */
public func dsymZip(archivePath: String? = nil,
                    dsymPath: String? = nil,
                    all: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "dsym_zip", className: nil, args: [RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                            RubyCommand.Argument(name: "dsym_path", value: dsymPath),
                                                                                            RubyCommand.Argument(name: "all", value: all)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `puts` action

 - parameter message: Message to be printed out
 */
public func echo(message: String? = nil) {
    let command = RubyCommand(commandID: "", methodName: "echo", className: nil, args: [RubyCommand.Argument(name: "message", value: message)])
    _ = runner.executeCommand(command)
}

/**
 Raises an exception if not using `bundle exec` to run fastlane

 This action will check if you are using `bundle exec` to run fastlane.
 You can put it into `before_all` to make sure that fastlane is ran using the `bundle exec fastlane` command.
 */
public func ensureBundleExec() {
    let command = RubyCommand(commandID: "", methodName: "ensure_bundle_exec", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Raises an exception if the specified env vars are not set

 - parameter envVars: The environment variables names that should be checked

 This action will check if some environment variables are set.
 */
public func ensureEnvVars(envVars: [String]) {
    let command = RubyCommand(commandID: "", methodName: "ensure_env_vars", className: nil, args: [RubyCommand.Argument(name: "env_vars", value: envVars)])
    _ = runner.executeCommand(command)
}

/**
 Raises an exception if not on a specific git branch

 - parameter branch: The branch that should be checked for. String that can be either the full name of the branch or a regex e.g. `^feature/.*$` to match

 This action will check if your git repo is checked out to a specific branch.
 You may only want to make releases from a specific branch, so `ensure_git_branch` will stop a lane if it was accidentally executed on an incorrect branch.
 */
public func ensureGitBranch(branch: String = "master") {
    let command = RubyCommand(commandID: "", methodName: "ensure_git_branch", className: nil, args: [RubyCommand.Argument(name: "branch", value: branch)])
    _ = runner.executeCommand(command)
}

/**
 Raises an exception if there are uncommitted git changes

 - parameters:
   - showUncommittedChanges: The flag whether to show uncommitted changes if the repo is dirty
   - showDiff: The flag whether to show the git diff if the repo is dirty
   - ignored: The flag whether to ignore file the git status if the repo is dirty

 A sanity check to make sure you are working in a repo that is clean.
 Especially useful to put at the beginning of your Fastfile in the `before_all` block, if some of your other actions will touch your filesystem, do things to your git repo, or just as a general reminder to save your work.
 Also needed as a prerequisite for some other actions like `reset_git_repo`.
 */
public func ensureGitStatusClean(showUncommittedChanges: Bool = false,
                                 showDiff: Bool = false,
                                 ignored: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "ensure_git_status_clean", className: nil, args: [RubyCommand.Argument(name: "show_uncommitted_changes", value: showUncommittedChanges),
                                                                                                           RubyCommand.Argument(name: "show_diff", value: showDiff),
                                                                                                           RubyCommand.Argument(name: "ignored", value: ignored)])
    _ = runner.executeCommand(command)
}

/**
 Ensures the given text is nowhere in the code base

 - parameters:
   - text: The text that must not be in the code base
   - path: The directory containing all the source files
   - extension: The extension that should be searched for
   - extensions: An array of file extensions that should be searched for
   - exclude: Exclude a certain pattern from the search
   - excludeDirs: An array of dirs that should not be included in the search

 You don't want any debug code to slip into production.
 This can be used to check if there is any debug code still in your codebase or if you have things like `// TO DO` or similar.
 */
public func ensureNoDebugCode(text: String,
                              path: String = ".",
                              extension: String? = nil,
                              extensions: Any? = nil,
                              exclude: String? = nil,
                              excludeDirs: [String]? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "ensure_no_debug_code", className: nil, args: [RubyCommand.Argument(name: "text", value: text),
                                                                                                        RubyCommand.Argument(name: "path", value: path),
                                                                                                        RubyCommand.Argument(name: "extension", value: `extension`),
                                                                                                        RubyCommand.Argument(name: "extensions", value: extensions),
                                                                                                        RubyCommand.Argument(name: "exclude", value: exclude),
                                                                                                        RubyCommand.Argument(name: "exclude_dirs", value: excludeDirs)])
    _ = runner.executeCommand(command)
}

/**
 Ensure the right version of Xcode is used

 - parameters:
   - version: Xcode version to verify that is selected
   - strict: Should the version be verified strictly (all 3 version numbers), or matching only the given version numbers (i.e. `11.3` == `11.3.x`)

 If building your app requires a specific version of Xcode, you can invoke this command before using gym.
 For example, to ensure that a beta version of Xcode is not accidentally selected to build, which would make uploading to TestFlight fail.
 You can either manually provide a specific version using `version: ` or you make use of the `.xcode-version` file.
 Using the `strict` parameter, you can either verify the full set of version numbers strictly (i.e. `11.3.1`) or only a subset of them (i.e. `11.3` or `11`).
 */
public func ensureXcodeVersion(version: String? = nil,
                               strict: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "ensure_xcode_version", className: nil, args: [RubyCommand.Argument(name: "version", value: version),
                                                                                                        RubyCommand.Argument(name: "strict", value: strict)])
    _ = runner.executeCommand(command)
}

/**
 Sets/gets env vars for Fastlane.swift. Don't use in ruby, use `ENV[key] = val`

 - parameters:
   - set: Set the environment variables named
   - get: Get the environment variable named
   - remove: Remove the environment variable named
 */
@discardableResult public func environmentVariable(set: [String: Any]? = nil,
                                                   get: String? = nil,
                                                   remove: String? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "environment_variable", className: nil, args: [RubyCommand.Argument(name: "set", value: set),
                                                                                                        RubyCommand.Argument(name: "get", value: get),
                                                                                                        RubyCommand.Argument(name: "remove", value: remove)])
    return runner.executeCommand(command)
}

/**
 Allows to Generate output files based on ERB templates

 - parameters:
   - template: ERB Template File
   - destination: Destination file
   - placeholders: Placeholders given as a hash
   - trimMode: Trim mode applied to the ERB

 Renders an ERB template with `:placeholders` given as a hash via parameter.
 If no `:destination` is set, it returns the rendered template as string.
 */
public func erb(template: String,
                destination: String? = nil,
                placeholders: [String: Any] = [:],
                trimMode: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "erb", className: nil, args: [RubyCommand.Argument(name: "template", value: template),
                                                                                       RubyCommand.Argument(name: "destination", value: destination),
                                                                                       RubyCommand.Argument(name: "placeholders", value: placeholders),
                                                                                       RubyCommand.Argument(name: "trim_mode", value: trimMode)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `min_fastlane_version` action

 Add this to your `Fastfile` to require a certain version of _fastlane_.
 Use it if you use an action that just recently came out and you need it.
 */
public func fastlaneVersion() {
    let command = RubyCommand(commandID: "", methodName: "fastlane_version", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Send a message to a [Flock](https://flock.com/) group

 - parameters:
   - message: Message text
   - token: Token for the Flock incoming webhook
   - baseUrl: Base URL of the Flock incoming message webhook

 To obtain the token, create a new [incoming message webhook](https://dev.flock.co/wiki/display/FlockAPI/Incoming+Webhooks) in your Flock admin panel.
 */
public func flock(message: String,
                  token: String,
                  baseUrl: String = "https://api.flock.co/hooks/sendMessage")
{
    let command = RubyCommand(commandID: "", methodName: "flock", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                         RubyCommand.Argument(name: "token", value: token),
                                                                                         RubyCommand.Argument(name: "base_url", value: baseUrl)])
    _ = runner.executeCommand(command)
}

/**
 Adds device frames around all screenshots (via _frameit_)

 - parameters:
   - white: Use white device frames
   - silver: Use white device frames. Alias for :white
   - roseGold: Use rose gold device frames. Alias for :rose_gold
   - gold: Use gold device frames. Alias for :gold
   - forceDeviceType: Forces a given device type, useful for Mac screenshots, as their sizes vary
   - useLegacyIphone5s: Use iPhone 5s instead of iPhone SE frames
   - useLegacyIphone6s: Use iPhone 6s frames instead of iPhone 7 frames
   - useLegacyIphone7: Use iPhone 7 frames instead of iPhone 8 frames
   - useLegacyIphonex: Use iPhone X instead of iPhone XS frames
   - useLegacyIphonexr: Use iPhone XR instead of iPhone 11 frames
   - useLegacyIphonexs: Use iPhone XS instead of iPhone 11 Pro frames
   - useLegacyIphonexsmax: Use iPhone XS Max instead of iPhone 11 Pro Max frames
   - forceOrientationBlock: [Advanced] A block to customize your screenshots' device orientation
   - debugMode: Output debug information in framed screenshots
   - resume: Resume frameit instead of reprocessing all screenshots
   - usePlatform: Choose a platform, the valid options are IOS, ANDROID and ANY (default is either general platform defined in the fastfile or IOS to ensure backward compatibility)
   - path: The path to the directory containing the screenshots

 Uses [frameit](https://docs.fastlane.tools/actions/frameit/) to prepare perfect screenshots for the App Store, your website, QA or emails.
 You can add background and titles to the framed screenshots as well.
 */
public func frameScreenshots(white: Bool? = nil,
                             silver: Bool? = nil,
                             roseGold: Bool? = nil,
                             gold: Bool? = nil,
                             forceDeviceType: String? = nil,
                             useLegacyIphone5s: Bool = false,
                             useLegacyIphone6s: Bool = false,
                             useLegacyIphone7: Bool = false,
                             useLegacyIphonex: Bool = false,
                             useLegacyIphonexr: Bool = false,
                             useLegacyIphonexs: Bool = false,
                             useLegacyIphonexsmax: Bool = false,
                             forceOrientationBlock: ((String) -> Void)? = nil,
                             debugMode: Bool = false,
                             resume: Bool = false,
                             usePlatform: String = "IOS",
                             path: String = "./")
{
    let command = RubyCommand(commandID: "", methodName: "frame_screenshots", className: nil, args: [RubyCommand.Argument(name: "white", value: white),
                                                                                                     RubyCommand.Argument(name: "silver", value: silver),
                                                                                                     RubyCommand.Argument(name: "rose_gold", value: roseGold),
                                                                                                     RubyCommand.Argument(name: "gold", value: gold),
                                                                                                     RubyCommand.Argument(name: "force_device_type", value: forceDeviceType),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphone5s", value: useLegacyIphone5s),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphone6s", value: useLegacyIphone6s),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphone7", value: useLegacyIphone7),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphonex", value: useLegacyIphonex),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphonexr", value: useLegacyIphonexr),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphonexs", value: useLegacyIphonexs),
                                                                                                     RubyCommand.Argument(name: "use_legacy_iphonexsmax", value: useLegacyIphonexsmax),
                                                                                                     RubyCommand.Argument(name: "force_orientation_block", value: forceOrientationBlock, type: .stringClosure),
                                                                                                     RubyCommand.Argument(name: "debug_mode", value: debugMode),
                                                                                                     RubyCommand.Argument(name: "resume", value: resume),
                                                                                                     RubyCommand.Argument(name: "use_platform", value: usePlatform),
                                                                                                     RubyCommand.Argument(name: "path", value: path)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `frame_screenshots` action

 - parameters:
   - white: Use white device frames
   - silver: Use white device frames. Alias for :white
   - roseGold: Use rose gold device frames. Alias for :rose_gold
   - gold: Use gold device frames. Alias for :gold
   - forceDeviceType: Forces a given device type, useful for Mac screenshots, as their sizes vary
   - useLegacyIphone5s: Use iPhone 5s instead of iPhone SE frames
   - useLegacyIphone6s: Use iPhone 6s frames instead of iPhone 7 frames
   - useLegacyIphone7: Use iPhone 7 frames instead of iPhone 8 frames
   - useLegacyIphonex: Use iPhone X instead of iPhone XS frames
   - useLegacyIphonexr: Use iPhone XR instead of iPhone 11 frames
   - useLegacyIphonexs: Use iPhone XS instead of iPhone 11 Pro frames
   - useLegacyIphonexsmax: Use iPhone XS Max instead of iPhone 11 Pro Max frames
   - forceOrientationBlock: [Advanced] A block to customize your screenshots' device orientation
   - debugMode: Output debug information in framed screenshots
   - resume: Resume frameit instead of reprocessing all screenshots
   - usePlatform: Choose a platform, the valid options are IOS, ANDROID and ANY (default is either general platform defined in the fastfile or IOS to ensure backward compatibility)
   - path: The path to the directory containing the screenshots

 Uses [frameit](https://docs.fastlane.tools/actions/frameit/) to prepare perfect screenshots for the App Store, your website, QA or emails.
 You can add background and titles to the framed screenshots as well.
 */
public func frameit(white: Bool? = nil,
                    silver: Bool? = nil,
                    roseGold: Bool? = nil,
                    gold: Bool? = nil,
                    forceDeviceType: String? = nil,
                    useLegacyIphone5s: Bool = false,
                    useLegacyIphone6s: Bool = false,
                    useLegacyIphone7: Bool = false,
                    useLegacyIphonex: Bool = false,
                    useLegacyIphonexr: Bool = false,
                    useLegacyIphonexs: Bool = false,
                    useLegacyIphonexsmax: Bool = false,
                    forceOrientationBlock: ((String) -> Void)? = nil,
                    debugMode: Bool = false,
                    resume: Bool = false,
                    usePlatform: String = "IOS",
                    path: String = "./")
{
    let command = RubyCommand(commandID: "", methodName: "frameit", className: nil, args: [RubyCommand.Argument(name: "white", value: white),
                                                                                           RubyCommand.Argument(name: "silver", value: silver),
                                                                                           RubyCommand.Argument(name: "rose_gold", value: roseGold),
                                                                                           RubyCommand.Argument(name: "gold", value: gold),
                                                                                           RubyCommand.Argument(name: "force_device_type", value: forceDeviceType),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphone5s", value: useLegacyIphone5s),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphone6s", value: useLegacyIphone6s),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphone7", value: useLegacyIphone7),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphonex", value: useLegacyIphonex),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphonexr", value: useLegacyIphonexr),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphonexs", value: useLegacyIphonexs),
                                                                                           RubyCommand.Argument(name: "use_legacy_iphonexsmax", value: useLegacyIphonexsmax),
                                                                                           RubyCommand.Argument(name: "force_orientation_block", value: forceOrientationBlock, type: .stringClosure),
                                                                                           RubyCommand.Argument(name: "debug_mode", value: debugMode),
                                                                                           RubyCommand.Argument(name: "resume", value: resume),
                                                                                           RubyCommand.Argument(name: "use_platform", value: usePlatform),
                                                                                           RubyCommand.Argument(name: "path", value: path)])
    _ = runner.executeCommand(command)
}

/**
 Runs test coverage reports for your Xcode project

 Generate summarized code coverage reports using [gcovr](http://gcovr.com/)
 */
public func gcovr() {
    let command = RubyCommand(commandID: "", methodName: "gcovr", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Get the build number of your project

 - parameters:
   - xcodeproj: optional, you must specify the path to your main Xcode project if it is not in the project root directory
   - hideErrorWhenVersioningDisabled: Used during `fastlane init` to hide the error message

 This action will return the current build number set on your project.
 You first have to set up your Xcode project, if you haven't done it already: [https://developer.apple.com/library/ios/qa/qa1827/_index.html](https://developer.apple.com/library/ios/qa/qa1827/_index.html).
 */
@discardableResult public func getBuildNumber(xcodeproj: String? = nil,
                                              hideErrorWhenVersioningDisabled: Bool = false) -> String
{
    let command = RubyCommand(commandID: "", methodName: "get_build_number", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                    RubyCommand.Argument(name: "hide_error_when_versioning_disabled", value: hideErrorWhenVersioningDisabled)])
    return runner.executeCommand(command)
}

/**
 Get the build number from the current repository

 - parameter useHgRevisionNumber: Use hg revision number instead of hash (ignored for non-hg repos)

 - returns: The build number from the current repository

 This action will get the **build number** according to what the SCM HEAD reports.
 Currently supported SCMs are svn (uses root revision), git-svn (uses svn revision), git (uses short hash) and mercurial (uses short hash or revision number).
 There is an option, `:use_hg_revision_number`, which allows to use mercurial revision number instead of hash.
 */
public func getBuildNumberRepository(useHgRevisionNumber: Bool = false) {
    let command = RubyCommand(commandID: "", methodName: "get_build_number_repository", className: nil, args: [RubyCommand.Argument(name: "use_hg_revision_number", value: useHgRevisionNumber)])
    _ = runner.executeCommand(command)
}

/**
 Create new iOS code signing certificates (via _cert_)

 - parameters:
   - development: Create a development certificate instead of a distribution one
   - type: Create specific certificate type (takes precedence over :development)
   - force: Create a certificate even if an existing certificate exists
   - generateAppleCerts: Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - filename: The filename of certificate to store
   - outputPath: The path to a directory in which all certificates and private keys should be stored
   - keychainPath: Path to a custom keychain
   - keychainPassword: This might be required the first time you access certificates on a new mac. For the login/default keychain this is your macOS account password
   - skipSetPartitionList: Skips setting the partition list (which can sometimes take a long time). Setting the partition list is usually needed to prevent Xcode from prompting to allow a cert to be used for signing
   - platform: Set the provisioning profile's platform (ios, macos, tvos)

 **Important**: It is recommended to use [match](https://docs.fastlane.tools/actions/match/) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your certificates. Use _cert_ directly only if you want full control over what's going on and know more about codesigning.
 Use this action to download the latest code signing identity.
 */
public func getCertificates(development: Bool = false,
                            type: String? = nil,
                            force: Bool = false,
                            generateAppleCerts: Bool = true,
                            apiKeyPath: String? = nil,
                            apiKey: [String: Any]? = nil,
                            username: String,
                            teamId: String? = nil,
                            teamName: String? = nil,
                            filename: String? = nil,
                            outputPath: String = ".",
                            keychainPath: String,
                            keychainPassword: String? = nil,
                            skipSetPartitionList: Bool = false,
                            platform: String = "ios")
{
    let command = RubyCommand(commandID: "", methodName: "get_certificates", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
                                                                                                    RubyCommand.Argument(name: "type", value: type),
                                                                                                    RubyCommand.Argument(name: "force", value: force),
                                                                                                    RubyCommand.Argument(name: "generate_apple_certs", value: generateAppleCerts),
                                                                                                    RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                    RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                    RubyCommand.Argument(name: "username", value: username),
                                                                                                    RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                    RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                    RubyCommand.Argument(name: "filename", value: filename),
                                                                                                    RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                    RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                                    RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                    RubyCommand.Argument(name: "skip_set_partition_list", value: skipSetPartitionList),
                                                                                                    RubyCommand.Argument(name: "platform", value: platform)])
    _ = runner.executeCommand(command)
}

/**
 This will verify if a given release version is available on GitHub

 - parameters:
   - url: The path to your repo, e.g. 'KrauseFx/fastlane'
   - serverUrl: The server url. e.g. 'https://your.github.server/api/v3' (Default: 'https://api.github.com')
   - version: The version tag of the release to check
   - apiToken: GitHub Personal Token (required for private repositories)

 This will return all information about a release. For example:|
 |
 ```no-highlight|
 {|
   "url"=>"https://api.github.com/repos/KrauseFx/fastlane/releases/1537713",|
    "assets_url"=>"https://api.github.com/repos/KrauseFx/fastlane/releases/1537713/assets",|
    "upload_url"=>"https://uploads.github.com/repos/KrauseFx/fastlane/releases/1537713/assets{?name}",|
    "html_url"=>"https://github.com/fastlane/fastlane/releases/tag/1.8.0",|
    "id"=>1537713,|
    "tag_name"=>"1.8.0",|
    "target_commitish"=>"master",|
    "name"=>"1.8.0 Switch Lanes & Pass Parameters",|
    "draft"=>false,|
    "author"=>|
     {"login"=>"KrauseFx",|
      "id"=>869950,|
      "avatar_url"=>"https://avatars.githubusercontent.com/u/869950?v=3",|
      "gravatar_id"=>"",|
      "url"=>"https://api.github.com/users/KrauseFx",|
      "html_url"=>"https://github.com/fastlane",|
      "followers_url"=>"https://api.github.com/users/KrauseFx/followers",|
      "following_url"=>"https://api.github.com/users/KrauseFx/following{/other_user}",|
      "gists_url"=>"https://api.github.com/users/KrauseFx/gists{/gist_id}",|
      "starred_url"=>"https://api.github.com/users/KrauseFx/starred{/owner}{/repo}",|
      "subscriptions_url"=>"https://api.github.com/users/KrauseFx/subscriptions",|
      "organizations_url"=>"https://api.github.com/users/KrauseFx/orgs",|
      "repos_url"=>"https://api.github.com/users/KrauseFx/repos",|
      "events_url"=>"https://api.github.com/users/KrauseFx/events{/privacy}",|
      "received_events_url"=>"https://api.github.com/users/KrauseFx/received_events",|
      "type"=>"User",|
      "site_admin"=>false},|
    "prerelease"=>false,|
    "created_at"=>"2015-07-14T23:33:01Z",|
    "published_at"=>"2015-07-14T23:44:10Z",|
    "assets"=>[],|
    "tarball_url"=>"https://api.github.com/repos/KrauseFx/fastlane/tarball/1.8.0",|
    "zipball_url"=>"https://api.github.com/repos/KrauseFx/fastlane/zipball/1.8.0",|
    "body"=> ...Markdown...|
   "This is one of the biggest updates of _fastlane_ yet"|
 }|
 ```|
 >|
 */
public func getGithubRelease(url: String,
                             serverUrl: String = "https://api.github.com",
                             version: String,
                             apiToken: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "get_github_release", className: nil, args: [RubyCommand.Argument(name: "url", value: url),
                                                                                                      RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                                      RubyCommand.Argument(name: "version", value: version),
                                                                                                      RubyCommand.Argument(name: "api_token", value: apiToken)])
    _ = runner.executeCommand(command)
}

/**
 Returns value from Info.plist of your project as native Ruby data structures

 - parameters:
   - key: Name of parameter
   - path: Path to plist file you want to read

 Get a value from a plist file, which can be used to fetch the app identifier and more information about your app
 */
@discardableResult public func getInfoPlistValue(key: String,
                                                 path: String) -> String
{
    let command = RubyCommand(commandID: "", methodName: "get_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key),
                                                                                                        RubyCommand.Argument(name: "path", value: path)])
    return runner.executeCommand(command)
}

/**
 Returns a value from Info.plist inside a .ipa file

 - parameters:
   - key: Name of parameter
   - ipa: Path to IPA

 - returns: Returns the value in the .ipa's Info.plist corresponding to the passed in Key

 This is useful for introspecting Info.plist files for `.ipa` files that have already been built.
 */
@discardableResult public func getIpaInfoPlistValue(key: String,
                                                    ipa: String) -> String
{
    let command = RubyCommand(commandID: "", methodName: "get_ipa_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key),
                                                                                                            RubyCommand.Argument(name: "ipa", value: ipa)])
    return runner.executeCommand(command)
}

/**
 Obtain publishing rights for custom apps on Managed Google Play Store

 - parameters:
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google

 - returns: An URI to obtain publishing rights for custom apps on Managed Play Store

 If you haven't done so before, start by following the first two steps of Googles ["Get started with custom app publishing"](https://developers.google.com/android/work/play/custom-app-api/get-started) -> ["Preliminary setup"](https://developers.google.com/android/work/play/custom-app-api/get-started#preliminary_setup) instructions:
 "[Enable the Google Play Custom App Publishing API](https://developers.google.com/android/work/play/custom-app-api/get-started#enable_the_google_play_custom_app_publishing_api)" and "[Create a service account](https://developers.google.com/android/work/play/custom-app-api/get-started#create_a_service_account)".
 You need the "service account's private key file" to continue.
 Run the action and supply the "private key file" to it as the `json_key` parameter. The command will output a URL to visit. After logging in you are redirected to a page that outputs your "Developer Account ID" - take note of that, you will need it to be able to use [`create_app_on_managed_play_store`](https://docs.fastlane.tools/actions/create_app_on_managed_play_store/).
 */
public func getManagedPlayStorePublishingRights(jsonKey: String? = nil,
                                                jsonKeyData: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "get_managed_play_store_publishing_rights", className: nil, args: [RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                            RubyCommand.Argument(name: "json_key_data", value: jsonKeyData)])
    _ = runner.executeCommand(command)
}

/**
 Generates a provisioning profile, saving it in the current folder (via _sigh_)

 - parameters:
   - adhoc: Setting this flag will generate AdHoc profiles instead of App Store Profiles
   - developerId: Setting this flag will generate Developer ID profiles instead of App Store Profiles
   - development: Renew the development certificate instead of the production one
   - skipInstall: By default, the certificate will be added to your local machine. Setting this flag will skip this action
   - force: Renew provisioning profiles regardless of its state - to automatically add all devices for ad hoc profiles
   - appIdentifier: The bundle identifier of your app
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - provisioningName: The name of the profile that is used on the Apple Developer Portal
   - ignoreProfilesWithDifferentName: Use in combination with :provisioning_name - when true only profiles matching this exact name will be downloaded
   - outputPath: Directory in which the profile should be stored
   - certId: The ID of the code signing certificate to use (e.g. 78ADL6LVAA)
   - certOwnerName: The certificate name to use for new profiles, or to renew with. (e.g. "Felix Krause")
   - filename: Filename to use for the generated provisioning profile (must include .mobileprovision)
   - skipFetchProfiles: Skips the verification of existing profiles which is useful if you have thousands of profiles
   - skipCertificateVerification: Skips the verification of the certificates for every existing profiles. This will make sure the provisioning profile can be used on the local machine
   - platform: Set the provisioning profile's platform (i.e. ios, tvos, macos, catalyst)
   - readonly: Only fetch existing profile, don't generate new ones
   - templateName: The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. "Apple Pay Pass Suppression Development")
   - failOnNameTaken: Should the command fail if it was about to create a duplicate of an existing provisioning profile. It can happen due to issues on Apple Developer Portal, when profile to be recreated was not properly deleted first

 - returns: The UUID of the profile sigh just fetched/generated

 **Note**: It is recommended to use [match](https://docs.fastlane.tools/actions/match/) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your provisioning profiles. Use _sigh_ directly only if you want full control over what's going on and know more about codesigning.
 */
public func getProvisioningProfile(adhoc: Bool = false,
                                   developerId: Bool = false,
                                   development: Bool = false,
                                   skipInstall: Bool = false,
                                   force: Bool = false,
                                   appIdentifier: String,
                                   apiKeyPath: String? = nil,
                                   apiKey: [String: Any]? = nil,
                                   username: String,
                                   teamId: String? = nil,
                                   teamName: String? = nil,
                                   provisioningName: String? = nil,
                                   ignoreProfilesWithDifferentName: Bool = false,
                                   outputPath: String = ".",
                                   certId: String? = nil,
                                   certOwnerName: String? = nil,
                                   filename: String? = nil,
                                   skipFetchProfiles: Bool = false,
                                   skipCertificateVerification: Bool = false,
                                   platform: Any = "ios",
                                   readonly: Bool = false,
                                   templateName: String? = nil,
                                   failOnNameTaken: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "get_provisioning_profile", className: nil, args: [RubyCommand.Argument(name: "adhoc", value: adhoc),
                                                                                                            RubyCommand.Argument(name: "developer_id", value: developerId),
                                                                                                            RubyCommand.Argument(name: "development", value: development),
                                                                                                            RubyCommand.Argument(name: "skip_install", value: skipInstall),
                                                                                                            RubyCommand.Argument(name: "force", value: force),
                                                                                                            RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                            RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                            RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                            RubyCommand.Argument(name: "username", value: username),
                                                                                                            RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                            RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                            RubyCommand.Argument(name: "provisioning_name", value: provisioningName),
                                                                                                            RubyCommand.Argument(name: "ignore_profiles_with_different_name", value: ignoreProfilesWithDifferentName),
                                                                                                            RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                            RubyCommand.Argument(name: "cert_id", value: certId),
                                                                                                            RubyCommand.Argument(name: "cert_owner_name", value: certOwnerName),
                                                                                                            RubyCommand.Argument(name: "filename", value: filename),
                                                                                                            RubyCommand.Argument(name: "skip_fetch_profiles", value: skipFetchProfiles),
                                                                                                            RubyCommand.Argument(name: "skip_certificate_verification", value: skipCertificateVerification),
                                                                                                            RubyCommand.Argument(name: "platform", value: platform),
                                                                                                            RubyCommand.Argument(name: "readonly", value: readonly),
                                                                                                            RubyCommand.Argument(name: "template_name", value: templateName),
                                                                                                            RubyCommand.Argument(name: "fail_on_name_taken", value: failOnNameTaken)])
    _ = runner.executeCommand(command)
}

/**
 Ensure a valid push profile is active, creating a new one if needed (via _pem_)

 - parameters:
   - development: Renew the development push certificate instead of the production one
   - websitePush: Create a Website Push certificate
   - generateP12: Generate a p12 file additionally to a PEM file
   - activeDaysLimit: If the current certificate is active for less than this number of days, generate a new one
   - force: Create a new push certificate, even if the current one is active for 30 (or PEM_ACTIVE_DAYS_LIMIT) more days
   - savePrivateKey: Set to save the private RSA key
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - p12Password: The password that is used for your p12 file
   - pemName: The file name of the generated .pem file
   - outputPath: The path to a directory in which all certificates and private keys should be stored
   - newProfile: Block that is called if there is a new profile

 Additionally to the available options, you can also specify a block that only gets executed if a new profile was created. You can use it to upload the new profile to your server.
 Use it like this:|
 |
 ```ruby|
 get_push_certificate(|
   new_profile: proc do|
     # your upload code|
   end|
 )|
 ```|
 >|
 */
public func getPushCertificate(development: Bool = false,
                               websitePush: Bool = false,
                               generateP12: Bool = true,
                               activeDaysLimit: Int = 30,
                               force: Bool = false,
                               savePrivateKey: Bool = true,
                               appIdentifier: String,
                               username: String,
                               teamId: String? = nil,
                               teamName: String? = nil,
                               p12Password: String,
                               pemName: String? = nil,
                               outputPath: String = ".",
                               newProfile: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "get_push_certificate", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
                                                                                                        RubyCommand.Argument(name: "website_push", value: websitePush),
                                                                                                        RubyCommand.Argument(name: "generate_p12", value: generateP12),
                                                                                                        RubyCommand.Argument(name: "active_days_limit", value: activeDaysLimit),
                                                                                                        RubyCommand.Argument(name: "force", value: force),
                                                                                                        RubyCommand.Argument(name: "save_private_key", value: savePrivateKey),
                                                                                                        RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                        RubyCommand.Argument(name: "username", value: username),
                                                                                                        RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                        RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                        RubyCommand.Argument(name: "p12_password", value: p12Password),
                                                                                                        RubyCommand.Argument(name: "pem_name", value: pemName),
                                                                                                        RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                        RubyCommand.Argument(name: "new_profile", value: newProfile)])
    _ = runner.executeCommand(command)
}

/**
 Get the version number of your project

 - parameters:
   - xcodeproj: Path to the main Xcode project to read version number from, optional. By default will use the first Xcode project found within the project root directory
   - target: Target name, optional. Will be needed if you have more than one non-test target to avoid being prompted to select one
   - configuration: Configuration name, optional. Will be needed if you have altered the configurations from the default or your version number depends on the configuration selected

 This action will return the current version number set on your project.
 */
@discardableResult public func getVersionNumber(xcodeproj: String? = nil,
                                                target: String? = nil,
                                                configuration: String? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "get_version_number", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                      RubyCommand.Argument(name: "target", value: target),
                                                                                                      RubyCommand.Argument(name: "configuration", value: configuration)])
    return runner.executeCommand(command)
}

/**
 Directly add the given file or all files

 - parameters:
   - path: The file(s) and path(s) you want to add
   - shellEscape: Shell escapes paths (set to false if using wildcards or manually escaping spaces in :path)
   - pathspec: **DEPRECATED!** Use `--path` instead - The pathspec you want to add files from
 */
public func gitAdd(path: Any? = nil,
                   shellEscape: Bool = true,
                   pathspec: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "git_add", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                           RubyCommand.Argument(name: "shell_escape", value: shellEscape),
                                                                                           RubyCommand.Argument(name: "pathspec", value: pathspec)])
    _ = runner.executeCommand(command)
}

/**
 Returns the name of the current git branch, possibly as managed by CI ENV vars

 If no branch could be found, this action will return an empty string
 */
@discardableResult public func gitBranch() -> String {
    let command = RubyCommand(commandID: "", methodName: "git_branch", className: nil, args: [])
    return runner.executeCommand(command)
}

/**
 Directly commit the given file with the given message

 - parameters:
   - path: The file(s) or directory(ies) you want to commit. You can pass an array of multiple file-paths or fileglobs "*.txt" to commit all matching files. The files already staged but not specified and untracked files won't be committed
   - message: The commit message that should be used
   - skipGitHooks: Set to true to pass --no-verify to git
   - allowNothingToCommit: Set to true to allow commit without any git changes in the files you want to commit
 */
public func gitCommit(path: Any,
                      message: String,
                      skipGitHooks: Bool? = nil,
                      allowNothingToCommit: Bool? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "git_commit", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                              RubyCommand.Argument(name: "message", value: message),
                                                                                              RubyCommand.Argument(name: "skip_git_hooks", value: skipGitHooks),
                                                                                              RubyCommand.Argument(name: "allow_nothing_to_commit", value: allowNothingToCommit)])
    _ = runner.executeCommand(command)
}

/**
 Executes a simple git pull command

 - parameters:
   - onlyTags: Simply pull the tags, and not bring new commits to the current branch from the remote
   - rebase: Rebase on top of the remote branch instead of merge
 */
public func gitPull(onlyTags: Bool = false,
                    rebase: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "git_pull", className: nil, args: [RubyCommand.Argument(name: "only_tags", value: onlyTags),
                                                                                            RubyCommand.Argument(name: "rebase", value: rebase)])
    _ = runner.executeCommand(command)
}

/**
 Executes a git submodule command

 - parameters:
   - recursive: Should the submodules be updated recursively
   - init: Should the submodules be initiated before update
 */
public func gitSubmoduleUpdate(recursive: Bool = false,
                               init: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "git_submodule_update", className: nil, args: [RubyCommand.Argument(name: "recursive", value: recursive),
                                                                                                        RubyCommand.Argument(name: "init", value: `init`)])
    _ = runner.executeCommand(command)
}

/**
 Checks if the git tag with the given name exists in the current repo

 - parameters:
   - tag: The tag name that should be checked
   - remote: Whether to check remote. Defaults to `false`
   - remoteName: The remote to check. Defaults to `origin`

 - returns: Boolean value whether the tag exists or not
 */
public func gitTagExists(tag: String,
                         remote: Bool = false,
                         remoteName: String = "origin")
{
    let command = RubyCommand(commandID: "", methodName: "git_tag_exists", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag),
                                                                                                  RubyCommand.Argument(name: "remote", value: remote),
                                                                                                  RubyCommand.Argument(name: "remote_name", value: remoteName)])
    _ = runner.executeCommand(command)
}

/**
 Call a GitHub API endpoint and get the resulting JSON response

 - parameters:
   - serverUrl: The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com')
   - apiToken: Personal API Token for GitHub - generate one at https://github.com/settings/tokens
   - apiBearer: Use a Bearer authorization token. Usually generated by Github Apps, e.g. GitHub Actions GITHUB_TOKEN environment variable
   - httpMethod: The HTTP method. e.g. GET / POST
   - body: The request body in JSON or hash format
   - rawBody: The request body taken verbatim instead of as JSON, useful for file uploads
   - path: The endpoint path. e.g. '/repos/:owner/:repo/readme'
   - url: The complete full url - used instead of path. e.g. 'https://uploads.github.com/repos/fastlane...'
   - errorHandlers: Optional error handling hash based on status code, or pass '*' to handle all errors
   - headers: Optional headers to apply
   - secure: Optionally disable secure requests (ssl_verify_peer)

 - returns: A hash including the HTTP status code (:status), the response body (:body), and if valid JSON has been returned the parsed JSON (:json).

 Calls any GitHub API endpoint. You must provide your GitHub Personal token (get one from [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new)).
 Out parameters provide the status code and the full response JSON if valid, otherwise the raw response body.
 Documentation: [https://developer.github.com/v3](https://developer.github.com/v3).
 */
public func githubApi(serverUrl: String = "https://api.github.com",
                      apiToken: String? = nil,
                      apiBearer: String? = nil,
                      httpMethod: String = "GET",
                      body: [String: Any] = [:],
                      rawBody: String? = nil,
                      path: String? = nil,
                      url: String? = nil,
                      errorHandlers: [String: Any] = [:],
                      headers: [String: Any] = [:],
                      secure: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "github_api", className: nil, args: [RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                              RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                              RubyCommand.Argument(name: "api_bearer", value: apiBearer),
                                                                                              RubyCommand.Argument(name: "http_method", value: httpMethod),
                                                                                              RubyCommand.Argument(name: "body", value: body),
                                                                                              RubyCommand.Argument(name: "raw_body", value: rawBody),
                                                                                              RubyCommand.Argument(name: "path", value: path),
                                                                                              RubyCommand.Argument(name: "url", value: url),
                                                                                              RubyCommand.Argument(name: "error_handlers", value: errorHandlers),
                                                                                              RubyCommand.Argument(name: "headers", value: headers),
                                                                                              RubyCommand.Argument(name: "secure", value: secure)])
    _ = runner.executeCommand(command)
}

/**
 Retrieves release names for a Google Play track

 - parameters:
   - packageName: The package name of the application to use
   - track: The track of the application to use. The default available tracks are: production, beta, alpha, internal
   - key: **DEPRECATED!** Use `--json_key` instead - The p12 File used to authenticate with Google
   - issuer: **DEPRECATED!** Use `--json_key` instead - The issuer of the p12 file (email address of the service account)
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - timeout: Timeout for read, open, and send (in seconds)

 - returns: Array of strings representing the release names for the given Google Play track

 More information: [https://docs.fastlane.tools/actions/supply/](https://docs.fastlane.tools/actions/supply/)
 */
public func googlePlayTrackReleaseNames(packageName: String,
                                        track: String = "production",
                                        key: String? = nil,
                                        issuer: String? = nil,
                                        jsonKey: String? = nil,
                                        jsonKeyData: String? = nil,
                                        rootUrl: String? = nil,
                                        timeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "google_play_track_release_names", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                                                   RubyCommand.Argument(name: "track", value: track),
                                                                                                                   RubyCommand.Argument(name: "key", value: key),
                                                                                                                   RubyCommand.Argument(name: "issuer", value: issuer),
                                                                                                                   RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                   RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                                   RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                                   RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Retrieves version codes for a Google Play track

 - parameters:
   - packageName: The package name of the application to use
   - track: The track of the application to use. The default available tracks are: production, beta, alpha, internal
   - key: **DEPRECATED!** Use `--json_key` instead - The p12 File used to authenticate with Google
   - issuer: **DEPRECATED!** Use `--json_key` instead - The issuer of the p12 file (email address of the service account)
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - timeout: Timeout for read, open, and send (in seconds)

 - returns: Array of integers representing the version codes for the given Google Play track

 More information: [https://docs.fastlane.tools/actions/supply/](https://docs.fastlane.tools/actions/supply/)
 */
public func googlePlayTrackVersionCodes(packageName: String,
                                        track: String = "production",
                                        key: String? = nil,
                                        issuer: String? = nil,
                                        jsonKey: String? = nil,
                                        jsonKeyData: String? = nil,
                                        rootUrl: String? = nil,
                                        timeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "google_play_track_version_codes", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                                                   RubyCommand.Argument(name: "track", value: track),
                                                                                                                   RubyCommand.Argument(name: "key", value: key),
                                                                                                                   RubyCommand.Argument(name: "issuer", value: issuer),
                                                                                                                   RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                   RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                                   RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                                   RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 All gradle related actions, including building and testing your Android app

 - parameters:
   - task: The gradle task you want to execute, e.g. `assemble`, `bundle` or `test`. For tasks such as `assembleMyFlavorRelease` you should use gradle(task: 'assemble', flavor: 'Myflavor', build_type: 'Release')
   - flavor: The flavor that you want the task for, e.g. `MyFlavor`. If you are running the `assemble` task in a multi-flavor project, and you rely on Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] then you must specify a flavor here or else this value will be undefined
   - buildType: The build type that you want the task for, e.g. `Release`. Useful for some tasks such as `assemble`
   - tasks: The multiple gradle tasks that you want to execute, e.g. `[assembleDebug, bundleDebug]`
   - flags: All parameter flags you want to pass to the gradle command, e.g. `--exitcode --xml file.xml`
   - projectDir: The root directory of the gradle project
   - gradlePath: The path to your `gradlew`. If you specify a relative path, it is assumed to be relative to the `project_dir`
   - properties: Gradle properties to be exposed to the gradle script
   - systemProperties: Gradle system properties to be exposed to the gradle script
   - serial: Android serial, which device should be used for this command
   - printCommand: Control whether the generated Gradle command is printed as output before running it (true/false)
   - printCommandOutput: Control whether the output produced by given Gradle command is printed while running (true/false)

 - returns: The output of running the gradle task

 Run `./gradlew tasks` to get a list of all available gradle tasks for your project
 */
public func gradle(task: String? = nil,
                   flavor: String? = nil,
                   buildType: String? = nil,
                   tasks: [String]? = nil,
                   flags: String? = nil,
                   projectDir: String = ".",
                   gradlePath: String? = nil,
                   properties: Any? = nil,
                   systemProperties: Any? = nil,
                   serial: String = "",
                   printCommand: Bool = true,
                   printCommandOutput: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "gradle", className: nil, args: [RubyCommand.Argument(name: "task", value: task),
                                                                                          RubyCommand.Argument(name: "flavor", value: flavor),
                                                                                          RubyCommand.Argument(name: "build_type", value: buildType),
                                                                                          RubyCommand.Argument(name: "tasks", value: tasks),
                                                                                          RubyCommand.Argument(name: "flags", value: flags),
                                                                                          RubyCommand.Argument(name: "project_dir", value: projectDir),
                                                                                          RubyCommand.Argument(name: "gradle_path", value: gradlePath),
                                                                                          RubyCommand.Argument(name: "properties", value: properties),
                                                                                          RubyCommand.Argument(name: "system_properties", value: systemProperties),
                                                                                          RubyCommand.Argument(name: "serial", value: serial),
                                                                                          RubyCommand.Argument(name: "print_command", value: printCommand),
                                                                                          RubyCommand.Argument(name: "print_command_output", value: printCommandOutput)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `build_app` action

 - parameters:
   - workspace: Path to the workspace file
   - project: Path to the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - clean: Should the project be cleaned before building it?
   - outputDirectory: The directory in which the ipa file should be stored in
   - outputName: The name of the resulting ipa file
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - silent: Hide all information that's not necessary while building
   - codesigningIdentity: The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'
   - skipPackageIpa: Should we skip packaging the ipa?
   - skipPackagePkg: Should we skip packaging the pkg?
   - includeSymbols: Should the ipa file include symbols?
   - includeBitcode: Should the ipa file include bitcode?
   - exportMethod: Method used to export the archive. Valid values are: app-store, validation, ad-hoc, package, enterprise, development, developer-id and mac-application
   - exportOptions: Path to an export options plist or a hash with export options. Use 'xcodebuild -help' to print the full set of available options
   - exportXcargs: Pass additional arguments to xcodebuild for the package phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - skipBuildArchive: Export ipa from previously built xcarchive. Uses archive_path as source
   - skipArchive: After building, don't archive, effectively not including -archivePath param
   - skipCodesigning: Build without codesigning
   - catalystPlatform: Platform to build when using a Catalyst enabled app. Valid values are: ios, macos
   - installerCertName: Full name of 3rd Party Mac Developer Installer or Developer ID Installer certificate. Example: `3rd Party Mac Developer Installer: Your Company (ABC1234XWYZ)`
   - buildPath: The directory in which the archive should be stored in
   - archivePath: The path to the created archive
   - derivedDataPath: The directory where built products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - resultBundlePath: Path to the result bundle directory to create. Ignored if `result_bundle` if false
   - buildlogPath: The directory where to store the build log
   - sdk: The SDK that should be used for building the application
   - toolchain: The toolchain that should be used for building the application (e.g. com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a)
   - destination: Use a custom destination for building the app
   - exportTeamId: Optional: Sometimes you need to specify a team id when exporting the ipa file
   - xcargs: Pass additional arguments to xcodebuild for the build phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - disableXcpretty: Disable xcpretty formatting of build output
   - xcprettyTestFormat: Use the test (RSpec style) format for build output
   - xcprettyFormatter: A custom xcpretty formatter to use
   - xcprettyReportJunit: Have xcpretty create a JUnit-style XML report at the provided path
   - xcprettyReportHtml: Have xcpretty create a simple HTML report at the provided path
   - xcprettyReportJson: Have xcpretty create a JSON compilation database at the provided path
   - analyzeBuildTime: Analyze the project build time and store the output in 'culprits.txt' file
   - xcprettyUtf: Have xcpretty use unicode encoding when reporting builds
   - skipProfileDetection: Do not try to build a profile mapping from the xcodeproj. Match or a manually provided mapping should be used
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - useSystemScm: Lets xcodebuild use system's scm configuration

 - returns: The absolute path to the generated ipa file

 More information: https://fastlane.tools/gym
 */
public func gym(workspace: Any? = gymfile.workspace,
                project: Any? = gymfile.project,
                scheme: Any? = gymfile.scheme,
                clean: Bool = gymfile.clean,
                outputDirectory: Any = gymfile.outputDirectory,
                outputName: Any? = gymfile.outputName,
                configuration: Any? = gymfile.configuration,
                silent: Bool = gymfile.silent,
                codesigningIdentity: Any? = gymfile.codesigningIdentity,
                skipPackageIpa: Bool = gymfile.skipPackageIpa,
                skipPackagePkg: Bool = gymfile.skipPackagePkg,
                includeSymbols: Bool? = gymfile.includeSymbols,
                includeBitcode: Bool? = gymfile.includeBitcode,
                exportMethod: Any? = gymfile.exportMethod,
                exportOptions: [String: Any]? = gymfile.exportOptions,
                exportXcargs: Any? = gymfile.exportXcargs,
                skipBuildArchive: Bool? = gymfile.skipBuildArchive,
                skipArchive: Bool? = gymfile.skipArchive,
                skipCodesigning: Bool? = gymfile.skipCodesigning,
                catalystPlatform: Any? = gymfile.catalystPlatform,
                installerCertName: Any? = gymfile.installerCertName,
                buildPath: Any? = gymfile.buildPath,
                archivePath: Any? = gymfile.archivePath,
                derivedDataPath: Any? = gymfile.derivedDataPath,
                resultBundle: Bool = gymfile.resultBundle,
                resultBundlePath: Any? = gymfile.resultBundlePath,
                buildlogPath: Any = gymfile.buildlogPath,
                sdk: Any? = gymfile.sdk,
                toolchain: Any? = gymfile.toolchain,
                destination: Any? = gymfile.destination,
                exportTeamId: Any? = gymfile.exportTeamId,
                xcargs: Any? = gymfile.xcargs,
                xcconfig: Any? = gymfile.xcconfig,
                suppressXcodeOutput: Bool? = gymfile.suppressXcodeOutput,
                disableXcpretty: Bool? = gymfile.disableXcpretty,
                xcprettyTestFormat: Bool? = gymfile.xcprettyTestFormat,
                xcprettyFormatter: Any? = gymfile.xcprettyFormatter,
                xcprettyReportJunit: Any? = gymfile.xcprettyReportJunit,
                xcprettyReportHtml: Any? = gymfile.xcprettyReportHtml,
                xcprettyReportJson: Any? = gymfile.xcprettyReportJson,
                analyzeBuildTime: Bool? = gymfile.analyzeBuildTime,
                xcprettyUtf: Bool? = gymfile.xcprettyUtf,
                skipProfileDetection: Bool = gymfile.skipProfileDetection,
                clonedSourcePackagesPath: Any? = gymfile.clonedSourcePackagesPath,
                skipPackageDependenciesResolution: Bool = gymfile.skipPackageDependenciesResolution,
                disablePackageAutomaticUpdates: Bool = gymfile.disablePackageAutomaticUpdates,
                useSystemScm: Bool = gymfile.useSystemScm)
{
    let command = RubyCommand(commandID: "", methodName: "gym", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                       RubyCommand.Argument(name: "project", value: project),
                                                                                       RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                       RubyCommand.Argument(name: "clean", value: clean),
                                                                                       RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                       RubyCommand.Argument(name: "output_name", value: outputName),
                                                                                       RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                       RubyCommand.Argument(name: "silent", value: silent),
                                                                                       RubyCommand.Argument(name: "codesigning_identity", value: codesigningIdentity),
                                                                                       RubyCommand.Argument(name: "skip_package_ipa", value: skipPackageIpa),
                                                                                       RubyCommand.Argument(name: "skip_package_pkg", value: skipPackagePkg),
                                                                                       RubyCommand.Argument(name: "include_symbols", value: includeSymbols),
                                                                                       RubyCommand.Argument(name: "include_bitcode", value: includeBitcode),
                                                                                       RubyCommand.Argument(name: "export_method", value: exportMethod),
                                                                                       RubyCommand.Argument(name: "export_options", value: exportOptions),
                                                                                       RubyCommand.Argument(name: "export_xcargs", value: exportXcargs),
                                                                                       RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive),
                                                                                       RubyCommand.Argument(name: "skip_archive", value: skipArchive),
                                                                                       RubyCommand.Argument(name: "skip_codesigning", value: skipCodesigning),
                                                                                       RubyCommand.Argument(name: "catalyst_platform", value: catalystPlatform),
                                                                                       RubyCommand.Argument(name: "installer_cert_name", value: installerCertName),
                                                                                       RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                       RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                       RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                       RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                       RubyCommand.Argument(name: "result_bundle_path", value: resultBundlePath),
                                                                                       RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                       RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                       RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                       RubyCommand.Argument(name: "destination", value: destination),
                                                                                       RubyCommand.Argument(name: "export_team_id", value: exportTeamId),
                                                                                       RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                       RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                       RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                       RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                       RubyCommand.Argument(name: "xcpretty_test_format", value: xcprettyTestFormat),
                                                                                       RubyCommand.Argument(name: "xcpretty_formatter", value: xcprettyFormatter),
                                                                                       RubyCommand.Argument(name: "xcpretty_report_junit", value: xcprettyReportJunit),
                                                                                       RubyCommand.Argument(name: "xcpretty_report_html", value: xcprettyReportHtml),
                                                                                       RubyCommand.Argument(name: "xcpretty_report_json", value: xcprettyReportJson),
                                                                                       RubyCommand.Argument(name: "analyze_build_time", value: analyzeBuildTime),
                                                                                       RubyCommand.Argument(name: "xcpretty_utf", value: xcprettyUtf),
                                                                                       RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection),
                                                                                       RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                       RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                       RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                       RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 This will add a hg tag to the current branch

 - parameter tag: Tag to create
 */
public func hgAddTag(tag: String) {
    let command = RubyCommand(commandID: "", methodName: "hg_add_tag", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag)])
    _ = runner.executeCommand(command)
}

/**
 This will commit a version bump to the hg repo

 - parameters:
   - message: The commit message when committing the version bump
   - xcodeproj: The path to your project file (Not the workspace). If you have only one, this is optional
   - force: Forces the commit, even if other files than the ones containing the version number have been modified
   - testDirtyFiles: A list of dirty files passed in for testing
   - testExpectedFiles: A list of expected changed files passed in for testing

 The mercurial equivalent of the [commit_version_bump](https://docs.fastlane.tools/actions/commit_version_bump/) git action. Like the git version, it is useful in conjunction with [`increment_build_number`](https://docs.fastlane.tools/actions/increment_build_number/).
 It checks the repo to make sure that only the relevant files have changed, these are the files that `increment_build_number` (`agvtool`) touches:|
 |
 >- All `.plist` files|
 - The `.xcodeproj/project.pbxproj` file|
 >|
 Then commits those files to the repo.
 Customize the message with the `:message` option, defaults to 'Version Bump'
 If you have other uncommitted changes in your repo, this action will fail. If you started off in a clean repo, and used the _ipa_ and or _sigh_ actions, then you can use the [clean_build_artifacts](https://docs.fastlane.tools/actions/clean_build_artifacts/) action to clean those temporary files up before running this action.
 */
public func hgCommitVersionBump(message: String = "Version Bump",
                                xcodeproj: String? = nil,
                                force: Bool = false,
                                testDirtyFiles: String = "file1, file2",
                                testExpectedFiles: String = "file1, file2")
{
    let command = RubyCommand(commandID: "", methodName: "hg_commit_version_bump", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                                          RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                          RubyCommand.Argument(name: "force", value: force),
                                                                                                          RubyCommand.Argument(name: "test_dirty_files", value: testDirtyFiles),
                                                                                                          RubyCommand.Argument(name: "test_expected_files", value: testExpectedFiles)])
    _ = runner.executeCommand(command)
}

/**
 Raises an exception if there are uncommitted hg changes

 Along the same lines as the [ensure_git_status_clean](https://docs.fastlane.tools/actions/ensure_git_status_clean/) action, this is a sanity check to ensure the working mercurial repo is clean. Especially useful to put at the beginning of your Fastfile in the `before_all` block.
 */
public func hgEnsureCleanStatus() {
    let command = RubyCommand(commandID: "", methodName: "hg_ensure_clean_status", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 This will push changes to the remote hg repository

 - parameters:
   - force: Force push to remote
   - destination: The destination to push to

 The mercurial equivalent of [push_to_git_remote](https://docs.fastlane.tools/actions/push_to_git_remote/). Pushes your local commits to a remote mercurial repo. Useful when local changes such as adding a version bump commit or adding a tag are part of your lane’s actions.
 */
public func hgPush(force: Bool = false,
                   destination: String = "")
{
    let command = RubyCommand(commandID: "", methodName: "hg_push", className: nil, args: [RubyCommand.Argument(name: "force", value: force),
                                                                                           RubyCommand.Argument(name: "destination", value: destination)])
    _ = runner.executeCommand(command)
}

/**
 Send a error/success message to [HipChat](https://www.hipchat.com/)

 - parameters:
   - message: The message to post on HipChat
   - channel: The room or @username
   - apiToken: Hipchat API Token
   - customColor: Specify a custom color, this overrides the success boolean. Can be one of 'yellow', 'red', 'green', 'purple', 'gray', or 'random'
   - success: Was this build successful? (true/false)
   - version: Version of the Hipchat API. Must be 1 or 2
   - notifyRoom: Should the people in the room be notified? (true/false)
   - apiHost: The host of the HipChat-Server API
   - messageFormat: Format of the message to post. Must be either 'html' or 'text'
   - includeHtmlHeader: Should html formatted messages include a preformatted header? (true/false)
   - from: Name the message will appear to be sent from

 Send a message to **room** (by default) or a direct message to **@username** with success (green) or failure (red) status.
 */
public func hipchat(message: String = "",
                    channel: String,
                    apiToken: String,
                    customColor: String? = nil,
                    success: Bool = true,
                    version: String,
                    notifyRoom: Bool = false,
                    apiHost: String = "api.hipchat.com",
                    messageFormat: String = "html",
                    includeHtmlHeader: Bool = true,
                    from: String = "fastlane")
{
    let command = RubyCommand(commandID: "", methodName: "hipchat", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                           RubyCommand.Argument(name: "channel", value: channel),
                                                                                           RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                           RubyCommand.Argument(name: "custom_color", value: customColor),
                                                                                           RubyCommand.Argument(name: "success", value: success),
                                                                                           RubyCommand.Argument(name: "version", value: version),
                                                                                           RubyCommand.Argument(name: "notify_room", value: notifyRoom),
                                                                                           RubyCommand.Argument(name: "api_host", value: apiHost),
                                                                                           RubyCommand.Argument(name: "message_format", value: messageFormat),
                                                                                           RubyCommand.Argument(name: "include_html_header", value: includeHtmlHeader),
                                                                                           RubyCommand.Argument(name: "from", value: from)])
    _ = runner.executeCommand(command)
}

/**
 Refer to [App Center](https://github.com/Microsoft/fastlane-plugin-appcenter/)

 - parameters:
   - apk: Path to your APK file
   - apiToken: API Token for Hockey Access
   - ipa: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file. In addition you could use this to upload .msi, .zip, .pkg, etc if you use the 'create_update' mechanism
   - dsym: Path to your symbols file. For iOS and Mac provide path to app.dSYM.zip. For Android provide path to mappings.txt file
   - createUpdate: Set true if you want to create then update your app as opposed to just upload it. You will need the 'public_identifier', 'bundle_version' and 'bundle_short_version'
   - notes: Beta Notes
   - notify: Notify testers? "1" for yes
   - status: Download status: "1" = No user can download; "2" = Available for download (only possible with full-access token)
   - createStatus: Download status for initial version creation when create_update is true: "1" = No user can download; "2" = Available for download (only possible with full-access token)
   - notesType: Notes type for your :notes, "0" = Textile, "1" = Markdown (default)
   - releaseType: Release type of the app: "0" = Beta (default), "1" = Store, "2" = Alpha, "3" = Enterprise
   - mandatory: Set to "1" to make this update mandatory
   - teams: Comma separated list of team ID numbers to which this build will be restricted
   - users: Comma separated list of user ID numbers to which this build will be restricted
   - tags: Comma separated list of tags which will receive access to the build
   - bundleShortVersion: The bundle_short_version of your application, required when using `create_update`
   - bundleVersion: The bundle_version of your application, required when using `create_update`
   - publicIdentifier: App id of the app you are targeting, usually you won't need this value. Required, if `upload_dsym_only` set to `true`
   - commitSha: The Git commit SHA for this build
   - repositoryUrl: The URL of your source repository
   - buildServerUrl: The URL of the build job on your build server
   - uploadDsymOnly: Flag to upload only the dSYM file to hockey app
   - ownerId: ID for the owner of the app
   - strategy: Strategy: 'add' = to add the build as a new build even if it has the same build number (default); 'replace' = to replace a build with the same build number
   - timeout: Request timeout in seconds
   - bypassCdn: Flag to bypass Hockey CDN when it uploads successfully but reports error
   - dsaSignature: DSA signature for sparkle updates for macOS

 HockeyApp will be no longer supported and will be transitioned into App Center on November 16, 2019.
 Please migrate over to [App Center](https://github.com/Microsoft/fastlane-plugin-appcenter/)

 Symbols will also be uploaded automatically if a `app.dSYM.zip` file is found next to `app.ipa`. In case it is located in a different place you can specify the path explicitly in the `:dsym` parameter.
 More information about the available options can be found in the [HockeyApp Docs](http://support.hockeyapp.net/kb/api/api-versions#upload-version).
 */
public func hockey(apk: String? = nil,
                   apiToken: String,
                   ipa: String? = nil,
                   dsym: String? = nil,
                   createUpdate: Bool = false,
                   notes: String = "No changelog given",
                   notify: String = "1",
                   status: String = "2",
                   createStatus: String = "2",
                   notesType: String = "1",
                   releaseType: String = "0",
                   mandatory: String = "0",
                   teams: String? = nil,
                   users: String? = nil,
                   tags: String? = nil,
                   bundleShortVersion: String? = nil,
                   bundleVersion: String? = nil,
                   publicIdentifier: String? = nil,
                   commitSha: String? = nil,
                   repositoryUrl: String? = nil,
                   buildServerUrl: String? = nil,
                   uploadDsymOnly: Bool = false,
                   ownerId: String? = nil,
                   strategy: String = "add",
                   timeout: Int? = nil,
                   bypassCdn: Bool = false,
                   dsaSignature: String = "")
{
    let command = RubyCommand(commandID: "", methodName: "hockey", className: nil, args: [RubyCommand.Argument(name: "apk", value: apk),
                                                                                          RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                          RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                          RubyCommand.Argument(name: "dsym", value: dsym),
                                                                                          RubyCommand.Argument(name: "create_update", value: createUpdate),
                                                                                          RubyCommand.Argument(name: "notes", value: notes),
                                                                                          RubyCommand.Argument(name: "notify", value: notify),
                                                                                          RubyCommand.Argument(name: "status", value: status),
                                                                                          RubyCommand.Argument(name: "create_status", value: createStatus),
                                                                                          RubyCommand.Argument(name: "notes_type", value: notesType),
                                                                                          RubyCommand.Argument(name: "release_type", value: releaseType),
                                                                                          RubyCommand.Argument(name: "mandatory", value: mandatory),
                                                                                          RubyCommand.Argument(name: "teams", value: teams),
                                                                                          RubyCommand.Argument(name: "users", value: users),
                                                                                          RubyCommand.Argument(name: "tags", value: tags),
                                                                                          RubyCommand.Argument(name: "bundle_short_version", value: bundleShortVersion),
                                                                                          RubyCommand.Argument(name: "bundle_version", value: bundleVersion),
                                                                                          RubyCommand.Argument(name: "public_identifier", value: publicIdentifier),
                                                                                          RubyCommand.Argument(name: "commit_sha", value: commitSha),
                                                                                          RubyCommand.Argument(name: "repository_url", value: repositoryUrl),
                                                                                          RubyCommand.Argument(name: "build_server_url", value: buildServerUrl),
                                                                                          RubyCommand.Argument(name: "upload_dsym_only", value: uploadDsymOnly),
                                                                                          RubyCommand.Argument(name: "owner_id", value: ownerId),
                                                                                          RubyCommand.Argument(name: "strategy", value: strategy),
                                                                                          RubyCommand.Argument(name: "timeout", value: timeout),
                                                                                          RubyCommand.Argument(name: "bypass_cdn", value: bypassCdn),
                                                                                          RubyCommand.Argument(name: "dsa_signature", value: dsaSignature)])
    _ = runner.executeCommand(command)
}

/**
 Connect to the [IFTTT Maker Channel](https://ifttt.com/maker)

 - parameters:
   - apiKey: API key
   - eventName: The name of the event that will be triggered
   - value1: Extra data sent with the event
   - value2: Extra data sent with the event
   - value3: Extra data sent with the event

 Connect to the IFTTT [Maker Channel](https://ifttt.com/maker). An IFTTT Recipe has two components: a Trigger and an Action. In this case, the Trigger will fire every time the Maker Channel receives a web request (made by this _fastlane_ action) to notify it of an event. The Action can be anything that IFTTT supports: email, SMS, etc.
 */
public func ifttt(apiKey: String,
                  eventName: String,
                  value1: String? = nil,
                  value2: String? = nil,
                  value3: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "ifttt", className: nil, args: [RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                         RubyCommand.Argument(name: "event_name", value: eventName),
                                                                                         RubyCommand.Argument(name: "value1", value: value1),
                                                                                         RubyCommand.Argument(name: "value2", value: value2),
                                                                                         RubyCommand.Argument(name: "value3", value: value3)])
    _ = runner.executeCommand(command)
}

/**
 Import certificate from inputfile into a keychain

 - parameters:
   - certificatePath: Path to certificate
   - certificatePassword: Certificate password
   - keychainName: Keychain the items should be imported to
   - keychainPath: Path to the Keychain file to which the items should be imported
   - keychainPassword: The password for the keychain. Note that for the login keychain this is your user's password
   - logOutput: If output should be logged to the console

 Import certificates (and private keys) into the current default keychain. Use the `create_keychain` action to create a new keychain.
 */
public func importCertificate(certificatePath: String,
                              certificatePassword: String? = nil,
                              keychainName: String,
                              keychainPath: String? = nil,
                              keychainPassword: String? = nil,
                              logOutput: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "import_certificate", className: nil, args: [RubyCommand.Argument(name: "certificate_path", value: certificatePath),
                                                                                                      RubyCommand.Argument(name: "certificate_password", value: certificatePassword),
                                                                                                      RubyCommand.Argument(name: "keychain_name", value: keychainName),
                                                                                                      RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                                      RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                      RubyCommand.Argument(name: "log_output", value: logOutput)])
    _ = runner.executeCommand(command)
}

/**
 Increment the build number of your project

 - parameters:
   - buildNumber: Change to a specific version. When you provide this parameter, Apple Generic Versioning does not have to be enabled
   - xcodeproj: optional, you must specify the path to your main Xcode project if it is not in the project root directory

 - returns: The new build number
 */
@discardableResult public func incrementBuildNumber(buildNumber: Any? = nil,
                                                    xcodeproj: String? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "increment_build_number", className: nil, args: [RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                                          RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
    return runner.executeCommand(command)
}

/**
 Increment the version number of your project

 - parameters:
   - bumpType: The type of this version bump. Available: patch, minor, major
   - versionNumber: Change to a specific version. This will replace the bump type value
   - xcodeproj: optional, you must specify the path to your main Xcode project if it is not in the project root directory

 - returns: The new version number

 This action will increment the version number.
 You first have to set up your Xcode project, if you haven't done it already: [https://developer.apple.com/library/ios/qa/qa1827/_index.html](https://developer.apple.com/library/ios/qa/qa1827/_index.html).
 */
@discardableResult public func incrementVersionNumber(bumpType: String = "bump",
                                                      versionNumber: String? = nil,
                                                      xcodeproj: String? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "increment_version_number", className: nil, args: [RubyCommand.Argument(name: "bump_type", value: bumpType),
                                                                                                            RubyCommand.Argument(name: "version_number", value: versionNumber),
                                                                                                            RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
    return runner.executeCommand(command)
}

/**
 Installs an .ipa file on a connected iOS-device via usb or wifi

 - parameters:
   - extra: Extra Commandline arguments passed to ios-deploy
   - deviceId: id of the device / if not set defaults to first found device
   - skipWifi: Do not search for devices via WiFi
   - ipa: The IPA file to put on the device

 Installs the ipa on the device. If no id is given, the first found iOS device will be used. Works via USB or Wi-Fi. This requires `ios-deploy` to be installed. Please have a look at [ios-deploy](https://github.com/ios-control/ios-deploy). To quickly install it, use `npm -g i ios-deploy`
 */
public func installOnDevice(extra: String? = nil,
                            deviceId: String? = nil,
                            skipWifi: Any? = nil,
                            ipa: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "install_on_device", className: nil, args: [RubyCommand.Argument(name: "extra", value: extra),
                                                                                                     RubyCommand.Argument(name: "device_id", value: deviceId),
                                                                                                     RubyCommand.Argument(name: "skip_wifi", value: skipWifi),
                                                                                                     RubyCommand.Argument(name: "ipa", value: ipa)])
    _ = runner.executeCommand(command)
}

/**
 Install provisioning profile from path

 - parameter path: Path to provisioning profile

 - returns: The absolute path to the installed provisioning profile

 Install provisioning profile from path for current user
 */
public func installProvisioningProfile(path: String) {
    let command = RubyCommand(commandID: "", methodName: "install_provisioning_profile", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
    _ = runner.executeCommand(command)
}

/**
 Install an Xcode plugin for the current user

 - parameters:
   - url: URL for Xcode plugin ZIP file
   - github: GitHub repository URL for Xcode plugin
 */
public func installXcodePlugin(url: String,
                               github: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "install_xcode_plugin", className: nil, args: [RubyCommand.Argument(name: "url", value: url),
                                                                                                        RubyCommand.Argument(name: "github", value: github)])
    _ = runner.executeCommand(command)
}

/**
 Upload a new build to [Installr](http://installrapp.com/)

 - parameters:
   - apiToken: API Token for Installr Access
   - ipa: Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action
   - notes: Release notes
   - notify: Groups to notify (e.g. 'dev,qa')
   - add: Groups to add (e.g. 'exec,ops')
 */
public func installr(apiToken: String,
                     ipa: String,
                     notes: String? = nil,
                     notify: String? = nil,
                     add: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "installr", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                            RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                            RubyCommand.Argument(name: "notes", value: notes),
                                                                                            RubyCommand.Argument(name: "notify", value: notify),
                                                                                            RubyCommand.Argument(name: "add", value: add)])
    _ = runner.executeCommand(command)
}

/**
 Easily build and sign your app using shenzhen

 - parameters:
   - workspace: WORKSPACE Workspace (.xcworkspace) file to use to build app (automatically detected in current directory)
   - project: Project (.xcodeproj) file to use to build app (automatically detected in current directory, overridden by --workspace option, if passed)
   - configuration: Configuration used to build
   - scheme: Scheme used to build app
   - clean: Clean project before building
   - archive: Archive project after building
   - destination: Build destination. Defaults to current directory
   - embed: Sign .ipa file with .mobileprovision
   - identity: Identity to be used along with --embed
   - sdk: Use SDK as the name or path of the base SDK when building the project
   - ipa: Specify the name of the .ipa file to generate (including file extension)
   - xcconfig: Use an extra XCCONFIG file to build the app
   - xcargs: Pass additional arguments to xcodebuild when building the app. Be sure to quote multiple args
 */
public func ipa(workspace: String? = nil,
                project: String? = nil,
                configuration: String? = nil,
                scheme: String? = nil,
                clean: Any? = nil,
                archive: Any? = nil,
                destination: String? = nil,
                embed: String? = nil,
                identity: String? = nil,
                sdk: String? = nil,
                ipa: String? = nil,
                xcconfig: String? = nil,
                xcargs: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "ipa", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                       RubyCommand.Argument(name: "project", value: project),
                                                                                       RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                       RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                       RubyCommand.Argument(name: "clean", value: clean),
                                                                                       RubyCommand.Argument(name: "archive", value: archive),
                                                                                       RubyCommand.Argument(name: "destination", value: destination),
                                                                                       RubyCommand.Argument(name: "embed", value: embed),
                                                                                       RubyCommand.Argument(name: "identity", value: identity),
                                                                                       RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                       RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                       RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                       RubyCommand.Argument(name: "xcargs", value: xcargs)])
    _ = runner.executeCommand(command)
}

/**
 Is the current run being executed on a CI system, like Jenkins or Travis

 The return value of this method is true if fastlane is currently executed on Travis, Jenkins, Circle or a similar CI service
 */
@discardableResult public func isCi() -> Bool {
    let command = RubyCommand(commandID: "", methodName: "is_ci", className: nil, args: [])
    return parseBool(fromString: runner.executeCommand(command))
}

/**
 Generate docs using Jazzy

 - parameters:
   - config: Path to jazzy config file
   - moduleVersion: Version string to use as part of the the default docs title and inside the docset
 */
public func jazzy(config: String? = nil,
                  moduleVersion: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "jazzy", className: nil, args: [RubyCommand.Argument(name: "config", value: config),
                                                                                         RubyCommand.Argument(name: "module_version", value: moduleVersion)])
    _ = runner.executeCommand(command)
}

/**
 Leave a comment on JIRA tickets

 - parameters:
   - url: URL for Jira instance
   - contextPath: Appends to the url (ex: "/jira")
   - username: Username for JIRA instance
   - password: Password for Jira
   - ticketId: Ticket ID for Jira, i.e. IOS-123
   - commentText: Text to add to the ticket as a comment
 */
public func jira(url: String,
                 contextPath: String = "",
                 username: String,
                 password: String,
                 ticketId: String,
                 commentText: String)
{
    let command = RubyCommand(commandID: "", methodName: "jira", className: nil, args: [RubyCommand.Argument(name: "url", value: url),
                                                                                        RubyCommand.Argument(name: "context_path", value: contextPath),
                                                                                        RubyCommand.Argument(name: "username", value: username),
                                                                                        RubyCommand.Argument(name: "password", value: password),
                                                                                        RubyCommand.Argument(name: "ticket_id", value: ticketId),
                                                                                        RubyCommand.Argument(name: "comment_text", value: commentText)])
    _ = runner.executeCommand(command)
}

/**
 Access lane context values

 Access the fastlane lane context values.
 More information about how the lane context works: [https://docs.fastlane.tools/advanced/#lane-context](https://docs.fastlane.tools/advanced/#lane-context).
 */
@discardableResult public func laneContext() -> [String: Any] {
    let command = RubyCommand(commandID: "", methodName: "lane_context", className: nil, args: [])
    return parseDictionary(fromString: runner.executeCommand(command))
}

/**
 Return last git commit hash, abbreviated commit hash, commit message and author

 - returns: Returns the following dict: {commit_hash: "commit hash", abbreviated_commit_hash: "abbreviated commit hash" author: "Author", author_email: "author email", message: "commit message"}. Example: {:message=>"message", :author=>"author", :author_email=>"author_email", :commit_hash=>"commit_hash", :abbreviated_commit_hash=>"short_hash"}
 */
@discardableResult public func lastGitCommit() -> [String: String] {
    let command = RubyCommand(commandID: "", methodName: "last_git_commit", className: nil, args: [])
    return parseDictionary(fromString: runner.executeCommand(command))
}

/**
 Get the most recent git tag

 - parameter pattern: Pattern to filter tags when looking for last one. Limit tags to ones matching given shell glob. If pattern lacks ?, *, or [, * at the end is implied

 If you are using this action on a **shallow clone**, *the default with some CI systems like Bamboo*, you need to ensure that you have also pulled all the git tags appropriately. Assuming your git repo has the correct remote set you can issue `sh('git fetch --tags')`.
 Pattern parameter allows you to filter to a subset of tags.
 */
@discardableResult public func lastGitTag(pattern: String? = nil) -> String {
    let command = RubyCommand(commandID: "", methodName: "last_git_tag", className: nil, args: [RubyCommand.Argument(name: "pattern", value: pattern)])
    return runner.executeCommand(command)
}

/**
 Fetches most recent build number from TestFlight

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - live: Query the live version (ready-for-sale)
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - version: The version number whose latest build number we want
   - platform: The platform to use (optional)
   - initialBuildNumber: sets the build number to given value if no build is in current train
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams

 - returns: Integer representation of the latest build number uploaded to TestFlight. Example: 2

 Provides a way to have `increment_build_number` be based on the latest build you uploaded to iTC.
 Fetches the most recent build number from TestFlight based on the version number. Provides a way to have `increment_build_number` be based on the latest build you uploaded to iTC.
 */
@discardableResult public func latestTestflightBuildNumber(apiKeyPath: String? = nil,
                                                           apiKey: [String: Any]? = nil,
                                                           live: Bool = false,
                                                           appIdentifier: String,
                                                           username: String,
                                                           version: String? = nil,
                                                           platform: String = "ios",
                                                           initialBuildNumber: Int = 1,
                                                           teamId: Any? = nil,
                                                           teamName: String? = nil) -> Int
{
    let command = RubyCommand(commandID: "", methodName: "latest_testflight_build_number", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                                  RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                                  RubyCommand.Argument(name: "live", value: live),
                                                                                                                  RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                                  RubyCommand.Argument(name: "username", value: username),
                                                                                                                  RubyCommand.Argument(name: "version", value: version),
                                                                                                                  RubyCommand.Argument(name: "platform", value: platform),
                                                                                                                  RubyCommand.Argument(name: "initial_build_number", value: initialBuildNumber),
                                                                                                                  RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                                  RubyCommand.Argument(name: "team_name", value: teamName)])
    return parseInt(fromString: runner.executeCommand(command))
}

/**
 Generates coverage data using lcov

 - parameters:
   - projectName: Name of the project
   - scheme: Scheme of the project
   - arch: The build arch where will search .gcda files
   - outputDir: The output directory that coverage data will be stored. If not passed will use coverage_reports as default value
 */
public func lcov(projectName: String,
                 scheme: String,
                 arch: String = "i386",
                 outputDir: String = "coverage_reports")
{
    let command = RubyCommand(commandID: "", methodName: "lcov", className: nil, args: [RubyCommand.Argument(name: "project_name", value: projectName),
                                                                                        RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                        RubyCommand.Argument(name: "arch", value: arch),
                                                                                        RubyCommand.Argument(name: "output_dir", value: outputDir)])
    _ = runner.executeCommand(command)
}

/**
 Send a success/error message to an email group

 - parameters:
   - mailgunSandboxDomain: Mailgun sandbox domain postmaster for your mail. Please use postmaster instead
   - mailgunSandboxPostmaster: Mailgun sandbox domain postmaster for your mail. Please use postmaster instead
   - mailgunApikey: Mailgun apikey for your mail. Please use postmaster instead
   - postmaster: Mailgun sandbox domain postmaster for your mail
   - apikey: Mailgun apikey for your mail
   - to: Destination of your mail
   - from: Mailgun sender name
   - message: Message of your mail
   - subject: Subject of your mail
   - success: Was this build successful? (true/false)
   - appLink: App Release link
   - ciBuildLink: CI Build Link
   - templatePath: Mail HTML template
   - replyTo: Mail Reply to
   - attachment: Mail Attachment filenames, either an array or just one string
   - customPlaceholders: Placeholders for template given as a hash
 */
public func mailgun(mailgunSandboxDomain: String? = nil,
                    mailgunSandboxPostmaster: String? = nil,
                    mailgunApikey: String? = nil,
                    postmaster: String,
                    apikey: String,
                    to: String,
                    from: String = "Mailgun Sandbox",
                    message: String,
                    subject: String = "fastlane build",
                    success: Bool = true,
                    appLink: String,
                    ciBuildLink: String? = nil,
                    templatePath: String? = nil,
                    replyTo: String? = nil,
                    attachment: Any? = nil,
                    customPlaceholders: [String: Any] = [:])
{
    let command = RubyCommand(commandID: "", methodName: "mailgun", className: nil, args: [RubyCommand.Argument(name: "mailgun_sandbox_domain", value: mailgunSandboxDomain),
                                                                                           RubyCommand.Argument(name: "mailgun_sandbox_postmaster", value: mailgunSandboxPostmaster),
                                                                                           RubyCommand.Argument(name: "mailgun_apikey", value: mailgunApikey),
                                                                                           RubyCommand.Argument(name: "postmaster", value: postmaster),
                                                                                           RubyCommand.Argument(name: "apikey", value: apikey),
                                                                                           RubyCommand.Argument(name: "to", value: to),
                                                                                           RubyCommand.Argument(name: "from", value: from),
                                                                                           RubyCommand.Argument(name: "message", value: message),
                                                                                           RubyCommand.Argument(name: "subject", value: subject),
                                                                                           RubyCommand.Argument(name: "success", value: success),
                                                                                           RubyCommand.Argument(name: "app_link", value: appLink),
                                                                                           RubyCommand.Argument(name: "ci_build_link", value: ciBuildLink),
                                                                                           RubyCommand.Argument(name: "template_path", value: templatePath),
                                                                                           RubyCommand.Argument(name: "reply_to", value: replyTo),
                                                                                           RubyCommand.Argument(name: "attachment", value: attachment),
                                                                                           RubyCommand.Argument(name: "custom_placeholders", value: customPlaceholders)])
    _ = runner.executeCommand(command)
}

/**
 Generate a changelog using the Changes section from the current Jenkins build

 - parameters:
   - fallbackChangelog: Fallback changelog if there is not one on Jenkins, or it couldn't be read
   - includeCommitBody: Include the commit body along with the summary

 This is useful when deploying automated builds. The changelog from Jenkins lists all the commit messages since the last build.
 */
public func makeChangelogFromJenkins(fallbackChangelog: String = "",
                                     includeCommitBody: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "make_changelog_from_jenkins", className: nil, args: [RubyCommand.Argument(name: "fallback_changelog", value: fallbackChangelog),
                                                                                                               RubyCommand.Argument(name: "include_commit_body", value: includeCommitBody)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `sync_code_signing` action

 - parameters:
   - type: Define the profile type, can be appstore, adhoc, development, enterprise, developer_id, mac_installer_distribution
   - additionalCertTypes: Create additional cert types needed for macOS installers (valid values: mac_installer_distribution, developer_id_installer)
   - readonly: Only fetch existing certificates and profiles, don't generate new ones
   - generateAppleCerts: Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)
   - skipProvisioningProfiles: Skip syncing provisioning profiles
   - appIdentifier: The bundle identifier(s) of your app (comma-separated string or array of strings)
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - storageMode: Define where you want to store your certificates
   - gitUrl: URL to the git repo containing all the certificates
   - gitBranch: Specific git branch to use
   - gitFullName: git user full name to commit
   - gitUserEmail: git user email to commit
   - shallowClone: Make a shallow clone of the repository (truncate the history to 1 revision)
   - cloneBranchDirectly: Clone just the branch specified, instead of the whole repo. This requires that the branch already exists. Otherwise the command will fail
   - gitBasicAuthorization: Use a basic authorization header to access the git repo (e.g.: access via HTTPS, GitHub Actions, etc), usually a string in Base64
   - gitBearerAuthorization: Use a bearer authorization header to access the git repo (e.g.: access to an Azure DevOps repository), usually a string in Base64
   - gitPrivateKey: Use a private key to access the git repo (e.g.: access to GitHub repository via Deploy keys), usually a id_rsa named file or the contents hereof
   - googleCloudBucketName: Name of the Google Cloud Storage bucket to use
   - googleCloudKeysFile: Path to the gc_keys.json file
   - googleCloudProjectId: ID of the Google Cloud project to use for authentication
   - s3Region: Name of the S3 region
   - s3AccessKey: S3 access key
   - s3SecretAccessKey: S3 secret access key
   - s3Bucket: Name of the S3 bucket
   - s3ObjectPrefix: Prefix to be used on all objects uploaded to S3
   - keychainName: Keychain the items should be imported to
   - keychainPassword: This might be required the first time you access certificates on a new mac. For the login/default keychain this is your macOS account password
   - force: Renew the provisioning profiles every time you run match
   - forceForNewDevices: Renew the provisioning profiles if the device count on the developer portal has changed. Ignored for profile type 'appstore'
   - skipConfirmation: Disables confirmation prompts during nuke, answering them with yes
   - skipDocs: Skip generation of a README.md for the created git repository
   - platform: Set the provisioning profile's platform to work with (i.e. ios, tvos, macos, catalyst)
   - deriveCatalystAppIdentifier: Enable this if you have the Mac Catalyst capability enabled and your project was created with Xcode 11.3 or earlier. Prepends 'maccatalyst.' to the app identifier for the provisioning profile mapping
   - templateName: The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. "Apple Pay Pass Suppression Development")
   - profileName: A custom name for the provisioning profile. This will replace the default provisioning profile name if specified
   - failOnNameTaken: Should the command fail if it was about to create a duplicate of an existing provisioning profile. It can happen due to issues on Apple Developer Portal, when profile to be recreated was not properly deleted first
   - skipCertificateMatching: Set to true if there is no access to Apple developer portal but there are certificates, keys and profiles provided. Only works with match import action
   - outputPath: Path in which to export certificates, key and profile
   - skipSetPartitionList: Skips setting the partition list (which can sometimes take a long time). Setting the partition list is usually needed to prevent Xcode from prompting to allow a cert to be used for signing
   - verbose: Print out extra information and all commands

 More information: https://docs.fastlane.tools/actions/match/
 */
public func match(type: Any = matchfile.type,
                  additionalCertTypes: [String]? = matchfile.additionalCertTypes,
                  readonly: Bool = matchfile.readonly,
                  generateAppleCerts: Bool = matchfile.generateAppleCerts,
                  skipProvisioningProfiles: Bool = matchfile.skipProvisioningProfiles,
                  appIdentifier: [String] = matchfile.appIdentifier,
                  apiKeyPath: Any? = matchfile.apiKeyPath,
                  apiKey: [String: Any]? = matchfile.apiKey,
                  username: Any? = matchfile.username,
                  teamId: Any? = matchfile.teamId,
                  teamName: Any? = matchfile.teamName,
                  storageMode: Any = matchfile.storageMode,
                  gitUrl: Any = matchfile.gitUrl,
                  gitBranch: Any = matchfile.gitBranch,
                  gitFullName: Any? = matchfile.gitFullName,
                  gitUserEmail: Any? = matchfile.gitUserEmail,
                  shallowClone: Bool = matchfile.shallowClone,
                  cloneBranchDirectly: Bool = matchfile.cloneBranchDirectly,
                  gitBasicAuthorization: Any? = matchfile.gitBasicAuthorization,
                  gitBearerAuthorization: Any? = matchfile.gitBearerAuthorization,
                  gitPrivateKey: Any? = matchfile.gitPrivateKey,
                  googleCloudBucketName: Any? = matchfile.googleCloudBucketName,
                  googleCloudKeysFile: Any? = matchfile.googleCloudKeysFile,
                  googleCloudProjectId: Any? = matchfile.googleCloudProjectId,
                  s3Region: Any? = matchfile.s3Region,
                  s3AccessKey: Any? = matchfile.s3AccessKey,
                  s3SecretAccessKey: Any? = matchfile.s3SecretAccessKey,
                  s3Bucket: Any? = matchfile.s3Bucket,
                  s3ObjectPrefix: Any? = matchfile.s3ObjectPrefix,
                  keychainName: Any = matchfile.keychainName,
                  keychainPassword: Any? = matchfile.keychainPassword,
                  force: Bool = matchfile.force,
                  forceForNewDevices: Bool = matchfile.forceForNewDevices,
                  skipConfirmation: Bool = matchfile.skipConfirmation,
                  skipDocs: Bool = matchfile.skipDocs,
                  platform: Any = matchfile.platform,
                  deriveCatalystAppIdentifier: Bool = matchfile.deriveCatalystAppIdentifier,
                  templateName: Any? = matchfile.templateName,
                  profileName: Any? = matchfile.profileName,
                  failOnNameTaken: Bool = matchfile.failOnNameTaken,
                  skipCertificateMatching: Bool = matchfile.skipCertificateMatching,
                  outputPath: Any? = matchfile.outputPath,
                  skipSetPartitionList: Bool = matchfile.skipSetPartitionList,
                  verbose: Bool = matchfile.verbose)
{
    let command = RubyCommand(commandID: "", methodName: "match", className: nil, args: [RubyCommand.Argument(name: "type", value: type),
                                                                                         RubyCommand.Argument(name: "additional_cert_types", value: additionalCertTypes),
                                                                                         RubyCommand.Argument(name: "readonly", value: readonly),
                                                                                         RubyCommand.Argument(name: "generate_apple_certs", value: generateAppleCerts),
                                                                                         RubyCommand.Argument(name: "skip_provisioning_profiles", value: skipProvisioningProfiles),
                                                                                         RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                         RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                         RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                         RubyCommand.Argument(name: "username", value: username),
                                                                                         RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                         RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                         RubyCommand.Argument(name: "storage_mode", value: storageMode),
                                                                                         RubyCommand.Argument(name: "git_url", value: gitUrl),
                                                                                         RubyCommand.Argument(name: "git_branch", value: gitBranch),
                                                                                         RubyCommand.Argument(name: "git_full_name", value: gitFullName),
                                                                                         RubyCommand.Argument(name: "git_user_email", value: gitUserEmail),
                                                                                         RubyCommand.Argument(name: "shallow_clone", value: shallowClone),
                                                                                         RubyCommand.Argument(name: "clone_branch_directly", value: cloneBranchDirectly),
                                                                                         RubyCommand.Argument(name: "git_basic_authorization", value: gitBasicAuthorization),
                                                                                         RubyCommand.Argument(name: "git_bearer_authorization", value: gitBearerAuthorization),
                                                                                         RubyCommand.Argument(name: "git_private_key", value: gitPrivateKey),
                                                                                         RubyCommand.Argument(name: "google_cloud_bucket_name", value: googleCloudBucketName),
                                                                                         RubyCommand.Argument(name: "google_cloud_keys_file", value: googleCloudKeysFile),
                                                                                         RubyCommand.Argument(name: "google_cloud_project_id", value: googleCloudProjectId),
                                                                                         RubyCommand.Argument(name: "s3_region", value: s3Region),
                                                                                         RubyCommand.Argument(name: "s3_access_key", value: s3AccessKey),
                                                                                         RubyCommand.Argument(name: "s3_secret_access_key", value: s3SecretAccessKey),
                                                                                         RubyCommand.Argument(name: "s3_bucket", value: s3Bucket),
                                                                                         RubyCommand.Argument(name: "s3_object_prefix", value: s3ObjectPrefix),
                                                                                         RubyCommand.Argument(name: "keychain_name", value: keychainName),
                                                                                         RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                         RubyCommand.Argument(name: "force", value: force),
                                                                                         RubyCommand.Argument(name: "force_for_new_devices", value: forceForNewDevices),
                                                                                         RubyCommand.Argument(name: "skip_confirmation", value: skipConfirmation),
                                                                                         RubyCommand.Argument(name: "skip_docs", value: skipDocs),
                                                                                         RubyCommand.Argument(name: "platform", value: platform),
                                                                                         RubyCommand.Argument(name: "derive_catalyst_app_identifier", value: deriveCatalystAppIdentifier),
                                                                                         RubyCommand.Argument(name: "template_name", value: templateName),
                                                                                         RubyCommand.Argument(name: "profile_name", value: profileName),
                                                                                         RubyCommand.Argument(name: "fail_on_name_taken", value: failOnNameTaken),
                                                                                         RubyCommand.Argument(name: "skip_certificate_matching", value: skipCertificateMatching),
                                                                                         RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                         RubyCommand.Argument(name: "skip_set_partition_list", value: skipSetPartitionList),
                                                                                         RubyCommand.Argument(name: "verbose", value: verbose)])
    _ = runner.executeCommand(command)
}

/**
 Verifies the minimum fastlane version required

 Add this to your `Fastfile` to require a certain version of _fastlane_.
 Use it if you use an action that just recently came out and you need it.
 */
public func minFastlaneVersion() {
    let command = RubyCommand(commandID: "", methodName: "min_fastlane_version", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Modifies the services of the app created on Developer Portal

 - parameters:
   - username: Your Apple ID Username
   - appIdentifier: App Identifier (Bundle ID, e.g. com.krausefx.app)
   - services: Array with Spaceship App Services (e.g. access_wifi: (on|off)(:on|:off)(true|false), app_group: (on|off)(:on|:off)(true|false), apple_pay: (on|off)(:on|:off)(true|false), associated_domains: (on|off)(:on|:off)(true|false), auto_fill_credential: (on|off)(:on|:off)(true|false), data_protection: (complete|unlessopen|untilfirstauth)(:on|:off)(true|false), game_center: (on|off)(:on|:off)(true|false), health_kit: (on|off)(:on|:off)(true|false), home_kit: (on|off)(:on|:off)(true|false), hotspot: (on|off)(:on|:off)(true|false), icloud: (legacy|cloudkit)(:on|:off)(true|false), in_app_purchase: (on|off)(:on|:off)(true|false), inter_app_audio: (on|off)(:on|:off)(true|false), multipath: (on|off)(:on|:off)(true|false), network_extension: (on|off)(:on|:off)(true|false), nfc_tag_reading: (on|off)(:on|:off)(true|false), personal_vpn: (on|off)(:on|:off)(true|false), passbook: (on|off)(:on|:off)(true|false), push_notification: (on|off)(:on|:off)(true|false), siri_kit: (on|off)(:on|:off)(true|false), vpn_configuration: (on|off)(:on|:off)(true|false), wallet: (on|off)(:on|:off)(true|false), wireless_accessory: (on|off)(:on|:off)(true|false))
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams

 The options are the same as `:enable_services` in the [produce action](https://docs.fastlane.tools/actions/produce/#parameters_1)
 */
public func modifyServices(username: String,
                           appIdentifier: String,
                           services: [String: Any] = [:],
                           teamId: String? = nil,
                           teamName: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "modify_services", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                   RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                   RubyCommand.Argument(name: "services", value: services),
                                                                                                   RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                   RubyCommand.Argument(name: "team_name", value: teamName)])
    _ = runner.executeCommand(command)
}

/**
 Upload a file to [Sonatype Nexus platform](https://www.sonatype.com)

 - parameters:
   - file: File to be uploaded to Nexus
   - repoId: Nexus repository id e.g. artefacts
   - repoGroupId: Nexus repository group id e.g. com.company
   - repoProjectName: Nexus repository commandect name. Only letters, digits, underscores(_), hyphens(-), and dots(.) are allowed
   - repoProjectVersion: Nexus repository commandect version
   - repoClassifier: Nexus repository artifact classifier (optional)
   - endpoint: Nexus endpoint e.g. http://nexus:8081
   - mountPath: Nexus mount path (Nexus 3 instances have this configured as empty by default)
   - username: Nexus username
   - password: Nexus password
   - sslVerify: Verify SSL
   - nexusVersion: Nexus major version
   - verbose: Make detailed output
   - proxyUsername: Proxy username
   - proxyPassword: Proxy password
   - proxyAddress: Proxy address
   - proxyPort: Proxy port
 */
public func nexusUpload(file: String,
                        repoId: String,
                        repoGroupId: String,
                        repoProjectName: String,
                        repoProjectVersion: String,
                        repoClassifier: String? = nil,
                        endpoint: String,
                        mountPath: String = "/nexus",
                        username: String,
                        password: String,
                        sslVerify: Bool = true,
                        nexusVersion: Int = 2,
                        verbose: Bool = false,
                        proxyUsername: String? = nil,
                        proxyPassword: String? = nil,
                        proxyAddress: String? = nil,
                        proxyPort: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "nexus_upload", className: nil, args: [RubyCommand.Argument(name: "file", value: file),
                                                                                                RubyCommand.Argument(name: "repo_id", value: repoId),
                                                                                                RubyCommand.Argument(name: "repo_group_id", value: repoGroupId),
                                                                                                RubyCommand.Argument(name: "repo_project_name", value: repoProjectName),
                                                                                                RubyCommand.Argument(name: "repo_project_version", value: repoProjectVersion),
                                                                                                RubyCommand.Argument(name: "repo_classifier", value: repoClassifier),
                                                                                                RubyCommand.Argument(name: "endpoint", value: endpoint),
                                                                                                RubyCommand.Argument(name: "mount_path", value: mountPath),
                                                                                                RubyCommand.Argument(name: "username", value: username),
                                                                                                RubyCommand.Argument(name: "password", value: password),
                                                                                                RubyCommand.Argument(name: "ssl_verify", value: sslVerify),
                                                                                                RubyCommand.Argument(name: "nexus_version", value: nexusVersion),
                                                                                                RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                                RubyCommand.Argument(name: "proxy_username", value: proxyUsername),
                                                                                                RubyCommand.Argument(name: "proxy_password", value: proxyPassword),
                                                                                                RubyCommand.Argument(name: "proxy_address", value: proxyAddress),
                                                                                                RubyCommand.Argument(name: "proxy_port", value: proxyPort)])
    _ = runner.executeCommand(command)
}

/**
 Notarizes a macOS app

 - parameters:
   - package: Path to package to notarize, e.g. .app bundle or disk image
   - tryEarlyStapling: Whether to try early stapling while the notarization request is in progress
   - bundleId: Bundle identifier to uniquely identify the package
   - username: Apple ID username
   - ascProvider: Provider short name for accounts associated with multiple providers
   - printLog: Whether to print notarization log file, listing issues on failure and warnings on success
   - verbose: Whether to log requests
 */
public func notarize(package: String,
                     tryEarlyStapling: Bool = false,
                     bundleId: String? = nil,
                     username: String,
                     ascProvider: String? = nil,
                     printLog: Bool = false,
                     verbose: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "notarize", className: nil, args: [RubyCommand.Argument(name: "package", value: package),
                                                                                            RubyCommand.Argument(name: "try_early_stapling", value: tryEarlyStapling),
                                                                                            RubyCommand.Argument(name: "bundle_id", value: bundleId),
                                                                                            RubyCommand.Argument(name: "username", value: username),
                                                                                            RubyCommand.Argument(name: "asc_provider", value: ascProvider),
                                                                                            RubyCommand.Argument(name: "print_log", value: printLog),
                                                                                            RubyCommand.Argument(name: "verbose", value: verbose)])
    _ = runner.executeCommand(command)
}

/**
 Display a macOS notification with custom message and title

 - parameters:
   - title: The title to display in the notification
   - subtitle: A subtitle to display in the notification
   - message: The message to display in the notification
   - sound: The name of a sound to play when the notification appears (names are listed in Sound Preferences)
   - activate: Bundle identifier of application to be opened when the notification is clicked
   - appIcon: The URL of an image to display instead of the application icon (Mavericks+ only)
   - contentImage: The URL of an image to display attached to the notification (Mavericks+ only)
   - open: URL of the resource to be opened when the notification is clicked
   - execute: Shell command to run when the notification is clicked
 */
public func notification(title: String = "fastlane",
                         subtitle: String? = nil,
                         message: String,
                         sound: String? = nil,
                         activate: String? = nil,
                         appIcon: String? = nil,
                         contentImage: String? = nil,
                         open: String? = nil,
                         execute: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "notification", className: nil, args: [RubyCommand.Argument(name: "title", value: title),
                                                                                                RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                                RubyCommand.Argument(name: "message", value: message),
                                                                                                RubyCommand.Argument(name: "sound", value: sound),
                                                                                                RubyCommand.Argument(name: "activate", value: activate),
                                                                                                RubyCommand.Argument(name: "app_icon", value: appIcon),
                                                                                                RubyCommand.Argument(name: "content_image", value: contentImage),
                                                                                                RubyCommand.Argument(name: "open", value: open),
                                                                                                RubyCommand.Argument(name: "execute", value: execute)])
    _ = runner.executeCommand(command)
}

/**
 Shows a macOS notification - use `notification` instead
 */
public func notify() {
    let command = RubyCommand(commandID: "", methodName: "notify", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Return the number of commits in current git branch

 - parameter all: Returns number of all commits instead of current branch

 - returns: The total number of all commits in current git branch

 You can use this action to get the number of commits of this branch. This is useful if you want to set the build number to the number of commits. See `fastlane actions number_of_commits` for more details.
 */
@discardableResult public func numberOfCommits(all: Any? = nil) -> Int {
    let command = RubyCommand(commandID: "", methodName: "number_of_commits", className: nil, args: [RubyCommand.Argument(name: "all", value: all)])
    return parseInt(fromString: runner.executeCommand(command))
}

/**
 Lints implementation files with OCLint

 - parameters:
   - oclintPath: The path to oclint binary
   - compileCommands: The json compilation database, use xctool reporter 'json-compilation-database'
   - selectReqex: Select all files matching this reqex
   - selectRegex: Select all files matching this regex
   - excludeRegex: Exclude all files matching this regex
   - reportType: The type of the report (default: html)
   - reportPath: The reports file path
   - listEnabledRules: List enabled rules
   - rc: Override the default behavior of rules
   - thresholds: List of rule thresholds to override the default behavior of rules
   - enableRules: List of rules to pick explicitly
   - disableRules: List of rules to disable
   - maxPriority1: The max allowed number of priority 1 violations
   - maxPriority2: The max allowed number of priority 2 violations
   - maxPriority3: The max allowed number of priority 3 violations
   - enableClangStaticAnalyzer: Enable Clang Static Analyzer, and integrate results into OCLint report
   - enableGlobalAnalysis: Compile every source, and analyze across global contexts (depends on number of source files, could results in high memory load)
   - allowDuplicatedViolations: Allow duplicated violations in the OCLint report
   - extraArg: Additional argument to append to the compiler command line

 Run the static analyzer tool [OCLint](http://oclint.org) for your project. You need to have a `compile_commands.json` file in your _fastlane_ directory or pass a path to your file.
 */
public func oclint(oclintPath: String = "oclint",
                   compileCommands: String = "compile_commands.json",
                   selectReqex: Any? = nil,
                   selectRegex: Any? = nil,
                   excludeRegex: Any? = nil,
                   reportType: String = "html",
                   reportPath: String? = nil,
                   listEnabledRules: Bool = false,
                   rc: String? = nil,
                   thresholds: Any? = nil,
                   enableRules: Any? = nil,
                   disableRules: Any? = nil,
                   maxPriority1: Any? = nil,
                   maxPriority2: Any? = nil,
                   maxPriority3: Any? = nil,
                   enableClangStaticAnalyzer: Bool = false,
                   enableGlobalAnalysis: Bool = false,
                   allowDuplicatedViolations: Bool = false,
                   extraArg: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "oclint", className: nil, args: [RubyCommand.Argument(name: "oclint_path", value: oclintPath),
                                                                                          RubyCommand.Argument(name: "compile_commands", value: compileCommands),
                                                                                          RubyCommand.Argument(name: "select_reqex", value: selectReqex),
                                                                                          RubyCommand.Argument(name: "select_regex", value: selectRegex),
                                                                                          RubyCommand.Argument(name: "exclude_regex", value: excludeRegex),
                                                                                          RubyCommand.Argument(name: "report_type", value: reportType),
                                                                                          RubyCommand.Argument(name: "report_path", value: reportPath),
                                                                                          RubyCommand.Argument(name: "list_enabled_rules", value: listEnabledRules),
                                                                                          RubyCommand.Argument(name: "rc", value: rc),
                                                                                          RubyCommand.Argument(name: "thresholds", value: thresholds),
                                                                                          RubyCommand.Argument(name: "enable_rules", value: enableRules),
                                                                                          RubyCommand.Argument(name: "disable_rules", value: disableRules),
                                                                                          RubyCommand.Argument(name: "max_priority_1", value: maxPriority1),
                                                                                          RubyCommand.Argument(name: "max_priority_2", value: maxPriority2),
                                                                                          RubyCommand.Argument(name: "max_priority_3", value: maxPriority3),
                                                                                          RubyCommand.Argument(name: "enable_clang_static_analyzer", value: enableClangStaticAnalyzer),
                                                                                          RubyCommand.Argument(name: "enable_global_analysis", value: enableGlobalAnalysis),
                                                                                          RubyCommand.Argument(name: "allow_duplicated_violations", value: allowDuplicatedViolations),
                                                                                          RubyCommand.Argument(name: "extra_arg", value: extraArg)])
    _ = runner.executeCommand(command)
}

/**
 Create or update a new [OneSignal](https://onesignal.com/) application

 - parameters:
   - appId: OneSignal App ID. Setting this updates an existing app
   - authToken: OneSignal Authorization Key
   - appName: OneSignal App Name. This is required when creating an app (in other words, when `:app_id` is not set, and optional when updating an app
   - androidToken: ANDROID GCM KEY
   - androidGcmSenderId: GCM SENDER ID
   - apnsP12: APNS P12 File (in .p12 format)
   - apnsP12Password: APNS P12 password
   - apnsEnv: APNS environment
   - organizationId: OneSignal Organization ID

 You can use this action to automatically create or update a OneSignal application. You can also upload a `.p12` with password, a GCM key, or both.
 */
public func onesignal(appId: String? = nil,
                      authToken: String,
                      appName: String? = nil,
                      androidToken: String? = nil,
                      androidGcmSenderId: String? = nil,
                      apnsP12: String? = nil,
                      apnsP12Password: String? = nil,
                      apnsEnv: String = "production",
                      organizationId: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "onesignal", className: nil, args: [RubyCommand.Argument(name: "app_id", value: appId),
                                                                                             RubyCommand.Argument(name: "auth_token", value: authToken),
                                                                                             RubyCommand.Argument(name: "app_name", value: appName),
                                                                                             RubyCommand.Argument(name: "android_token", value: androidToken),
                                                                                             RubyCommand.Argument(name: "android_gcm_sender_id", value: androidGcmSenderId),
                                                                                             RubyCommand.Argument(name: "apns_p12", value: apnsP12),
                                                                                             RubyCommand.Argument(name: "apns_p12_password", value: apnsP12Password),
                                                                                             RubyCommand.Argument(name: "apns_env", value: apnsEnv),
                                                                                             RubyCommand.Argument(name: "organization_id", value: organizationId)])
    _ = runner.executeCommand(command)
}

/**
 This will prevent reports from being uploaded when _fastlane_ crashes

 _fastlane_ doesn't have crash reporting any more. Feel free to remove `opt_out_crash_reporting` from your Fastfile.
 */
public func optOutCrashReporting() {
    let command = RubyCommand(commandID: "", methodName: "opt_out_crash_reporting", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 This will stop uploading the information which actions were run

 By default, _fastlane_ will track what actions are being used. No personal/sensitive information is recorded.
 Learn more at [https://docs.fastlane.tools/#metrics](https://docs.fastlane.tools/#metrics).
 Add `opt_out_usage` at the top of your Fastfile to disable metrics collection.
 */
public func optOutUsage() {
    let command = RubyCommand(commandID: "", methodName: "opt_out_usage", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `get_push_certificate` action

 - parameters:
   - development: Renew the development push certificate instead of the production one
   - websitePush: Create a Website Push certificate
   - generateP12: Generate a p12 file additionally to a PEM file
   - activeDaysLimit: If the current certificate is active for less than this number of days, generate a new one
   - force: Create a new push certificate, even if the current one is active for 30 (or PEM_ACTIVE_DAYS_LIMIT) more days
   - savePrivateKey: Set to save the private RSA key
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - p12Password: The password that is used for your p12 file
   - pemName: The file name of the generated .pem file
   - outputPath: The path to a directory in which all certificates and private keys should be stored
   - newProfile: Block that is called if there is a new profile

 Additionally to the available options, you can also specify a block that only gets executed if a new profile was created. You can use it to upload the new profile to your server.
 Use it like this:|
 |
 ```ruby|
 get_push_certificate(|
   new_profile: proc do|
     # your upload code|
   end|
 )|
 ```|
 >|
 */
public func pem(development: Bool = false,
                websitePush: Bool = false,
                generateP12: Bool = true,
                activeDaysLimit: Int = 30,
                force: Bool = false,
                savePrivateKey: Bool = true,
                appIdentifier: String,
                username: String,
                teamId: String? = nil,
                teamName: String? = nil,
                p12Password: String,
                pemName: String? = nil,
                outputPath: String = ".",
                newProfile: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "pem", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
                                                                                       RubyCommand.Argument(name: "website_push", value: websitePush),
                                                                                       RubyCommand.Argument(name: "generate_p12", value: generateP12),
                                                                                       RubyCommand.Argument(name: "active_days_limit", value: activeDaysLimit),
                                                                                       RubyCommand.Argument(name: "force", value: force),
                                                                                       RubyCommand.Argument(name: "save_private_key", value: savePrivateKey),
                                                                                       RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                       RubyCommand.Argument(name: "username", value: username),
                                                                                       RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                       RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                       RubyCommand.Argument(name: "p12_password", value: p12Password),
                                                                                       RubyCommand.Argument(name: "pem_name", value: pemName),
                                                                                       RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                       RubyCommand.Argument(name: "new_profile", value: newProfile)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `upload_to_testflight` action

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - appIdentifier: The bundle identifier of the app to upload or manage testers (optional)
   - appPlatform: The platform to use (optional)
   - appleId: Apple ID property in the App Information section in App Store Connect
   - ipa: Path to the ipa file to upload
   - demoAccountRequired: Do you need a demo account when Apple does review?
   - betaAppReviewInfo: Beta app review information for contact info and demo account
   - localizedAppInfo: Localized beta app test info for description, feedback email, marketing url, and privacy policy
   - betaAppDescription: Provide the 'Beta App Description' when uploading a new build
   - betaAppFeedbackEmail: Provide the beta app email when uploading a new build
   - localizedBuildInfo: Localized beta app test info for what's new
   - changelog: Provide the 'What to Test' text when uploading a new build
   - skipSubmission: Skip the distributing action of pilot and only upload the ipa file
   - skipWaitingForBuildProcessing: If set to true, the `distribute_external` option won't work and no build will be distributed to testers. (You might want to use this option if you are using this action on CI and have to pay for 'minutes used' on your CI plan). If set to `true` and a changelog is provided, it will partially wait for the build to appear on AppStore Connect so the changelog can be set, and skip the remaining processing steps
   - updateBuildInfoOnUpload: **DEPRECATED!** Update build info immediately after validation. This is deprecated and will be removed in a future release. App Store Connect no longer supports setting build info until after build processing has completed, which is when build info is updated by default
   - distributeOnly: Distribute a previously uploaded build (equivalent to the `fastlane pilot distribute` command)
   - usesNonExemptEncryption: Provide the 'Uses Non-Exempt Encryption' for export compliance. This is used if there is 'ITSAppUsesNonExemptEncryption' is not set in the Info.plist
   - distributeExternal: Should the build be distributed to external testers?
   - notifyExternalTesters: Should notify external testers?
   - appVersion: The version number of the application build to distribute. If the version number is not specified, then the most recent build uploaded to TestFlight will be distributed. If specified, the most recent build for the version number will be distributed
   - buildNumber: The build number of the application build to distribute. If the build number is not specified, the most recent build is distributed
   - expirePreviousBuilds: Should expire previous builds?
   - firstName: The tester's first name
   - lastName: The tester's last name
   - email: The tester's email
   - testersFilePath: Path to a CSV file of testers
   - groups: Associate tester to one group or more by group name / group id. E.g. `-g "Team 1","Team 2"`
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - devPortalTeamId: The short ID of your team in the developer portal, if you're in multiple teams. Different from your iTC team ID!
   - itcProvider: The provider short name to be used with the iTMSTransporter to identify your team. This value will override the automatically detected provider short name. To get provider short name run `pathToXcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m provider -u 'USERNAME' -p 'PASSWORD' -account_type itunes_connect -v off`. The short names of providers should be listed in the second column
   - waitProcessingInterval: Interval in seconds to wait for App Store Connect processing
   - waitForUploadedBuild: **DEPRECATED!** No longer needed with the transition over to the App Store Connect API - Use version info from uploaded ipa file to determine what build to use for distribution. If set to false, latest processing or any latest build will be used
   - rejectBuildWaitingForReview: Expire previous if it's 'waiting for review'

 More details can be found on https://docs.fastlane.tools/actions/pilot/.
 This integration will only do the TestFlight upload.
 */
public func pilot(apiKeyPath: String? = nil,
                  apiKey: [String: Any]? = nil,
                  username: String,
                  appIdentifier: String? = nil,
                  appPlatform: String = "ios",
                  appleId: String? = nil,
                  ipa: String? = nil,
                  demoAccountRequired: Bool? = nil,
                  betaAppReviewInfo: [String: Any]? = nil,
                  localizedAppInfo: [String: Any]? = nil,
                  betaAppDescription: String? = nil,
                  betaAppFeedbackEmail: String? = nil,
                  localizedBuildInfo: [String: Any]? = nil,
                  changelog: String? = nil,
                  skipSubmission: Bool = false,
                  skipWaitingForBuildProcessing: Bool = false,
                  updateBuildInfoOnUpload: Bool = false,
                  distributeOnly: Bool = false,
                  usesNonExemptEncryption: Bool = false,
                  distributeExternal: Bool = false,
                  notifyExternalTesters: Bool = true,
                  appVersion: String? = nil,
                  buildNumber: String? = nil,
                  expirePreviousBuilds: Bool = false,
                  firstName: String? = nil,
                  lastName: String? = nil,
                  email: String? = nil,
                  testersFilePath: String = "./testers.csv",
                  groups: [String]? = nil,
                  teamId: Any? = nil,
                  teamName: String? = nil,
                  devPortalTeamId: String? = nil,
                  itcProvider: String? = nil,
                  waitProcessingInterval: Int = 30,
                  waitForUploadedBuild: Bool = false,
                  rejectBuildWaitingForReview: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "pilot", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                         RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                         RubyCommand.Argument(name: "username", value: username),
                                                                                         RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                         RubyCommand.Argument(name: "app_platform", value: appPlatform),
                                                                                         RubyCommand.Argument(name: "apple_id", value: appleId),
                                                                                         RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                         RubyCommand.Argument(name: "demo_account_required", value: demoAccountRequired),
                                                                                         RubyCommand.Argument(name: "beta_app_review_info", value: betaAppReviewInfo),
                                                                                         RubyCommand.Argument(name: "localized_app_info", value: localizedAppInfo),
                                                                                         RubyCommand.Argument(name: "beta_app_description", value: betaAppDescription),
                                                                                         RubyCommand.Argument(name: "beta_app_feedback_email", value: betaAppFeedbackEmail),
                                                                                         RubyCommand.Argument(name: "localized_build_info", value: localizedBuildInfo),
                                                                                         RubyCommand.Argument(name: "changelog", value: changelog),
                                                                                         RubyCommand.Argument(name: "skip_submission", value: skipSubmission),
                                                                                         RubyCommand.Argument(name: "skip_waiting_for_build_processing", value: skipWaitingForBuildProcessing),
                                                                                         RubyCommand.Argument(name: "update_build_info_on_upload", value: updateBuildInfoOnUpload),
                                                                                         RubyCommand.Argument(name: "distribute_only", value: distributeOnly),
                                                                                         RubyCommand.Argument(name: "uses_non_exempt_encryption", value: usesNonExemptEncryption),
                                                                                         RubyCommand.Argument(name: "distribute_external", value: distributeExternal),
                                                                                         RubyCommand.Argument(name: "notify_external_testers", value: notifyExternalTesters),
                                                                                         RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                         RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                         RubyCommand.Argument(name: "expire_previous_builds", value: expirePreviousBuilds),
                                                                                         RubyCommand.Argument(name: "first_name", value: firstName),
                                                                                         RubyCommand.Argument(name: "last_name", value: lastName),
                                                                                         RubyCommand.Argument(name: "email", value: email),
                                                                                         RubyCommand.Argument(name: "testers_file_path", value: testersFilePath),
                                                                                         RubyCommand.Argument(name: "groups", value: groups),
                                                                                         RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                         RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                         RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId),
                                                                                         RubyCommand.Argument(name: "itc_provider", value: itcProvider),
                                                                                         RubyCommand.Argument(name: "wait_processing_interval", value: waitProcessingInterval),
                                                                                         RubyCommand.Argument(name: "wait_for_uploaded_build", value: waitForUploadedBuild),
                                                                                         RubyCommand.Argument(name: "reject_build_waiting_for_review", value: rejectBuildWaitingForReview)])
    _ = runner.executeCommand(command)
}

/**
 [31mNo description provided[0m

 - parameters:
   - outputPath:
   - templatePath:
   - cachePath:
 */
public func pluginScores(outputPath: String,
                         templatePath: String,
                         cachePath: String)
{
    let command = RubyCommand(commandID: "", methodName: "plugin_scores", className: nil, args: [RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                 RubyCommand.Argument(name: "template_path", value: templatePath),
                                                                                                 RubyCommand.Argument(name: "cache_path", value: cachePath)])
    _ = runner.executeCommand(command)
}

/**
 Pod lib lint

 - parameters:
   - useBundleExec: Use bundle exec when there is a Gemfile presented
   - podspec: Path of spec to lint
   - verbose: Allow output detail in console
   - allowWarnings: Allow warnings during pod lint
   - sources: The sources of repos you want the pod spec to lint with, separated by commas
   - subspec: A specific subspec to lint instead of the entire spec
   - includePodspecs: A Glob of additional ancillary podspecs which are used for linting via :path (available since cocoapods >= 1.7)
   - externalPodspecs: A Glob of additional ancillary podspecs which are used for linting via :podspec. If there are --include-podspecs, then these are removed from them (available since cocoapods >= 1.7)
   - swiftVersion: The SWIFT_VERSION that should be used to lint the spec. This takes precedence over a .swift-version file
   - useLibraries: Lint uses static libraries to install the spec
   - useModularHeaders: Lint using modular libraries (available since cocoapods >= 1.6)
   - failFast: Lint stops on the first failing platform or subspec
   - private: Lint skips checks that apply only to public specs
   - quick: Lint skips checks that would require to download and build the spec
   - noClean: Lint leaves the build directory intact for inspection
   - noSubspecs: Lint skips validation of subspecs
   - platforms: Lint against specific platforms (defaults to all platforms supported by the podspec). Multiple platforms must be comma-delimited (available since cocoapods >= 1.6)
   - skipImportValidation: Lint skips validating that the pod can be imported (available since cocoapods >= 1.3)
   - skipTests: Lint skips building and running tests during validation (available since cocoapods >= 1.3)
   - analyze: Validate with the Xcode Static Analysis tool (available since cocoapods >= 1.6.1)

 Test the syntax of your Podfile by linting the pod against the files of its directory
 */
public func podLibLint(useBundleExec: Bool = true,
                       podspec: String? = nil,
                       verbose: Bool? = nil,
                       allowWarnings: Bool? = nil,
                       sources: [String]? = nil,
                       subspec: String? = nil,
                       includePodspecs: String? = nil,
                       externalPodspecs: String? = nil,
                       swiftVersion: String? = nil,
                       useLibraries: Bool = false,
                       useModularHeaders: Bool = false,
                       failFast: Bool = false,
                       private: Bool = false,
                       quick: Bool = false,
                       noClean: Bool = false,
                       noSubspecs: Bool = false,
                       platforms: String? = nil,
                       skipImportValidation: Bool = false,
                       skipTests: Bool = false,
                       analyze: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "pod_lib_lint", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                                RubyCommand.Argument(name: "podspec", value: podspec),
                                                                                                RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                                RubyCommand.Argument(name: "allow_warnings", value: allowWarnings),
                                                                                                RubyCommand.Argument(name: "sources", value: sources),
                                                                                                RubyCommand.Argument(name: "subspec", value: subspec),
                                                                                                RubyCommand.Argument(name: "include_podspecs", value: includePodspecs),
                                                                                                RubyCommand.Argument(name: "external_podspecs", value: externalPodspecs),
                                                                                                RubyCommand.Argument(name: "swift_version", value: swiftVersion),
                                                                                                RubyCommand.Argument(name: "use_libraries", value: useLibraries),
                                                                                                RubyCommand.Argument(name: "use_modular_headers", value: useModularHeaders),
                                                                                                RubyCommand.Argument(name: "fail_fast", value: failFast),
                                                                                                RubyCommand.Argument(name: "private", value: `private`),
                                                                                                RubyCommand.Argument(name: "quick", value: quick),
                                                                                                RubyCommand.Argument(name: "no_clean", value: noClean),
                                                                                                RubyCommand.Argument(name: "no_subspecs", value: noSubspecs),
                                                                                                RubyCommand.Argument(name: "platforms", value: platforms),
                                                                                                RubyCommand.Argument(name: "skip_import_validation", value: skipImportValidation),
                                                                                                RubyCommand.Argument(name: "skip_tests", value: skipTests),
                                                                                                RubyCommand.Argument(name: "analyze", value: analyze)])
    _ = runner.executeCommand(command)
}

/**
 Push a Podspec to Trunk or a private repository

 - parameters:
   - useBundleExec: Use bundle exec when there is a Gemfile presented
   - path: The Podspec you want to push
   - repo: The repo you want to push. Pushes to Trunk by default
   - allowWarnings: Allow warnings during pod push
   - useLibraries: Allow lint to use static libraries to install the spec
   - sources: The sources of repos you want the pod spec to lint with, separated by commas
   - swiftVersion: The SWIFT_VERSION that should be used to lint the spec. This takes precedence over a .swift-version file
   - skipImportValidation: Lint skips validating that the pod can be imported
   - skipTests: Lint skips building and running tests during validation
   - useJson: Convert the podspec to JSON before pushing it to the repo
   - verbose: Show more debugging information
   - useModularHeaders: Use modular headers option during validation
   - synchronous: If validation depends on other recently pushed pods, synchronize
 */
public func podPush(useBundleExec: Bool = false,
                    path: String? = nil,
                    repo: String? = nil,
                    allowWarnings: Bool? = nil,
                    useLibraries: Bool? = nil,
                    sources: [String]? = nil,
                    swiftVersion: String? = nil,
                    skipImportValidation: Bool? = nil,
                    skipTests: Bool? = nil,
                    useJson: Bool? = nil,
                    verbose: Bool = false,
                    useModularHeaders: Bool? = nil,
                    synchronous: Bool? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "pod_push", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                            RubyCommand.Argument(name: "path", value: path),
                                                                                            RubyCommand.Argument(name: "repo", value: repo),
                                                                                            RubyCommand.Argument(name: "allow_warnings", value: allowWarnings),
                                                                                            RubyCommand.Argument(name: "use_libraries", value: useLibraries),
                                                                                            RubyCommand.Argument(name: "sources", value: sources),
                                                                                            RubyCommand.Argument(name: "swift_version", value: swiftVersion),
                                                                                            RubyCommand.Argument(name: "skip_import_validation", value: skipImportValidation),
                                                                                            RubyCommand.Argument(name: "skip_tests", value: skipTests),
                                                                                            RubyCommand.Argument(name: "use_json", value: useJson),
                                                                                            RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                            RubyCommand.Argument(name: "use_modular_headers", value: useModularHeaders),
                                                                                            RubyCommand.Argument(name: "synchronous", value: synchronous)])
    _ = runner.executeCommand(command)
}

/**
 Creates or updates an item within your Podio app

 - parameters:
   - clientId: Client ID for Podio API (see https://developers.podio.com/api-key)
   - clientSecret: Client secret for Podio API (see https://developers.podio.com/api-key)
   - appId: App ID of the app you intend to authenticate with (see https://developers.podio.com/authentication/app_auth)
   - appToken: App token of the app you intend to authenticate with (see https://developers.podio.com/authentication/app_auth)
   - identifyingField: String specifying the field key used for identification of an item
   - identifyingValue: String uniquely specifying an item within the app
   - otherFields: Dictionary of your app fields. Podio supports several field types, see https://developers.podio.com/doc/items

 Use this action to create or update an item within your Podio app (see [https://help.podio.com/hc/en-us/articles/201019278-Creating-apps-](https://help.podio.com/hc/en-us/articles/201019278-Creating-apps-)).
 Pass in dictionary with field keys and their values.
 Field key is located under `Modify app` -> `Advanced` -> `Developer` -> `External ID` (see [https://developers.podio.com/examples/items](https://developers.podio.com/examples/items)).
 */
public func podioItem(clientId: String,
                      clientSecret: String,
                      appId: String,
                      appToken: String,
                      identifyingField: String,
                      identifyingValue: String,
                      otherFields: [String: Any]? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "podio_item", className: nil, args: [RubyCommand.Argument(name: "client_id", value: clientId),
                                                                                              RubyCommand.Argument(name: "client_secret", value: clientSecret),
                                                                                              RubyCommand.Argument(name: "app_id", value: appId),
                                                                                              RubyCommand.Argument(name: "app_token", value: appToken),
                                                                                              RubyCommand.Argument(name: "identifying_field", value: identifyingField),
                                                                                              RubyCommand.Argument(name: "identifying_value", value: identifyingValue),
                                                                                              RubyCommand.Argument(name: "other_fields", value: otherFields)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `check_app_store_metadata` action

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - platform: The platform to use (optional)
   - defaultRuleLevel: The default rule level unless otherwise configured
   - includeInAppPurchases: Should check in-app purchases?
   - useLive: Should force check live app?
   - freeStuffInIap: using text indicating that your IAP is free

 - returns: true if precheck passes, else, false

 More information: https://fastlane.tools/precheck
 */
public func precheck(apiKeyPath: Any? = precheckfile.apiKeyPath,
                     apiKey: [String: Any]? = precheckfile.apiKey,
                     appIdentifier: Any = precheckfile.appIdentifier,
                     username: Any = precheckfile.username,
                     teamId: Any? = precheckfile.teamId,
                     teamName: Any? = precheckfile.teamName,
                     platform: Any = precheckfile.platform,
                     defaultRuleLevel: Any = precheckfile.defaultRuleLevel,
                     includeInAppPurchases: Bool = precheckfile.includeInAppPurchases,
                     useLive: Bool = precheckfile.useLive,
                     freeStuffInIap: Any? = precheckfile.freeStuffInIap)
{
    let command = RubyCommand(commandID: "", methodName: "precheck", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                            RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                            RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                            RubyCommand.Argument(name: "username", value: username),
                                                                                            RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                            RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                            RubyCommand.Argument(name: "platform", value: platform),
                                                                                            RubyCommand.Argument(name: "default_rule_level", value: defaultRuleLevel),
                                                                                            RubyCommand.Argument(name: "include_in_app_purchases", value: includeInAppPurchases),
                                                                                            RubyCommand.Argument(name: "use_live", value: useLive),
                                                                                            RubyCommand.Argument(name: "free_stuff_in_iap", value: freeStuffInIap)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `puts` action

 - parameter message: Message to be printed out
 */
public func println(message: String? = nil) {
    let command = RubyCommand(commandID: "", methodName: "println", className: nil, args: [RubyCommand.Argument(name: "message", value: message)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `create_app_online` action

 - parameters:
   - username: Your Apple ID Username
   - appIdentifier: App Identifier (Bundle ID, e.g. com.krausefx.app)
   - bundleIdentifierSuffix: App Identifier Suffix (Ignored if App Identifier does not end with .*)
   - appName: App Name
   - appVersion: Initial version number (e.g. '1.0')
   - sku: SKU Number (e.g. '1234')
   - platform: The platform to use (optional)
   - platforms: The platforms to use (optional)
   - language: Primary Language (e.g. 'en-US', 'fr-FR')
   - companyName: The name of your company. Only required if it's the first app you create
   - skipItc: Skip the creation of the app on App Store Connect
   - itcUsers: Array of App Store Connect users. If provided, you can limit access to this newly created app for users with the App Manager, Developer, Marketer or Sales roles
   - enabledFeatures: **DEPRECATED!** Please use `enable_services` instead - Array with Spaceship App Services
   - enableServices: Array with Spaceship App Services (e.g. access_wifi: (on|off), app_group: (on|off), apple_pay: (on|off), associated_domains: (on|off), auto_fill_credential: (on|off), data_protection: (complete|unlessopen|untilfirstauth), game_center: (on|off), health_kit: (on|off), home_kit: (on|off), hotspot: (on|off), icloud: (legacy|cloudkit), in_app_purchase: (on|off), inter_app_audio: (on|off), multipath: (on|off), network_extension: (on|off), nfc_tag_reading: (on|off), personal_vpn: (on|off), passbook: (on|off), push_notification: (on|off), siri_kit: (on|off), vpn_configuration: (on|off), wallet: (on|off), wireless_accessory: (on|off))
   - skipDevcenter: Skip the creation of the app on the Apple Developer Portal
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - itcTeamId: The ID of your App Store Connect team if you're in multiple teams
   - itcTeamName: The name of your App Store Connect team if you're in multiple teams

 Create new apps on App Store Connect and Apple Developer Portal via _produce_.
 If the app already exists, `create_app_online` will not do anything.
 For more information about _produce_, visit its documentation page: [https://docs.fastlane.tools/actions/produce/](https://docs.fastlane.tools/actions/produce/).
 */
public func produce(username: String,
                    appIdentifier: String,
                    bundleIdentifierSuffix: String? = nil,
                    appName: String,
                    appVersion: String? = nil,
                    sku: String,
                    platform: String = "ios",
                    platforms: [String]? = nil,
                    language: String = "English",
                    companyName: String? = nil,
                    skipItc: Bool = false,
                    itcUsers: [String]? = nil,
                    enabledFeatures: [String: Any] = [:],
                    enableServices: [String: Any] = [:],
                    skipDevcenter: Bool = false,
                    teamId: String? = nil,
                    teamName: String? = nil,
                    itcTeamId: Any? = nil,
                    itcTeamName: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "produce", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                           RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                           RubyCommand.Argument(name: "bundle_identifier_suffix", value: bundleIdentifierSuffix),
                                                                                           RubyCommand.Argument(name: "app_name", value: appName),
                                                                                           RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                           RubyCommand.Argument(name: "sku", value: sku),
                                                                                           RubyCommand.Argument(name: "platform", value: platform),
                                                                                           RubyCommand.Argument(name: "platforms", value: platforms),
                                                                                           RubyCommand.Argument(name: "language", value: language),
                                                                                           RubyCommand.Argument(name: "company_name", value: companyName),
                                                                                           RubyCommand.Argument(name: "skip_itc", value: skipItc),
                                                                                           RubyCommand.Argument(name: "itc_users", value: itcUsers),
                                                                                           RubyCommand.Argument(name: "enabled_features", value: enabledFeatures),
                                                                                           RubyCommand.Argument(name: "enable_services", value: enableServices),
                                                                                           RubyCommand.Argument(name: "skip_devcenter", value: skipDevcenter),
                                                                                           RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                           RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                           RubyCommand.Argument(name: "itc_team_id", value: itcTeamId),
                                                                                           RubyCommand.Argument(name: "itc_team_name", value: itcTeamName)])
    _ = runner.executeCommand(command)
}

/**
 Ask the user for a value or for confirmation

 - parameters:
   - text: The text that will be displayed to the user
   - ciInput: The default text that will be used when being executed on a CI service
   - boolean: Is that a boolean question (yes/no)? This will add (y/n) at the end
   - secureText: Is that a secure text (yes/no)?
   - multiLineEndKeyword: Enable multi-line inputs by providing an end text (e.g. 'END') which will stop the user input

 You can use `prompt` to ask the user for a value or to just let the user confirm the next step.
 When this is executed on a CI service, the passed `ci_input` value will be returned.
 This action also supports multi-line inputs using the `multi_line_end_keyword` option.
 */
@discardableResult public func prompt(text: String = "Please enter some text: ",
                                      ciInput: String = "",
                                      boolean: Bool = false,
                                      secureText: Bool = false,
                                      multiLineEndKeyword: String? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "prompt", className: nil, args: [RubyCommand.Argument(name: "text", value: text),
                                                                                          RubyCommand.Argument(name: "ci_input", value: ciInput),
                                                                                          RubyCommand.Argument(name: "boolean", value: boolean),
                                                                                          RubyCommand.Argument(name: "secure_text", value: secureText),
                                                                                          RubyCommand.Argument(name: "multi_line_end_keyword", value: multiLineEndKeyword)])
    return runner.executeCommand(command)
}

/**
 Push local tags to the remote - this will only push tags

 - parameters:
   - force: Force push to remote
   - remote: The remote to push tags to
   - tag: The tag to push to remote

 If you only want to push the tags and nothing else, you can use the `push_git_tags` action
 */
public func pushGitTags(force: Bool = false,
                        remote: String = "origin",
                        tag: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "push_git_tags", className: nil, args: [RubyCommand.Argument(name: "force", value: force),
                                                                                                 RubyCommand.Argument(name: "remote", value: remote),
                                                                                                 RubyCommand.Argument(name: "tag", value: tag)])
    _ = runner.executeCommand(command)
}

/**
 Push local changes to the remote branch

 - parameters:
   - localBranch: The local branch to push from. Defaults to the current branch
   - remoteBranch: The remote branch to push to. Defaults to the local branch
   - force: Force push to remote
   - forceWithLease: Force push with lease to remote
   - tags: Whether tags are pushed to remote
   - remote: The remote to push to
   - noVerify: Whether or not to use --no-verify
   - setUpstream: Whether or not to use --set-upstream
   - pushOptions: Array of strings to be passed using the '--push-option' option

 Lets you push your local commits to a remote git repo. Useful if you make local changes such as adding a version bump commit (using `commit_version_bump`) or a git tag (using 'add_git_tag') on a CI server, and you want to push those changes back to your canonical/main repo.
 If this is a new branch, use the `set_upstream` option to set the remote branch as upstream.
 */
public func pushToGitRemote(localBranch: String? = nil,
                            remoteBranch: String? = nil,
                            force: Bool = false,
                            forceWithLease: Bool = false,
                            tags: Bool = true,
                            remote: String = "origin",
                            noVerify: Bool = false,
                            setUpstream: Bool = false,
                            pushOptions: [String] = [])
{
    let command = RubyCommand(commandID: "", methodName: "push_to_git_remote", className: nil, args: [RubyCommand.Argument(name: "local_branch", value: localBranch),
                                                                                                      RubyCommand.Argument(name: "remote_branch", value: remoteBranch),
                                                                                                      RubyCommand.Argument(name: "force", value: force),
                                                                                                      RubyCommand.Argument(name: "force_with_lease", value: forceWithLease),
                                                                                                      RubyCommand.Argument(name: "tags", value: tags),
                                                                                                      RubyCommand.Argument(name: "remote", value: remote),
                                                                                                      RubyCommand.Argument(name: "no_verify", value: noVerify),
                                                                                                      RubyCommand.Argument(name: "set_upstream", value: setUpstream),
                                                                                                      RubyCommand.Argument(name: "push_options", value: pushOptions)])
    _ = runner.executeCommand(command)
}

/**
 Prints out the given text

 - parameter message: Message to be printed out
 */
public func puts(message: String? = nil) {
    let command = RubyCommand(commandID: "", methodName: "puts", className: nil, args: [RubyCommand.Argument(name: "message", value: message)])
    _ = runner.executeCommand(command)
}

/**
 Loads a CocoaPods spec as JSON

 - parameter path: Path to the podspec to be read

 This can be used for only specifying a version string in your podspec - and during your release process you'd read it from the podspec by running `version = read_podspec['version']` at the beginning of your lane.
 Loads the specified (or the first found) podspec in the folder as JSON, so that you can inspect its `version`, `files` etc.
 This can be useful when basing your release process on the version string only stored in one place - in the podspec.
 As one of the first steps you'd read the podspec and its version and the rest of the workflow can use that version string (when e.g. creating a new git tag or a GitHub Release).
 */
@discardableResult public func readPodspec(path: String) -> [String: String] {
    let command = RubyCommand(commandID: "", methodName: "read_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
    return parseDictionary(fromString: runner.executeCommand(command))
}

/**
 Recreate not shared Xcode project schemes

 - parameter project: The Xcode project
 */
public func recreateSchemes(project: String) {
    let command = RubyCommand(commandID: "", methodName: "recreate_schemes", className: nil, args: [RubyCommand.Argument(name: "project", value: project)])
    _ = runner.executeCommand(command)
}

/**
 Registers a new device to the Apple Dev Portal

 - parameters:
   - name: Provide the name of the device to register as
   - platform: Provide the platform of the device to register as (ios, mac)
   - udid: Provide the UDID of the device to register as
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - username: Optional: Your Apple ID

 This will register an iOS device with the Developer Portal so that you can include it in your provisioning profiles.
 This is an optimistic action, in that it will only ever add a device to the member center. If the device has already been registered within the member center, it will be left alone in the member center.
 The action will connect to the Apple Developer Portal using the username you specified in your `Appfile` with `apple_id`, but you can override it using the `:username` option.
 */
@discardableResult public func registerDevice(name: String,
                                              platform: String = "ios",
                                              udid: String,
                                              apiKeyPath: String? = nil,
                                              apiKey: [String: Any]? = nil,
                                              teamId: String? = nil,
                                              teamName: String? = nil,
                                              username: String? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "register_device", className: nil, args: [RubyCommand.Argument(name: "name", value: name),
                                                                                                   RubyCommand.Argument(name: "platform", value: platform),
                                                                                                   RubyCommand.Argument(name: "udid", value: udid),
                                                                                                   RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                   RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                   RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                   RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                   RubyCommand.Argument(name: "username", value: username)])
    return runner.executeCommand(command)
}

/**
 Registers new devices to the Apple Dev Portal

 - parameters:
   - devices: A hash of devices, with the name as key and the UDID as value
   - devicesFile: Provide a path to a file with the devices to register. For the format of the file see the examples
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - username: Optional: Your Apple ID
   - platform: The platform to use (optional)

 This will register iOS/Mac devices with the Developer Portal so that you can include them in your provisioning profiles.
 This is an optimistic action, in that it will only ever add new devices to the member center, and never remove devices. If a device which has already been registered within the member center is not passed to this action, it will be left alone in the member center and continue to work.
 The action will connect to the Apple Developer Portal using the username you specified in your `Appfile` with `apple_id`, but you can override it using the `username` option, or by setting the env variable `ENV['DELIVER_USER']`.
 */
public func registerDevices(devices: [String: Any]? = nil,
                            devicesFile: String? = nil,
                            apiKeyPath: String? = nil,
                            apiKey: [String: Any]? = nil,
                            teamId: String? = nil,
                            teamName: String? = nil,
                            username: String? = nil,
                            platform: String = "ios")
{
    let command = RubyCommand(commandID: "", methodName: "register_devices", className: nil, args: [RubyCommand.Argument(name: "devices", value: devices),
                                                                                                    RubyCommand.Argument(name: "devices_file", value: devicesFile),
                                                                                                    RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                    RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                    RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                    RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                    RubyCommand.Argument(name: "username", value: username),
                                                                                                    RubyCommand.Argument(name: "platform", value: platform)])
    _ = runner.executeCommand(command)
}

/**
 Resets git repo to a clean state by discarding uncommitted changes

 - parameters:
   - files: Array of files the changes should be discarded. If not given, all files will be discarded
   - force: Skip verifying of previously clean state of repo. Only recommended in combination with `files` option
   - skipClean: Skip 'git clean' to avoid removing untracked files like `.env`
   - disregardGitignore: Setting this to true will clean the whole repository, ignoring anything in your local .gitignore. Set this to true if you want the equivalent of a fresh clone, and for all untracked and ignore files to also be removed
   - exclude: You can pass a string, or array of, file pattern(s) here which you want to have survive the cleaning process, and remain on disk, e.g. to leave the `artifacts` directory you would specify `exclude: 'artifacts'`. Make sure this pattern is also in your gitignore! See the gitignore documentation for info on patterns

 This action will reset your git repo to a clean state, discarding any uncommitted and untracked changes. Useful in case you need to revert the repo back to a clean state, e.g. after running _fastlane_.
 Untracked files like `.env` will also be deleted, unless `:skip_clean` is true.
 It's a pretty drastic action so it comes with a sort of safety latch. It will only proceed with the reset if this condition is met:|
 |
 >- You have called the `ensure_git_status_clean` action prior to calling this action. This ensures that your repo started off in a clean state, so the only things that will get destroyed by this action are files that are created as a byproduct of the fastlane run.|
 >|
 */
public func resetGitRepo(files: Any? = nil,
                         force: Bool = false,
                         skipClean: Bool = false,
                         disregardGitignore: Bool = true,
                         exclude: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "reset_git_repo", className: nil, args: [RubyCommand.Argument(name: "files", value: files),
                                                                                                  RubyCommand.Argument(name: "force", value: force),
                                                                                                  RubyCommand.Argument(name: "skip_clean", value: skipClean),
                                                                                                  RubyCommand.Argument(name: "disregard_gitignore", value: disregardGitignore),
                                                                                                  RubyCommand.Argument(name: "exclude", value: exclude)])
    _ = runner.executeCommand(command)
}

/**
 Shutdown and reset running simulators

 - parameters:
   - ios: **DEPRECATED!** Use `:os_versions` instead - Which OS versions of Simulators you want to reset content and settings, this does not remove/recreate the simulators
   - osVersions: Which OS versions of Simulators you want to reset content and settings, this does not remove/recreate the simulators
 */
public func resetSimulatorContents(ios: [String]? = nil,
                                   osVersions: [String]? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "reset_simulator_contents", className: nil, args: [RubyCommand.Argument(name: "ios", value: ios),
                                                                                                            RubyCommand.Argument(name: "os_versions", value: osVersions)])
    _ = runner.executeCommand(command)
}

/**
 Codesign an existing ipa file

 - parameters:
   - ipa: Path to the ipa file to resign. Optional if you use the _gym_ or _xcodebuild_ action
   - signingIdentity: Code signing identity to use. e.g. `iPhone Distribution: Luka Mirosevic (0123456789)`
   - entitlements: Path to the entitlement file to use, e.g. `myApp/MyApp.entitlements`
   - provisioningProfile: Path to your provisioning_profile. Optional if you use _sigh_
   - version: Version number to force resigned ipa to use. Updates both `CFBundleShortVersionString` and `CFBundleVersion` values in `Info.plist`. Applies for main app and all nested apps or extensions
   - displayName: Display name to force resigned ipa to use
   - shortVersion: Short version string to force resigned ipa to use (`CFBundleShortVersionString`)
   - bundleVersion: Bundle version to force resigned ipa to use (`CFBundleVersion`)
   - bundleId: Set new bundle ID during resign (`CFBundleIdentifier`)
   - useAppEntitlements: Extract app bundle codesigning entitlements and combine with entitlements from new provisioning profile
   - keychainPath: Provide a path to a keychain file that should be used by `/usr/bin/codesign`
 */
public func resign(ipa: String,
                   signingIdentity: String,
                   entitlements: String? = nil,
                   provisioningProfile: Any,
                   version: String? = nil,
                   displayName: String? = nil,
                   shortVersion: String? = nil,
                   bundleVersion: String? = nil,
                   bundleId: String? = nil,
                   useAppEntitlements: Any? = nil,
                   keychainPath: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "resign", className: nil, args: [RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                          RubyCommand.Argument(name: "signing_identity", value: signingIdentity),
                                                                                          RubyCommand.Argument(name: "entitlements", value: entitlements),
                                                                                          RubyCommand.Argument(name: "provisioning_profile", value: provisioningProfile),
                                                                                          RubyCommand.Argument(name: "version", value: version),
                                                                                          RubyCommand.Argument(name: "display_name", value: displayName),
                                                                                          RubyCommand.Argument(name: "short_version", value: shortVersion),
                                                                                          RubyCommand.Argument(name: "bundle_version", value: bundleVersion),
                                                                                          RubyCommand.Argument(name: "bundle_id", value: bundleId),
                                                                                          RubyCommand.Argument(name: "use_app_entitlements", value: useAppEntitlements),
                                                                                          RubyCommand.Argument(name: "keychain_path", value: keychainPath)])
    _ = runner.executeCommand(command)
}

/**
 This action restore your file that was backuped with the `backup_file` action

 - parameter path: Original file name you want to restore
 */
public func restoreFile(path: String) {
    let command = RubyCommand(commandID: "", methodName: "restore_file", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
    _ = runner.executeCommand(command)
}

/**
 Outputs ascii-art for a rocket 🚀

 Print an ascii Rocket :rocket:. Useful after using _crashlytics_ or _pilot_ to indicate that your new build has been shipped to outer-space.
 */
@discardableResult public func rocket() -> String {
    let command = RubyCommand(commandID: "", methodName: "rocket", className: nil, args: [])
    return runner.executeCommand(command)
}

/**
 Run tests using rspec
 */
public func rspec() {
    let command = RubyCommand(commandID: "", methodName: "rspec", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Rsync files from :source to :destination

 - parameters:
   - extra: Port
   - source: source file/folder
   - destination: destination file/folder

 A wrapper around `rsync`, which is a tool that lets you synchronize files, including permissions and so on. For a more detailed information about `rsync`, please see [rsync(1) man page](https://linux.die.net/man/1/rsync).
 */
public func rsync(extra: String = "-av",
                  source: String,
                  destination: String)
{
    let command = RubyCommand(commandID: "", methodName: "rsync", className: nil, args: [RubyCommand.Argument(name: "extra", value: extra),
                                                                                         RubyCommand.Argument(name: "source", value: source),
                                                                                         RubyCommand.Argument(name: "destination", value: destination)])
    _ = runner.executeCommand(command)
}

/**
 Runs the code style checks
 */
public func rubocop() {
    let command = RubyCommand(commandID: "", methodName: "rubocop", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Verifies the minimum ruby version required

 Add this to your `Fastfile` to require a certain version of _ruby_.
 Put it at the top of your `Fastfile` to ensure that _fastlane_ is executed appropriately.
 */
public func rubyVersion() {
    let command = RubyCommand(commandID: "", methodName: "ruby_version", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Easily run tests of your iOS app (via _scan_)

 - parameters:
   - workspace: Path to the workspace file
   - project: Path to the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - device: The name of the simulator type you want to run tests on (e.g. 'iPhone 6')
   - devices: Array of devices to run the tests on (e.g. ['iPhone 6', 'iPad Air'])
   - skipDetectDevices: Should skip auto detecting of devices if none were specified
   - forceQuitSimulator: Enabling this option will automatically killall Simulator processes before the run
   - resetSimulator: Enabling this option will automatically erase the simulator before running the application
   - disableSlideToType: Enabling this option will disable the simulator from showing the 'Slide to type' prompt
   - prelaunchSimulator: Enabling this option will launch the first simulator prior to calling any xcodebuild command
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - appIdentifier: The bundle identifier of the app to uninstall (only needed when enabling reinstall_app)
   - onlyTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to run
   - skipTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to skip
   - testplan: The testplan associated with the scheme that should be used for testing
   - onlyTestConfigurations: Array of strings matching test plan configurations to run
   - skipTestConfigurations: Array of strings matching test plan configurations to skip
   - xctestrun: Run tests using the provided `.xctestrun` file
   - toolchain: The toolchain that should be used for building the application (e.g. `com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a`)
   - clean: Should the project be cleaned before building it?
   - codeCoverage: Should code coverage be generated? (Xcode 7 and up)
   - addressSanitizer: Should the address sanitizer be turned on?
   - threadSanitizer: Should the thread sanitizer be turned on?
   - openReport: Should the HTML report be opened when tests are completed?
   - disableXcpretty: Disable xcpretty formatting of build, similar to `output_style='raw'` but this will also skip the test results table
   - outputDirectory: The directory in which all reports will be stored
   - outputStyle: Define how the output should look like. Valid values are: standard, basic, rspec, or raw (disables xcpretty during xcodebuild)
   - outputTypes: Comma separated list of the output types (e.g. html, junit, json-compilation-database)
   - outputFiles: Comma separated list of the output files, corresponding to the types provided by :output_types (order should match). If specifying an output type of json-compilation-database with :use_clang_report_name enabled, that option will take precedence
   - buildlogPath: The directory where to store the raw log
   - includeSimulatorLogs: If the logs generated by the app (e.g. using NSLog, perror, etc.) in the Simulator should be written to the output_directory
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - formatter: A custom xcpretty formatter to use
   - xcprettyArgs: Pass in xcpretty additional command line arguments (e.g. '--test --no-color' or '--tap --no-utf')
   - derivedDataPath: The directory where build products and other derived data will go
   - shouldZipBuildProducts: Should zip the derived data build products and place in output path?
   - outputXctestrun: Should provide additional copy of .xctestrun file (settings.xctestrun) and place in output path?
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - useClangReportName: Generate the json compilation database with clang naming convention (compile_commands.json)
   - concurrentWorkers: Specify the exact number of test runners that will be spawned during parallel testing. Equivalent to -parallel-testing-worker-count
   - maxConcurrentSimulators: Constrain the number of simulator devices on which to test concurrently. Equivalent to -maximum-concurrent-test-simulator-destinations
   - disableConcurrentTesting: Do not run test bundles in parallel on the specified destinations. Testing will occur on each destination serially. Equivalent to -disable-concurrent-testing
   - skipBuild: Should debug build be skipped before test build?
   - testWithoutBuilding: Test without building, requires a derived data path
   - buildForTesting: Build for testing only, does not run tests
   - sdk: The SDK that should be used for building the application
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - xcargs: Pass additional arguments to xcodebuild. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - appName: App name to use in slack message and logfile name
   - deploymentTargetVersion: Target version of the app being build or tested. Used to filter out simulator version
   - slackUrl: Create an Incoming WebHook for your Slack group to post results there
   - slackChannel: #channel or @username
   - slackMessage: The message included with each message posted to slack
   - slackUseWebhookConfiguredUsernameAndIcon: Use webhook's default username and icon settings? (true/false)
   - slackUsername: Overrides the webhook's username property if slack_use_webhook_configured_username_and_icon is false
   - slackIconUrl: Overrides the webhook's image property if slack_use_webhook_configured_username_and_icon is false
   - skipSlack: Don't publish to slack, even when an URL is given
   - slackOnlyOnFailure: Only post on Slack if the tests fail
   - slackDefaultPayloads: Specifies default payloads to include in Slack messages. For more info visit https://docs.fastlane.tools/actions/slack
   - destination: Use only if you're a pro, use the other options instead
   - catalystPlatform: Platform to build when using a Catalyst enabled app. Valid values are: ios, macos
   - customReportFileName: **DEPRECATED!** Use `--output_files` instead - Sets custom full report file name when generating a single report
   - xcodebuildCommand: Allows for override of the default `xcodebuild` command
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - useSystemScm: Lets xcodebuild use system's scm configuration
   - failBuild: Should this step stop the build if the tests fail? Set this to false if you're using trainer

 More information: https://docs.fastlane.tools/actions/scan/
 */
public func runTests(workspace: String? = nil,
                     project: String? = nil,
                     scheme: String? = nil,
                     device: String? = nil,
                     devices: [String]? = nil,
                     skipDetectDevices: Bool = false,
                     forceQuitSimulator: Bool = false,
                     resetSimulator: Bool = false,
                     disableSlideToType: Bool = true,
                     prelaunchSimulator: Bool? = nil,
                     reinstallApp: Bool = false,
                     appIdentifier: String? = nil,
                     onlyTesting: Any? = nil,
                     skipTesting: Any? = nil,
                     testplan: String? = nil,
                     onlyTestConfigurations: Any? = nil,
                     skipTestConfigurations: Any? = nil,
                     xctestrun: String? = nil,
                     toolchain: Any? = nil,
                     clean: Bool = false,
                     codeCoverage: Bool? = nil,
                     addressSanitizer: Bool? = nil,
                     threadSanitizer: Bool? = nil,
                     openReport: Bool = false,
                     disableXcpretty: Bool? = nil,
                     outputDirectory: String = "./test_output",
                     outputStyle: String? = nil,
                     outputTypes: String = "html,junit",
                     outputFiles: String? = nil,
                     buildlogPath: String = "~/Library/Logs/scan",
                     includeSimulatorLogs: Bool = false,
                     suppressXcodeOutput: Bool? = nil,
                     formatter: String? = nil,
                     xcprettyArgs: String? = nil,
                     derivedDataPath: String? = nil,
                     shouldZipBuildProducts: Bool = false,
                     outputXctestrun: Bool = false,
                     resultBundle: Bool = false,
                     useClangReportName: Bool = false,
                     concurrentWorkers: Int? = nil,
                     maxConcurrentSimulators: Int? = nil,
                     disableConcurrentTesting: Bool = false,
                     skipBuild: Bool = false,
                     testWithoutBuilding: Bool? = nil,
                     buildForTesting: Bool? = nil,
                     sdk: String? = nil,
                     configuration: String? = nil,
                     xcargs: String? = nil,
                     xcconfig: String? = nil,
                     appName: String? = nil,
                     deploymentTargetVersion: String? = nil,
                     slackUrl: String? = nil,
                     slackChannel: String? = nil,
                     slackMessage: String? = nil,
                     slackUseWebhookConfiguredUsernameAndIcon: Bool = false,
                     slackUsername: String = "fastlane",
                     slackIconUrl: String = "https://fastlane.tools/assets/img/fastlane_icon.png",
                     skipSlack: Bool = false,
                     slackOnlyOnFailure: Bool = false,
                     slackDefaultPayloads: [String]? = nil,
                     destination: Any? = nil,
                     catalystPlatform: String? = nil,
                     customReportFileName: String? = nil,
                     xcodebuildCommand: String = "env NSUnbufferedIO=YES xcodebuild",
                     clonedSourcePackagesPath: String? = nil,
                     skipPackageDependenciesResolution: Bool = false,
                     disablePackageAutomaticUpdates: Bool = false,
                     useSystemScm: Bool = false,
                     failBuild: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "run_tests", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                             RubyCommand.Argument(name: "project", value: project),
                                                                                             RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                             RubyCommand.Argument(name: "device", value: device),
                                                                                             RubyCommand.Argument(name: "devices", value: devices),
                                                                                             RubyCommand.Argument(name: "skip_detect_devices", value: skipDetectDevices),
                                                                                             RubyCommand.Argument(name: "force_quit_simulator", value: forceQuitSimulator),
                                                                                             RubyCommand.Argument(name: "reset_simulator", value: resetSimulator),
                                                                                             RubyCommand.Argument(name: "disable_slide_to_type", value: disableSlideToType),
                                                                                             RubyCommand.Argument(name: "prelaunch_simulator", value: prelaunchSimulator),
                                                                                             RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                             RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                             RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                             RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                             RubyCommand.Argument(name: "testplan", value: testplan),
                                                                                             RubyCommand.Argument(name: "only_test_configurations", value: onlyTestConfigurations),
                                                                                             RubyCommand.Argument(name: "skip_test_configurations", value: skipTestConfigurations),
                                                                                             RubyCommand.Argument(name: "xctestrun", value: xctestrun),
                                                                                             RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                             RubyCommand.Argument(name: "clean", value: clean),
                                                                                             RubyCommand.Argument(name: "code_coverage", value: codeCoverage),
                                                                                             RubyCommand.Argument(name: "address_sanitizer", value: addressSanitizer),
                                                                                             RubyCommand.Argument(name: "thread_sanitizer", value: threadSanitizer),
                                                                                             RubyCommand.Argument(name: "open_report", value: openReport),
                                                                                             RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                             RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                             RubyCommand.Argument(name: "output_style", value: outputStyle),
                                                                                             RubyCommand.Argument(name: "output_types", value: outputTypes),
                                                                                             RubyCommand.Argument(name: "output_files", value: outputFiles),
                                                                                             RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                             RubyCommand.Argument(name: "include_simulator_logs", value: includeSimulatorLogs),
                                                                                             RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                             RubyCommand.Argument(name: "formatter", value: formatter),
                                                                                             RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs),
                                                                                             RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                             RubyCommand.Argument(name: "should_zip_build_products", value: shouldZipBuildProducts),
                                                                                             RubyCommand.Argument(name: "output_xctestrun", value: outputXctestrun),
                                                                                             RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                             RubyCommand.Argument(name: "use_clang_report_name", value: useClangReportName),
                                                                                             RubyCommand.Argument(name: "concurrent_workers", value: concurrentWorkers),
                                                                                             RubyCommand.Argument(name: "max_concurrent_simulators", value: maxConcurrentSimulators),
                                                                                             RubyCommand.Argument(name: "disable_concurrent_testing", value: disableConcurrentTesting),
                                                                                             RubyCommand.Argument(name: "skip_build", value: skipBuild),
                                                                                             RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                             RubyCommand.Argument(name: "build_for_testing", value: buildForTesting),
                                                                                             RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                             RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                             RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                             RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                             RubyCommand.Argument(name: "app_name", value: appName),
                                                                                             RubyCommand.Argument(name: "deployment_target_version", value: deploymentTargetVersion),
                                                                                             RubyCommand.Argument(name: "slack_url", value: slackUrl),
                                                                                             RubyCommand.Argument(name: "slack_channel", value: slackChannel),
                                                                                             RubyCommand.Argument(name: "slack_message", value: slackMessage),
                                                                                             RubyCommand.Argument(name: "slack_use_webhook_configured_username_and_icon", value: slackUseWebhookConfiguredUsernameAndIcon),
                                                                                             RubyCommand.Argument(name: "slack_username", value: slackUsername),
                                                                                             RubyCommand.Argument(name: "slack_icon_url", value: slackIconUrl),
                                                                                             RubyCommand.Argument(name: "skip_slack", value: skipSlack),
                                                                                             RubyCommand.Argument(name: "slack_only_on_failure", value: slackOnlyOnFailure),
                                                                                             RubyCommand.Argument(name: "slack_default_payloads", value: slackDefaultPayloads),
                                                                                             RubyCommand.Argument(name: "destination", value: destination),
                                                                                             RubyCommand.Argument(name: "catalyst_platform", value: catalystPlatform),
                                                                                             RubyCommand.Argument(name: "custom_report_file_name", value: customReportFileName),
                                                                                             RubyCommand.Argument(name: "xcodebuild_command", value: xcodebuildCommand),
                                                                                             RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                             RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                             RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                             RubyCommand.Argument(name: "use_system_scm", value: useSystemScm),
                                                                                             RubyCommand.Argument(name: "fail_build", value: failBuild)])
    _ = runner.executeCommand(command)
}

/**
 Generates a plist file and uploads all to AWS S3

 - parameters:
   - ipa: .ipa file for the build
   - dsym: zipped .dsym package for the build
   - uploadMetadata: Upload relevant metadata for this build
   - plistTemplatePath: plist template path
   - plistFileName: uploaded plist filename
   - htmlTemplatePath: html erb template path
   - htmlFileName: uploaded html filename
   - versionTemplatePath: version erb template path
   - versionFileName: uploaded version filename
   - accessKey: AWS Access Key ID
   - secretAccessKey: AWS Secret Access Key
   - bucket: AWS bucket name
   - region: AWS region (for bucket creation)
   - path: S3 'path'. Values from Info.plist will be substituted for keys wrapped in {}
   - source: Optional source directory e.g. ./build
   - acl: Uploaded object permissions e.g public_read (default), private, public_read_write, authenticated_read

 Upload a new build to Amazon S3 to distribute the build to beta testers.
 Works for both Ad Hoc and Enterprise signed applications. This step will generate the necessary HTML, plist, and version files for you.
 It is recommended to **not** store the AWS access keys in the `Fastfile`. The uploaded `version.json` file provides an easy way for apps to poll if a new update is available.
 */
public func s3(ipa: String? = nil,
               dsym: String? = nil,
               uploadMetadata: Bool = true,
               plistTemplatePath: String? = nil,
               plistFileName: String? = nil,
               htmlTemplatePath: String? = nil,
               htmlFileName: String? = nil,
               versionTemplatePath: String? = nil,
               versionFileName: String? = nil,
               accessKey: String? = nil,
               secretAccessKey: String? = nil,
               bucket: String? = nil,
               region: String? = nil,
               path: String = "v{CFBundleShortVersionString}_b{CFBundleVersion}/",
               source: String? = nil,
               acl: String = "public_read")
{
    let command = RubyCommand(commandID: "", methodName: "s3", className: nil, args: [RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                      RubyCommand.Argument(name: "dsym", value: dsym),
                                                                                      RubyCommand.Argument(name: "upload_metadata", value: uploadMetadata),
                                                                                      RubyCommand.Argument(name: "plist_template_path", value: plistTemplatePath),
                                                                                      RubyCommand.Argument(name: "plist_file_name", value: plistFileName),
                                                                                      RubyCommand.Argument(name: "html_template_path", value: htmlTemplatePath),
                                                                                      RubyCommand.Argument(name: "html_file_name", value: htmlFileName),
                                                                                      RubyCommand.Argument(name: "version_template_path", value: versionTemplatePath),
                                                                                      RubyCommand.Argument(name: "version_file_name", value: versionFileName),
                                                                                      RubyCommand.Argument(name: "access_key", value: accessKey),
                                                                                      RubyCommand.Argument(name: "secret_access_key", value: secretAccessKey),
                                                                                      RubyCommand.Argument(name: "bucket", value: bucket),
                                                                                      RubyCommand.Argument(name: "region", value: region),
                                                                                      RubyCommand.Argument(name: "path", value: path),
                                                                                      RubyCommand.Argument(name: "source", value: source),
                                                                                      RubyCommand.Argument(name: "acl", value: acl)])
    _ = runner.executeCommand(command)
}

/**
 This action speaks the given text out loud

 - parameters:
   - text: Text to be spoken out loud (as string or array of strings)
   - mute: If say should be muted with text printed out
 */
public func say(text: Any,
                mute: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "say", className: nil, args: [RubyCommand.Argument(name: "text", value: text),
                                                                                       RubyCommand.Argument(name: "mute", value: mute)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `run_tests` action

 - parameters:
   - workspace: Path to the workspace file
   - project: Path to the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - device: The name of the simulator type you want to run tests on (e.g. 'iPhone 6')
   - devices: Array of devices to run the tests on (e.g. ['iPhone 6', 'iPad Air'])
   - skipDetectDevices: Should skip auto detecting of devices if none were specified
   - forceQuitSimulator: Enabling this option will automatically killall Simulator processes before the run
   - resetSimulator: Enabling this option will automatically erase the simulator before running the application
   - disableSlideToType: Enabling this option will disable the simulator from showing the 'Slide to type' prompt
   - prelaunchSimulator: Enabling this option will launch the first simulator prior to calling any xcodebuild command
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - appIdentifier: The bundle identifier of the app to uninstall (only needed when enabling reinstall_app)
   - onlyTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to run
   - skipTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to skip
   - testplan: The testplan associated with the scheme that should be used for testing
   - onlyTestConfigurations: Array of strings matching test plan configurations to run
   - skipTestConfigurations: Array of strings matching test plan configurations to skip
   - xctestrun: Run tests using the provided `.xctestrun` file
   - toolchain: The toolchain that should be used for building the application (e.g. `com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a`)
   - clean: Should the project be cleaned before building it?
   - codeCoverage: Should code coverage be generated? (Xcode 7 and up)
   - addressSanitizer: Should the address sanitizer be turned on?
   - threadSanitizer: Should the thread sanitizer be turned on?
   - openReport: Should the HTML report be opened when tests are completed?
   - disableXcpretty: Disable xcpretty formatting of build, similar to `output_style='raw'` but this will also skip the test results table
   - outputDirectory: The directory in which all reports will be stored
   - outputStyle: Define how the output should look like. Valid values are: standard, basic, rspec, or raw (disables xcpretty during xcodebuild)
   - outputTypes: Comma separated list of the output types (e.g. html, junit, json-compilation-database)
   - outputFiles: Comma separated list of the output files, corresponding to the types provided by :output_types (order should match). If specifying an output type of json-compilation-database with :use_clang_report_name enabled, that option will take precedence
   - buildlogPath: The directory where to store the raw log
   - includeSimulatorLogs: If the logs generated by the app (e.g. using NSLog, perror, etc.) in the Simulator should be written to the output_directory
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - formatter: A custom xcpretty formatter to use
   - xcprettyArgs: Pass in xcpretty additional command line arguments (e.g. '--test --no-color' or '--tap --no-utf')
   - derivedDataPath: The directory where build products and other derived data will go
   - shouldZipBuildProducts: Should zip the derived data build products and place in output path?
   - outputXctestrun: Should provide additional copy of .xctestrun file (settings.xctestrun) and place in output path?
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - useClangReportName: Generate the json compilation database with clang naming convention (compile_commands.json)
   - concurrentWorkers: Specify the exact number of test runners that will be spawned during parallel testing. Equivalent to -parallel-testing-worker-count
   - maxConcurrentSimulators: Constrain the number of simulator devices on which to test concurrently. Equivalent to -maximum-concurrent-test-simulator-destinations
   - disableConcurrentTesting: Do not run test bundles in parallel on the specified destinations. Testing will occur on each destination serially. Equivalent to -disable-concurrent-testing
   - skipBuild: Should debug build be skipped before test build?
   - testWithoutBuilding: Test without building, requires a derived data path
   - buildForTesting: Build for testing only, does not run tests
   - sdk: The SDK that should be used for building the application
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - xcargs: Pass additional arguments to xcodebuild. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - appName: App name to use in slack message and logfile name
   - deploymentTargetVersion: Target version of the app being build or tested. Used to filter out simulator version
   - slackUrl: Create an Incoming WebHook for your Slack group to post results there
   - slackChannel: #channel or @username
   - slackMessage: The message included with each message posted to slack
   - slackUseWebhookConfiguredUsernameAndIcon: Use webhook's default username and icon settings? (true/false)
   - slackUsername: Overrides the webhook's username property if slack_use_webhook_configured_username_and_icon is false
   - slackIconUrl: Overrides the webhook's image property if slack_use_webhook_configured_username_and_icon is false
   - skipSlack: Don't publish to slack, even when an URL is given
   - slackOnlyOnFailure: Only post on Slack if the tests fail
   - slackDefaultPayloads: Specifies default payloads to include in Slack messages. For more info visit https://docs.fastlane.tools/actions/slack
   - destination: Use only if you're a pro, use the other options instead
   - catalystPlatform: Platform to build when using a Catalyst enabled app. Valid values are: ios, macos
   - customReportFileName: **DEPRECATED!** Use `--output_files` instead - Sets custom full report file name when generating a single report
   - xcodebuildCommand: Allows for override of the default `xcodebuild` command
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - useSystemScm: Lets xcodebuild use system's scm configuration
   - failBuild: Should this step stop the build if the tests fail? Set this to false if you're using trainer

 More information: https://docs.fastlane.tools/actions/scan/
 */
public func scan(workspace: Any? = scanfile.workspace,
                 project: Any? = scanfile.project,
                 scheme: Any? = scanfile.scheme,
                 device: Any? = scanfile.device,
                 devices: [String]? = scanfile.devices,
                 skipDetectDevices: Bool = scanfile.skipDetectDevices,
                 forceQuitSimulator: Bool = scanfile.forceQuitSimulator,
                 resetSimulator: Bool = scanfile.resetSimulator,
                 disableSlideToType: Bool = scanfile.disableSlideToType,
                 prelaunchSimulator: Bool? = scanfile.prelaunchSimulator,
                 reinstallApp: Bool = scanfile.reinstallApp,
                 appIdentifier: Any? = scanfile.appIdentifier,
                 onlyTesting: Any? = scanfile.onlyTesting,
                 skipTesting: Any? = scanfile.skipTesting,
                 testplan: Any? = scanfile.testplan,
                 onlyTestConfigurations: Any? = scanfile.onlyTestConfigurations,
                 skipTestConfigurations: Any? = scanfile.skipTestConfigurations,
                 xctestrun: Any? = scanfile.xctestrun,
                 toolchain: Any? = scanfile.toolchain,
                 clean: Bool = scanfile.clean,
                 codeCoverage: Bool? = scanfile.codeCoverage,
                 addressSanitizer: Bool? = scanfile.addressSanitizer,
                 threadSanitizer: Bool? = scanfile.threadSanitizer,
                 openReport: Bool = scanfile.openReport,
                 disableXcpretty: Bool? = scanfile.disableXcpretty,
                 outputDirectory: Any = scanfile.outputDirectory,
                 outputStyle: Any? = scanfile.outputStyle,
                 outputTypes: Any = scanfile.outputTypes,
                 outputFiles: Any? = scanfile.outputFiles,
                 buildlogPath: Any = scanfile.buildlogPath,
                 includeSimulatorLogs: Bool = scanfile.includeSimulatorLogs,
                 suppressXcodeOutput: Bool? = scanfile.suppressXcodeOutput,
                 formatter: Any? = scanfile.formatter,
                 xcprettyArgs: Any? = scanfile.xcprettyArgs,
                 derivedDataPath: Any? = scanfile.derivedDataPath,
                 shouldZipBuildProducts: Bool = scanfile.shouldZipBuildProducts,
                 outputXctestrun: Bool = scanfile.outputXctestrun,
                 resultBundle: Bool = scanfile.resultBundle,
                 useClangReportName: Bool = scanfile.useClangReportName,
                 concurrentWorkers: Int? = scanfile.concurrentWorkers,
                 maxConcurrentSimulators: Int? = scanfile.maxConcurrentSimulators,
                 disableConcurrentTesting: Bool = scanfile.disableConcurrentTesting,
                 skipBuild: Bool = scanfile.skipBuild,
                 testWithoutBuilding: Bool? = scanfile.testWithoutBuilding,
                 buildForTesting: Bool? = scanfile.buildForTesting,
                 sdk: Any? = scanfile.sdk,
                 configuration: Any? = scanfile.configuration,
                 xcargs: Any? = scanfile.xcargs,
                 xcconfig: Any? = scanfile.xcconfig,
                 appName: Any? = scanfile.appName,
                 deploymentTargetVersion: Any? = scanfile.deploymentTargetVersion,
                 slackUrl: Any? = scanfile.slackUrl,
                 slackChannel: Any? = scanfile.slackChannel,
                 slackMessage: Any? = scanfile.slackMessage,
                 slackUseWebhookConfiguredUsernameAndIcon: Bool = scanfile.slackUseWebhookConfiguredUsernameAndIcon,
                 slackUsername: Any = scanfile.slackUsername,
                 slackIconUrl: Any = scanfile.slackIconUrl,
                 skipSlack: Bool = scanfile.skipSlack,
                 slackOnlyOnFailure: Bool = scanfile.slackOnlyOnFailure,
                 slackDefaultPayloads: [String]? = scanfile.slackDefaultPayloads,
                 destination: Any? = scanfile.destination,
                 catalystPlatform: Any? = scanfile.catalystPlatform,
                 customReportFileName: Any? = scanfile.customReportFileName,
                 xcodebuildCommand: Any = scanfile.xcodebuildCommand,
                 clonedSourcePackagesPath: Any? = scanfile.clonedSourcePackagesPath,
                 skipPackageDependenciesResolution: Bool = scanfile.skipPackageDependenciesResolution,
                 disablePackageAutomaticUpdates: Bool = scanfile.disablePackageAutomaticUpdates,
                 useSystemScm: Bool = scanfile.useSystemScm,
                 failBuild: Bool = scanfile.failBuild)
{
    let command = RubyCommand(commandID: "", methodName: "scan", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                        RubyCommand.Argument(name: "project", value: project),
                                                                                        RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                        RubyCommand.Argument(name: "device", value: device),
                                                                                        RubyCommand.Argument(name: "devices", value: devices),
                                                                                        RubyCommand.Argument(name: "skip_detect_devices", value: skipDetectDevices),
                                                                                        RubyCommand.Argument(name: "force_quit_simulator", value: forceQuitSimulator),
                                                                                        RubyCommand.Argument(name: "reset_simulator", value: resetSimulator),
                                                                                        RubyCommand.Argument(name: "disable_slide_to_type", value: disableSlideToType),
                                                                                        RubyCommand.Argument(name: "prelaunch_simulator", value: prelaunchSimulator),
                                                                                        RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                        RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                        RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                        RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                        RubyCommand.Argument(name: "testplan", value: testplan),
                                                                                        RubyCommand.Argument(name: "only_test_configurations", value: onlyTestConfigurations),
                                                                                        RubyCommand.Argument(name: "skip_test_configurations", value: skipTestConfigurations),
                                                                                        RubyCommand.Argument(name: "xctestrun", value: xctestrun),
                                                                                        RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                        RubyCommand.Argument(name: "clean", value: clean),
                                                                                        RubyCommand.Argument(name: "code_coverage", value: codeCoverage),
                                                                                        RubyCommand.Argument(name: "address_sanitizer", value: addressSanitizer),
                                                                                        RubyCommand.Argument(name: "thread_sanitizer", value: threadSanitizer),
                                                                                        RubyCommand.Argument(name: "open_report", value: openReport),
                                                                                        RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                        RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                        RubyCommand.Argument(name: "output_style", value: outputStyle),
                                                                                        RubyCommand.Argument(name: "output_types", value: outputTypes),
                                                                                        RubyCommand.Argument(name: "output_files", value: outputFiles),
                                                                                        RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                        RubyCommand.Argument(name: "include_simulator_logs", value: includeSimulatorLogs),
                                                                                        RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                        RubyCommand.Argument(name: "formatter", value: formatter),
                                                                                        RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs),
                                                                                        RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                        RubyCommand.Argument(name: "should_zip_build_products", value: shouldZipBuildProducts),
                                                                                        RubyCommand.Argument(name: "output_xctestrun", value: outputXctestrun),
                                                                                        RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                        RubyCommand.Argument(name: "use_clang_report_name", value: useClangReportName),
                                                                                        RubyCommand.Argument(name: "concurrent_workers", value: concurrentWorkers),
                                                                                        RubyCommand.Argument(name: "max_concurrent_simulators", value: maxConcurrentSimulators),
                                                                                        RubyCommand.Argument(name: "disable_concurrent_testing", value: disableConcurrentTesting),
                                                                                        RubyCommand.Argument(name: "skip_build", value: skipBuild),
                                                                                        RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                        RubyCommand.Argument(name: "build_for_testing", value: buildForTesting),
                                                                                        RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                        RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                        RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                        RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                        RubyCommand.Argument(name: "app_name", value: appName),
                                                                                        RubyCommand.Argument(name: "deployment_target_version", value: deploymentTargetVersion),
                                                                                        RubyCommand.Argument(name: "slack_url", value: slackUrl),
                                                                                        RubyCommand.Argument(name: "slack_channel", value: slackChannel),
                                                                                        RubyCommand.Argument(name: "slack_message", value: slackMessage),
                                                                                        RubyCommand.Argument(name: "slack_use_webhook_configured_username_and_icon", value: slackUseWebhookConfiguredUsernameAndIcon),
                                                                                        RubyCommand.Argument(name: "slack_username", value: slackUsername),
                                                                                        RubyCommand.Argument(name: "slack_icon_url", value: slackIconUrl),
                                                                                        RubyCommand.Argument(name: "skip_slack", value: skipSlack),
                                                                                        RubyCommand.Argument(name: "slack_only_on_failure", value: slackOnlyOnFailure),
                                                                                        RubyCommand.Argument(name: "slack_default_payloads", value: slackDefaultPayloads),
                                                                                        RubyCommand.Argument(name: "destination", value: destination),
                                                                                        RubyCommand.Argument(name: "catalyst_platform", value: catalystPlatform),
                                                                                        RubyCommand.Argument(name: "custom_report_file_name", value: customReportFileName),
                                                                                        RubyCommand.Argument(name: "xcodebuild_command", value: xcodebuildCommand),
                                                                                        RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                        RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                        RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                        RubyCommand.Argument(name: "use_system_scm", value: useSystemScm),
                                                                                        RubyCommand.Argument(name: "fail_build", value: failBuild)])
    _ = runner.executeCommand(command)
}

/**
 Transfer files via SCP

 - parameters:
   - username: Username
   - password: Password
   - host: Hostname
   - port: Port
   - upload: Upload
   - download: Download
 */
public func scp(username: String,
                password: String? = nil,
                host: String,
                port: String = "22",
                upload: [String: Any]? = nil,
                download: [String: Any]? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "scp", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                       RubyCommand.Argument(name: "password", value: password),
                                                                                       RubyCommand.Argument(name: "host", value: host),
                                                                                       RubyCommand.Argument(name: "port", value: port),
                                                                                       RubyCommand.Argument(name: "upload", value: upload),
                                                                                       RubyCommand.Argument(name: "download", value: download)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `capture_android_screenshots` action

 - parameters:
   - androidHome: Path to the root of your Android SDK installation, e.g. ~/tools/android-sdk-macosx
   - buildToolsVersion: The Android build tools version to use, e.g. '23.0.2'
   - locales: A list of locales which should be used
   - clearPreviousScreenshots: Enabling this option will automatically clear previously generated screenshots before running screengrab
   - outputDirectory: The directory where to store the screenshots
   - skipOpenSummary: Don't open the summary after running _screengrab_
   - appPackageName: The package name of the app under test (e.g. com.yourcompany.yourapp)
   - testsPackageName: The package name of the tests bundle (e.g. com.yourcompany.yourapp.test)
   - useTestsInPackages: Only run tests in these Java packages
   - useTestsInClasses: Only run tests in these Java classes
   - launchArguments: Additional launch arguments
   - testInstrumentationRunner: The fully qualified class name of your test instrumentation runner
   - endingLocale: Return the device to this locale after running tests
   - useAdbRoot: Restarts the adb daemon using `adb root` to allow access to screenshots directories on device. Use if getting 'Permission denied' errors
   - appApkPath: The path to the APK for the app under test
   - testsApkPath: The path to the APK for the the tests bundle
   - specificDevice: Use the device or emulator with the given serial number or qualifier
   - deviceType: Type of device used for screenshots. Matches Google Play Types (phone, sevenInch, tenInch, tv, wear)
   - exitOnTestFailure: Whether or not to exit Screengrab on test failure. Exiting on failure will not copy sceenshots to local machine nor open sceenshots summary
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - useTimestampSuffix: Add timestamp suffix to screenshot filename
   - adbHost: Configure the host used by adb to connect, allows running on remote devices farm
 */
public func screengrab(androidHome: Any? = screengrabfile.androidHome,
                       buildToolsVersion: Any? = screengrabfile.buildToolsVersion,
                       locales: [String] = screengrabfile.locales,
                       clearPreviousScreenshots: Bool = screengrabfile.clearPreviousScreenshots,
                       outputDirectory: Any = screengrabfile.outputDirectory,
                       skipOpenSummary: Bool = screengrabfile.skipOpenSummary,
                       appPackageName: Any = screengrabfile.appPackageName,
                       testsPackageName: Any? = screengrabfile.testsPackageName,
                       useTestsInPackages: [String]? = screengrabfile.useTestsInPackages,
                       useTestsInClasses: [String]? = screengrabfile.useTestsInClasses,
                       launchArguments: [String]? = screengrabfile.launchArguments,
                       testInstrumentationRunner: Any = screengrabfile.testInstrumentationRunner,
                       endingLocale: Any = screengrabfile.endingLocale,
                       useAdbRoot: Bool = screengrabfile.useAdbRoot,
                       appApkPath: Any? = screengrabfile.appApkPath,
                       testsApkPath: Any? = screengrabfile.testsApkPath,
                       specificDevice: Any? = screengrabfile.specificDevice,
                       deviceType: Any = screengrabfile.deviceType,
                       exitOnTestFailure: Bool = screengrabfile.exitOnTestFailure,
                       reinstallApp: Bool = screengrabfile.reinstallApp,
                       useTimestampSuffix: Bool = screengrabfile.useTimestampSuffix,
                       adbHost: Any? = screengrabfile.adbHost)
{
    let command = RubyCommand(commandID: "", methodName: "screengrab", className: nil, args: [RubyCommand.Argument(name: "android_home", value: androidHome),
                                                                                              RubyCommand.Argument(name: "build_tools_version", value: buildToolsVersion),
                                                                                              RubyCommand.Argument(name: "locales", value: locales),
                                                                                              RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots),
                                                                                              RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                              RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary),
                                                                                              RubyCommand.Argument(name: "app_package_name", value: appPackageName),
                                                                                              RubyCommand.Argument(name: "tests_package_name", value: testsPackageName),
                                                                                              RubyCommand.Argument(name: "use_tests_in_packages", value: useTestsInPackages),
                                                                                              RubyCommand.Argument(name: "use_tests_in_classes", value: useTestsInClasses),
                                                                                              RubyCommand.Argument(name: "launch_arguments", value: launchArguments),
                                                                                              RubyCommand.Argument(name: "test_instrumentation_runner", value: testInstrumentationRunner),
                                                                                              RubyCommand.Argument(name: "ending_locale", value: endingLocale),
                                                                                              RubyCommand.Argument(name: "use_adb_root", value: useAdbRoot),
                                                                                              RubyCommand.Argument(name: "app_apk_path", value: appApkPath),
                                                                                              RubyCommand.Argument(name: "tests_apk_path", value: testsApkPath),
                                                                                              RubyCommand.Argument(name: "specific_device", value: specificDevice),
                                                                                              RubyCommand.Argument(name: "device_type", value: deviceType),
                                                                                              RubyCommand.Argument(name: "exit_on_test_failure", value: exitOnTestFailure),
                                                                                              RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                              RubyCommand.Argument(name: "use_timestamp_suffix", value: useTimestampSuffix),
                                                                                              RubyCommand.Argument(name: "adb_host", value: adbHost)])
    _ = runner.executeCommand(command)
}

/**
 Set the build number from the current repository

 - parameters:
   - useHgRevisionNumber: Use hg revision number instead of hash (ignored for non-hg repos)
   - xcodeproj: explicitly specify which xcodeproj to use

 This action will set the **build number** according to what the SCM HEAD reports.
 Currently supported SCMs are svn (uses root revision), git-svn (uses svn revision) and git (uses short hash) and mercurial (uses short hash or revision number).
 There is an option, `:use_hg_revision_number`, which allows to use mercurial revision number instead of hash.
 */
public func setBuildNumberRepository(useHgRevisionNumber: Bool = false,
                                     xcodeproj: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "set_build_number_repository", className: nil, args: [RubyCommand.Argument(name: "use_hg_revision_number", value: useHgRevisionNumber),
                                                                                                               RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
    _ = runner.executeCommand(command)
}

/**
 Set the changelog for all languages on App Store Connect

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - appIdentifier: The bundle identifier of your app
   - username: Your Apple ID Username
   - version: The version number to create/update
   - changelog: Changelog text that should be uploaded to App Store Connect
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - platform: The platform of the app (ios, appletvos, mac)

 This is useful if you have only one changelog for all languages.
 You can store the changelog in `./changelog.txt` and it will automatically get loaded from there. This integration is useful if you support e.g. 10 languages and want to use the same "What's new"-text for all languages.
 Defining the version is optional. _fastlane_ will try to automatically detect it if you don't provide one.
 */
public func setChangelog(apiKeyPath: String? = nil,
                         apiKey: [String: Any]? = nil,
                         appIdentifier: String,
                         username: String? = nil,
                         version: String? = nil,
                         changelog: String? = nil,
                         teamId: Any? = nil,
                         teamName: String? = nil,
                         platform: String = "ios")
{
    let command = RubyCommand(commandID: "", methodName: "set_changelog", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                 RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                 RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                 RubyCommand.Argument(name: "username", value: username),
                                                                                                 RubyCommand.Argument(name: "version", value: version),
                                                                                                 RubyCommand.Argument(name: "changelog", value: changelog),
                                                                                                 RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                 RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                 RubyCommand.Argument(name: "platform", value: platform)])
    _ = runner.executeCommand(command)
}

/**
  This will create a new release on GitHub and upload assets for it

  - parameters:
    - repositoryName: The path to your repo, e.g. 'fastlane/fastlane'
    - serverUrl: The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com')
    - apiToken: Personal API Token for GitHub - generate one at https://github.com/settings/tokens
    - apiBearer: Use a Bearer authorization token. Usually generated by Github Apps, e.g. GitHub Actions GITHUB_TOKEN environment variable
    - tagName: Pass in the tag name
    - name: Name of this release
    - commitish: Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists. Default: the repository's default branch (usually master)
    - description: Description of this release
    - isDraft: Whether the release should be marked as draft
    - isPrerelease: Whether the release should be marked as prerelease
    - uploadAssets: Path to assets to be uploaded with the release

  - returns: A hash containing all relevant information of this release
 Access things like 'html_url', 'tag_name', 'name', 'body'

  Creates a new release on GitHub. You must provide your GitHub Personal token (get one from [https://github.com/settings/tokens/new](https://github.com/settings/tokens/new)), the repository name and tag name. By default, that's `master`.
  If the tag doesn't exist, one will be created on the commit or branch passed in as commitish.
  Out parameters provide the release's id, which can be used for later editing and the release HTML link to GitHub. You can also specify a list of assets to be uploaded to the release with the `:upload_assets` parameter.
 */
@discardableResult public func setGithubRelease(repositoryName: String,
                                                serverUrl: String = "https://api.github.com",
                                                apiToken: String? = nil,
                                                apiBearer: String? = nil,
                                                tagName: String,
                                                name: String? = nil,
                                                commitish: String? = nil,
                                                description: String? = nil,
                                                isDraft: Bool = false,
                                                isPrerelease: Bool = false,
                                                uploadAssets: [String]? = nil) -> [String: Any]
{
    let command = RubyCommand(commandID: "", methodName: "set_github_release", className: nil, args: [RubyCommand.Argument(name: "repository_name", value: repositoryName),
                                                                                                      RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                                      RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                      RubyCommand.Argument(name: "api_bearer", value: apiBearer),
                                                                                                      RubyCommand.Argument(name: "tag_name", value: tagName),
                                                                                                      RubyCommand.Argument(name: "name", value: name),
                                                                                                      RubyCommand.Argument(name: "commitish", value: commitish),
                                                                                                      RubyCommand.Argument(name: "description", value: description),
                                                                                                      RubyCommand.Argument(name: "is_draft", value: isDraft),
                                                                                                      RubyCommand.Argument(name: "is_prerelease", value: isPrerelease),
                                                                                                      RubyCommand.Argument(name: "upload_assets", value: uploadAssets)])
    return parseDictionary(fromString: runner.executeCommand(command))
}

/**
 Sets value to Info.plist of your project as native Ruby data structures

 - parameters:
   - key: Name of key in plist
   - subkey: Name of subkey in plist
   - value: Value to setup
   - path: Path to plist file you want to update
   - outputFileName: Path to the output file you want to generate
 */
public func setInfoPlistValue(key: String,
                              subkey: String? = nil,
                              value: Any,
                              path: String,
                              outputFileName: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "set_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key),
                                                                                                        RubyCommand.Argument(name: "subkey", value: subkey),
                                                                                                        RubyCommand.Argument(name: "value", value: value),
                                                                                                        RubyCommand.Argument(name: "path", value: path),
                                                                                                        RubyCommand.Argument(name: "output_file_name", value: outputFileName)])
    _ = runner.executeCommand(command)
}

/**
 Sets a value for a key with cocoapods-keys

 - parameters:
   - useBundleExec: Use bundle exec when there is a Gemfile presented
   - key: The key to be saved with cocoapods-keys
   - value: The value to be saved with cocoapods-keys
   - project: The project name

 Adds a key to [cocoapods-keys](https://github.com/orta/cocoapods-keys)
 */
public func setPodKey(useBundleExec: Bool = true,
                      key: String,
                      value: String,
                      project: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "set_pod_key", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                               RubyCommand.Argument(name: "key", value: key),
                                                                                               RubyCommand.Argument(name: "value", value: value),
                                                                                               RubyCommand.Argument(name: "project", value: project)])
    _ = runner.executeCommand(command)
}

/**
 Setup the keychain and match to work with CI

 - parameters:
   - force: Force setup, even if not executed by CI
   - provider: CI provider. If none is set, the provider is detected automatically

 - Creates a new temporary keychain for use with match|
 - Switches match to `readonly` mode to not create new profiles/cert on CI|
 - Sets up log and test result paths to be easily collectible|
 >|
 This action helps with CI integration. Add this to the top of your Fastfile if you use CI.
 */
public func setupCi(force: Bool = false,
                    provider: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "setup_ci", className: nil, args: [RubyCommand.Argument(name: "force", value: force),
                                                                                            RubyCommand.Argument(name: "provider", value: provider)])
    _ = runner.executeCommand(command)
}

/**
 Setup the keychain and match to work with CircleCI

 - parameter force: Force setup, even if not executed by CircleCI

 - Creates a new temporary keychain for use with match|
 - Switches match to `readonly` mode to not create new profiles/cert on CI|
 - Sets up log and test result paths to be easily collectible|
 >|
 This action helps with CircleCI integration. Add this to the top of your Fastfile if you use CircleCI.
 */
public func setupCircleCi(force: Bool = false) {
    let command = RubyCommand(commandID: "", methodName: "setup_circle_ci", className: nil, args: [RubyCommand.Argument(name: "force", value: force)])
    _ = runner.executeCommand(command)
}

/**
 Setup xcodebuild, gym and scan for easier Jenkins integration

 - parameters:
   - force: Force setup, even if not executed by Jenkins
   - unlockKeychain: Unlocks keychain
   - addKeychainToSearchList: Add to keychain search list
   - setDefaultKeychain: Set keychain as default
   - keychainPath: Path to keychain
   - keychainPassword: Keychain password
   - setCodeSigningIdentity: Set code signing identity from CODE_SIGNING_IDENTITY environment
   - codeSigningIdentity: Code signing identity
   - outputDirectory: The directory in which the ipa file should be stored in
   - derivedDataPath: The directory where built products and other derived data will go
   - resultBundle: Produce the result bundle describing what occurred will be placed

 - Adds and unlocks keychains from Jenkins 'Keychains and Provisioning Profiles Plugin'|
 - Sets unlocked keychain to be used by Match|
 - Sets code signing identity from Jenkins 'Keychains and Provisioning Profiles Plugin'|
 - Sets output directory to './output' (gym, scan and backup_xcarchive)|
 - Sets derived data path to './derivedData' (xcodebuild, gym, scan and clear_derived_data, carthage)|
 - Produce result bundle (gym and scan)|
 >|
 This action helps with Jenkins integration. Creates own derived data for each job. All build results like IPA files and archives will be stored in the `./output` directory.
 The action also works with [Keychains and Provisioning Profiles Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Keychains+and+Provisioning+Profiles+Plugin), the selected keychain will be automatically unlocked and the selected code signing identity will be used.
 [Match](https://docs.fastlane.tools/actions/match/) will be also set up to use the unlocked keychain and set in read-only mode, if its environment variables were not yet defined.
 By default this action will only work when _fastlane_ is executed on a CI system.
 */
public func setupJenkins(force: Bool = false,
                         unlockKeychain: Bool = true,
                         addKeychainToSearchList: Any = "replace",
                         setDefaultKeychain: Bool = true,
                         keychainPath: String? = nil,
                         keychainPassword: String,
                         setCodeSigningIdentity: Bool = true,
                         codeSigningIdentity: String? = nil,
                         outputDirectory: String = "./output",
                         derivedDataPath: String = "./derivedData",
                         resultBundle: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "setup_jenkins", className: nil, args: [RubyCommand.Argument(name: "force", value: force),
                                                                                                 RubyCommand.Argument(name: "unlock_keychain", value: unlockKeychain),
                                                                                                 RubyCommand.Argument(name: "add_keychain_to_search_list", value: addKeychainToSearchList),
                                                                                                 RubyCommand.Argument(name: "set_default_keychain", value: setDefaultKeychain),
                                                                                                 RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                                 RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                 RubyCommand.Argument(name: "set_code_signing_identity", value: setCodeSigningIdentity),
                                                                                                 RubyCommand.Argument(name: "code_signing_identity", value: codeSigningIdentity),
                                                                                                 RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                                 RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                                 RubyCommand.Argument(name: "result_bundle", value: resultBundle)])
    _ = runner.executeCommand(command)
}

/**
 Setup the keychain and match to work with Travis CI

 - parameter force: Force setup, even if not executed by travis

 - Creates a new temporary keychain for use with match|
 - Switches match to `readonly` mode to not create new profiles/cert on CI|
 >|
 This action helps with Travis integration. Add this to the top of your Fastfile if you use Travis.
 */
public func setupTravis(force: Bool = false) {
    let command = RubyCommand(commandID: "", methodName: "setup_travis", className: nil, args: [RubyCommand.Argument(name: "force", value: force)])
    _ = runner.executeCommand(command)
}

/**
 Runs a shell command

 - parameters:
   - command: Shell command to be executed
   - log: Determines whether fastlane should print out the executed command itself and output of the executed command. If command line option --troubleshoot is used, then it overrides this option to true
   - errorCallback: A callback invoked with the command output if there is a non-zero exit status

 - returns: Outputs the string and executes it. When running in tests, it returns the actual command instead of executing it

 Allows running an arbitrary shell command.
 Be aware of a specific behavior of `sh` action with regard to the working directory. For details, refer to [Advanced](https://docs.fastlane.tools/advanced/#directory-behavior).
 */
@discardableResult public func sh(command: String,
                                  log: Bool = true,
                                  errorCallback: ((String) -> Void)? = nil) -> String
{
    let command = RubyCommand(commandID: "", methodName: "sh", className: nil, args: [RubyCommand.Argument(name: "command", value: command),
                                                                                      RubyCommand.Argument(name: "log", value: log),
                                                                                      RubyCommand.Argument(name: "error_callback", value: errorCallback, type: .stringClosure)])
    return runner.executeCommand(command)
}

/**
 Alias for the `get_provisioning_profile` action

 - parameters:
   - adhoc: Setting this flag will generate AdHoc profiles instead of App Store Profiles
   - developerId: Setting this flag will generate Developer ID profiles instead of App Store Profiles
   - development: Renew the development certificate instead of the production one
   - skipInstall: By default, the certificate will be added to your local machine. Setting this flag will skip this action
   - force: Renew provisioning profiles regardless of its state - to automatically add all devices for ad hoc profiles
   - appIdentifier: The bundle identifier of your app
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - provisioningName: The name of the profile that is used on the Apple Developer Portal
   - ignoreProfilesWithDifferentName: Use in combination with :provisioning_name - when true only profiles matching this exact name will be downloaded
   - outputPath: Directory in which the profile should be stored
   - certId: The ID of the code signing certificate to use (e.g. 78ADL6LVAA)
   - certOwnerName: The certificate name to use for new profiles, or to renew with. (e.g. "Felix Krause")
   - filename: Filename to use for the generated provisioning profile (must include .mobileprovision)
   - skipFetchProfiles: Skips the verification of existing profiles which is useful if you have thousands of profiles
   - skipCertificateVerification: Skips the verification of the certificates for every existing profiles. This will make sure the provisioning profile can be used on the local machine
   - platform: Set the provisioning profile's platform (i.e. ios, tvos, macos, catalyst)
   - readonly: Only fetch existing profile, don't generate new ones
   - templateName: The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. "Apple Pay Pass Suppression Development")
   - failOnNameTaken: Should the command fail if it was about to create a duplicate of an existing provisioning profile. It can happen due to issues on Apple Developer Portal, when profile to be recreated was not properly deleted first

 - returns: The UUID of the profile sigh just fetched/generated

 **Note**: It is recommended to use [match](https://docs.fastlane.tools/actions/match/) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your provisioning profiles. Use _sigh_ directly only if you want full control over what's going on and know more about codesigning.
 */
public func sigh(adhoc: Bool = false,
                 developerId: Bool = false,
                 development: Bool = false,
                 skipInstall: Bool = false,
                 force: Bool = false,
                 appIdentifier: String,
                 apiKeyPath: String? = nil,
                 apiKey: [String: Any]? = nil,
                 username: String,
                 teamId: String? = nil,
                 teamName: String? = nil,
                 provisioningName: String? = nil,
                 ignoreProfilesWithDifferentName: Bool = false,
                 outputPath: String = ".",
                 certId: String? = nil,
                 certOwnerName: String? = nil,
                 filename: String? = nil,
                 skipFetchProfiles: Bool = false,
                 skipCertificateVerification: Bool = false,
                 platform: Any = "ios",
                 readonly: Bool = false,
                 templateName: String? = nil,
                 failOnNameTaken: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "sigh", className: nil, args: [RubyCommand.Argument(name: "adhoc", value: adhoc),
                                                                                        RubyCommand.Argument(name: "developer_id", value: developerId),
                                                                                        RubyCommand.Argument(name: "development", value: development),
                                                                                        RubyCommand.Argument(name: "skip_install", value: skipInstall),
                                                                                        RubyCommand.Argument(name: "force", value: force),
                                                                                        RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                        RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                        RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                        RubyCommand.Argument(name: "username", value: username),
                                                                                        RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                        RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                        RubyCommand.Argument(name: "provisioning_name", value: provisioningName),
                                                                                        RubyCommand.Argument(name: "ignore_profiles_with_different_name", value: ignoreProfilesWithDifferentName),
                                                                                        RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                        RubyCommand.Argument(name: "cert_id", value: certId),
                                                                                        RubyCommand.Argument(name: "cert_owner_name", value: certOwnerName),
                                                                                        RubyCommand.Argument(name: "filename", value: filename),
                                                                                        RubyCommand.Argument(name: "skip_fetch_profiles", value: skipFetchProfiles),
                                                                                        RubyCommand.Argument(name: "skip_certificate_verification", value: skipCertificateVerification),
                                                                                        RubyCommand.Argument(name: "platform", value: platform),
                                                                                        RubyCommand.Argument(name: "readonly", value: readonly),
                                                                                        RubyCommand.Argument(name: "template_name", value: templateName),
                                                                                        RubyCommand.Argument(name: "fail_on_name_taken", value: failOnNameTaken)])
    _ = runner.executeCommand(command)
}

/**
 Skip the creation of the fastlane/README.md file when running fastlane

 Tell _fastlane_ to not automatically create a `fastlane/README.md` when running _fastlane_. You can always trigger the creation of this file manually by running `fastlane docs`.
 */
public func skipDocs() {
    let command = RubyCommand(commandID: "", methodName: "skip_docs", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Send a success/error message to your [Slack](https://slack.com) group

 - parameters:
   - message: The message that should be displayed on Slack. This supports the standard Slack markup language
   - pretext: This is optional text that appears above the message attachment block. This supports the standard Slack markup language
   - channel: #channel or @username
   - useWebhookConfiguredUsernameAndIcon: Use webhook's default username and icon settings? (true/false)
   - slackUrl: Create an Incoming WebHook for your Slack group
   - username: Overrides the webhook's username property if use_webhook_configured_username_and_icon is false
   - iconUrl: Overrides the webhook's image property if use_webhook_configured_username_and_icon is false
   - payload: Add additional information to this post. payload must be a hash containing any key with any value
   - defaultPayloads: Specifies default payloads to include. Pass an empty array to suppress all the default payloads
   - attachmentProperties: Merge additional properties in the slack attachment, see https://api.slack.com/docs/attachments
   - success: Was this build successful? (true/false)
   - failOnError: Should an error sending the slack notification cause a failure? (true/false)
   - linkNames: Find and link channel names and usernames (true/false)

 Create an Incoming WebHook and export this as `SLACK_URL`. Can send a message to **#channel** (by default), a direct message to **@username** or a message to a private group **group** with success (green) or failure (red) status.
 */
public func slack(message: String? = nil,
                  pretext: String? = nil,
                  channel: String? = nil,
                  useWebhookConfiguredUsernameAndIcon: Bool = false,
                  slackUrl: String,
                  username: String = "fastlane",
                  iconUrl: String = "https://fastlane.tools/assets/img/fastlane_icon.png",
                  payload: [String: Any] = [:],
                  defaultPayloads: [String] = ["lane", "test_result", "git_branch", "git_author", "last_git_commit", "last_git_commit_hash"],
                  attachmentProperties: [String: Any] = [:],
                  success: Bool = true,
                  failOnError: Bool = true,
                  linkNames: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "slack", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                         RubyCommand.Argument(name: "pretext", value: pretext),
                                                                                         RubyCommand.Argument(name: "channel", value: channel),
                                                                                         RubyCommand.Argument(name: "use_webhook_configured_username_and_icon", value: useWebhookConfiguredUsernameAndIcon),
                                                                                         RubyCommand.Argument(name: "slack_url", value: slackUrl),
                                                                                         RubyCommand.Argument(name: "username", value: username),
                                                                                         RubyCommand.Argument(name: "icon_url", value: iconUrl),
                                                                                         RubyCommand.Argument(name: "payload", value: payload),
                                                                                         RubyCommand.Argument(name: "default_payloads", value: defaultPayloads),
                                                                                         RubyCommand.Argument(name: "attachment_properties", value: attachmentProperties),
                                                                                         RubyCommand.Argument(name: "success", value: success),
                                                                                         RubyCommand.Argument(name: "fail_on_error", value: failOnError),
                                                                                         RubyCommand.Argument(name: "link_names", value: linkNames)])
    _ = runner.executeCommand(command)
}

/**
 Show a train of the fastlane progress

 - returns: A string that is being sent to slack
 */
public func slackTrain() {
    let command = RubyCommand(commandID: "", methodName: "slack_train", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**

 */
public func slackTrainCrash() {
    let command = RubyCommand(commandID: "", methodName: "slack_train_crash", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Show a train of the fastlane progress

 - parameters:
   - distance: How many rails do we need?
   - train: Train emoji
   - rail: Character or emoji for the rail
   - reverseDirection: Pass true if you want the train to go from left to right
 */
public func slackTrainStart(distance: Int = 5,
                            train: String = "🚝",
                            rail: String = "=",
                            reverseDirection: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "slack_train_start", className: nil, args: [RubyCommand.Argument(name: "distance", value: distance),
                                                                                                     RubyCommand.Argument(name: "train", value: train),
                                                                                                     RubyCommand.Argument(name: "rail", value: rail),
                                                                                                     RubyCommand.Argument(name: "reverse_direction", value: reverseDirection)])
    _ = runner.executeCommand(command)
}

/**
 Use slather to generate a code coverage report

 - parameters:
   - buildDirectory: The location of the build output
   - proj: The project file that slather looks at
   - workspace: The workspace that slather looks at
   - scheme: Scheme to use when calling slather
   - configuration: Configuration to use when calling slather (since slather-2.4.1)
   - inputFormat: The input format that slather should look for
   - buildkite: Tell slather that it is running on Buildkite
   - teamcity: Tell slather that it is running on TeamCity
   - jenkins: Tell slather that it is running on Jenkins
   - travis: Tell slather that it is running on TravisCI
   - travisPro: Tell slather that it is running on TravisCI Pro
   - circleci: Tell slather that it is running on CircleCI
   - coveralls: Tell slather that it should post data to Coveralls
   - simpleOutput: Tell slather that it should output results to the terminal
   - gutterJson: Tell slather that it should output results as Gutter JSON format
   - coberturaXml: Tell slather that it should output results as Cobertura XML format
   - sonarqubeXml: Tell slather that it should output results as SonarQube Generic XML format
   - llvmCov: Tell slather that it should output results as llvm-cov show format
   - json: Tell slather that it should output results as static JSON report
   - html: Tell slather that it should output results as static HTML pages
   - show: Tell slather that it should open static html pages automatically
   - sourceDirectory: Tell slather the location of your source files
   - outputDirectory: Tell slather the location of for your output files
   - ignore: Tell slather to ignore files matching a path or any path from an array of paths
   - verbose: Tell slather to enable verbose mode
   - useBundleExec: Use bundle exec to execute slather. Make sure it is in the Gemfile
   - binaryBasename: Basename of the binary file, this should match the name of your bundle excluding its extension (i.e. YourApp [for YourApp.app bundle])
   - binaryFile: Binary file name to be used for code coverage
   - arch: Specify which architecture the binary file is in. Needed for universal binaries
   - sourceFiles: A Dir.glob compatible pattern used to limit the lookup to specific source files. Ignored in gcov mode
   - decimals: The amount of decimals to use for % coverage reporting

 Slather works with multiple code coverage formats, including Xcode 7 code coverage.
 Slather is available at [https://github.com/SlatherOrg/slather](https://github.com/SlatherOrg/slather).
 */
public func slather(buildDirectory: String? = nil,
                    proj: String? = nil,
                    workspace: String? = nil,
                    scheme: String? = nil,
                    configuration: String? = nil,
                    inputFormat: String? = nil,
                    buildkite: Bool? = nil,
                    teamcity: Bool? = nil,
                    jenkins: Bool? = nil,
                    travis: Bool? = nil,
                    travisPro: Bool? = nil,
                    circleci: Bool? = nil,
                    coveralls: Bool? = nil,
                    simpleOutput: Bool? = nil,
                    gutterJson: Bool? = nil,
                    coberturaXml: Bool? = nil,
                    sonarqubeXml: Bool? = nil,
                    llvmCov: Any? = nil,
                    json: Bool? = nil,
                    html: Bool? = nil,
                    show: Bool = false,
                    sourceDirectory: String? = nil,
                    outputDirectory: String? = nil,
                    ignore: [String]? = nil,
                    verbose: Bool? = nil,
                    useBundleExec: Bool = false,
                    binaryBasename: [String]? = nil,
                    binaryFile: [String]? = nil,
                    arch: String? = nil,
                    sourceFiles: Bool = false,
                    decimals: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "slather", className: nil, args: [RubyCommand.Argument(name: "build_directory", value: buildDirectory),
                                                                                           RubyCommand.Argument(name: "proj", value: proj),
                                                                                           RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                           RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                           RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                           RubyCommand.Argument(name: "input_format", value: inputFormat),
                                                                                           RubyCommand.Argument(name: "buildkite", value: buildkite),
                                                                                           RubyCommand.Argument(name: "teamcity", value: teamcity),
                                                                                           RubyCommand.Argument(name: "jenkins", value: jenkins),
                                                                                           RubyCommand.Argument(name: "travis", value: travis),
                                                                                           RubyCommand.Argument(name: "travis_pro", value: travisPro),
                                                                                           RubyCommand.Argument(name: "circleci", value: circleci),
                                                                                           RubyCommand.Argument(name: "coveralls", value: coveralls),
                                                                                           RubyCommand.Argument(name: "simple_output", value: simpleOutput),
                                                                                           RubyCommand.Argument(name: "gutter_json", value: gutterJson),
                                                                                           RubyCommand.Argument(name: "cobertura_xml", value: coberturaXml),
                                                                                           RubyCommand.Argument(name: "sonarqube_xml", value: sonarqubeXml),
                                                                                           RubyCommand.Argument(name: "llvm_cov", value: llvmCov),
                                                                                           RubyCommand.Argument(name: "json", value: json),
                                                                                           RubyCommand.Argument(name: "html", value: html),
                                                                                           RubyCommand.Argument(name: "show", value: show),
                                                                                           RubyCommand.Argument(name: "source_directory", value: sourceDirectory),
                                                                                           RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                           RubyCommand.Argument(name: "ignore", value: ignore),
                                                                                           RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                           RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                           RubyCommand.Argument(name: "binary_basename", value: binaryBasename),
                                                                                           RubyCommand.Argument(name: "binary_file", value: binaryFile),
                                                                                           RubyCommand.Argument(name: "arch", value: arch),
                                                                                           RubyCommand.Argument(name: "source_files", value: sourceFiles),
                                                                                           RubyCommand.Argument(name: "decimals", value: decimals)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `capture_ios_screenshots` action

 - parameters:
   - workspace: Path the workspace file
   - project: Path the project file
   - xcargs: Pass additional arguments to xcodebuild for the test phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
   - xcconfig: Use an extra XCCONFIG file to build your app
   - devices: A list of devices you want to take the screenshots from
   - languages: A list of languages which should be used
   - launchArguments: A list of launch arguments which should be used
   - outputDirectory: The directory where to store the screenshots
   - outputSimulatorLogs: If the logs generated by the app (e.g. using NSLog, perror, etc.) in the Simulator should be written to the output_directory
   - iosVersion: By default, the latest version should be used automatically. If you want to change it, do it here
   - skipOpenSummary: Don't open the HTML summary after running _snapshot_
   - skipHelperVersionCheck: Do not check for most recent SnapshotHelper code
   - clearPreviousScreenshots: Enabling this option will automatically clear previously generated screenshots before running snapshot
   - reinstallApp: Enabling this option will automatically uninstall the application before running it
   - eraseSimulator: Enabling this option will automatically erase the simulator before running the application
   - headless: Enabling this option will prevent displaying the simulator window
   - overrideStatusBar: Enabling this option will automatically override the status bar to show 9:41 AM, full battery, and full reception
   - localizeSimulator: Enabling this option will configure the Simulator's system language
   - darkMode: Enabling this option will configure the Simulator to be in dark mode (false for light, true for dark)
   - appIdentifier: The bundle identifier of the app to uninstall (only needed when enabling reinstall_app)
   - addPhotos: A list of photos that should be added to the simulator before running the application
   - addVideos: A list of videos that should be added to the simulator before running the application
   - htmlTemplate: A path to screenshots.html template
   - buildlogPath: The directory where to store the build log
   - clean: Should the project be cleaned before building it?
   - testWithoutBuilding: Test without building, requires a derived data path
   - configuration: The configuration to use when building the app. Defaults to 'Release'
   - xcprettyArgs: Additional xcpretty arguments
   - sdk: The SDK that should be used for building the application
   - scheme: The scheme you want to use, this must be the scheme for the UI Tests
   - numberOfRetries: The number of times a test can fail before snapshot should stop retrying
   - stopAfterFirstError: Should snapshot stop immediately after the tests completely failed on one device?
   - derivedDataPath: The directory where build products and other derived data will go
   - resultBundle: Should an Xcode result bundle be generated in the output directory
   - testTargetName: The name of the target you want to test (if you desire to override the Target Application from Xcode)
   - namespaceLogFiles: Separate the log files per device and per language
   - concurrentSimulators: Take snapshots on multiple simulators concurrently. Note: This option is only applicable when running against Xcode 9
   - disableSlideToType: Disable the simulator from showing the 'Slide to type' prompt
   - clonedSourcePackagesPath: Sets a custom path for Swift Package Manager dependencies
   - skipPackageDependenciesResolution: Skips resolution of Swift Package Manager dependencies
   - disablePackageAutomaticUpdates: Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
   - testplan: The testplan associated with the scheme that should be used for testing
   - onlyTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to run
   - skipTesting: Array of strings matching Test Bundle/Test Suite/Test Cases to skip
   - disableXcpretty: Disable xcpretty formatting of build
   - suppressXcodeOutput: Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
   - useSystemScm: Lets xcodebuild use system's scm configuration
 */
public func snapshot(workspace: Any? = snapshotfile.workspace,
                     project: Any? = snapshotfile.project,
                     xcargs: Any? = snapshotfile.xcargs,
                     xcconfig: Any? = snapshotfile.xcconfig,
                     devices: [String]? = snapshotfile.devices,
                     languages: [String] = snapshotfile.languages,
                     launchArguments: [String] = snapshotfile.launchArguments,
                     outputDirectory: Any = snapshotfile.outputDirectory,
                     outputSimulatorLogs: Bool = snapshotfile.outputSimulatorLogs,
                     iosVersion: Any? = snapshotfile.iosVersion,
                     skipOpenSummary: Bool = snapshotfile.skipOpenSummary,
                     skipHelperVersionCheck: Bool = snapshotfile.skipHelperVersionCheck,
                     clearPreviousScreenshots: Bool = snapshotfile.clearPreviousScreenshots,
                     reinstallApp: Bool = snapshotfile.reinstallApp,
                     eraseSimulator: Bool = snapshotfile.eraseSimulator,
                     headless: Bool = snapshotfile.headless,
                     overrideStatusBar: Bool = snapshotfile.overrideStatusBar,
                     localizeSimulator: Bool = snapshotfile.localizeSimulator,
                     darkMode: Bool? = snapshotfile.darkMode,
                     appIdentifier: Any? = snapshotfile.appIdentifier,
                     addPhotos: [String]? = snapshotfile.addPhotos,
                     addVideos: [String]? = snapshotfile.addVideos,
                     htmlTemplate: Any? = snapshotfile.htmlTemplate,
                     buildlogPath: Any = snapshotfile.buildlogPath,
                     clean: Bool = snapshotfile.clean,
                     testWithoutBuilding: Bool? = snapshotfile.testWithoutBuilding,
                     configuration: Any? = snapshotfile.configuration,
                     xcprettyArgs: Any? = snapshotfile.xcprettyArgs,
                     sdk: Any? = snapshotfile.sdk,
                     scheme: Any? = snapshotfile.scheme,
                     numberOfRetries: Int = snapshotfile.numberOfRetries,
                     stopAfterFirstError: Bool = snapshotfile.stopAfterFirstError,
                     derivedDataPath: Any? = snapshotfile.derivedDataPath,
                     resultBundle: Bool = snapshotfile.resultBundle,
                     testTargetName: Any? = snapshotfile.testTargetName,
                     namespaceLogFiles: Any? = snapshotfile.namespaceLogFiles,
                     concurrentSimulators: Bool = snapshotfile.concurrentSimulators,
                     disableSlideToType: Bool = snapshotfile.disableSlideToType,
                     clonedSourcePackagesPath: Any? = snapshotfile.clonedSourcePackagesPath,
                     skipPackageDependenciesResolution: Bool = snapshotfile.skipPackageDependenciesResolution,
                     disablePackageAutomaticUpdates: Bool = snapshotfile.disablePackageAutomaticUpdates,
                     testplan: Any? = snapshotfile.testplan,
                     onlyTesting: Any? = snapshotfile.onlyTesting,
                     skipTesting: Any? = snapshotfile.skipTesting,
                     disableXcpretty: Bool? = snapshotfile.disableXcpretty,
                     suppressXcodeOutput: Bool? = snapshotfile.suppressXcodeOutput,
                     useSystemScm: Bool = snapshotfile.useSystemScm)
{
    let command = RubyCommand(commandID: "", methodName: "snapshot", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                            RubyCommand.Argument(name: "project", value: project),
                                                                                            RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                            RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                            RubyCommand.Argument(name: "devices", value: devices),
                                                                                            RubyCommand.Argument(name: "languages", value: languages),
                                                                                            RubyCommand.Argument(name: "launch_arguments", value: launchArguments),
                                                                                            RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                            RubyCommand.Argument(name: "output_simulator_logs", value: outputSimulatorLogs),
                                                                                            RubyCommand.Argument(name: "ios_version", value: iosVersion),
                                                                                            RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary),
                                                                                            RubyCommand.Argument(name: "skip_helper_version_check", value: skipHelperVersionCheck),
                                                                                            RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots),
                                                                                            RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                            RubyCommand.Argument(name: "erase_simulator", value: eraseSimulator),
                                                                                            RubyCommand.Argument(name: "headless", value: headless),
                                                                                            RubyCommand.Argument(name: "override_status_bar", value: overrideStatusBar),
                                                                                            RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator),
                                                                                            RubyCommand.Argument(name: "dark_mode", value: darkMode),
                                                                                            RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                            RubyCommand.Argument(name: "add_photos", value: addPhotos),
                                                                                            RubyCommand.Argument(name: "add_videos", value: addVideos),
                                                                                            RubyCommand.Argument(name: "html_template", value: htmlTemplate),
                                                                                            RubyCommand.Argument(name: "buildlog_path", value: buildlogPath),
                                                                                            RubyCommand.Argument(name: "clean", value: clean),
                                                                                            RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                            RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                            RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs),
                                                                                            RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                            RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                            RubyCommand.Argument(name: "number_of_retries", value: numberOfRetries),
                                                                                            RubyCommand.Argument(name: "stop_after_first_error", value: stopAfterFirstError),
                                                                                            RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                            RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                            RubyCommand.Argument(name: "test_target_name", value: testTargetName),
                                                                                            RubyCommand.Argument(name: "namespace_log_files", value: namespaceLogFiles),
                                                                                            RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators),
                                                                                            RubyCommand.Argument(name: "disable_slide_to_type", value: disableSlideToType),
                                                                                            RubyCommand.Argument(name: "cloned_source_packages_path", value: clonedSourcePackagesPath),
                                                                                            RubyCommand.Argument(name: "skip_package_dependencies_resolution", value: skipPackageDependenciesResolution),
                                                                                            RubyCommand.Argument(name: "disable_package_automatic_updates", value: disablePackageAutomaticUpdates),
                                                                                            RubyCommand.Argument(name: "testplan", value: testplan),
                                                                                            RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                            RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                            RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty),
                                                                                            RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput),
                                                                                            RubyCommand.Argument(name: "use_system_scm", value: useSystemScm)])
    _ = runner.executeCommand(command)
}

/**
 Invokes sonar-scanner to programmatically run SonarQube analysis

 - parameters:
   - projectConfigurationPath: The path to your sonar project configuration file; defaults to `sonar-project.properties`
   - projectKey: The key sonar uses to identify the project, e.g. `name.gretzki.awesomeApp`. Must either be specified here or inside the sonar project configuration file
   - projectName: The name of the project that gets displayed on the sonar report page. Must either be specified here or inside the sonar project configuration file
   - projectVersion: The project's version that gets displayed on the sonar report page. Must either be specified here or inside the sonar project configuration file
   - sourcesPath: Comma-separated paths to directories containing source files. Must either be specified here or inside the sonar project configuration file
   - exclusions: Comma-separated paths to directories to be excluded from the analysis
   - projectLanguage: Language key, e.g. objc
   - sourceEncoding: Used encoding of source files, e.g., UTF-8
   - sonarRunnerArgs: Pass additional arguments to sonar-scanner. Be sure to provide the arguments with a leading `-D` e.g. FL_SONAR_RUNNER_ARGS="-Dsonar.verbose=true"
   - sonarLogin: Pass the Sonar Login token (e.g: xxxxxxprivate_token_XXXXbXX7e)
   - sonarUrl: Pass the url of the Sonar server
   - sonarOrganization: Key of the organization on SonarCloud
   - branchName: Pass the branch name which is getting scanned
   - pullRequestBranch: The name of the branch that contains the changes to be merged
   - pullRequestBase: The long-lived branch into which the PR will be merged
   - pullRequestKey: Unique identifier of your PR. Must correspond to the key of the PR in GitHub or TFS

 - returns: The exit code of the sonar-scanner binary

 See [http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner](http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner) for details.
 It can process unit test results if formatted as junit report as shown in [xctest](https://docs.fastlane.tools/actions/xctest/) action. It can also integrate coverage reports in Cobertura format, which can be transformed into by the [slather](https://docs.fastlane.tools/actions/slather/) action.
 */
public func sonar(projectConfigurationPath: String? = nil,
                  projectKey: String? = nil,
                  projectName: String? = nil,
                  projectVersion: String? = nil,
                  sourcesPath: String? = nil,
                  exclusions: String? = nil,
                  projectLanguage: String? = nil,
                  sourceEncoding: String? = nil,
                  sonarRunnerArgs: String? = nil,
                  sonarLogin: String? = nil,
                  sonarUrl: String? = nil,
                  sonarOrganization: String? = nil,
                  branchName: String? = nil,
                  pullRequestBranch: String? = nil,
                  pullRequestBase: String? = nil,
                  pullRequestKey: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "sonar", className: nil, args: [RubyCommand.Argument(name: "project_configuration_path", value: projectConfigurationPath),
                                                                                         RubyCommand.Argument(name: "project_key", value: projectKey),
                                                                                         RubyCommand.Argument(name: "project_name", value: projectName),
                                                                                         RubyCommand.Argument(name: "project_version", value: projectVersion),
                                                                                         RubyCommand.Argument(name: "sources_path", value: sourcesPath),
                                                                                         RubyCommand.Argument(name: "exclusions", value: exclusions),
                                                                                         RubyCommand.Argument(name: "project_language", value: projectLanguage),
                                                                                         RubyCommand.Argument(name: "source_encoding", value: sourceEncoding),
                                                                                         RubyCommand.Argument(name: "sonar_runner_args", value: sonarRunnerArgs),
                                                                                         RubyCommand.Argument(name: "sonar_login", value: sonarLogin),
                                                                                         RubyCommand.Argument(name: "sonar_url", value: sonarUrl),
                                                                                         RubyCommand.Argument(name: "sonar_organization", value: sonarOrganization),
                                                                                         RubyCommand.Argument(name: "branch_name", value: branchName),
                                                                                         RubyCommand.Argument(name: "pull_request_branch", value: pullRequestBranch),
                                                                                         RubyCommand.Argument(name: "pull_request_base", value: pullRequestBase),
                                                                                         RubyCommand.Argument(name: "pull_request_key", value: pullRequestKey)])
    _ = runner.executeCommand(command)
}

/**
 Find, print, and copy Spaceship logs

 - parameters:
   - latest: Finds only the latest Spaceshop log file if set to true, otherwise returns all
   - printContents: Prints the contents of the found Spaceship log file(s)
   - printPaths: Prints the paths of the found Spaceship log file(s)
   - copyToPath: Copies the found Spaceship log file(s) to a directory
   - copyToClipboard: Copies the contents of the found Spaceship log file(s) to the clipboard

 - returns: The array of Spaceship logs
 */
public func spaceshipLogs(latest: Bool = true,
                          printContents: Bool = false,
                          printPaths: Bool = false,
                          copyToPath: String? = nil,
                          copyToClipboard: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "spaceship_logs", className: nil, args: [RubyCommand.Argument(name: "latest", value: latest),
                                                                                                  RubyCommand.Argument(name: "print_contents", value: printContents),
                                                                                                  RubyCommand.Argument(name: "print_paths", value: printPaths),
                                                                                                  RubyCommand.Argument(name: "copy_to_path", value: copyToPath),
                                                                                                  RubyCommand.Argument(name: "copy_to_clipboard", value: copyToClipboard)])
    _ = runner.executeCommand(command)
}

/**
 Print out Spaceship stats from this session (number of request to each domain)

 - parameter printRequestLogs: Print all URLs requested
 */
public func spaceshipStats(printRequestLogs: Bool = false) {
    let command = RubyCommand(commandID: "", methodName: "spaceship_stats", className: nil, args: [RubyCommand.Argument(name: "print_request_logs", value: printRequestLogs)])
    _ = runner.executeCommand(command)
}

/**
 Upload dSYM file to [Splunk MINT](https://mint.splunk.com/)

 - parameters:
   - dsym: dSYM.zip file to upload to Splunk MINT
   - apiKey: Splunk MINT App API key e.g. f57a57ca
   - apiToken: Splunk MINT API token e.g. e05ba40754c4869fb7e0b61
   - verbose: Make detailed output
   - uploadProgress: Show upload progress
   - proxyUsername: Proxy username
   - proxyPassword: Proxy password
   - proxyAddress: Proxy address
   - proxyPort: Proxy port
 */
public func splunkmint(dsym: String? = nil,
                       apiKey: String,
                       apiToken: String,
                       verbose: Bool = false,
                       uploadProgress: Bool = false,
                       proxyUsername: String? = nil,
                       proxyPassword: String? = nil,
                       proxyAddress: String? = nil,
                       proxyPort: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "splunkmint", className: nil, args: [RubyCommand.Argument(name: "dsym", value: dsym),
                                                                                              RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                              RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                              RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                              RubyCommand.Argument(name: "upload_progress", value: uploadProgress),
                                                                                              RubyCommand.Argument(name: "proxy_username", value: proxyUsername),
                                                                                              RubyCommand.Argument(name: "proxy_password", value: proxyPassword),
                                                                                              RubyCommand.Argument(name: "proxy_address", value: proxyAddress),
                                                                                              RubyCommand.Argument(name: "proxy_port", value: proxyPort)])
    _ = runner.executeCommand(command)
}

/**
 Runs Swift Package Manager on your project

 - parameters:
   - command: The swift command (one of: build, test, clean, reset, update, resolve, generate-xcodeproj, init)
   - enableCodeCoverage: Enables code coverage for the generated Xcode project when using the 'generate-xcodeproj' and the 'test' command
   - buildPath: Specify build/cache directory [default: ./.build]
   - packagePath: Change working directory before any other operation
   - xcconfig: Use xcconfig file to override swift package generate-xcodeproj defaults
   - configuration: Build with configuration (debug|release) [default: debug]
   - disableSandbox: Disable using the sandbox when executing subprocesses
   - xcprettyOutput: Specifies the output type for xcpretty. eg. 'test', or 'simple'
   - xcprettyArgs: Pass in xcpretty additional command line arguments (e.g. '--test --no-color' or '--tap --no-utf'), requires xcpretty_output to be specified also
   - verbose: Increase verbosity of informational output
 */
public func spm(command: String = "build",
                enableCodeCoverage: Any? = nil,
                buildPath: String? = nil,
                packagePath: String? = nil,
                xcconfig: String? = nil,
                configuration: String? = nil,
                disableSandbox: Bool = false,
                xcprettyOutput: String? = nil,
                xcprettyArgs: String? = nil,
                verbose: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "spm", className: nil, args: [RubyCommand.Argument(name: "command", value: command),
                                                                                       RubyCommand.Argument(name: "enable_code_coverage", value: enableCodeCoverage),
                                                                                       RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                       RubyCommand.Argument(name: "package_path", value: packagePath),
                                                                                       RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                       RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                       RubyCommand.Argument(name: "disable_sandbox", value: disableSandbox),
                                                                                       RubyCommand.Argument(name: "xcpretty_output", value: xcprettyOutput),
                                                                                       RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs),
                                                                                       RubyCommand.Argument(name: "verbose", value: verbose)])
    _ = runner.executeCommand(command)
}

/**
 Allows remote command execution using ssh

 - parameters:
   - username: Username
   - password: Password
   - host: Hostname
   - port: Port
   - commands: Commands
   - log: Log commands and output

 Lets you execute remote commands via ssh using username/password or ssh-agent. If one of the commands in command-array returns non 0, it fails.
 */
public func ssh(username: String,
                password: String? = nil,
                host: String,
                port: String = "22",
                commands: [String]? = nil,
                log: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "ssh", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                       RubyCommand.Argument(name: "password", value: password),
                                                                                       RubyCommand.Argument(name: "host", value: host),
                                                                                       RubyCommand.Argument(name: "port", value: port),
                                                                                       RubyCommand.Argument(name: "commands", value: commands),
                                                                                       RubyCommand.Argument(name: "log", value: log)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `upload_to_play_store` action

 - parameters:
   - packageName: The package name of the application to use
   - versionName: Version name (used when uploading new apks/aabs) - defaults to 'versionName' in build.gradle or AndroidManifest.xml
   - versionCode: Version code (used when updating rollout or promoting specific versions)
   - releaseStatus: Release status (used when uploading new apks/aabs) - valid values are completed, draft, halted, inProgress
   - track: The track of the application to use. The default available tracks are: production, beta, alpha, internal
   - rollout: The percentage of the user fraction when uploading to the rollout track (setting to 1 will complete the rollout)
   - metadataPath: Path to the directory containing the metadata files
   - key: **DEPRECATED!** Use `--json_key` instead - The p12 File used to authenticate with Google
   - issuer: **DEPRECATED!** Use `--json_key` instead - The issuer of the p12 file (email address of the service account)
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - apk: Path to the APK file to upload
   - apkPaths: An array of paths to APK files to upload
   - aab: Path to the AAB file to upload
   - aabPaths: An array of paths to AAB files to upload
   - skipUploadApk: Whether to skip uploading APK
   - skipUploadAab: Whether to skip uploading AAB
   - skipUploadMetadata: Whether to skip uploading metadata, changelogs not included
   - skipUploadChangelogs: Whether to skip uploading changelogs
   - skipUploadImages: Whether to skip uploading images, screenshots not included
   - skipUploadScreenshots: Whether to skip uploading SCREENSHOTS
   - trackPromoteTo: The track to promote to. The default available tracks are: production, beta, alpha, internal
   - validateOnly: Only validate changes with Google Play rather than actually publish
   - mapping: Path to the mapping file to upload
   - mappingPaths: An array of paths to mapping files to upload
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - checkSupersededTracks: **DEPRECATED!** Google Play does this automatically now - Check the other tracks for superseded versions and disable them
   - timeout: Timeout for read, open, and send (in seconds)
   - deactivateOnPromote: **DEPRECATED!** Google Play does this automatically now - When promoting to a new track, deactivate the binary in the origin track
   - versionCodesToRetain: An array of version codes to retain when publishing a new APK
   - inAppUpdatePriority: In-app update priority for all the newly added apks in the release. Can take values between [0,5]
   - obbMainReferencesVersion: References version of 'main' expansion file
   - obbMainFileSize: Size of 'main' expansion file in bytes
   - obbPatchReferencesVersion: References version of 'patch' expansion file
   - obbPatchFileSize: Size of 'patch' expansion file in bytes
   - ackBundleInstallationWarning: Must be set to true if the bundle installation may trigger a warning on user devices (e.g can only be downloaded over wifi). Typically this is required for bundles over 150MB

 More information: https://docs.fastlane.tools/actions/supply/
 */
public func supply(packageName: String,
                   versionName: String? = nil,
                   versionCode: Int? = nil,
                   releaseStatus: String = "completed",
                   track: String = "production",
                   rollout: String? = nil,
                   metadataPath: String? = nil,
                   key: String? = nil,
                   issuer: String? = nil,
                   jsonKey: String? = nil,
                   jsonKeyData: String? = nil,
                   apk: String? = nil,
                   apkPaths: [String]? = nil,
                   aab: String? = nil,
                   aabPaths: [String]? = nil,
                   skipUploadApk: Bool = false,
                   skipUploadAab: Bool = false,
                   skipUploadMetadata: Bool = false,
                   skipUploadChangelogs: Bool = false,
                   skipUploadImages: Bool = false,
                   skipUploadScreenshots: Bool = false,
                   trackPromoteTo: String? = nil,
                   validateOnly: Bool = false,
                   mapping: String? = nil,
                   mappingPaths: [String]? = nil,
                   rootUrl: String? = nil,
                   checkSupersededTracks: Bool = false,
                   timeout: Int = 300,
                   deactivateOnPromote: Bool = true,
                   versionCodesToRetain: [String]? = nil,
                   inAppUpdatePriority: Int? = nil,
                   obbMainReferencesVersion: String? = nil,
                   obbMainFileSize: String? = nil,
                   obbPatchReferencesVersion: String? = nil,
                   obbPatchFileSize: String? = nil,
                   ackBundleInstallationWarning: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "supply", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                          RubyCommand.Argument(name: "version_name", value: versionName),
                                                                                          RubyCommand.Argument(name: "version_code", value: versionCode),
                                                                                          RubyCommand.Argument(name: "release_status", value: releaseStatus),
                                                                                          RubyCommand.Argument(name: "track", value: track),
                                                                                          RubyCommand.Argument(name: "rollout", value: rollout),
                                                                                          RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                          RubyCommand.Argument(name: "key", value: key),
                                                                                          RubyCommand.Argument(name: "issuer", value: issuer),
                                                                                          RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                          RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                          RubyCommand.Argument(name: "apk", value: apk),
                                                                                          RubyCommand.Argument(name: "apk_paths", value: apkPaths),
                                                                                          RubyCommand.Argument(name: "aab", value: aab),
                                                                                          RubyCommand.Argument(name: "aab_paths", value: aabPaths),
                                                                                          RubyCommand.Argument(name: "skip_upload_apk", value: skipUploadApk),
                                                                                          RubyCommand.Argument(name: "skip_upload_aab", value: skipUploadAab),
                                                                                          RubyCommand.Argument(name: "skip_upload_metadata", value: skipUploadMetadata),
                                                                                          RubyCommand.Argument(name: "skip_upload_changelogs", value: skipUploadChangelogs),
                                                                                          RubyCommand.Argument(name: "skip_upload_images", value: skipUploadImages),
                                                                                          RubyCommand.Argument(name: "skip_upload_screenshots", value: skipUploadScreenshots),
                                                                                          RubyCommand.Argument(name: "track_promote_to", value: trackPromoteTo),
                                                                                          RubyCommand.Argument(name: "validate_only", value: validateOnly),
                                                                                          RubyCommand.Argument(name: "mapping", value: mapping),
                                                                                          RubyCommand.Argument(name: "mapping_paths", value: mappingPaths),
                                                                                          RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                          RubyCommand.Argument(name: "check_superseded_tracks", value: checkSupersededTracks),
                                                                                          RubyCommand.Argument(name: "timeout", value: timeout),
                                                                                          RubyCommand.Argument(name: "deactivate_on_promote", value: deactivateOnPromote),
                                                                                          RubyCommand.Argument(name: "version_codes_to_retain", value: versionCodesToRetain),
                                                                                          RubyCommand.Argument(name: "in_app_update_priority", value: inAppUpdatePriority),
                                                                                          RubyCommand.Argument(name: "obb_main_references_version", value: obbMainReferencesVersion),
                                                                                          RubyCommand.Argument(name: "obb_main_file_size", value: obbMainFileSize),
                                                                                          RubyCommand.Argument(name: "obb_patch_references_version", value: obbPatchReferencesVersion),
                                                                                          RubyCommand.Argument(name: "obb_patch_file_size", value: obbPatchFileSize),
                                                                                          RubyCommand.Argument(name: "ack_bundle_installation_warning", value: ackBundleInstallationWarning)])
    _ = runner.executeCommand(command)
}

/**
 Run swift code validation using SwiftLint

 - parameters:
   - mode: SwiftLint mode: :lint, :autocorrect or :analyze
   - path: Specify path to lint
   - outputFile: Path to output SwiftLint result
   - configFile: Custom configuration file of SwiftLint
   - strict: Fail on warnings? (true/false)
   - files: List of files to process
   - ignoreExitStatus: Ignore the exit status of the SwiftLint command, so that serious violations                                                     don't fail the build (true/false)
   - raiseIfSwiftlintError: Raises an error if swiftlint fails, so you can fail CI/CD jobs if necessary                                                     (true/false)
   - reporter: Choose output reporter. Available: xcode, json, csv, checkstyle, codeclimate,                                                      junit, html, emoji, sonarqube, markdown, github-actions-logging
   - quiet: Don't print status logs like 'Linting <file>' & 'Done linting'
   - executable: Path to the `swiftlint` executable on your machine
   - format: Format code when mode is :autocorrect
   - noCache: Ignore the cache when mode is :autocorrect or :lint
   - compilerLogPath: Compiler log path when mode is :analyze
 */
public func swiftlint(mode: Any = "lint",
                      path: String? = nil,
                      outputFile: String? = nil,
                      configFile: String? = nil,
                      strict: Bool = false,
                      files: Any? = nil,
                      ignoreExitStatus: Bool = false,
                      raiseIfSwiftlintError: Bool = false,
                      reporter: String? = nil,
                      quiet: Bool = false,
                      executable: String? = nil,
                      format: Bool = false,
                      noCache: Bool = false,
                      compilerLogPath: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "swiftlint", className: nil, args: [RubyCommand.Argument(name: "mode", value: mode),
                                                                                             RubyCommand.Argument(name: "path", value: path),
                                                                                             RubyCommand.Argument(name: "output_file", value: outputFile),
                                                                                             RubyCommand.Argument(name: "config_file", value: configFile),
                                                                                             RubyCommand.Argument(name: "strict", value: strict),
                                                                                             RubyCommand.Argument(name: "files", value: files),
                                                                                             RubyCommand.Argument(name: "ignore_exit_status", value: ignoreExitStatus),
                                                                                             RubyCommand.Argument(name: "raise_if_swiftlint_error", value: raiseIfSwiftlintError),
                                                                                             RubyCommand.Argument(name: "reporter", value: reporter),
                                                                                             RubyCommand.Argument(name: "quiet", value: quiet),
                                                                                             RubyCommand.Argument(name: "executable", value: executable),
                                                                                             RubyCommand.Argument(name: "format", value: format),
                                                                                             RubyCommand.Argument(name: "no_cache", value: noCache),
                                                                                             RubyCommand.Argument(name: "compiler_log_path", value: compilerLogPath)])
    _ = runner.executeCommand(command)
}

/**
 Easily sync your certificates and profiles across your team (via _match_)

 - parameters:
   - type: Define the profile type, can be appstore, adhoc, development, enterprise, developer_id, mac_installer_distribution
   - additionalCertTypes: Create additional cert types needed for macOS installers (valid values: mac_installer_distribution, developer_id_installer)
   - readonly: Only fetch existing certificates and profiles, don't generate new ones
   - generateAppleCerts: Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)
   - skipProvisioningProfiles: Skip syncing provisioning profiles
   - appIdentifier: The bundle identifier(s) of your app (comma-separated string or array of strings)
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - teamId: The ID of your Developer Portal team if you're in multiple teams
   - teamName: The name of your Developer Portal team if you're in multiple teams
   - storageMode: Define where you want to store your certificates
   - gitUrl: URL to the git repo containing all the certificates
   - gitBranch: Specific git branch to use
   - gitFullName: git user full name to commit
   - gitUserEmail: git user email to commit
   - shallowClone: Make a shallow clone of the repository (truncate the history to 1 revision)
   - cloneBranchDirectly: Clone just the branch specified, instead of the whole repo. This requires that the branch already exists. Otherwise the command will fail
   - gitBasicAuthorization: Use a basic authorization header to access the git repo (e.g.: access via HTTPS, GitHub Actions, etc), usually a string in Base64
   - gitBearerAuthorization: Use a bearer authorization header to access the git repo (e.g.: access to an Azure DevOps repository), usually a string in Base64
   - gitPrivateKey: Use a private key to access the git repo (e.g.: access to GitHub repository via Deploy keys), usually a id_rsa named file or the contents hereof
   - googleCloudBucketName: Name of the Google Cloud Storage bucket to use
   - googleCloudKeysFile: Path to the gc_keys.json file
   - googleCloudProjectId: ID of the Google Cloud project to use for authentication
   - s3Region: Name of the S3 region
   - s3AccessKey: S3 access key
   - s3SecretAccessKey: S3 secret access key
   - s3Bucket: Name of the S3 bucket
   - s3ObjectPrefix: Prefix to be used on all objects uploaded to S3
   - keychainName: Keychain the items should be imported to
   - keychainPassword: This might be required the first time you access certificates on a new mac. For the login/default keychain this is your macOS account password
   - force: Renew the provisioning profiles every time you run match
   - forceForNewDevices: Renew the provisioning profiles if the device count on the developer portal has changed. Ignored for profile type 'appstore'
   - skipConfirmation: Disables confirmation prompts during nuke, answering them with yes
   - skipDocs: Skip generation of a README.md for the created git repository
   - platform: Set the provisioning profile's platform to work with (i.e. ios, tvos, macos, catalyst)
   - deriveCatalystAppIdentifier: Enable this if you have the Mac Catalyst capability enabled and your project was created with Xcode 11.3 or earlier. Prepends 'maccatalyst.' to the app identifier for the provisioning profile mapping
   - templateName: The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. "Apple Pay Pass Suppression Development")
   - profileName: A custom name for the provisioning profile. This will replace the default provisioning profile name if specified
   - failOnNameTaken: Should the command fail if it was about to create a duplicate of an existing provisioning profile. It can happen due to issues on Apple Developer Portal, when profile to be recreated was not properly deleted first
   - skipCertificateMatching: Set to true if there is no access to Apple developer portal but there are certificates, keys and profiles provided. Only works with match import action
   - outputPath: Path in which to export certificates, key and profile
   - skipSetPartitionList: Skips setting the partition list (which can sometimes take a long time). Setting the partition list is usually needed to prevent Xcode from prompting to allow a cert to be used for signing
   - verbose: Print out extra information and all commands

 More information: https://docs.fastlane.tools/actions/match/
 */
public func syncCodeSigning(type: String = "development",
                            additionalCertTypes: [String]? = nil,
                            readonly: Bool = false,
                            generateAppleCerts: Bool = true,
                            skipProvisioningProfiles: Bool = false,
                            appIdentifier: [String],
                            apiKeyPath: String? = nil,
                            apiKey: [String: Any]? = nil,
                            username: String? = nil,
                            teamId: String? = nil,
                            teamName: String? = nil,
                            storageMode: String = "git",
                            gitUrl: String,
                            gitBranch: String = "master",
                            gitFullName: String? = nil,
                            gitUserEmail: String? = nil,
                            shallowClone: Bool = false,
                            cloneBranchDirectly: Bool = false,
                            gitBasicAuthorization: String? = nil,
                            gitBearerAuthorization: String? = nil,
                            gitPrivateKey: String? = nil,
                            googleCloudBucketName: String? = nil,
                            googleCloudKeysFile: String? = nil,
                            googleCloudProjectId: String? = nil,
                            s3Region: String? = nil,
                            s3AccessKey: String? = nil,
                            s3SecretAccessKey: String? = nil,
                            s3Bucket: String? = nil,
                            s3ObjectPrefix: String? = nil,
                            keychainName: String = "login.keychain",
                            keychainPassword: String? = nil,
                            force: Bool = false,
                            forceForNewDevices: Bool = false,
                            skipConfirmation: Bool = false,
                            skipDocs: Bool = false,
                            platform: String = "ios",
                            deriveCatalystAppIdentifier: Bool = false,
                            templateName: String? = nil,
                            profileName: String? = nil,
                            failOnNameTaken: Bool = false,
                            skipCertificateMatching: Bool = false,
                            outputPath: String? = nil,
                            skipSetPartitionList: Bool = false,
                            verbose: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "sync_code_signing", className: nil, args: [RubyCommand.Argument(name: "type", value: type),
                                                                                                     RubyCommand.Argument(name: "additional_cert_types", value: additionalCertTypes),
                                                                                                     RubyCommand.Argument(name: "readonly", value: readonly),
                                                                                                     RubyCommand.Argument(name: "generate_apple_certs", value: generateAppleCerts),
                                                                                                     RubyCommand.Argument(name: "skip_provisioning_profiles", value: skipProvisioningProfiles),
                                                                                                     RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                     RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                     RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                     RubyCommand.Argument(name: "username", value: username),
                                                                                                     RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                     RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                     RubyCommand.Argument(name: "storage_mode", value: storageMode),
                                                                                                     RubyCommand.Argument(name: "git_url", value: gitUrl),
                                                                                                     RubyCommand.Argument(name: "git_branch", value: gitBranch),
                                                                                                     RubyCommand.Argument(name: "git_full_name", value: gitFullName),
                                                                                                     RubyCommand.Argument(name: "git_user_email", value: gitUserEmail),
                                                                                                     RubyCommand.Argument(name: "shallow_clone", value: shallowClone),
                                                                                                     RubyCommand.Argument(name: "clone_branch_directly", value: cloneBranchDirectly),
                                                                                                     RubyCommand.Argument(name: "git_basic_authorization", value: gitBasicAuthorization),
                                                                                                     RubyCommand.Argument(name: "git_bearer_authorization", value: gitBearerAuthorization),
                                                                                                     RubyCommand.Argument(name: "git_private_key", value: gitPrivateKey),
                                                                                                     RubyCommand.Argument(name: "google_cloud_bucket_name", value: googleCloudBucketName),
                                                                                                     RubyCommand.Argument(name: "google_cloud_keys_file", value: googleCloudKeysFile),
                                                                                                     RubyCommand.Argument(name: "google_cloud_project_id", value: googleCloudProjectId),
                                                                                                     RubyCommand.Argument(name: "s3_region", value: s3Region),
                                                                                                     RubyCommand.Argument(name: "s3_access_key", value: s3AccessKey),
                                                                                                     RubyCommand.Argument(name: "s3_secret_access_key", value: s3SecretAccessKey),
                                                                                                     RubyCommand.Argument(name: "s3_bucket", value: s3Bucket),
                                                                                                     RubyCommand.Argument(name: "s3_object_prefix", value: s3ObjectPrefix),
                                                                                                     RubyCommand.Argument(name: "keychain_name", value: keychainName),
                                                                                                     RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                     RubyCommand.Argument(name: "force", value: force),
                                                                                                     RubyCommand.Argument(name: "force_for_new_devices", value: forceForNewDevices),
                                                                                                     RubyCommand.Argument(name: "skip_confirmation", value: skipConfirmation),
                                                                                                     RubyCommand.Argument(name: "skip_docs", value: skipDocs),
                                                                                                     RubyCommand.Argument(name: "platform", value: platform),
                                                                                                     RubyCommand.Argument(name: "derive_catalyst_app_identifier", value: deriveCatalystAppIdentifier),
                                                                                                     RubyCommand.Argument(name: "template_name", value: templateName),
                                                                                                     RubyCommand.Argument(name: "profile_name", value: profileName),
                                                                                                     RubyCommand.Argument(name: "fail_on_name_taken", value: failOnNameTaken),
                                                                                                     RubyCommand.Argument(name: "skip_certificate_matching", value: skipCertificateMatching),
                                                                                                     RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                     RubyCommand.Argument(name: "skip_set_partition_list", value: skipSetPartitionList),
                                                                                                     RubyCommand.Argument(name: "verbose", value: verbose)])
    _ = runner.executeCommand(command)
}

/**
 Specify the Team ID you want to use for the Apple Developer Portal
 */
public func teamId() {
    let command = RubyCommand(commandID: "", methodName: "team_id", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Set a team to use by its name
 */
public func teamName() {
    let command = RubyCommand(commandID: "", methodName: "team_name", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Upload a new build to [TestFairy](https://www.testfairy.com/)

 - parameters:
   - apiKey: API Key for TestFairy
   - ipa: Path to your IPA file for iOS
   - apk: Path to your APK file for Android
   - symbolsFile: Symbols mapping file
   - uploadUrl: API URL for TestFairy
   - testersGroups: Array of tester groups to be notified
   - metrics: Array of metrics to record (cpu,memory,network,phone_signal,gps,battery,mic,wifi)
   - comment: Additional release notes for this upload. This text will be added to email notifications
   - autoUpdate: Allows an easy upgrade of all users to the current version. To enable set to 'on'
   - notify: Send email to testers
   - options: Array of options (shake,video_only_wifi,anonymous)
   - custom: Array of custom options. Contact support@testfairy.com for more information
   - timeout: Request timeout in seconds

 You can retrieve your API key on [your settings page](https://free.testfairy.com/settings/)
 */
public func testfairy(apiKey: String,
                      ipa: String? = nil,
                      apk: String? = nil,
                      symbolsFile: String? = nil,
                      uploadUrl: String = "https://upload.testfairy.com",
                      testersGroups: [String] = [],
                      metrics: [String] = [],
                      comment: String = "No comment provided",
                      autoUpdate: String = "off",
                      notify: String = "off",
                      options: [String] = [],
                      custom: String = "",
                      timeout: Int? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "testfairy", className: nil, args: [RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                             RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                             RubyCommand.Argument(name: "apk", value: apk),
                                                                                             RubyCommand.Argument(name: "symbols_file", value: symbolsFile),
                                                                                             RubyCommand.Argument(name: "upload_url", value: uploadUrl),
                                                                                             RubyCommand.Argument(name: "testers_groups", value: testersGroups),
                                                                                             RubyCommand.Argument(name: "metrics", value: metrics),
                                                                                             RubyCommand.Argument(name: "comment", value: comment),
                                                                                             RubyCommand.Argument(name: "auto_update", value: autoUpdate),
                                                                                             RubyCommand.Argument(name: "notify", value: notify),
                                                                                             RubyCommand.Argument(name: "options", value: options),
                                                                                             RubyCommand.Argument(name: "custom", value: custom),
                                                                                             RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Alias for the `upload_to_testflight` action

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - appIdentifier: The bundle identifier of the app to upload or manage testers (optional)
   - appPlatform: The platform to use (optional)
   - appleId: Apple ID property in the App Information section in App Store Connect
   - ipa: Path to the ipa file to upload
   - demoAccountRequired: Do you need a demo account when Apple does review?
   - betaAppReviewInfo: Beta app review information for contact info and demo account
   - localizedAppInfo: Localized beta app test info for description, feedback email, marketing url, and privacy policy
   - betaAppDescription: Provide the 'Beta App Description' when uploading a new build
   - betaAppFeedbackEmail: Provide the beta app email when uploading a new build
   - localizedBuildInfo: Localized beta app test info for what's new
   - changelog: Provide the 'What to Test' text when uploading a new build
   - skipSubmission: Skip the distributing action of pilot and only upload the ipa file
   - skipWaitingForBuildProcessing: If set to true, the `distribute_external` option won't work and no build will be distributed to testers. (You might want to use this option if you are using this action on CI and have to pay for 'minutes used' on your CI plan). If set to `true` and a changelog is provided, it will partially wait for the build to appear on AppStore Connect so the changelog can be set, and skip the remaining processing steps
   - updateBuildInfoOnUpload: **DEPRECATED!** Update build info immediately after validation. This is deprecated and will be removed in a future release. App Store Connect no longer supports setting build info until after build processing has completed, which is when build info is updated by default
   - distributeOnly: Distribute a previously uploaded build (equivalent to the `fastlane pilot distribute` command)
   - usesNonExemptEncryption: Provide the 'Uses Non-Exempt Encryption' for export compliance. This is used if there is 'ITSAppUsesNonExemptEncryption' is not set in the Info.plist
   - distributeExternal: Should the build be distributed to external testers?
   - notifyExternalTesters: Should notify external testers?
   - appVersion: The version number of the application build to distribute. If the version number is not specified, then the most recent build uploaded to TestFlight will be distributed. If specified, the most recent build for the version number will be distributed
   - buildNumber: The build number of the application build to distribute. If the build number is not specified, the most recent build is distributed
   - expirePreviousBuilds: Should expire previous builds?
   - firstName: The tester's first name
   - lastName: The tester's last name
   - email: The tester's email
   - testersFilePath: Path to a CSV file of testers
   - groups: Associate tester to one group or more by group name / group id. E.g. `-g "Team 1","Team 2"`
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - devPortalTeamId: The short ID of your team in the developer portal, if you're in multiple teams. Different from your iTC team ID!
   - itcProvider: The provider short name to be used with the iTMSTransporter to identify your team. This value will override the automatically detected provider short name. To get provider short name run `pathToXcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m provider -u 'USERNAME' -p 'PASSWORD' -account_type itunes_connect -v off`. The short names of providers should be listed in the second column
   - waitProcessingInterval: Interval in seconds to wait for App Store Connect processing
   - waitForUploadedBuild: **DEPRECATED!** No longer needed with the transition over to the App Store Connect API - Use version info from uploaded ipa file to determine what build to use for distribution. If set to false, latest processing or any latest build will be used
   - rejectBuildWaitingForReview: Expire previous if it's 'waiting for review'

 More details can be found on https://docs.fastlane.tools/actions/pilot/.
 This integration will only do the TestFlight upload.
 */
public func testflight(apiKeyPath: String? = nil,
                       apiKey: [String: Any]? = nil,
                       username: String,
                       appIdentifier: String? = nil,
                       appPlatform: String = "ios",
                       appleId: String? = nil,
                       ipa: String? = nil,
                       demoAccountRequired: Bool? = nil,
                       betaAppReviewInfo: [String: Any]? = nil,
                       localizedAppInfo: [String: Any]? = nil,
                       betaAppDescription: String? = nil,
                       betaAppFeedbackEmail: String? = nil,
                       localizedBuildInfo: [String: Any]? = nil,
                       changelog: String? = nil,
                       skipSubmission: Bool = false,
                       skipWaitingForBuildProcessing: Bool = false,
                       updateBuildInfoOnUpload: Bool = false,
                       distributeOnly: Bool = false,
                       usesNonExemptEncryption: Bool = false,
                       distributeExternal: Bool = false,
                       notifyExternalTesters: Bool = true,
                       appVersion: String? = nil,
                       buildNumber: String? = nil,
                       expirePreviousBuilds: Bool = false,
                       firstName: String? = nil,
                       lastName: String? = nil,
                       email: String? = nil,
                       testersFilePath: String = "./testers.csv",
                       groups: [String]? = nil,
                       teamId: Any? = nil,
                       teamName: String? = nil,
                       devPortalTeamId: String? = nil,
                       itcProvider: String? = nil,
                       waitProcessingInterval: Int = 30,
                       waitForUploadedBuild: Bool = false,
                       rejectBuildWaitingForReview: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "testflight", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                              RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                              RubyCommand.Argument(name: "username", value: username),
                                                                                              RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                              RubyCommand.Argument(name: "app_platform", value: appPlatform),
                                                                                              RubyCommand.Argument(name: "apple_id", value: appleId),
                                                                                              RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                              RubyCommand.Argument(name: "demo_account_required", value: demoAccountRequired),
                                                                                              RubyCommand.Argument(name: "beta_app_review_info", value: betaAppReviewInfo),
                                                                                              RubyCommand.Argument(name: "localized_app_info", value: localizedAppInfo),
                                                                                              RubyCommand.Argument(name: "beta_app_description", value: betaAppDescription),
                                                                                              RubyCommand.Argument(name: "beta_app_feedback_email", value: betaAppFeedbackEmail),
                                                                                              RubyCommand.Argument(name: "localized_build_info", value: localizedBuildInfo),
                                                                                              RubyCommand.Argument(name: "changelog", value: changelog),
                                                                                              RubyCommand.Argument(name: "skip_submission", value: skipSubmission),
                                                                                              RubyCommand.Argument(name: "skip_waiting_for_build_processing", value: skipWaitingForBuildProcessing),
                                                                                              RubyCommand.Argument(name: "update_build_info_on_upload", value: updateBuildInfoOnUpload),
                                                                                              RubyCommand.Argument(name: "distribute_only", value: distributeOnly),
                                                                                              RubyCommand.Argument(name: "uses_non_exempt_encryption", value: usesNonExemptEncryption),
                                                                                              RubyCommand.Argument(name: "distribute_external", value: distributeExternal),
                                                                                              RubyCommand.Argument(name: "notify_external_testers", value: notifyExternalTesters),
                                                                                              RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                              RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                              RubyCommand.Argument(name: "expire_previous_builds", value: expirePreviousBuilds),
                                                                                              RubyCommand.Argument(name: "first_name", value: firstName),
                                                                                              RubyCommand.Argument(name: "last_name", value: lastName),
                                                                                              RubyCommand.Argument(name: "email", value: email),
                                                                                              RubyCommand.Argument(name: "testers_file_path", value: testersFilePath),
                                                                                              RubyCommand.Argument(name: "groups", value: groups),
                                                                                              RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                              RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                              RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId),
                                                                                              RubyCommand.Argument(name: "itc_provider", value: itcProvider),
                                                                                              RubyCommand.Argument(name: "wait_processing_interval", value: waitProcessingInterval),
                                                                                              RubyCommand.Argument(name: "wait_for_uploaded_build", value: waitForUploadedBuild),
                                                                                              RubyCommand.Argument(name: "reject_build_waiting_for_review", value: rejectBuildWaitingForReview)])
    _ = runner.executeCommand(command)
}

/**
 Upload a new build to [Tryouts](https://tryouts.io/)

 - parameters:
   - appId: Tryouts application hash
   - apiToken: API Token (api_key:api_secret) for Tryouts Access
   - buildFile: Path to your IPA or APK file. Optional if you use the _gym_ or _xcodebuild_ action
   - notes: Release notes
   - notesPath: Release notes text file path. Overrides the :notes parameter
   - notify: Notify testers? 0 for no
   - status: 2 to make your release public. Release will be distributed to available testers. 1 to make your release private. Release won't be distributed to testers. This also prevents release from showing up for SDK update

 More information: [http://tryouts.readthedocs.org/en/latest/releases.html#create-release](http://tryouts.readthedocs.org/en/latest/releases.html#create-release)
 */
public func tryouts(appId: String,
                    apiToken: String,
                    buildFile: String,
                    notes: String? = nil,
                    notesPath: String? = nil,
                    notify: Int = 1,
                    status: Int = 2)
{
    let command = RubyCommand(commandID: "", methodName: "tryouts", className: nil, args: [RubyCommand.Argument(name: "app_id", value: appId),
                                                                                           RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                           RubyCommand.Argument(name: "build_file", value: buildFile),
                                                                                           RubyCommand.Argument(name: "notes", value: notes),
                                                                                           RubyCommand.Argument(name: "notes_path", value: notesPath),
                                                                                           RubyCommand.Argument(name: "notify", value: notify),
                                                                                           RubyCommand.Argument(name: "status", value: status)])
    _ = runner.executeCommand(command)
}

/**
 Post a tweet on [Twitter.com](https://twitter.com)

 - parameters:
   - consumerKey: Consumer Key
   - consumerSecret: Consumer Secret
   - accessToken: Access Token
   - accessTokenSecret: Access Token Secret
   - message: The tweet

 Post a tweet on Twitter. Requires you to setup an app on [twitter.com](https://twitter.com) and obtain `consumer` and `access_token`.
 */
public func twitter(consumerKey: String,
                    consumerSecret: String,
                    accessToken: String,
                    accessTokenSecret: String,
                    message: String)
{
    let command = RubyCommand(commandID: "", methodName: "twitter", className: nil, args: [RubyCommand.Argument(name: "consumer_key", value: consumerKey),
                                                                                           RubyCommand.Argument(name: "consumer_secret", value: consumerSecret),
                                                                                           RubyCommand.Argument(name: "access_token", value: accessToken),
                                                                                           RubyCommand.Argument(name: "access_token_secret", value: accessTokenSecret),
                                                                                           RubyCommand.Argument(name: "message", value: message)])
    _ = runner.executeCommand(command)
}

/**
 Post a message to [Typetalk](https://www.typetalk.com/)
 */
public func typetalk() {
    let command = RubyCommand(commandID: "", methodName: "typetalk", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Unlock a keychain

 - parameters:
   - path: Path to the keychain file
   - password: Keychain password
   - addToSearchList: Add to keychain search list
   - setDefault: Set as default keychain

 Unlocks the given keychain file and adds it to the keychain search list.
 Keychains can be replaced with `add_to_search_list: :replace`.
 */
public func unlockKeychain(path: String = "login",
                           password: String,
                           addToSearchList: Bool = true,
                           setDefault: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "unlock_keychain", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                   RubyCommand.Argument(name: "password", value: password),
                                                                                                   RubyCommand.Argument(name: "add_to_search_list", value: addToSearchList),
                                                                                                   RubyCommand.Argument(name: "set_default", value: setDefault)])
    _ = runner.executeCommand(command)
}

/**
 This action changes the app group identifiers in the entitlements file

 - parameters:
   - entitlementsFile: The path to the entitlement file which contains the app group identifiers
   - appGroupIdentifiers: An Array of unique identifiers for the app groups. Eg. ['group.com.test.testapp']

 Updates the App Group Identifiers in the given Entitlements file, so you can have app groups for the app store build and app groups for an enterprise build.
 */
public func updateAppGroupIdentifiers(entitlementsFile: String,
                                      appGroupIdentifiers: Any)
{
    let command = RubyCommand(commandID: "", methodName: "update_app_group_identifiers", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile),
                                                                                                                RubyCommand.Argument(name: "app_group_identifiers", value: appGroupIdentifiers)])
    _ = runner.executeCommand(command)
}

/**
 Update the project's bundle identifier

 - parameters:
   - xcodeproj: Path to your Xcode project
   - plistPath: Path to info plist, relative to your Xcode project
   - appIdentifier: The app Identifier you want to set

 Update an app identifier by either setting `CFBundleIdentifier` or `PRODUCT_BUNDLE_IDENTIFIER`, depending on which is already in use.
 */
public func updateAppIdentifier(xcodeproj: String,
                                plistPath: String,
                                appIdentifier: String)
{
    let command = RubyCommand(commandID: "", methodName: "update_app_identifier", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                         RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                         RubyCommand.Argument(name: "app_identifier", value: appIdentifier)])
    _ = runner.executeCommand(command)
}

/**
 Configures Xcode's Codesigning options

 - parameters:
   - path: Path to your Xcode project
   - useAutomaticSigning: Defines if project should use automatic signing
   - teamId: Team ID, is used when upgrading project
   - targets: Specify targets you want to toggle the signing mech. (default to all targets)
   - buildConfigurations: Specify build_configurations you want to toggle the signing mech. (default to all configurations)
   - codeSignIdentity: Code signing identity type (iPhone Developer, iPhone Distribution)
   - profileName: Provisioning profile name to use for code signing
   - profileUuid: Provisioning profile UUID to use for code signing
   - bundleIdentifier: Application Product Bundle Identifier

 - returns: The current status (boolean) of codesigning after modification

 Configures Xcode's Codesigning options of all targets in the project
 */
public func updateCodeSigningSettings(path: String,
                                      useAutomaticSigning: Bool = false,
                                      teamId: String? = nil,
                                      targets: [String]? = nil,
                                      buildConfigurations: [String]? = nil,
                                      codeSignIdentity: String? = nil,
                                      profileName: String? = nil,
                                      profileUuid: String? = nil,
                                      bundleIdentifier: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "update_code_signing_settings", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                                RubyCommand.Argument(name: "use_automatic_signing", value: useAutomaticSigning),
                                                                                                                RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                                RubyCommand.Argument(name: "targets", value: targets),
                                                                                                                RubyCommand.Argument(name: "build_configurations", value: buildConfigurations),
                                                                                                                RubyCommand.Argument(name: "code_sign_identity", value: codeSignIdentity),
                                                                                                                RubyCommand.Argument(name: "profile_name", value: profileName),
                                                                                                                RubyCommand.Argument(name: "profile_uuid", value: profileUuid),
                                                                                                                RubyCommand.Argument(name: "bundle_identifier", value: bundleIdentifier)])
    _ = runner.executeCommand(command)
}

/**
 Makes sure fastlane-tools are up-to-date when running fastlane

 - parameters:
   - noUpdate: Don't update during this run. This is used internally
   - nightly: **DEPRECATED!** Nightly builds are no longer being made available - Opt-in to install and use nightly fastlane builds

 This action will update fastlane to the most recent version - major version updates will not be performed automatically, as they might include breaking changes. If an update was performed, fastlane will be restarted before the run continues.

 If you are using rbenv or rvm, everything should be good to go. However, if you are using the system's default ruby, some additional setup is needed for this action to work correctly. In short, fastlane needs to be able to access your gem library without running in `sudo` mode.

 The simplest possible fix for this is putting the following lines into your `~/.bashrc` or `~/.zshrc` file:|
 |
 ```bash|
 export GEM_HOME=~/.gems|
 export PATH=$PATH:~/.gems/bin|
 ```|
 >|
 After the above changes, restart your terminal, then run `mkdir $GEM_HOME` to create the new gem directory. After this, you're good to go!

 Recommended usage of the `update_fastlane` action is at the top inside of the `before_all` block, before running any other action.
 */
public func updateFastlane(noUpdate: Bool = false,
                           nightly: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "update_fastlane", className: nil, args: [RubyCommand.Argument(name: "no_update", value: noUpdate),
                                                                                                   RubyCommand.Argument(name: "nightly", value: nightly)])
    _ = runner.executeCommand(command)
}

/**
 This action changes the iCloud container identifiers in the entitlements file

 - parameters:
   - entitlementsFile: The path to the entitlement file which contains the iCloud container identifiers
   - icloudContainerIdentifiers: An Array of unique identifiers for the iCloud containers. Eg. ['iCloud.com.test.testapp']

 Updates the iCloud Container Identifiers in the given Entitlements file, so you can use different iCloud containers for different builds like Adhoc, App Store, etc.
 */
public func updateIcloudContainerIdentifiers(entitlementsFile: String,
                                             icloudContainerIdentifiers: Any)
{
    let command = RubyCommand(commandID: "", methodName: "update_icloud_container_identifiers", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile),
                                                                                                                       RubyCommand.Argument(name: "icloud_container_identifiers", value: icloudContainerIdentifiers)])
    _ = runner.executeCommand(command)
}

/**
 Update a Info.plist file with bundle identifier and display name

 - parameters:
   - xcodeproj: Path to your Xcode project
   - plistPath: Path to info plist
   - scheme: Scheme of info plist
   - appIdentifier: The App Identifier of your app
   - displayName: The Display Name of your app
   - block: A block to process plist with custom logic

 This action allows you to modify your `Info.plist` file before building. This may be useful if you want a separate build for alpha, beta or nightly builds, but don't want a separate target.
 */
public func updateInfoPlist(xcodeproj: String? = nil,
                            plistPath: String? = nil,
                            scheme: String? = nil,
                            appIdentifier: String? = nil,
                            displayName: String? = nil,
                            block: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "update_info_plist", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                     RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                     RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                     RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                     RubyCommand.Argument(name: "display_name", value: displayName),
                                                                                                     RubyCommand.Argument(name: "block", value: block)])
    _ = runner.executeCommand(command)
}

/**
 This action changes the keychain access groups in the entitlements file

 - parameters:
   - entitlementsFile: The path to the entitlement file which contains the keychain access groups
   - identifiers: An Array of unique identifiers for the keychain access groups. Eg. ['your.keychain.access.groups.identifiers']

 Updates the Keychain Group Access Groups in the given Entitlements file, so you can have keychain access groups for the app store build and keychain access groups for an enterprise build.
 */
public func updateKeychainAccessGroups(entitlementsFile: String,
                                       identifiers: Any)
{
    let command = RubyCommand(commandID: "", methodName: "update_keychain_access_groups", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile),
                                                                                                                 RubyCommand.Argument(name: "identifiers", value: identifiers)])
    _ = runner.executeCommand(command)
}

/**
 Update a plist file

 - parameters:
   - plistPath: Path to plist file
   - block: A block to process plist with custom logic

 This action allows you to modify any value inside any `plist` file.
 */
public func updatePlist(plistPath: String? = nil,
                        block: Any)
{
    let command = RubyCommand(commandID: "", methodName: "update_plist", className: nil, args: [RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                RubyCommand.Argument(name: "block", value: block)])
    _ = runner.executeCommand(command)
}

/**
 Updated code signing settings from 'Automatic' to a specific profile

 - parameters:
   - path: Path to your Xcode project
   - udid: **DEPRECATED!** Use `:uuid` instead
   - uuid: The UUID of the provisioning profile you want to use
 */
public func updateProjectCodeSigning(path: String,
                                     udid: String? = nil,
                                     uuid: String)
{
    let command = RubyCommand(commandID: "", methodName: "update_project_code_signing", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                               RubyCommand.Argument(name: "udid", value: udid),
                                                                                                               RubyCommand.Argument(name: "uuid", value: uuid)])
    _ = runner.executeCommand(command)
}

/**
 Update projects code signing settings from your provisioning profile

 - parameters:
   - xcodeproj: Path to your Xcode project
   - profile: Path to provisioning profile (.mobileprovision)
   - targetFilter: A filter for the target name. Use a standard regex
   - buildConfigurationFilter: Legacy option, use 'target_filter' instead
   - buildConfiguration: A filter for the build configuration name. Use a standard regex. Applied to all configurations if not specified
   - certificate: Path to apple root certificate
   - codeSigningIdentity: Code sign identity for build configuration

 You should check out the [code signing guide](https://docs.fastlane.tools/codesigning/getting-started/) before using this action.
 This action retrieves a provisioning profile UUID from a provisioning profile (`.mobileprovision`) to set up the Xcode projects' code signing settings in `*.xcodeproj/project.pbxproj`.
 The `:target_filter` value can be used to only update code signing for the specified targets.
 The `:build_configuration` value can be used to only update code signing for the specified build configurations of the targets passing through the `:target_filter`.
 Example usage is the WatchKit Extension or WatchKit App, where you need separate provisioning profiles.
 Example: `update_project_provisioning(xcodeproj: "..", target_filter: ".*WatchKit App.*")`.
 */
public func updateProjectProvisioning(xcodeproj: String? = nil,
                                      profile: String,
                                      targetFilter: Any? = nil,
                                      buildConfigurationFilter: String? = nil,
                                      buildConfiguration: Any? = nil,
                                      certificate: String = "/tmp/AppleIncRootCertificate.cer",
                                      codeSigningIdentity: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "update_project_provisioning", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                               RubyCommand.Argument(name: "profile", value: profile),
                                                                                                               RubyCommand.Argument(name: "target_filter", value: targetFilter),
                                                                                                               RubyCommand.Argument(name: "build_configuration_filter", value: buildConfigurationFilter),
                                                                                                               RubyCommand.Argument(name: "build_configuration", value: buildConfiguration),
                                                                                                               RubyCommand.Argument(name: "certificate", value: certificate),
                                                                                                               RubyCommand.Argument(name: "code_signing_identity", value: codeSigningIdentity)])
    _ = runner.executeCommand(command)
}

/**
 Update Xcode Development Team ID

 - parameters:
   - path: Path to your Xcode project
   - targets: Name of the targets you want to update
   - teamid: The Team ID you want to use

 This action updates the Developer Team ID of your Xcode project.
 */
public func updateProjectTeam(path: String,
                              targets: [String]? = nil,
                              teamid: String)
{
    let command = RubyCommand(commandID: "", methodName: "update_project_team", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                       RubyCommand.Argument(name: "targets", value: targets),
                                                                                                       RubyCommand.Argument(name: "teamid", value: teamid)])
    _ = runner.executeCommand(command)
}

/**
 Set [Urban Airship](https://www.urbanairship.com/) plist configuration values

 - parameters:
   - plistPath: Path to Urban Airship configuration Plist
   - developmentAppKey: The development app key
   - developmentAppSecret: The development app secret
   - productionAppKey: The production app key
   - productionAppSecret: The production app secret
   - detectProvisioningMode: Automatically detect provisioning mode

 This action updates the `AirshipConfig.plist` needed to configure the Urban Airship SDK at runtime, allowing keys and secrets to easily be set for the Enterprise and Production versions of the application.
 */
public func updateUrbanAirshipConfiguration(plistPath: String,
                                            developmentAppKey: String? = nil,
                                            developmentAppSecret: String? = nil,
                                            productionAppKey: String? = nil,
                                            productionAppSecret: String? = nil,
                                            detectProvisioningMode: Bool? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "update_urban_airship_configuration", className: nil, args: [RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                                      RubyCommand.Argument(name: "development_app_key", value: developmentAppKey),
                                                                                                                      RubyCommand.Argument(name: "development_app_secret", value: developmentAppSecret),
                                                                                                                      RubyCommand.Argument(name: "production_app_key", value: productionAppKey),
                                                                                                                      RubyCommand.Argument(name: "production_app_secret", value: productionAppSecret),
                                                                                                                      RubyCommand.Argument(name: "detect_provisioning_mode", value: detectProvisioningMode)])
    _ = runner.executeCommand(command)
}

/**
 Updates the URL schemes in the given Info.plist

 - parameters:
   - path: The Plist file's path
   - urlSchemes: The new URL schemes
   - updateUrlSchemes: Block that is called to update schemes with current schemes passed in as parameter

 This action allows you to update the URL schemes of the app before building it.
 For example, you can use this to set a different URL scheme for the alpha or beta version of the app.
 */
public func updateUrlSchemes(path: String,
                             urlSchemes: Any? = nil,
                             updateUrlSchemes: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "update_url_schemes", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                      RubyCommand.Argument(name: "url_schemes", value: urlSchemes),
                                                                                                      RubyCommand.Argument(name: "update_url_schemes", value: updateUrlSchemes)])
    _ = runner.executeCommand(command)
}

/**
 Upload App Privacy Details for an app in App Store Connect

 - parameters:
   - username: Your Apple ID Username for App Store Connect
   - appIdentifier: The bundle identifier of your app
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - jsonPath: Path to the app usage data JSON
   - outputJsonPath: Path to the app usage data JSON file generated by interactive questions
   - skipJsonFileSaving: Whether to skip the saving of the JSON file
   - skipUpload: Whether to skip the upload and only create the JSON file with interactive questions
   - skipPublish: Whether to skip the publishing

 Upload App Privacy Details for an app in App Store Connect. For more detail information, view https://docs.fastlane.tools/uploading-app-privacy-details
 */
public func uploadAppPrivacyDetailsToAppStore(username: String,
                                              appIdentifier: String,
                                              teamId: Any? = nil,
                                              teamName: String? = nil,
                                              jsonPath: String? = nil,
                                              outputJsonPath: String = "./fastlane/app_privacy_details.json",
                                              skipJsonFileSaving: Bool = false,
                                              skipUpload: Bool = false,
                                              skipPublish: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "upload_app_privacy_details_to_app_store", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                                           RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                                           RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                                           RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                                           RubyCommand.Argument(name: "json_path", value: jsonPath),
                                                                                                                           RubyCommand.Argument(name: "output_json_path", value: outputJsonPath),
                                                                                                                           RubyCommand.Argument(name: "skip_json_file_saving", value: skipJsonFileSaving),
                                                                                                                           RubyCommand.Argument(name: "skip_upload", value: skipUpload),
                                                                                                                           RubyCommand.Argument(name: "skip_publish", value: skipPublish)])
    _ = runner.executeCommand(command)
}

/**
 Upload dSYM symbolication files to Crashlytics

 - parameters:
   - dsymPath: Path to the DSYM file or zip to upload
   - dsymPaths: Paths to the DSYM files or zips to upload
   - apiToken: Crashlytics API Key
   - gspPath: Path to GoogleService-Info.plist
   - appId: Firebase Crashlytics APP ID
   - binaryPath: The path to the upload-symbols file of the Fabric app
   - platform: The platform of the app (ios, appletvos, mac)
   - dsymWorkerThreads: The number of threads to use for simultaneous dSYM upload
   - debug: Enable debug mode for upload-symbols

 This action allows you to upload symbolication files to Crashlytics. It's extra useful if you use it to download the latest dSYM files from Apple when you use Bitcode. This action will not fail the build if one of the uploads failed. The reason for that is that sometimes some of dSYM files are invalid, and we don't want them to fail the complete build.
 */
public func uploadSymbolsToCrashlytics(dsymPath: String = "./spec/fixtures/dSYM/Themoji2.dSYM",
                                       dsymPaths: [String]? = nil,
                                       apiToken: String? = nil,
                                       gspPath: String? = nil,
                                       appId: String? = nil,
                                       binaryPath: String? = nil,
                                       platform: String = "ios",
                                       dsymWorkerThreads: Int = 1,
                                       debug: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "upload_symbols_to_crashlytics", className: nil, args: [RubyCommand.Argument(name: "dsym_path", value: dsymPath),
                                                                                                                 RubyCommand.Argument(name: "dsym_paths", value: dsymPaths),
                                                                                                                 RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                                 RubyCommand.Argument(name: "gsp_path", value: gspPath),
                                                                                                                 RubyCommand.Argument(name: "app_id", value: appId),
                                                                                                                 RubyCommand.Argument(name: "binary_path", value: binaryPath),
                                                                                                                 RubyCommand.Argument(name: "platform", value: platform),
                                                                                                                 RubyCommand.Argument(name: "dsym_worker_threads", value: dsymWorkerThreads),
                                                                                                                 RubyCommand.Argument(name: "debug", value: debug)])
    _ = runner.executeCommand(command)
}

/**
 Upload dSYM symbolication files to Sentry

 - parameters:
   - apiHost: API host url for Sentry
   - apiKey: API key for Sentry
   - authToken: Authentication token for Sentry
   - orgSlug: Organization slug for Sentry project
   - projectSlug: Project slug for Sentry
   - dsymPath: Path to your symbols file. For iOS and Mac provide path to app.dSYM.zip
   - dsymPaths: Path to an array of your symbols file. For iOS and Mac provide path to app.dSYM.zip

 - returns: The uploaded dSYM path(s)

 This action allows you to upload symbolication files to Sentry. It's extra useful if you use it to download the latest dSYM files from Apple when you use Bitcode.
 */
public func uploadSymbolsToSentry(apiHost: String = "https://app.getsentry.com/api/0",
                                  apiKey: String? = nil,
                                  authToken: String? = nil,
                                  orgSlug: String,
                                  projectSlug: String,
                                  dsymPath: String? = nil,
                                  dsymPaths: Any? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "upload_symbols_to_sentry", className: nil, args: [RubyCommand.Argument(name: "api_host", value: apiHost),
                                                                                                            RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                            RubyCommand.Argument(name: "auth_token", value: authToken),
                                                                                                            RubyCommand.Argument(name: "org_slug", value: orgSlug),
                                                                                                            RubyCommand.Argument(name: "project_slug", value: projectSlug),
                                                                                                            RubyCommand.Argument(name: "dsym_path", value: dsymPath),
                                                                                                            RubyCommand.Argument(name: "dsym_paths", value: dsymPaths)])
    _ = runner.executeCommand(command)
}

/**
 Upload metadata and binary to App Store Connect (via _deliver_)

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - appIdentifier: The bundle identifier of your app
   - appVersion: The version that should be edited or created
   - ipa: Path to your ipa file
   - pkg: Path to your pkg file
   - buildNumber: If set the given build number (already uploaded to iTC) will be used instead of the current built one
   - platform: The platform to use (optional)
   - editLive: Modify live metadata, this option disables ipa upload and screenshot upload
   - useLiveVersion: Force usage of live version rather than edit version
   - metadataPath: Path to the folder containing the metadata files
   - screenshotsPath: Path to the folder containing the screenshots
   - skipBinaryUpload: Skip uploading an ipa or pkg to App Store Connect
   - skipScreenshots: Don't upload the screenshots
   - skipMetadata: Don't upload the metadata (e.g. title, description). This will still upload screenshots
   - skipAppVersionUpdate: Don’t create or update the app version that is being prepared for submission
   - force: Skip verification of HTML preview file
   - overwriteScreenshots: Clear all previously uploaded screenshots before uploading the new ones
   - submitForReview: Submit the new version for Review after uploading everything
   - rejectIfPossible: Rejects the previously submitted build if it's in a state where it's possible
   - automaticRelease: Should the app be automatically released once it's approved? (Can not be used together with `auto_release_date`)
   - autoReleaseDate: Date in milliseconds for automatically releasing on pending approval (Can not be used together with `automatic_release`)
   - phasedRelease: Enable the phased release feature of iTC
   - resetRatings: Reset the summary rating when you release a new version of the application
   - priceTier: The price tier of this application
   - appRatingConfigPath: Path to the app rating's config
   - submissionInformation: Extra information for the submission (e.g. compliance specifications, IDFA settings)
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - devPortalTeamId: The short ID of your Developer Portal team, if you're in multiple teams. Different from your iTC team ID!
   - devPortalTeamName: The name of your Developer Portal team if you're in multiple teams
   - itcProvider: The provider short name to be used with the iTMSTransporter to identify your team. This value will override the automatically detected provider short name. To get provider short name run `pathToXcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m provider -u 'USERNAME' -p 'PASSWORD' -account_type itunes_connect -v off`. The short names of providers should be listed in the second column
   - runPrecheckBeforeSubmit: Run precheck before submitting to app review
   - precheckDefaultRuleLevel: The default precheck rule level unless otherwise configured
   - individualMetadataItems: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - An array of localized metadata items to upload individually by language so that errors can be identified. E.g. ['name', 'keywords', 'description']. Note: slow
   - appIcon: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - Metadata: The path to the app icon
   - appleWatchAppIcon: **DEPRECATED!** Removed after the migration to the new App Store Connect API in June 2020 - Metadata: The path to the Apple Watch app icon
   - copyright: Metadata: The copyright notice
   - primaryCategory: Metadata: The english name of the primary category (e.g. `Business`, `Books`)
   - secondaryCategory: Metadata: The english name of the secondary category (e.g. `Business`, `Books`)
   - primaryFirstSubCategory: Metadata: The english name of the primary first sub category (e.g. `Educational`, `Puzzle`)
   - primarySecondSubCategory: Metadata: The english name of the primary second sub category (e.g. `Educational`, `Puzzle`)
   - secondaryFirstSubCategory: Metadata: The english name of the secondary first sub category (e.g. `Educational`, `Puzzle`)
   - secondarySecondSubCategory: Metadata: The english name of the secondary second sub category (e.g. `Educational`, `Puzzle`)
   - tradeRepresentativeContactInformation: Metadata: A hash containing the trade representative contact information
   - appReviewInformation: Metadata: A hash containing the review information
   - appReviewAttachmentFile: Metadata: Path to the app review attachment file
   - description: Metadata: The localised app description
   - name: Metadata: The localised app name
   - subtitle: Metadata: The localised app subtitle
   - keywords: Metadata: An array of localised keywords
   - promotionalText: Metadata: An array of localised promotional texts
   - releaseNotes: Metadata: Localised release notes for this version
   - privacyUrl: Metadata: Localised privacy url
   - appleTvPrivacyPolicy: Metadata: Localised Apple TV privacy policy text
   - supportUrl: Metadata: Localised support url
   - marketingUrl: Metadata: Localised marketing url
   - languages: Metadata: List of languages to activate
   - ignoreLanguageDirectoryValidation: Ignore errors when invalid languages are found in metadata and screenshot directories
   - precheckIncludeInAppPurchases: Should precheck check in-app purchases?
   - app: The (spaceship) app ID of the app you want to use/modify

 Using _upload_to_app_store_ after _build_app_ and _capture_screenshots_ will automatically upload the latest ipa and screenshots with no other configuration.

 If you don't want to verify an HTML preview for App Store builds, use the `:force` option.
 This is useful when running _fastlane_ on your Continuous Integration server:
 `_upload_to_app_store_(force: true)`
 If your account is on multiple teams and you need to tell the `iTMSTransporter` which 'provider' to use, you can set the `:itc_provider` option to pass this info.
 */
public func uploadToAppStore(apiKeyPath: String? = nil,
                             apiKey: [String: Any]? = nil,
                             username: String,
                             appIdentifier: String? = nil,
                             appVersion: String? = nil,
                             ipa: String? = nil,
                             pkg: String? = nil,
                             buildNumber: String? = nil,
                             platform: String = "ios",
                             editLive: Bool = false,
                             useLiveVersion: Bool = false,
                             metadataPath: String? = nil,
                             screenshotsPath: String? = nil,
                             skipBinaryUpload: Bool = false,
                             skipScreenshots: Bool = false,
                             skipMetadata: Bool = false,
                             skipAppVersionUpdate: Bool = false,
                             force: Bool = false,
                             overwriteScreenshots: Bool = false,
                             submitForReview: Bool = false,
                             rejectIfPossible: Bool = false,
                             automaticRelease: Bool? = nil,
                             autoReleaseDate: Int? = nil,
                             phasedRelease: Bool = false,
                             resetRatings: Bool = false,
                             priceTier: Any? = nil,
                             appRatingConfigPath: String? = nil,
                             submissionInformation: [String: Any]? = nil,
                             teamId: Any? = nil,
                             teamName: String? = nil,
                             devPortalTeamId: String? = nil,
                             devPortalTeamName: String? = nil,
                             itcProvider: String? = nil,
                             runPrecheckBeforeSubmit: Bool = true,
                             precheckDefaultRuleLevel: Any = "warn",
                             individualMetadataItems: [String]? = nil,
                             appIcon: String? = nil,
                             appleWatchAppIcon: String? = nil,
                             copyright: String? = nil,
                             primaryCategory: String? = nil,
                             secondaryCategory: String? = nil,
                             primaryFirstSubCategory: String? = nil,
                             primarySecondSubCategory: String? = nil,
                             secondaryFirstSubCategory: String? = nil,
                             secondarySecondSubCategory: String? = nil,
                             tradeRepresentativeContactInformation: [String: Any]? = nil,
                             appReviewInformation: [String: Any]? = nil,
                             appReviewAttachmentFile: String? = nil,
                             description: Any? = nil,
                             name: Any? = nil,
                             subtitle: [String: Any]? = nil,
                             keywords: [String: Any]? = nil,
                             promotionalText: [String: Any]? = nil,
                             releaseNotes: Any? = nil,
                             privacyUrl: Any? = nil,
                             appleTvPrivacyPolicy: Any? = nil,
                             supportUrl: Any? = nil,
                             marketingUrl: Any? = nil,
                             languages: [String]? = nil,
                             ignoreLanguageDirectoryValidation: Bool = false,
                             precheckIncludeInAppPurchases: Bool = true,
                             app: Any)
{
    let command = RubyCommand(commandID: "", methodName: "upload_to_app_store", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                       RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                       RubyCommand.Argument(name: "username", value: username),
                                                                                                       RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                       RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                                       RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                                       RubyCommand.Argument(name: "pkg", value: pkg),
                                                                                                       RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                                       RubyCommand.Argument(name: "platform", value: platform),
                                                                                                       RubyCommand.Argument(name: "edit_live", value: editLive),
                                                                                                       RubyCommand.Argument(name: "use_live_version", value: useLiveVersion),
                                                                                                       RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                                       RubyCommand.Argument(name: "screenshots_path", value: screenshotsPath),
                                                                                                       RubyCommand.Argument(name: "skip_binary_upload", value: skipBinaryUpload),
                                                                                                       RubyCommand.Argument(name: "skip_screenshots", value: skipScreenshots),
                                                                                                       RubyCommand.Argument(name: "skip_metadata", value: skipMetadata),
                                                                                                       RubyCommand.Argument(name: "skip_app_version_update", value: skipAppVersionUpdate),
                                                                                                       RubyCommand.Argument(name: "force", value: force),
                                                                                                       RubyCommand.Argument(name: "overwrite_screenshots", value: overwriteScreenshots),
                                                                                                       RubyCommand.Argument(name: "submit_for_review", value: submitForReview),
                                                                                                       RubyCommand.Argument(name: "reject_if_possible", value: rejectIfPossible),
                                                                                                       RubyCommand.Argument(name: "automatic_release", value: automaticRelease),
                                                                                                       RubyCommand.Argument(name: "auto_release_date", value: autoReleaseDate),
                                                                                                       RubyCommand.Argument(name: "phased_release", value: phasedRelease),
                                                                                                       RubyCommand.Argument(name: "reset_ratings", value: resetRatings),
                                                                                                       RubyCommand.Argument(name: "price_tier", value: priceTier),
                                                                                                       RubyCommand.Argument(name: "app_rating_config_path", value: appRatingConfigPath),
                                                                                                       RubyCommand.Argument(name: "submission_information", value: submissionInformation),
                                                                                                       RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                       RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                       RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId),
                                                                                                       RubyCommand.Argument(name: "dev_portal_team_name", value: devPortalTeamName),
                                                                                                       RubyCommand.Argument(name: "itc_provider", value: itcProvider),
                                                                                                       RubyCommand.Argument(name: "run_precheck_before_submit", value: runPrecheckBeforeSubmit),
                                                                                                       RubyCommand.Argument(name: "precheck_default_rule_level", value: precheckDefaultRuleLevel),
                                                                                                       RubyCommand.Argument(name: "individual_metadata_items", value: individualMetadataItems),
                                                                                                       RubyCommand.Argument(name: "app_icon", value: appIcon),
                                                                                                       RubyCommand.Argument(name: "apple_watch_app_icon", value: appleWatchAppIcon),
                                                                                                       RubyCommand.Argument(name: "copyright", value: copyright),
                                                                                                       RubyCommand.Argument(name: "primary_category", value: primaryCategory),
                                                                                                       RubyCommand.Argument(name: "secondary_category", value: secondaryCategory),
                                                                                                       RubyCommand.Argument(name: "primary_first_sub_category", value: primaryFirstSubCategory),
                                                                                                       RubyCommand.Argument(name: "primary_second_sub_category", value: primarySecondSubCategory),
                                                                                                       RubyCommand.Argument(name: "secondary_first_sub_category", value: secondaryFirstSubCategory),
                                                                                                       RubyCommand.Argument(name: "secondary_second_sub_category", value: secondarySecondSubCategory),
                                                                                                       RubyCommand.Argument(name: "trade_representative_contact_information", value: tradeRepresentativeContactInformation),
                                                                                                       RubyCommand.Argument(name: "app_review_information", value: appReviewInformation),
                                                                                                       RubyCommand.Argument(name: "app_review_attachment_file", value: appReviewAttachmentFile),
                                                                                                       RubyCommand.Argument(name: "description", value: description),
                                                                                                       RubyCommand.Argument(name: "name", value: name),
                                                                                                       RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                                       RubyCommand.Argument(name: "keywords", value: keywords),
                                                                                                       RubyCommand.Argument(name: "promotional_text", value: promotionalText),
                                                                                                       RubyCommand.Argument(name: "release_notes", value: releaseNotes),
                                                                                                       RubyCommand.Argument(name: "privacy_url", value: privacyUrl),
                                                                                                       RubyCommand.Argument(name: "apple_tv_privacy_policy", value: appleTvPrivacyPolicy),
                                                                                                       RubyCommand.Argument(name: "support_url", value: supportUrl),
                                                                                                       RubyCommand.Argument(name: "marketing_url", value: marketingUrl),
                                                                                                       RubyCommand.Argument(name: "languages", value: languages),
                                                                                                       RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation),
                                                                                                       RubyCommand.Argument(name: "precheck_include_in_app_purchases", value: precheckIncludeInAppPurchases),
                                                                                                       RubyCommand.Argument(name: "app", value: app)])
    _ = runner.executeCommand(command)
}

/**
 Upload metadata, screenshots and binaries to Google Play (via _supply_)

 - parameters:
   - packageName: The package name of the application to use
   - versionName: Version name (used when uploading new apks/aabs) - defaults to 'versionName' in build.gradle or AndroidManifest.xml
   - versionCode: Version code (used when updating rollout or promoting specific versions)
   - releaseStatus: Release status (used when uploading new apks/aabs) - valid values are completed, draft, halted, inProgress
   - track: The track of the application to use. The default available tracks are: production, beta, alpha, internal
   - rollout: The percentage of the user fraction when uploading to the rollout track (setting to 1 will complete the rollout)
   - metadataPath: Path to the directory containing the metadata files
   - key: **DEPRECATED!** Use `--json_key` instead - The p12 File used to authenticate with Google
   - issuer: **DEPRECATED!** Use `--json_key` instead - The issuer of the p12 file (email address of the service account)
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - apk: Path to the APK file to upload
   - apkPaths: An array of paths to APK files to upload
   - aab: Path to the AAB file to upload
   - aabPaths: An array of paths to AAB files to upload
   - skipUploadApk: Whether to skip uploading APK
   - skipUploadAab: Whether to skip uploading AAB
   - skipUploadMetadata: Whether to skip uploading metadata, changelogs not included
   - skipUploadChangelogs: Whether to skip uploading changelogs
   - skipUploadImages: Whether to skip uploading images, screenshots not included
   - skipUploadScreenshots: Whether to skip uploading SCREENSHOTS
   - trackPromoteTo: The track to promote to. The default available tracks are: production, beta, alpha, internal
   - validateOnly: Only validate changes with Google Play rather than actually publish
   - mapping: Path to the mapping file to upload
   - mappingPaths: An array of paths to mapping files to upload
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - checkSupersededTracks: **DEPRECATED!** Google Play does this automatically now - Check the other tracks for superseded versions and disable them
   - timeout: Timeout for read, open, and send (in seconds)
   - deactivateOnPromote: **DEPRECATED!** Google Play does this automatically now - When promoting to a new track, deactivate the binary in the origin track
   - versionCodesToRetain: An array of version codes to retain when publishing a new APK
   - inAppUpdatePriority: In-app update priority for all the newly added apks in the release. Can take values between [0,5]
   - obbMainReferencesVersion: References version of 'main' expansion file
   - obbMainFileSize: Size of 'main' expansion file in bytes
   - obbPatchReferencesVersion: References version of 'patch' expansion file
   - obbPatchFileSize: Size of 'patch' expansion file in bytes
   - ackBundleInstallationWarning: Must be set to true if the bundle installation may trigger a warning on user devices (e.g can only be downloaded over wifi). Typically this is required for bundles over 150MB

 More information: https://docs.fastlane.tools/actions/supply/
 */
public func uploadToPlayStore(packageName: String,
                              versionName: String? = nil,
                              versionCode: Int? = nil,
                              releaseStatus: String = "completed",
                              track: String = "production",
                              rollout: String? = nil,
                              metadataPath: String? = nil,
                              key: String? = nil,
                              issuer: String? = nil,
                              jsonKey: String? = nil,
                              jsonKeyData: String? = nil,
                              apk: String? = nil,
                              apkPaths: [String]? = nil,
                              aab: String? = nil,
                              aabPaths: [String]? = nil,
                              skipUploadApk: Bool = false,
                              skipUploadAab: Bool = false,
                              skipUploadMetadata: Bool = false,
                              skipUploadChangelogs: Bool = false,
                              skipUploadImages: Bool = false,
                              skipUploadScreenshots: Bool = false,
                              trackPromoteTo: String? = nil,
                              validateOnly: Bool = false,
                              mapping: String? = nil,
                              mappingPaths: [String]? = nil,
                              rootUrl: String? = nil,
                              checkSupersededTracks: Bool = false,
                              timeout: Int = 300,
                              deactivateOnPromote: Bool = true,
                              versionCodesToRetain: [String]? = nil,
                              inAppUpdatePriority: Int? = nil,
                              obbMainReferencesVersion: String? = nil,
                              obbMainFileSize: String? = nil,
                              obbPatchReferencesVersion: String? = nil,
                              obbPatchFileSize: String? = nil,
                              ackBundleInstallationWarning: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "upload_to_play_store", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                                        RubyCommand.Argument(name: "version_name", value: versionName),
                                                                                                        RubyCommand.Argument(name: "version_code", value: versionCode),
                                                                                                        RubyCommand.Argument(name: "release_status", value: releaseStatus),
                                                                                                        RubyCommand.Argument(name: "track", value: track),
                                                                                                        RubyCommand.Argument(name: "rollout", value: rollout),
                                                                                                        RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                                        RubyCommand.Argument(name: "key", value: key),
                                                                                                        RubyCommand.Argument(name: "issuer", value: issuer),
                                                                                                        RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                        RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                        RubyCommand.Argument(name: "apk", value: apk),
                                                                                                        RubyCommand.Argument(name: "apk_paths", value: apkPaths),
                                                                                                        RubyCommand.Argument(name: "aab", value: aab),
                                                                                                        RubyCommand.Argument(name: "aab_paths", value: aabPaths),
                                                                                                        RubyCommand.Argument(name: "skip_upload_apk", value: skipUploadApk),
                                                                                                        RubyCommand.Argument(name: "skip_upload_aab", value: skipUploadAab),
                                                                                                        RubyCommand.Argument(name: "skip_upload_metadata", value: skipUploadMetadata),
                                                                                                        RubyCommand.Argument(name: "skip_upload_changelogs", value: skipUploadChangelogs),
                                                                                                        RubyCommand.Argument(name: "skip_upload_images", value: skipUploadImages),
                                                                                                        RubyCommand.Argument(name: "skip_upload_screenshots", value: skipUploadScreenshots),
                                                                                                        RubyCommand.Argument(name: "track_promote_to", value: trackPromoteTo),
                                                                                                        RubyCommand.Argument(name: "validate_only", value: validateOnly),
                                                                                                        RubyCommand.Argument(name: "mapping", value: mapping),
                                                                                                        RubyCommand.Argument(name: "mapping_paths", value: mappingPaths),
                                                                                                        RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                        RubyCommand.Argument(name: "check_superseded_tracks", value: checkSupersededTracks),
                                                                                                        RubyCommand.Argument(name: "timeout", value: timeout),
                                                                                                        RubyCommand.Argument(name: "deactivate_on_promote", value: deactivateOnPromote),
                                                                                                        RubyCommand.Argument(name: "version_codes_to_retain", value: versionCodesToRetain),
                                                                                                        RubyCommand.Argument(name: "in_app_update_priority", value: inAppUpdatePriority),
                                                                                                        RubyCommand.Argument(name: "obb_main_references_version", value: obbMainReferencesVersion),
                                                                                                        RubyCommand.Argument(name: "obb_main_file_size", value: obbMainFileSize),
                                                                                                        RubyCommand.Argument(name: "obb_patch_references_version", value: obbPatchReferencesVersion),
                                                                                                        RubyCommand.Argument(name: "obb_patch_file_size", value: obbPatchFileSize),
                                                                                                        RubyCommand.Argument(name: "ack_bundle_installation_warning", value: ackBundleInstallationWarning)])
    _ = runner.executeCommand(command)
}

/**
 Upload binaries to Google Play Internal App Sharing (via _supply_)

 - parameters:
   - packageName: The package name of the application to use
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - apk: Path to the APK file to upload
   - apkPaths: An array of paths to APK files to upload
   - aab: Path to the AAB file to upload
   - aabPaths: An array of paths to AAB files to upload
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - timeout: Timeout for read, open, and send (in seconds)

 - returns: Returns a string containing the download URL for the uploaded APK/AAB (or array of strings if multiple were uploaded).

 More information: https://docs.fastlane.tools/actions/upload_to_play_store_internal_app_sharing/
 */
public func uploadToPlayStoreInternalAppSharing(packageName: String,
                                                jsonKey: String? = nil,
                                                jsonKeyData: String? = nil,
                                                apk: String? = nil,
                                                apkPaths: [String]? = nil,
                                                aab: String? = nil,
                                                aabPaths: [String]? = nil,
                                                rootUrl: String? = nil,
                                                timeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "upload_to_play_store_internal_app_sharing", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                                                             RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                             RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                                             RubyCommand.Argument(name: "apk", value: apk),
                                                                                                                             RubyCommand.Argument(name: "apk_paths", value: apkPaths),
                                                                                                                             RubyCommand.Argument(name: "aab", value: aab),
                                                                                                                             RubyCommand.Argument(name: "aab_paths", value: aabPaths),
                                                                                                                             RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                                             RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Upload new binary to App Store Connect for TestFlight beta testing (via _pilot_)

 - parameters:
   - apiKeyPath: Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
   - apiKey: Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)
   - username: Your Apple ID Username
   - appIdentifier: The bundle identifier of the app to upload or manage testers (optional)
   - appPlatform: The platform to use (optional)
   - appleId: Apple ID property in the App Information section in App Store Connect
   - ipa: Path to the ipa file to upload
   - demoAccountRequired: Do you need a demo account when Apple does review?
   - betaAppReviewInfo: Beta app review information for contact info and demo account
   - localizedAppInfo: Localized beta app test info for description, feedback email, marketing url, and privacy policy
   - betaAppDescription: Provide the 'Beta App Description' when uploading a new build
   - betaAppFeedbackEmail: Provide the beta app email when uploading a new build
   - localizedBuildInfo: Localized beta app test info for what's new
   - changelog: Provide the 'What to Test' text when uploading a new build
   - skipSubmission: Skip the distributing action of pilot and only upload the ipa file
   - skipWaitingForBuildProcessing: If set to true, the `distribute_external` option won't work and no build will be distributed to testers. (You might want to use this option if you are using this action on CI and have to pay for 'minutes used' on your CI plan). If set to `true` and a changelog is provided, it will partially wait for the build to appear on AppStore Connect so the changelog can be set, and skip the remaining processing steps
   - updateBuildInfoOnUpload: **DEPRECATED!** Update build info immediately after validation. This is deprecated and will be removed in a future release. App Store Connect no longer supports setting build info until after build processing has completed, which is when build info is updated by default
   - distributeOnly: Distribute a previously uploaded build (equivalent to the `fastlane pilot distribute` command)
   - usesNonExemptEncryption: Provide the 'Uses Non-Exempt Encryption' for export compliance. This is used if there is 'ITSAppUsesNonExemptEncryption' is not set in the Info.plist
   - distributeExternal: Should the build be distributed to external testers?
   - notifyExternalTesters: Should notify external testers?
   - appVersion: The version number of the application build to distribute. If the version number is not specified, then the most recent build uploaded to TestFlight will be distributed. If specified, the most recent build for the version number will be distributed
   - buildNumber: The build number of the application build to distribute. If the build number is not specified, the most recent build is distributed
   - expirePreviousBuilds: Should expire previous builds?
   - firstName: The tester's first name
   - lastName: The tester's last name
   - email: The tester's email
   - testersFilePath: Path to a CSV file of testers
   - groups: Associate tester to one group or more by group name / group id. E.g. `-g "Team 1","Team 2"`
   - teamId: The ID of your App Store Connect team if you're in multiple teams
   - teamName: The name of your App Store Connect team if you're in multiple teams
   - devPortalTeamId: The short ID of your team in the developer portal, if you're in multiple teams. Different from your iTC team ID!
   - itcProvider: The provider short name to be used with the iTMSTransporter to identify your team. This value will override the automatically detected provider short name. To get provider short name run `pathToXcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m provider -u 'USERNAME' -p 'PASSWORD' -account_type itunes_connect -v off`. The short names of providers should be listed in the second column
   - waitProcessingInterval: Interval in seconds to wait for App Store Connect processing
   - waitForUploadedBuild: **DEPRECATED!** No longer needed with the transition over to the App Store Connect API - Use version info from uploaded ipa file to determine what build to use for distribution. If set to false, latest processing or any latest build will be used
   - rejectBuildWaitingForReview: Expire previous if it's 'waiting for review'

 More details can be found on https://docs.fastlane.tools/actions/pilot/.
 This integration will only do the TestFlight upload.
 */
public func uploadToTestflight(apiKeyPath: String? = nil,
                               apiKey: [String: Any]? = nil,
                               username: String,
                               appIdentifier: String? = nil,
                               appPlatform: String = "ios",
                               appleId: String? = nil,
                               ipa: String? = nil,
                               demoAccountRequired: Bool? = nil,
                               betaAppReviewInfo: [String: Any]? = nil,
                               localizedAppInfo: [String: Any]? = nil,
                               betaAppDescription: String? = nil,
                               betaAppFeedbackEmail: String? = nil,
                               localizedBuildInfo: [String: Any]? = nil,
                               changelog: String? = nil,
                               skipSubmission: Bool = false,
                               skipWaitingForBuildProcessing: Bool = false,
                               updateBuildInfoOnUpload: Bool = false,
                               distributeOnly: Bool = false,
                               usesNonExemptEncryption: Bool = false,
                               distributeExternal: Bool = false,
                               notifyExternalTesters: Bool = true,
                               appVersion: String? = nil,
                               buildNumber: String? = nil,
                               expirePreviousBuilds: Bool = false,
                               firstName: String? = nil,
                               lastName: String? = nil,
                               email: String? = nil,
                               testersFilePath: String = "./testers.csv",
                               groups: [String]? = nil,
                               teamId: Any? = nil,
                               teamName: String? = nil,
                               devPortalTeamId: String? = nil,
                               itcProvider: String? = nil,
                               waitProcessingInterval: Int = 30,
                               waitForUploadedBuild: Bool = false,
                               rejectBuildWaitingForReview: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "upload_to_testflight", className: nil, args: [RubyCommand.Argument(name: "api_key_path", value: apiKeyPath),
                                                                                                        RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                        RubyCommand.Argument(name: "username", value: username),
                                                                                                        RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                        RubyCommand.Argument(name: "app_platform", value: appPlatform),
                                                                                                        RubyCommand.Argument(name: "apple_id", value: appleId),
                                                                                                        RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                                        RubyCommand.Argument(name: "demo_account_required", value: demoAccountRequired),
                                                                                                        RubyCommand.Argument(name: "beta_app_review_info", value: betaAppReviewInfo),
                                                                                                        RubyCommand.Argument(name: "localized_app_info", value: localizedAppInfo),
                                                                                                        RubyCommand.Argument(name: "beta_app_description", value: betaAppDescription),
                                                                                                        RubyCommand.Argument(name: "beta_app_feedback_email", value: betaAppFeedbackEmail),
                                                                                                        RubyCommand.Argument(name: "localized_build_info", value: localizedBuildInfo),
                                                                                                        RubyCommand.Argument(name: "changelog", value: changelog),
                                                                                                        RubyCommand.Argument(name: "skip_submission", value: skipSubmission),
                                                                                                        RubyCommand.Argument(name: "skip_waiting_for_build_processing", value: skipWaitingForBuildProcessing),
                                                                                                        RubyCommand.Argument(name: "update_build_info_on_upload", value: updateBuildInfoOnUpload),
                                                                                                        RubyCommand.Argument(name: "distribute_only", value: distributeOnly),
                                                                                                        RubyCommand.Argument(name: "uses_non_exempt_encryption", value: usesNonExemptEncryption),
                                                                                                        RubyCommand.Argument(name: "distribute_external", value: distributeExternal),
                                                                                                        RubyCommand.Argument(name: "notify_external_testers", value: notifyExternalTesters),
                                                                                                        RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                                        RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                                        RubyCommand.Argument(name: "expire_previous_builds", value: expirePreviousBuilds),
                                                                                                        RubyCommand.Argument(name: "first_name", value: firstName),
                                                                                                        RubyCommand.Argument(name: "last_name", value: lastName),
                                                                                                        RubyCommand.Argument(name: "email", value: email),
                                                                                                        RubyCommand.Argument(name: "testers_file_path", value: testersFilePath),
                                                                                                        RubyCommand.Argument(name: "groups", value: groups),
                                                                                                        RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                        RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                        RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId),
                                                                                                        RubyCommand.Argument(name: "itc_provider", value: itcProvider),
                                                                                                        RubyCommand.Argument(name: "wait_processing_interval", value: waitProcessingInterval),
                                                                                                        RubyCommand.Argument(name: "wait_for_uploaded_build", value: waitForUploadedBuild),
                                                                                                        RubyCommand.Argument(name: "reject_build_waiting_for_review", value: rejectBuildWaitingForReview)])
    _ = runner.executeCommand(command)
}

/**
 Validate that the Google Play Store `json_key` works

 - parameters:
   - jsonKey: The path to a file containing service account JSON, used to authenticate with Google
   - jsonKeyData: The raw service account JSON data used to authenticate with Google
   - rootUrl: Root URL for the Google Play API. The provided URL will be used for API calls in place of https://www.googleapis.com/
   - timeout: Timeout for read, open, and send (in seconds)

 Use this action to test and validate your private key json key file used to connect and authenticate with the Google Play API
 */
public func validatePlayStoreJsonKey(jsonKey: String? = nil,
                                     jsonKeyData: String? = nil,
                                     rootUrl: String? = nil,
                                     timeout: Int = 300)
{
    let command = RubyCommand(commandID: "", methodName: "validate_play_store_json_key", className: nil, args: [RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                                RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                                RubyCommand.Argument(name: "timeout", value: timeout)])
    _ = runner.executeCommand(command)
}

/**
 Able to verify various settings in ipa file

 - parameters:
   - provisioningType: Required type of provisioning
   - provisioningUuid: Required UUID of provisioning profile
   - teamIdentifier: Required team identifier
   - teamName: Required team name
   - appName: Required app name
   - bundleIdentifier: Required bundle identifier
   - ipaPath: Explicitly set the ipa path
   - buildPath: Explicitly set the ipa, app or xcarchive path

 Verifies that the built app was built using the expected build resources. This is relevant for people who build on machines that are used to build apps with different profiles, certificates and/or bundle identifiers to guard against configuration mistakes.
 */
public func verifyBuild(provisioningType: String? = nil,
                        provisioningUuid: String? = nil,
                        teamIdentifier: String? = nil,
                        teamName: String? = nil,
                        appName: String? = nil,
                        bundleIdentifier: String? = nil,
                        ipaPath: String? = nil,
                        buildPath: String? = nil)
{
    let command = RubyCommand(commandID: "", methodName: "verify_build", className: nil, args: [RubyCommand.Argument(name: "provisioning_type", value: provisioningType),
                                                                                                RubyCommand.Argument(name: "provisioning_uuid", value: provisioningUuid),
                                                                                                RubyCommand.Argument(name: "team_identifier", value: teamIdentifier),
                                                                                                RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                RubyCommand.Argument(name: "app_name", value: appName),
                                                                                                RubyCommand.Argument(name: "bundle_identifier", value: bundleIdentifier),
                                                                                                RubyCommand.Argument(name: "ipa_path", value: ipaPath),
                                                                                                RubyCommand.Argument(name: "build_path", value: buildPath)])
    _ = runner.executeCommand(command)
}

/**
 Verifies all keys referenced from the Podfile are non-empty

 Runs a check against all keys specified in your Podfile to make sure they're more than a single character long. This is to ensure you don't deploy with stubbed keys.
 */
public func verifyPodKeys() {
    let command = RubyCommand(commandID: "", methodName: "verify_pod_keys", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Verifies that the Xcode installation is properly signed by Apple

 - parameter xcodePath: The path to the Xcode installation to test

 This action was implemented after the recent Xcode attack to make sure you're not using a [hacked Xcode installation](http://researchcenter.paloaltonetworks.com/2015/09/novel-malware-xcodeghost-modifies-xcode-infects-apple-ios-apps-and-hits-app-store/).
 */
public func verifyXcode(xcodePath: String) {
    let command = RubyCommand(commandID: "", methodName: "verify_xcode", className: nil, args: [RubyCommand.Argument(name: "xcode_path", value: xcodePath)])
    _ = runner.executeCommand(command)
}

/**
 Increment or set the version in a podspec file

 - parameters:
   - path: You must specify the path to the podspec file to update
   - bumpType: The type of this version bump. Available: patch, minor, major
   - versionNumber: Change to a specific version. This will replace the bump type value
   - versionAppendix: Change version appendix to a specific value. For example 1.4.14.4.1 -> 1.4.14.5
   - requireVariablePrefix: true by default, this is used for non CocoaPods version bumps only

 You can use this action to manipulate any 'version' variable contained in a ruby file.
 For example, you can use it to bump the version of a CocoaPods' podspec file.
 It also supports versions that are not semantic: `1.4.14.4.1`.
 For such versions, there is an option to change the appendix (e.g. `4.1`).
 */
public func versionBumpPodspec(path: String,
                               bumpType: String = "patch",
                               versionNumber: String? = nil,
                               versionAppendix: String? = nil,
                               requireVariablePrefix: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "version_bump_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                        RubyCommand.Argument(name: "bump_type", value: bumpType),
                                                                                                        RubyCommand.Argument(name: "version_number", value: versionNumber),
                                                                                                        RubyCommand.Argument(name: "version_appendix", value: versionAppendix),
                                                                                                        RubyCommand.Argument(name: "require_variable_prefix", value: requireVariablePrefix)])
    _ = runner.executeCommand(command)
}

/**
 Receive the version number from a podspec file

 - parameters:
   - path: You must specify the path to the podspec file
   - requireVariablePrefix: true by default, this is used for non CocoaPods version bumps only
 */
public func versionGetPodspec(path: String,
                              requireVariablePrefix: Bool = true)
{
    let command = RubyCommand(commandID: "", methodName: "version_get_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                       RubyCommand.Argument(name: "require_variable_prefix", value: requireVariablePrefix)])
    _ = runner.executeCommand(command)
}

/**
 Archives the project using `xcodebuild`
 */
public func xcarchive() {
    let command = RubyCommand(commandID: "", methodName: "xcarchive", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Builds the project using `xcodebuild`
 */
public func xcbuild() {
    let command = RubyCommand(commandID: "", methodName: "xcbuild", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Cleans the project using `xcodebuild`
 */
public func xcclean() {
    let command = RubyCommand(commandID: "", methodName: "xcclean", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Exports the project using `xcodebuild`
 */
public func xcexport() {
    let command = RubyCommand(commandID: "", methodName: "xcexport", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Make sure a certain version of Xcode is installed

 - parameters:
   - version: The version number of the version of Xcode to install
   - username: Your Apple ID Username
   - teamId: The ID of your team if you're in multiple teams
   - downloadRetryAttempts: Number of times the download will be retried in case of failure

 - returns: The path to the newly installed Xcode version

 Makes sure a specific version of Xcode is installed. If that's not the case, it will automatically be downloaded by the [xcode_install](https://github.com/neonichu/xcode-install) gem. This will make sure to use the correct Xcode for later actions.
 */
@discardableResult public func xcodeInstall(version: String,
                                            username: String,
                                            teamId: String? = nil,
                                            downloadRetryAttempts: Int = 3) -> String
{
    let command = RubyCommand(commandID: "", methodName: "xcode_install", className: nil, args: [RubyCommand.Argument(name: "version", value: version),
                                                                                                 RubyCommand.Argument(name: "username", value: username),
                                                                                                 RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                 RubyCommand.Argument(name: "download_retry_attempts", value: downloadRetryAttempts)])
    return runner.executeCommand(command)
}

/**
 Change the xcode-path to use. Useful for beta versions of Xcode

 Select and build with the Xcode installed at the provided path.
 Use the `xcversion` action if you want to select an Xcode:
 - Based on a version specifier or
 - You don't have known, stable paths, as may happen in a CI environment.
 */
public func xcodeSelect() {
    let command = RubyCommand(commandID: "", methodName: "xcode_select", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Downloads Xcode Bot assets like the `.xcarchive` and logs

 - parameters:
   - host: IP Address/Hostname of Xcode Server
   - botName: Name of the Bot to pull assets from
   - integrationNumber: Optionally you can override which integration's assets should be downloaded. If not provided, the latest integration is used
   - username: Username for your Xcode Server
   - password: Password for your Xcode Server
   - targetFolder: Relative path to a folder into which to download assets
   - keepAllAssets: Whether to keep all assets or let the script delete everything except for the .xcarchive
   - trustSelfSignedCerts: Whether to trust self-signed certs on your Xcode Server

 This action downloads assets from your Xcode Server Bot (works with Xcode Server using Xcode 6 and 7. By default, this action downloads all assets, unzips them and deletes everything except for the `.xcarchive`.
 If you'd like to keep all downloaded assets, pass `keep_all_assets: true`.
 This action returns the path to the downloaded assets folder and puts into shared values the paths to the asset folder and to the `.xcarchive` inside it.
 */
@discardableResult public func xcodeServerGetAssets(host: String,
                                                    botName: String,
                                                    integrationNumber: Any? = nil,
                                                    username: String = "",
                                                    password: String? = nil,
                                                    targetFolder: String = "./xcs_assets",
                                                    keepAllAssets: Bool = false,
                                                    trustSelfSignedCerts: Bool = true) -> [String]
{
    let command = RubyCommand(commandID: "", methodName: "xcode_server_get_assets", className: nil, args: [RubyCommand.Argument(name: "host", value: host),
                                                                                                           RubyCommand.Argument(name: "bot_name", value: botName),
                                                                                                           RubyCommand.Argument(name: "integration_number", value: integrationNumber),
                                                                                                           RubyCommand.Argument(name: "username", value: username),
                                                                                                           RubyCommand.Argument(name: "password", value: password),
                                                                                                           RubyCommand.Argument(name: "target_folder", value: targetFolder),
                                                                                                           RubyCommand.Argument(name: "keep_all_assets", value: keepAllAssets),
                                                                                                           RubyCommand.Argument(name: "trust_self_signed_certs", value: trustSelfSignedCerts)])
    return parseArray(fromString: runner.executeCommand(command))
}

/**
 Use the `xcodebuild` command to build and sign your app

 **Note**: `xcodebuild` is a complex command, so it is recommended to use [_gym_](https://docs.fastlane.tools/actions/gym/) for building your ipa file and [_scan_](https://docs.fastlane.tools/actions/scan/) for testing your app instead.
 */
public func xcodebuild() {
    let command = RubyCommand(commandID: "", methodName: "xcodebuild", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Nice code coverage reports without hassle

 - parameters:
   - workspace: Path the workspace file
   - project: Path the project file
   - scheme: The project's scheme. Make sure it's marked as `Shared`
   - configuration: The configuration used when building the app. Defaults to 'Release'
   - sourceDirectory: The path to project's root directory
   - derivedDataPath: The directory where build products and other derived data will go
   - outputDirectory: The directory in which all reports will be stored
   - htmlReport: Produce an HTML report
   - markdownReport: Produce a Markdown report
   - jsonReport: Produce a JSON report
   - minimumCoveragePercentage: Raise exception if overall coverage percentage is under this value (ie. 75)
   - slackUrl: Create an Incoming WebHook for your Slack group to post results there
   - slackChannel: #channel or @username
   - skipSlack: Don't publish to slack, even when an URL is given
   - slackUsername: The username which is used to publish to slack
   - slackMessage: The message which is published together with a successful report
   - ignoreFilePath: Relative or absolute path to the file containing the list of ignored files
   - includeTestTargets: Enables coverage reports for .xctest targets
   - excludeTargets: Comma separated list of targets to exclude from coverage report
   - includeTargets: Comma separated list of targets to include in coverage report. If specified then exlude_targets will be ignored
   - onlyProjectTargets: Display the coverage only for main project targets (e.g. skip Pods targets)
   - disableCoveralls: Add this flag to disable automatic submission to Coveralls
   - coverallsServiceName: Name of the CI service compatible with Coveralls. i.e. travis-ci. This option must be defined along with coveralls_service_job_id
   - coverallsServiceJobId: Name of the current job running on a CI service compatible with Coveralls. This option must be defined along with coveralls_service_name
   - coverallsRepoToken: Repository token to be used by integrations not compatible with Coveralls
   - xcconfig: Use an extra XCCONFIG file to build your app
   - ideFoundationPath: Absolute path to the IDEFoundation.framework binary
   - legacySupport: Whether xcov should parse a xccoverage file instead on xccovreport

 Create nice code coverage reports and post coverage summaries on Slack *(xcov gem is required)*.
 More information: [https://github.com/nakiostudio/xcov](https://github.com/nakiostudio/xcov).
 */
public func xcov(workspace: String? = nil,
                 project: String? = nil,
                 scheme: String? = nil,
                 configuration: String? = nil,
                 sourceDirectory: String? = nil,
                 derivedDataPath: String? = nil,
                 outputDirectory: String = "./xcov_report",
                 htmlReport: Bool = true,
                 markdownReport: Bool = false,
                 jsonReport: Bool = false,
                 minimumCoveragePercentage: Float = 0,
                 slackUrl: String? = nil,
                 slackChannel: String? = nil,
                 skipSlack: Bool = false,
                 slackUsername: String = "xcov",
                 slackMessage: String = "Your *xcov* coverage report",
                 ignoreFilePath: String = "./.xcovignore",
                 includeTestTargets: Bool = false,
                 excludeTargets: String? = nil,
                 includeTargets: String? = nil,
                 onlyProjectTargets: Bool = false,
                 disableCoveralls: Bool = false,
                 coverallsServiceName: String? = nil,
                 coverallsServiceJobId: String? = nil,
                 coverallsRepoToken: String? = nil,
                 xcconfig: String? = nil,
                 ideFoundationPath: String = "/Applications/Xcode-12.2.app/Contents/Developer/../Frameworks/IDEFoundation.framework/Versions/A/IDEFoundation",
                 legacySupport: Bool = false)
{
    let command = RubyCommand(commandID: "", methodName: "xcov", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                        RubyCommand.Argument(name: "project", value: project),
                                                                                        RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                        RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                        RubyCommand.Argument(name: "source_directory", value: sourceDirectory),
                                                                                        RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                        RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                        RubyCommand.Argument(name: "html_report", value: htmlReport),
                                                                                        RubyCommand.Argument(name: "markdown_report", value: markdownReport),
                                                                                        RubyCommand.Argument(name: "json_report", value: jsonReport),
                                                                                        RubyCommand.Argument(name: "minimum_coverage_percentage", value: minimumCoveragePercentage),
                                                                                        RubyCommand.Argument(name: "slack_url", value: slackUrl),
                                                                                        RubyCommand.Argument(name: "slack_channel", value: slackChannel),
                                                                                        RubyCommand.Argument(name: "skip_slack", value: skipSlack),
                                                                                        RubyCommand.Argument(name: "slack_username", value: slackUsername),
                                                                                        RubyCommand.Argument(name: "slack_message", value: slackMessage),
                                                                                        RubyCommand.Argument(name: "ignore_file_path", value: ignoreFilePath),
                                                                                        RubyCommand.Argument(name: "include_test_targets", value: includeTestTargets),
                                                                                        RubyCommand.Argument(name: "exclude_targets", value: excludeTargets),
                                                                                        RubyCommand.Argument(name: "include_targets", value: includeTargets),
                                                                                        RubyCommand.Argument(name: "only_project_targets", value: onlyProjectTargets),
                                                                                        RubyCommand.Argument(name: "disable_coveralls", value: disableCoveralls),
                                                                                        RubyCommand.Argument(name: "coveralls_service_name", value: coverallsServiceName),
                                                                                        RubyCommand.Argument(name: "coveralls_service_job_id", value: coverallsServiceJobId),
                                                                                        RubyCommand.Argument(name: "coveralls_repo_token", value: coverallsRepoToken),
                                                                                        RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                        RubyCommand.Argument(name: "ideFoundationPath", value: ideFoundationPath),
                                                                                        RubyCommand.Argument(name: "legacy_support", value: legacySupport)])
    _ = runner.executeCommand(command)
}

/**
 Runs tests on the given simulator
 */
public func xctest() {
    let command = RubyCommand(commandID: "", methodName: "xctest", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Run tests using xctool

 You can run any `xctool` action. This will require having [xctool](https://github.com/facebook/xctool) installed through [Homebrew](http://brew.sh).
 It is recommended to store the build configuration in the `.xctool-args` file.
 More information: [https://docs.fastlane.tools/actions/xctool/](https://docs.fastlane.tools/actions/xctool/).
 */
public func xctool() {
    let command = RubyCommand(commandID: "", methodName: "xctool", className: nil, args: [])
    _ = runner.executeCommand(command)
}

/**
 Select an Xcode to use by version specifier

 - parameter version: The version of Xcode to select specified as a Gem::Version requirement string (e.g. '~> 7.1.0')

 Finds and selects a version of an installed Xcode that best matches the provided [`Gem::Version` requirement specifier](http://www.rubydoc.info/github/rubygems/rubygems/Gem/Version)
 */
public func xcversion(version: String) {
    let command = RubyCommand(commandID: "", methodName: "xcversion", className: nil, args: [RubyCommand.Argument(name: "version", value: version)])
    _ = runner.executeCommand(command)
}

/**
 Compress a file or folder to a zip

 - parameters:
   - path: Path to the directory or file to be zipped
   - outputPath: The name of the resulting zip file
   - verbose: Enable verbose output of zipped file
   - password: Encrypt the contents of the zip archive using a password
   - symlinks: Store symbolic links as such in the zip archive

 - returns: The path to the output zip file
 */
@discardableResult public func zip(path: String,
                                   outputPath: String? = nil,
                                   verbose: Bool = true,
                                   password: String? = nil,
                                   symlinks: Bool = false) -> String
{
    let command = RubyCommand(commandID: "", methodName: "zip", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                       RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                       RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                       RubyCommand.Argument(name: "password", value: password),
                                                                                       RubyCommand.Argument(name: "symlinks", value: symlinks)])
    return runner.executeCommand(command)
}

// These are all the parsing functions needed to transform our data into the expected types
func parseArray(fromString: String, function: String = #function) -> [String] {
    verbose(message: "parsing an Array from data: \(fromString), from function: \(function)")
    let potentialArray: String
    if fromString.count < 2 {
        potentialArray = "[\(fromString)]"
    } else {
        potentialArray = fromString
    }
    let array: [String] = try! JSONSerialization.jsonObject(with: potentialArray.data(using: .utf8)!, options: []) as! [String]
    return array
}

func parseDictionary(fromString: String, function: String = #function) -> [String: String] {
    return parseDictionaryHelper(fromString: fromString, function: function) as! [String: String]
}

func parseDictionary(fromString: String, function: String = #function) -> [String: Any] {
    return parseDictionaryHelper(fromString: fromString, function: function)
}

func parseDictionaryHelper(fromString: String, function: String = #function) -> [String: Any] {
    verbose(message: "parsing an Array from data: \(fromString), from function: \(function)")
    let potentialDictionary: String
    if fromString.count < 2 {
        verbose(message: "Dictionary value too small: \(fromString), from function: \(function)")
        potentialDictionary = "{}"
    } else {
        potentialDictionary = fromString
    }
    let dictionary: [String: Any] = try! JSONSerialization.jsonObject(with: potentialDictionary.data(using: .utf8)!, options: []) as! [String: Any]
    return dictionary
}

func parseBool(fromString: String, function: String = #function) -> Bool {
    verbose(message: "parsing a Bool from data: \(fromString), from function: \(function)")
    return NSString(string: fromString.trimmingCharacters(in: .punctuationCharacters)).boolValue
}

func parseInt(fromString: String, function: String = #function) -> Int {
    verbose(message: "parsing an Int from data: \(fromString), from function: \(function)")
    return NSString(string: fromString.trimmingCharacters(in: .punctuationCharacters)).integerValue
}

public let deliverfile = Deliverfile()
public let gymfile = Gymfile()
public let matchfile = Matchfile()
public let precheckfile = Precheckfile()
public let scanfile = Scanfile()
public let screengrabfile = Screengrabfile()
public let snapshotfile = Snapshotfile()

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.112]
