import Foundation
@discardableResult func adb(serial: String = "",
                            command: String? = nil,
                            adbPath: String = "adb") -> String {
  let command = RubyCommand(commandID: "", methodName: "adb", className: nil, args: [RubyCommand.Argument(name: "serial", value: serial),
                                                                                     RubyCommand.Argument(name: "command", value: command),
                                                                                     RubyCommand.Argument(name: "adb_path", value: adbPath)])
  return runner.executeCommand(command)
}
func adbDevices(adbPath: String = "adb") {
  let command = RubyCommand(commandID: "", methodName: "adb_devices", className: nil, args: [RubyCommand.Argument(name: "adb_path", value: adbPath)])
  _ = runner.executeCommand(command)
}
func addExtraPlatforms(platforms: [String] = []) {
  let command = RubyCommand(commandID: "", methodName: "add_extra_platforms", className: nil, args: [RubyCommand.Argument(name: "platforms", value: platforms)])
  _ = runner.executeCommand(command)
}
func addGitTag(tag: String? = nil,
               grouping: String = "builds",
               `prefix`: String = "",
               `postfix`: String = "",
               buildNumber: String,
               message: String? = nil,
               commit: String? = nil,
               force: Bool = false,
               sign: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "add_git_tag", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag),
                                                                                             RubyCommand.Argument(name: "grouping", value: grouping),
                                                                                             RubyCommand.Argument(name: "prefix", value: `prefix`),
                                                                                             RubyCommand.Argument(name: "postfix", value: `postfix`),
                                                                                             RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                             RubyCommand.Argument(name: "message", value: message),
                                                                                             RubyCommand.Argument(name: "commit", value: commit),
                                                                                             RubyCommand.Argument(name: "force", value: force),
                                                                                             RubyCommand.Argument(name: "sign", value: sign)])
  _ = runner.executeCommand(command)
}
func appStoreBuildNumber(initialBuildNumber: String,
                         appIdentifier: String,
                         username: String,
                         teamId: String? = nil,
                         live: Bool = true,
                         version: String? = nil,
                         platform: String = "ios",
                         teamName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "app_store_build_number", className: nil, args: [RubyCommand.Argument(name: "initial_build_number", value: initialBuildNumber),
                                                                                                        RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                        RubyCommand.Argument(name: "username", value: username),
                                                                                                        RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                        RubyCommand.Argument(name: "live", value: live),
                                                                                                        RubyCommand.Argument(name: "version", value: version),
                                                                                                        RubyCommand.Argument(name: "platform", value: platform),
                                                                                                        RubyCommand.Argument(name: "team_name", value: teamName)])
  _ = runner.executeCommand(command)
}
func appaloosa(binary: String,
               apiToken: String,
               storeId: String,
               groupIds: String = "",
               screenshots: String,
               locale: String = "en-US",
               device: String? = nil,
               description: String? = nil) {
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
func appetize(apiHost: String = "api.appetize.io",
              apiToken: String,
              url: String? = nil,
              platform: String = "ios",
              path: String? = nil,
              publicKey: String? = nil,
              note: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "appetize", className: nil, args: [RubyCommand.Argument(name: "api_host", value: apiHost),
                                                                                          RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                          RubyCommand.Argument(name: "url", value: url),
                                                                                          RubyCommand.Argument(name: "platform", value: platform),
                                                                                          RubyCommand.Argument(name: "path", value: path),
                                                                                          RubyCommand.Argument(name: "public_key", value: publicKey),
                                                                                          RubyCommand.Argument(name: "note", value: note)])
  _ = runner.executeCommand(command)
}
func appetizeViewingUrlGenerator(publicKey: String,
                                 baseUrl: String = "https://appetize.io/embed",
                                 device: String = "iphone5s",
                                 scale: String? = nil,
                                 orientation: String = "portrait",
                                 language: String? = nil,
                                 color: String = "black",
                                 launchUrl: String? = nil,
                                 osVersion: String? = nil,
                                 params: String? = nil,
                                 proxy: String? = nil) {
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
func appium(platform: String,
            specPath: String,
            appPath: String,
            invokeAppiumServer: Bool = true,
            host: String = "0.0.0.0",
            port: Int = 4723,
            appiumPath: String? = nil,
            caps: [String : Any]? = nil,
            appiumLib: [String : Any]? = nil) {
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
func appledoc(input: String,
              output: String? = nil,
              templates: String? = nil,
              docsetInstallPath: String? = nil,
              include: String? = nil,
              ignore: String? = nil,
              excludeOutput: String? = nil,
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
              logformat: String? = nil,
              verbose: String? = nil) {
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
func appstore(username: String,
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
              automaticRelease: Bool = false,
              autoReleaseDate: String? = nil,
              phasedRelease: Bool = false,
              resetRatings: Bool = false,
              priceTier: String? = nil,
              appRatingConfigPath: String? = nil,
              submissionInformation: String? = nil,
              teamId: String? = nil,
              teamName: String? = nil,
              devPortalTeamId: String? = nil,
              devPortalTeamName: String? = nil,
              itcProvider: String? = nil,
              runPrecheckBeforeSubmit: Bool = true,
              precheckDefaultRuleLevel: String = "warn",
              individualMetadataItems: [String] = [],
              appIcon: String? = nil,
              appleWatchAppIcon: String? = nil,
              copyright: String? = nil,
              primaryCategory: String? = nil,
              secondaryCategory: String? = nil,
              primaryFirstSubCategory: String? = nil,
              primarySecondSubCategory: String? = nil,
              secondaryFirstSubCategory: String? = nil,
              secondarySecondSubCategory: String? = nil,
              tradeRepresentativeContactInformation: [String : Any]? = nil,
              appReviewInformation: [String : Any]? = nil,
              description: String? = nil,
              name: String? = nil,
              subtitle: [String : Any]? = nil,
              keywords: [String : Any]? = nil,
              promotionalText: [String : Any]? = nil,
              releaseNotes: String? = nil,
              privacyUrl: String? = nil,
              supportUrl: String? = nil,
              marketingUrl: String? = nil,
              languages: [String]? = nil,
              ignoreLanguageDirectoryValidation: Bool = false,
              precheckIncludeInAppPurchases: Bool = true,
              app: String) {
  let command = RubyCommand(commandID: "", methodName: "appstore", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
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
                                                                                          RubyCommand.Argument(name: "description", value: description),
                                                                                          RubyCommand.Argument(name: "name", value: name),
                                                                                          RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                          RubyCommand.Argument(name: "keywords", value: keywords),
                                                                                          RubyCommand.Argument(name: "promotional_text", value: promotionalText),
                                                                                          RubyCommand.Argument(name: "release_notes", value: releaseNotes),
                                                                                          RubyCommand.Argument(name: "privacy_url", value: privacyUrl),
                                                                                          RubyCommand.Argument(name: "support_url", value: supportUrl),
                                                                                          RubyCommand.Argument(name: "marketing_url", value: marketingUrl),
                                                                                          RubyCommand.Argument(name: "languages", value: languages),
                                                                                          RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation),
                                                                                          RubyCommand.Argument(name: "precheck_include_in_app_purchases", value: precheckIncludeInAppPurchases),
                                                                                          RubyCommand.Argument(name: "app", value: app)])
  _ = runner.executeCommand(command)
}
func apteligent(dsym: String? = nil,
                appId: String,
                apiKey: String) {
  let command = RubyCommand(commandID: "", methodName: "apteligent", className: nil, args: [RubyCommand.Argument(name: "dsym", value: dsym),
                                                                                            RubyCommand.Argument(name: "app_id", value: appId),
                                                                                            RubyCommand.Argument(name: "api_key", value: apiKey)])
  _ = runner.executeCommand(command)
}
func artifactory(file: String,
                 repo: String,
                 repoPath: String,
                 endpoint: String,
                 username: String,
                 password: String,
                 properties: [String : Any] = [:],
                 sslPemFile: String? = nil,
                 sslVerify: Bool = true,
                 proxyUsername: String? = nil,
                 proxyPassword: String? = nil,
                 proxyAddress: String? = nil,
                 proxyPort: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "artifactory", className: nil, args: [RubyCommand.Argument(name: "file", value: file),
                                                                                             RubyCommand.Argument(name: "repo", value: repo),
                                                                                             RubyCommand.Argument(name: "repo_path", value: repoPath),
                                                                                             RubyCommand.Argument(name: "endpoint", value: endpoint),
                                                                                             RubyCommand.Argument(name: "username", value: username),
                                                                                             RubyCommand.Argument(name: "password", value: password),
                                                                                             RubyCommand.Argument(name: "properties", value: properties),
                                                                                             RubyCommand.Argument(name: "ssl_pem_file", value: sslPemFile),
                                                                                             RubyCommand.Argument(name: "ssl_verify", value: sslVerify),
                                                                                             RubyCommand.Argument(name: "proxy_username", value: proxyUsername),
                                                                                             RubyCommand.Argument(name: "proxy_password", value: proxyPassword),
                                                                                             RubyCommand.Argument(name: "proxy_address", value: proxyAddress),
                                                                                             RubyCommand.Argument(name: "proxy_port", value: proxyPort)])
  _ = runner.executeCommand(command)
}
func automaticCodeSigning(path: String,
                          useAutomaticSigning: Bool = false,
                          teamId: String? = nil,
                          targets: [String]? = nil,
                          codeSignIdentity: String? = nil,
                          profileName: String? = nil,
                          profileUuid: String? = nil,
                          bundleIdentifier: String? = nil) {
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
func backupFile(path: String) {
  let command = RubyCommand(commandID: "", methodName: "backup_file", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func backupXcarchive(xcarchive: String,
                     destination: String,
                     zip: Bool = true,
                     zipFilename: String? = nil,
                     versioned: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "backup_xcarchive", className: nil, args: [RubyCommand.Argument(name: "xcarchive", value: xcarchive),
                                                                                                  RubyCommand.Argument(name: "destination", value: destination),
                                                                                                  RubyCommand.Argument(name: "zip", value: zip),
                                                                                                  RubyCommand.Argument(name: "zip_filename", value: zipFilename),
                                                                                                  RubyCommand.Argument(name: "versioned", value: versioned)])
  _ = runner.executeCommand(command)
}
func badge(dark: String? = nil,
           custom: String? = nil,
           noBadge: String? = nil,
           shield: String? = nil,
           alpha: String? = nil,
           path: String = ".",
           shieldIoTimeout: String? = nil,
           glob: String? = nil,
           alphaChannel: String? = nil,
           shieldGravity: String? = nil,
           shieldNoResize: String? = nil) {
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
func buildAndUploadToAppetize(xcodebuild: [String : Any] = [:],
                              scheme: String? = nil,
                              apiToken: String) {
  let command = RubyCommand(commandID: "", methodName: "build_and_upload_to_appetize", className: nil, args: [RubyCommand.Argument(name: "xcodebuild", value: xcodebuild),
                                                                                                              RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                              RubyCommand.Argument(name: "api_token", value: apiToken)])
  _ = runner.executeCommand(command)
}
func buildAndroidApp(task: String,
                     flavor: String? = nil,
                     buildType: String? = nil,
                     flags: String? = nil,
                     projectDir: String = ".",
                     gradlePath: String? = nil,
                     properties: String? = nil,
                     systemProperties: String? = nil,
                     serial: String = "",
                     printCommand: Bool = true,
                     printCommandOutput: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "build_android_app", className: nil, args: [RubyCommand.Argument(name: "task", value: task),
                                                                                                   RubyCommand.Argument(name: "flavor", value: flavor),
                                                                                                   RubyCommand.Argument(name: "build_type", value: buildType),
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
func buildApp(workspace: String? = nil,
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
              exportOptions: [String : Any]? = nil,
              exportXcargs: String? = nil,
              skipBuildArchive: Bool? = nil,
              skipArchive: Bool? = nil,
              buildPath: String? = nil,
              archivePath: String? = nil,
              derivedDataPath: String? = nil,
              resultBundle: Bool = false,
              buildlogPath: String = "~/Library/Logs/gym",
              sdk: String? = nil,
              toolchain: String? = nil,
              destination: String? = nil,
              exportTeamId: String? = nil,
              xcargs: String? = nil,
              xcconfig: String? = nil,
              suppressXcodeOutput: String? = nil,
              disableXcpretty: String? = nil,
              xcprettyTestFormat: String? = nil,
              xcprettyFormatter: String? = nil,
              xcprettyReportJunit: String? = nil,
              xcprettyReportHtml: String? = nil,
              xcprettyReportJson: String? = nil,
              analyzeBuildTime: String? = nil,
              xcprettyUtf: String? = nil,
              skipProfileDetection: Bool = false) {
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
                                                                                           RubyCommand.Argument(name: "include_symbols", value: includeSymbols),
                                                                                           RubyCommand.Argument(name: "include_bitcode", value: includeBitcode),
                                                                                           RubyCommand.Argument(name: "export_method", value: exportMethod),
                                                                                           RubyCommand.Argument(name: "export_options", value: exportOptions),
                                                                                           RubyCommand.Argument(name: "export_xcargs", value: exportXcargs),
                                                                                           RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive),
                                                                                           RubyCommand.Argument(name: "skip_archive", value: skipArchive),
                                                                                           RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                           RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                           RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                           RubyCommand.Argument(name: "result_bundle", value: resultBundle),
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
                                                                                           RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection)])
  _ = runner.executeCommand(command)
}
func buildIosApp(workspace: String? = nil,
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
                 exportOptions: [String : Any]? = nil,
                 exportXcargs: String? = nil,
                 skipBuildArchive: Bool? = nil,
                 skipArchive: Bool? = nil,
                 buildPath: String? = nil,
                 archivePath: String? = nil,
                 derivedDataPath: String? = nil,
                 resultBundle: Bool = false,
                 buildlogPath: String = "~/Library/Logs/gym",
                 sdk: String? = nil,
                 toolchain: String? = nil,
                 destination: String? = nil,
                 exportTeamId: String? = nil,
                 xcargs: String? = nil,
                 xcconfig: String? = nil,
                 suppressXcodeOutput: String? = nil,
                 disableXcpretty: String? = nil,
                 xcprettyTestFormat: String? = nil,
                 xcprettyFormatter: String? = nil,
                 xcprettyReportJunit: String? = nil,
                 xcprettyReportHtml: String? = nil,
                 xcprettyReportJson: String? = nil,
                 analyzeBuildTime: String? = nil,
                 xcprettyUtf: String? = nil,
                 skipProfileDetection: Bool = false) {
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
                                                                                               RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                               RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                               RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                               RubyCommand.Argument(name: "result_bundle", value: resultBundle),
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
                                                                                               RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection)])
  _ = runner.executeCommand(command)
}
func bundleInstall(binstubs: String? = nil,
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
                   with: String? = nil) {
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
func captureAndroidScreenshots(androidHome: String? = nil,
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
                               testInstrumentationRunner: String = "android.support.test.runner.AndroidJUnitRunner",
                               endingLocale: String = "en-US",
                               appApkPath: String? = nil,
                               testsApkPath: String? = nil,
                               specificDevice: String? = nil,
                               deviceType: String = "phone",
                               exitOnTestFailure: Bool = true,
                               reinstallApp: Bool = false) {
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
                                                                                                             RubyCommand.Argument(name: "app_apk_path", value: appApkPath),
                                                                                                             RubyCommand.Argument(name: "tests_apk_path", value: testsApkPath),
                                                                                                             RubyCommand.Argument(name: "specific_device", value: specificDevice),
                                                                                                             RubyCommand.Argument(name: "device_type", value: deviceType),
                                                                                                             RubyCommand.Argument(name: "exit_on_test_failure", value: exitOnTestFailure),
                                                                                                             RubyCommand.Argument(name: "reinstall_app", value: reinstallApp)])
  _ = runner.executeCommand(command)
}
func captureIosScreenshots(workspace: String? = nil,
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
                           localizeSimulator: Bool = false,
                           appIdentifier: String? = nil,
                           addPhotos: [String]? = nil,
                           addVideos: [String]? = nil,
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
                           namespaceLogFiles: String? = nil,
                           concurrentSimulators: Bool = true) {
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
                                                                                                         RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator),
                                                                                                         RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                         RubyCommand.Argument(name: "add_photos", value: addPhotos),
                                                                                                         RubyCommand.Argument(name: "add_videos", value: addVideos),
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
                                                                                                         RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators)])
  _ = runner.executeCommand(command)
}
func captureScreenshots(workspace: String? = nil,
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
                        localizeSimulator: Bool = false,
                        appIdentifier: String? = nil,
                        addPhotos: [String]? = nil,
                        addVideos: [String]? = nil,
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
                        namespaceLogFiles: String? = nil,
                        concurrentSimulators: Bool = true) {
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
                                                                                                     RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator),
                                                                                                     RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                     RubyCommand.Argument(name: "add_photos", value: addPhotos),
                                                                                                     RubyCommand.Argument(name: "add_videos", value: addVideos),
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
                                                                                                     RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators)])
  _ = runner.executeCommand(command)
}
func carthage(command: String = "bootstrap",
              dependencies: [String] = [],
              useSsh: Bool? = nil,
              useSubmodules: Bool? = nil,
              useBinaries: Bool? = nil,
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
              executable: String = "carthage") {
  let command = RubyCommand(commandID: "", methodName: "carthage", className: nil, args: [RubyCommand.Argument(name: "command", value: command),
                                                                                          RubyCommand.Argument(name: "dependencies", value: dependencies),
                                                                                          RubyCommand.Argument(name: "use_ssh", value: useSsh),
                                                                                          RubyCommand.Argument(name: "use_submodules", value: useSubmodules),
                                                                                          RubyCommand.Argument(name: "use_binaries", value: useBinaries),
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
                                                                                          RubyCommand.Argument(name: "executable", value: executable)])
  _ = runner.executeCommand(command)
}
func cert(development: Bool = false,
          force: Bool = false,
          username: String,
          teamId: String? = nil,
          teamName: String? = nil,
          filename: String? = nil,
          outputPath: String = ".",
          keychainPath: String,
          keychainPassword: String? = nil,
          platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "cert", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
                                                                                      RubyCommand.Argument(name: "force", value: force),
                                                                                      RubyCommand.Argument(name: "username", value: username),
                                                                                      RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                      RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                      RubyCommand.Argument(name: "filename", value: filename),
                                                                                      RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                      RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                      RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                      RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
@discardableResult func changelogFromGitCommits(between: String? = nil,
                                                commitsCount: Int? = nil,
                                                path: String = "./",
                                                pretty: String = "%B",
                                                dateFormat: String? = nil,
                                                ancestryPath: Bool = false,
                                                tagMatchPattern: String? = nil,
                                                matchLightweightTag: Bool = true,
                                                quiet: Bool = false,
                                                includeMerges: Bool? = nil,
                                                mergeCommitFiltering: String = "include_merges") -> String {
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
func chatwork(apiToken: String,
              message: String,
              roomid: String,
              success: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "chatwork", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                          RubyCommand.Argument(name: "message", value: message),
                                                                                          RubyCommand.Argument(name: "roomid", value: roomid),
                                                                                          RubyCommand.Argument(name: "success", value: success)])
  _ = runner.executeCommand(command)
}
func checkAppStoreMetadata(appIdentifier: String,
                           username: String,
                           teamId: String? = nil,
                           teamName: String? = nil,
                           defaultRuleLevel: String = "error",
                           includeInAppPurchases: Bool = true,
                           negativeAppleSentiment: String? = nil,
                           placeholderText: String? = nil,
                           otherPlatforms: String? = nil,
                           futureFunctionality: String? = nil,
                           testWords: String? = nil,
                           curseWords: String? = nil,
                           freeStuffInIap: String? = nil,
                           customText: String? = nil,
                           copyrightDate: String? = nil,
                           unreachableUrls: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "check_app_store_metadata", className: nil, args: [RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                          RubyCommand.Argument(name: "username", value: username),
                                                                                                          RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                          RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                          RubyCommand.Argument(name: "default_rule_level", value: defaultRuleLevel),
                                                                                                          RubyCommand.Argument(name: "include_in_app_purchases", value: includeInAppPurchases),
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
func cleanBuildArtifacts(excludePattern: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "clean_build_artifacts", className: nil, args: [RubyCommand.Argument(name: "exclude_pattern", value: excludePattern)])
  _ = runner.executeCommand(command)
}
func cleanCocoapodsCache(name: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "clean_cocoapods_cache", className: nil, args: [RubyCommand.Argument(name: "name", value: name)])
  _ = runner.executeCommand(command)
}
func clearDerivedData(derivedDataPath: String = "~/Library/Developer/Xcode/DerivedData") {
  let command = RubyCommand(commandID: "", methodName: "clear_derived_data", className: nil, args: [RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath)])
  _ = runner.executeCommand(command)
}
func clipboard(value: String) {
  let command = RubyCommand(commandID: "", methodName: "clipboard", className: nil, args: [RubyCommand.Argument(name: "value", value: value)])
  _ = runner.executeCommand(command)
}
func cloc(binaryPath: String = "/usr/local/bin/cloc",
          excludeDir: String? = nil,
          outputDirectory: String = "build",
          sourceDirectory: String = "",
          xml: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "cloc", className: nil, args: [RubyCommand.Argument(name: "binary_path", value: binaryPath),
                                                                                      RubyCommand.Argument(name: "exclude_dir", value: excludeDir),
                                                                                      RubyCommand.Argument(name: "output_directory", value: outputDirectory),
                                                                                      RubyCommand.Argument(name: "source_directory", value: sourceDirectory),
                                                                                      RubyCommand.Argument(name: "xml", value: xml)])
  _ = runner.executeCommand(command)
}
func clubmate() {
  let command = RubyCommand(commandID: "", methodName: "clubmate", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func cocoapods(repoUpdate: Bool = false,
               silent: Bool = false,
               verbose: Bool = false,
               ansi: Bool = true,
               useBundleExec: Bool = true,
               podfile: String? = nil,
               errorCallback: String? = nil,
               tryRepoUpdateOnError: Bool = false,
               clean: Bool = true,
               integrate: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "cocoapods", className: nil, args: [RubyCommand.Argument(name: "repo_update", value: repoUpdate),
                                                                                           RubyCommand.Argument(name: "silent", value: silent),
                                                                                           RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                           RubyCommand.Argument(name: "ansi", value: ansi),
                                                                                           RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                           RubyCommand.Argument(name: "podfile", value: podfile),
                                                                                           RubyCommand.Argument(name: "error_callback", value: errorCallback),
                                                                                           RubyCommand.Argument(name: "try_repo_update_on_error", value: tryRepoUpdateOnError),
                                                                                           RubyCommand.Argument(name: "clean", value: clean),
                                                                                           RubyCommand.Argument(name: "integrate", value: integrate)])
  _ = runner.executeCommand(command)
}
@discardableResult func commitGithubFile(repositoryName: String,
                                         serverUrl: String = "https://api.github.com",
                                         apiToken: String,
                                         branch: String = "master",
                                         path: String,
                                         message: String? = nil,
                                         secure: Bool = true) -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "commit_github_file", className: nil, args: [RubyCommand.Argument(name: "repository_name", value: repositoryName),
                                                                                                    RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                                    RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                    RubyCommand.Argument(name: "branch", value: branch),
                                                                                                    RubyCommand.Argument(name: "path", value: path),
                                                                                                    RubyCommand.Argument(name: "message", value: message),
                                                                                                    RubyCommand.Argument(name: "secure", value: secure)])
  return parseDictionary(fromString: runner.executeCommand(command))
}
func commitVersionBump(message: String? = nil,
                       xcodeproj: String? = nil,
                       force: Bool = false,
                       settings: Bool = false,
                       ignore: String? = nil,
                       include: [String] = []) {
  let command = RubyCommand(commandID: "", methodName: "commit_version_bump", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                                     RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                     RubyCommand.Argument(name: "force", value: force),
                                                                                                     RubyCommand.Argument(name: "settings", value: settings),
                                                                                                     RubyCommand.Argument(name: "ignore", value: ignore),
                                                                                                     RubyCommand.Argument(name: "include", value: include)])
  _ = runner.executeCommand(command)
}
func copyArtifacts(keepOriginal: Bool = true,
                   targetPath: String = "artifacts",
                   artifacts: [String] = [],
                   failOnMissing: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "copy_artifacts", className: nil, args: [RubyCommand.Argument(name: "keep_original", value: keepOriginal),
                                                                                                RubyCommand.Argument(name: "target_path", value: targetPath),
                                                                                                RubyCommand.Argument(name: "artifacts", value: artifacts),
                                                                                                RubyCommand.Argument(name: "fail_on_missing", value: failOnMissing)])
  _ = runner.executeCommand(command)
}
func crashlytics(ipaPath: String? = nil,
                 apkPath: String? = nil,
                 crashlyticsPath: String? = nil,
                 apiToken: String,
                 buildSecret: String,
                 notesPath: String? = nil,
                 notes: String? = nil,
                 groups: String? = nil,
                 emails: String? = nil,
                 notifications: Bool = true,
                 debug: Bool = false) {
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
func createAppOnManagedPlayStore(jsonKey: String? = nil,
                                 jsonKeyData: String? = nil,
                                 developerAccountId: String,
                                 apk: String,
                                 appTitle: String,
                                 language: String = "en_US",
                                 rootUrl: String? = nil,
                                 timeout: Int = 300) {
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
func createAppOnline(username: String,
                     appIdentifier: String,
                     bundleIdentifierSuffix: String? = nil,
                     appName: String,
                     appVersion: String? = nil,
                     sku: String,
                     platform: String = "ios",
                     language: String = "English",
                     companyName: String? = nil,
                     skipItc: Bool = false,
                     itcUsers: [String]? = nil,
                     enabledFeatures: [String : Any] = [:],
                     enableServices: [String : Any] = [:],
                     skipDevcenter: Bool = false,
                     teamId: String? = nil,
                     teamName: String? = nil,
                     itcTeamId: String? = nil,
                     itcTeamName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "create_app_online", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                   RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                   RubyCommand.Argument(name: "bundle_identifier_suffix", value: bundleIdentifierSuffix),
                                                                                                   RubyCommand.Argument(name: "app_name", value: appName),
                                                                                                   RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                                   RubyCommand.Argument(name: "sku", value: sku),
                                                                                                   RubyCommand.Argument(name: "platform", value: platform),
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
func createKeychain(name: String? = nil,
                    path: String? = nil,
                    password: String,
                    defaultKeychain: Bool = false,
                    unlock: Bool = false,
                    timeout: Int = 300,
                    lockWhenSleeps: Bool = false,
                    lockAfterTimeout: Bool = false,
                    addToSearchList: Bool = true,
                    requireCreate: Bool = false) {
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
func createPullRequest(apiToken: String,
                       repo: String,
                       title: String,
                       body: String? = nil,
                       labels: [String]? = nil,
                       head: String? = nil,
                       base: String = "master",
                       apiUrl: String = "https://api.github.com") {
  let command = RubyCommand(commandID: "", methodName: "create_pull_request", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                     RubyCommand.Argument(name: "repo", value: repo),
                                                                                                     RubyCommand.Argument(name: "title", value: title),
                                                                                                     RubyCommand.Argument(name: "body", value: body),
                                                                                                     RubyCommand.Argument(name: "labels", value: labels),
                                                                                                     RubyCommand.Argument(name: "head", value: head),
                                                                                                     RubyCommand.Argument(name: "base", value: base),
                                                                                                     RubyCommand.Argument(name: "api_url", value: apiUrl)])
  _ = runner.executeCommand(command)
}
func danger(useBundleExec: Bool = true,
            verbose: Bool = false,
            dangerId: String? = nil,
            dangerfile: String? = nil,
            githubApiToken: String? = nil,
            failOnErrors: Bool = false,
            newComment: Bool = false,
            base: String? = nil,
            head: String? = nil,
            pr: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "danger", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                        RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                        RubyCommand.Argument(name: "danger_id", value: dangerId),
                                                                                        RubyCommand.Argument(name: "dangerfile", value: dangerfile),
                                                                                        RubyCommand.Argument(name: "github_api_token", value: githubApiToken),
                                                                                        RubyCommand.Argument(name: "fail_on_errors", value: failOnErrors),
                                                                                        RubyCommand.Argument(name: "new_comment", value: newComment),
                                                                                        RubyCommand.Argument(name: "base", value: base),
                                                                                        RubyCommand.Argument(name: "head", value: head),
                                                                                        RubyCommand.Argument(name: "pr", value: pr)])
  _ = runner.executeCommand(command)
}
func debug() {
  let command = RubyCommand(commandID: "", methodName: "debug", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func defaultPlatform() {
  let command = RubyCommand(commandID: "", methodName: "default_platform", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func deleteKeychain(name: String? = nil,
                    keychainPath: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "delete_keychain", className: nil, args: [RubyCommand.Argument(name: "name", value: name),
                                                                                                 RubyCommand.Argument(name: "keychain_path", value: keychainPath)])
  _ = runner.executeCommand(command)
}
func deliver(username: String = deliverfile.username,
             appIdentifier: String? = deliverfile.appIdentifier,
             appVersion: String? = deliverfile.appVersion,
             ipa: String? = deliverfile.ipa,
             pkg: String? = deliverfile.pkg,
             buildNumber: String? = deliverfile.buildNumber,
             platform: String = deliverfile.platform,
             editLive: Bool = deliverfile.editLive,
             useLiveVersion: Bool = deliverfile.useLiveVersion,
             metadataPath: String? = deliverfile.metadataPath,
             screenshotsPath: String? = deliverfile.screenshotsPath,
             skipBinaryUpload: Bool = deliverfile.skipBinaryUpload,
             skipScreenshots: Bool = deliverfile.skipScreenshots,
             skipMetadata: Bool = deliverfile.skipMetadata,
             skipAppVersionUpdate: Bool = deliverfile.skipAppVersionUpdate,
             force: Bool = deliverfile.force,
             overwriteScreenshots: Bool = deliverfile.overwriteScreenshots,
             submitForReview: Bool = deliverfile.submitForReview,
             rejectIfPossible: Bool = deliverfile.rejectIfPossible,
             automaticRelease: Bool = deliverfile.automaticRelease,
             autoReleaseDate: String? = deliverfile.autoReleaseDate,
             phasedRelease: Bool = deliverfile.phasedRelease,
             resetRatings: Bool = deliverfile.resetRatings,
             priceTier: String? = deliverfile.priceTier,
             appRatingConfigPath: String? = deliverfile.appRatingConfigPath,
             submissionInformation: String? = deliverfile.submissionInformation,
             teamId: String? = deliverfile.teamId,
             teamName: String? = deliverfile.teamName,
             devPortalTeamId: String? = deliverfile.devPortalTeamId,
             devPortalTeamName: String? = deliverfile.devPortalTeamName,
             itcProvider: String? = deliverfile.itcProvider,
             runPrecheckBeforeSubmit: Bool = deliverfile.runPrecheckBeforeSubmit,
             precheckDefaultRuleLevel: String = deliverfile.precheckDefaultRuleLevel,
             individualMetadataItems: [String] = deliverfile.individualMetadataItems,
             appIcon: String? = deliverfile.appIcon,
             appleWatchAppIcon: String? = deliverfile.appleWatchAppIcon,
             copyright: String? = deliverfile.copyright,
             primaryCategory: String? = deliverfile.primaryCategory,
             secondaryCategory: String? = deliverfile.secondaryCategory,
             primaryFirstSubCategory: String? = deliverfile.primaryFirstSubCategory,
             primarySecondSubCategory: String? = deliverfile.primarySecondSubCategory,
             secondaryFirstSubCategory: String? = deliverfile.secondaryFirstSubCategory,
             secondarySecondSubCategory: String? = deliverfile.secondarySecondSubCategory,
             tradeRepresentativeContactInformation: [String : Any]? = deliverfile.tradeRepresentativeContactInformation,
             appReviewInformation: [String : Any]? = deliverfile.appReviewInformation,
             description: String? = deliverfile.description,
             name: String? = deliverfile.name,
             subtitle: [String : Any]? = deliverfile.subtitle,
             keywords: [String : Any]? = deliverfile.keywords,
             promotionalText: [String : Any]? = deliverfile.promotionalText,
             releaseNotes: String? = deliverfile.releaseNotes,
             privacyUrl: String? = deliverfile.privacyUrl,
             supportUrl: String? = deliverfile.supportUrl,
             marketingUrl: String? = deliverfile.marketingUrl,
             languages: [String]? = deliverfile.languages,
             ignoreLanguageDirectoryValidation: Bool = deliverfile.ignoreLanguageDirectoryValidation,
             precheckIncludeInAppPurchases: Bool = deliverfile.precheckIncludeInAppPurchases,
             app: String = deliverfile.app) {
  let command = RubyCommand(commandID: "", methodName: "deliver", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
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
                                                                                         RubyCommand.Argument(name: "description", value: description),
                                                                                         RubyCommand.Argument(name: "name", value: name),
                                                                                         RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                         RubyCommand.Argument(name: "keywords", value: keywords),
                                                                                         RubyCommand.Argument(name: "promotional_text", value: promotionalText),
                                                                                         RubyCommand.Argument(name: "release_notes", value: releaseNotes),
                                                                                         RubyCommand.Argument(name: "privacy_url", value: privacyUrl),
                                                                                         RubyCommand.Argument(name: "support_url", value: supportUrl),
                                                                                         RubyCommand.Argument(name: "marketing_url", value: marketingUrl),
                                                                                         RubyCommand.Argument(name: "languages", value: languages),
                                                                                         RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation),
                                                                                         RubyCommand.Argument(name: "precheck_include_in_app_purchases", value: precheckIncludeInAppPurchases),
                                                                                         RubyCommand.Argument(name: "app", value: app)])
  _ = runner.executeCommand(command)
}
func deploygate(apiToken: String,
                user: String,
                ipa: String? = nil,
                apk: String? = nil,
                message: String = "No changelog provided",
                distributionKey: String? = nil,
                releaseNote: String? = nil,
                disableNotify: Bool = false,
                distributionName: String? = nil) {
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
func dotgpgEnvironment(dotgpgFile: String) {
  let command = RubyCommand(commandID: "", methodName: "dotgpg_environment", className: nil, args: [RubyCommand.Argument(name: "dotgpg_file", value: dotgpgFile)])
  _ = runner.executeCommand(command)
}
func download(url: String) {
  let command = RubyCommand(commandID: "", methodName: "download", className: nil, args: [RubyCommand.Argument(name: "url", value: url)])
  _ = runner.executeCommand(command)
}
func downloadDsyms(username: String,
                   appIdentifier: String,
                   teamId: String? = nil,
                   teamName: String? = nil,
                   platform: String = "ios",
                   version: String? = nil,
                   buildNumber: String? = nil,
                   minVersion: String? = nil,
                   outputDirectory: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "download_dsyms", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                RubyCommand.Argument(name: "platform", value: platform),
                                                                                                RubyCommand.Argument(name: "version", value: version),
                                                                                                RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                                RubyCommand.Argument(name: "min_version", value: minVersion),
                                                                                                RubyCommand.Argument(name: "output_directory", value: outputDirectory)])
  _ = runner.executeCommand(command)
}
func downloadFromPlayStore(packageName: String,
                           metadataPath: String? = nil,
                           key: String? = nil,
                           issuer: String? = nil,
                           jsonKey: String? = nil,
                           jsonKeyData: String? = nil,
                           rootUrl: String? = nil,
                           timeout: Int = 300) {
  let command = RubyCommand(commandID: "", methodName: "download_from_play_store", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
                                                                                                          RubyCommand.Argument(name: "metadata_path", value: metadataPath),
                                                                                                          RubyCommand.Argument(name: "key", value: key),
                                                                                                          RubyCommand.Argument(name: "issuer", value: issuer),
                                                                                                          RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                          RubyCommand.Argument(name: "json_key_data", value: jsonKeyData),
                                                                                                          RubyCommand.Argument(name: "root_url", value: rootUrl),
                                                                                                          RubyCommand.Argument(name: "timeout", value: timeout)])
  _ = runner.executeCommand(command)
}
func dsymZip(archivePath: String? = nil,
             dsymPath: String? = nil,
             all: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "dsym_zip", className: nil, args: [RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                          RubyCommand.Argument(name: "dsym_path", value: dsymPath),
                                                                                          RubyCommand.Argument(name: "all", value: all)])
  _ = runner.executeCommand(command)
}
func echo(message: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "echo", className: nil, args: [RubyCommand.Argument(name: "message", value: message)])
  _ = runner.executeCommand(command)
}
func ensureBundleExec() {
  let command = RubyCommand(commandID: "", methodName: "ensure_bundle_exec", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func ensureGitBranch(branch: String = "master") {
  let command = RubyCommand(commandID: "", methodName: "ensure_git_branch", className: nil, args: [RubyCommand.Argument(name: "branch", value: branch)])
  _ = runner.executeCommand(command)
}
func ensureGitStatusClean(showUncommittedChanges: Bool = false,
                          showDiff: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "ensure_git_status_clean", className: nil, args: [RubyCommand.Argument(name: "show_uncommitted_changes", value: showUncommittedChanges),
                                                                                                         RubyCommand.Argument(name: "show_diff", value: showDiff)])
  _ = runner.executeCommand(command)
}
func ensureNoDebugCode(text: String,
                       path: String = ".",
                       `extension`: String? = nil,
                       extensions: String? = nil,
                       exclude: String? = nil,
                       excludeDirs: [String]? = nil) {
  let command = RubyCommand(commandID: "", methodName: "ensure_no_debug_code", className: nil, args: [RubyCommand.Argument(name: "text", value: text),
                                                                                                      RubyCommand.Argument(name: "path", value: path),
                                                                                                      RubyCommand.Argument(name: "extension", value: `extension`),
                                                                                                      RubyCommand.Argument(name: "extensions", value: extensions),
                                                                                                      RubyCommand.Argument(name: "exclude", value: exclude),
                                                                                                      RubyCommand.Argument(name: "exclude_dirs", value: excludeDirs)])
  _ = runner.executeCommand(command)
}
func ensureXcodeVersion(version: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "ensure_xcode_version", className: nil, args: [RubyCommand.Argument(name: "version", value: version)])
  _ = runner.executeCommand(command)
}
@discardableResult func environmentVariable(`set`: [String : Any]? = nil,
                                            `get`: String? = nil,
                                            remove: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "environment_variable", className: nil, args: [RubyCommand.Argument(name: "set", value: `set`),
                                                                                                      RubyCommand.Argument(name: "get", value: `get`),
                                                                                                      RubyCommand.Argument(name: "remove", value: remove)])
  return runner.executeCommand(command)
}
func erb(template: String,
         destination: String? = nil,
         placeholders: [String : Any] = [:]) {
  let command = RubyCommand(commandID: "", methodName: "erb", className: nil, args: [RubyCommand.Argument(name: "template", value: template),
                                                                                     RubyCommand.Argument(name: "destination", value: destination),
                                                                                     RubyCommand.Argument(name: "placeholders", value: placeholders)])
  _ = runner.executeCommand(command)
}
func fastlaneVersion() {
  let command = RubyCommand(commandID: "", methodName: "fastlane_version", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func flock(message: String,
           token: String,
           baseUrl: String = "https://api.flock.co/hooks/sendMessage") {
  let command = RubyCommand(commandID: "", methodName: "flock", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                       RubyCommand.Argument(name: "token", value: token),
                                                                                       RubyCommand.Argument(name: "base_url", value: baseUrl)])
  _ = runner.executeCommand(command)
}
func frameScreenshots(white: Bool? = nil,
                      silver: Bool? = nil,
                      roseGold: Bool? = nil,
                      gold: Bool? = nil,
                      forceDeviceType: String? = nil,
                      useLegacyIphone5s: Bool = false,
                      useLegacyIphone6s: Bool = false,
                      useLegacyIphonex: Bool = false,
                      forceOrientationBlock: String? = nil,
                      debugMode: Bool = false,
                      path: String = "./") {
  let command = RubyCommand(commandID: "", methodName: "frame_screenshots", className: nil, args: [RubyCommand.Argument(name: "white", value: white),
                                                                                                   RubyCommand.Argument(name: "silver", value: silver),
                                                                                                   RubyCommand.Argument(name: "rose_gold", value: roseGold),
                                                                                                   RubyCommand.Argument(name: "gold", value: gold),
                                                                                                   RubyCommand.Argument(name: "force_device_type", value: forceDeviceType),
                                                                                                   RubyCommand.Argument(name: "use_legacy_iphone5s", value: useLegacyIphone5s),
                                                                                                   RubyCommand.Argument(name: "use_legacy_iphone6s", value: useLegacyIphone6s),
                                                                                                   RubyCommand.Argument(name: "use_legacy_iphonex", value: useLegacyIphonex),
                                                                                                   RubyCommand.Argument(name: "force_orientation_block", value: forceOrientationBlock),
                                                                                                   RubyCommand.Argument(name: "debug_mode", value: debugMode),
                                                                                                   RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func frameit(white: Bool? = nil,
             silver: Bool? = nil,
             roseGold: Bool? = nil,
             gold: Bool? = nil,
             forceDeviceType: String? = nil,
             useLegacyIphone5s: Bool = false,
             useLegacyIphone6s: Bool = false,
             useLegacyIphonex: Bool = false,
             forceOrientationBlock: String? = nil,
             debugMode: Bool = false,
             path: String = "./") {
  let command = RubyCommand(commandID: "", methodName: "frameit", className: nil, args: [RubyCommand.Argument(name: "white", value: white),
                                                                                         RubyCommand.Argument(name: "silver", value: silver),
                                                                                         RubyCommand.Argument(name: "rose_gold", value: roseGold),
                                                                                         RubyCommand.Argument(name: "gold", value: gold),
                                                                                         RubyCommand.Argument(name: "force_device_type", value: forceDeviceType),
                                                                                         RubyCommand.Argument(name: "use_legacy_iphone5s", value: useLegacyIphone5s),
                                                                                         RubyCommand.Argument(name: "use_legacy_iphone6s", value: useLegacyIphone6s),
                                                                                         RubyCommand.Argument(name: "use_legacy_iphonex", value: useLegacyIphonex),
                                                                                         RubyCommand.Argument(name: "force_orientation_block", value: forceOrientationBlock),
                                                                                         RubyCommand.Argument(name: "debug_mode", value: debugMode),
                                                                                         RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func gcovr() {
  let command = RubyCommand(commandID: "", methodName: "gcovr", className: nil, args: [])
  _ = runner.executeCommand(command)
}
@discardableResult func getBuildNumber(xcodeproj: String? = nil,
                                       hideErrorWhenVersioningDisabled: Bool = false) -> String {
  let command = RubyCommand(commandID: "", methodName: "get_build_number", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                  RubyCommand.Argument(name: "hide_error_when_versioning_disabled", value: hideErrorWhenVersioningDisabled)])
  return runner.executeCommand(command)
}
func getBuildNumberRepository(useHgRevisionNumber: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "get_build_number_repository", className: nil, args: [RubyCommand.Argument(name: "use_hg_revision_number", value: useHgRevisionNumber)])
  _ = runner.executeCommand(command)
}
func getCertificates(development: Bool = false,
                     force: Bool = false,
                     username: String,
                     teamId: String? = nil,
                     teamName: String? = nil,
                     filename: String? = nil,
                     outputPath: String = ".",
                     keychainPath: String,
                     keychainPassword: String? = nil,
                     platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "get_certificates", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
                                                                                                  RubyCommand.Argument(name: "force", value: force),
                                                                                                  RubyCommand.Argument(name: "username", value: username),
                                                                                                  RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                  RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                  RubyCommand.Argument(name: "filename", value: filename),
                                                                                                  RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                  RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                                  RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                  RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
func getGithubRelease(url: String,
                      serverUrl: String = "https://api.github.com",
                      version: String,
                      apiToken: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "get_github_release", className: nil, args: [RubyCommand.Argument(name: "url", value: url),
                                                                                                    RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                                    RubyCommand.Argument(name: "version", value: version),
                                                                                                    RubyCommand.Argument(name: "api_token", value: apiToken)])
  _ = runner.executeCommand(command)
}
@discardableResult func getInfoPlistValue(key: String,
                                          path: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "get_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key),
                                                                                                      RubyCommand.Argument(name: "path", value: path)])
  return runner.executeCommand(command)
}
@discardableResult func getIpaInfoPlistValue(key: String,
                                             ipa: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "get_ipa_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key),
                                                                                                          RubyCommand.Argument(name: "ipa", value: ipa)])
  return runner.executeCommand(command)
}
func getManagedPlayStorePublishingRights(jsonKey: String? = nil,
                                         jsonKeyData: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "get_managed_play_store_publishing_rights", className: nil, args: [RubyCommand.Argument(name: "json_key", value: jsonKey),
                                                                                                                          RubyCommand.Argument(name: "json_key_data", value: jsonKeyData)])
  _ = runner.executeCommand(command)
}
func getProvisioningProfile(adhoc: Bool = false,
                            developerId: Bool = false,
                            development: Bool = false,
                            skipInstall: Bool = false,
                            force: Bool = false,
                            appIdentifier: String,
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
                            platform: String = "ios",
                            readonly: Bool = false,
                            templateName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "get_provisioning_profile", className: nil, args: [RubyCommand.Argument(name: "adhoc", value: adhoc),
                                                                                                          RubyCommand.Argument(name: "developer_id", value: developerId),
                                                                                                          RubyCommand.Argument(name: "development", value: development),
                                                                                                          RubyCommand.Argument(name: "skip_install", value: skipInstall),
                                                                                                          RubyCommand.Argument(name: "force", value: force),
                                                                                                          RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
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
                                                                                                          RubyCommand.Argument(name: "template_name", value: templateName)])
  _ = runner.executeCommand(command)
}
func getPushCertificate(development: Bool = false,
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
                        newProfile: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "get_push_certificate", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
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
@discardableResult func getVersionNumber(xcodeproj: String? = nil,
                                         target: String? = nil,
                                         configuration: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "get_version_number", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                    RubyCommand.Argument(name: "target", value: target),
                                                                                                    RubyCommand.Argument(name: "configuration", value: configuration)])
  return runner.executeCommand(command)
}
func gitAdd(path: String? = nil,
            shellEscape: Bool = true,
            pathspec: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "git_add", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                         RubyCommand.Argument(name: "shell_escape", value: shellEscape),
                                                                                         RubyCommand.Argument(name: "pathspec", value: pathspec)])
  _ = runner.executeCommand(command)
}
@discardableResult func gitBranch() -> String {
  let command = RubyCommand(commandID: "", methodName: "git_branch", className: nil, args: [])
  return runner.executeCommand(command)
}
func gitCommit(path: String,
               message: String,
               skipGitHooks: Bool? = nil) {
  let command = RubyCommand(commandID: "", methodName: "git_commit", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                            RubyCommand.Argument(name: "message", value: message),
                                                                                            RubyCommand.Argument(name: "skip_git_hooks", value: skipGitHooks)])
  _ = runner.executeCommand(command)
}
func gitPull(onlyTags: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "git_pull", className: nil, args: [RubyCommand.Argument(name: "only_tags", value: onlyTags)])
  _ = runner.executeCommand(command)
}
func gitSubmoduleUpdate(recursive: Bool = false,
                        `init`: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "git_submodule_update", className: nil, args: [RubyCommand.Argument(name: "recursive", value: recursive),
                                                                                                      RubyCommand.Argument(name: "init", value: `init`)])
  _ = runner.executeCommand(command)
}
func gitTagExists(tag: String,
                  remote: Bool = false,
                  remoteName: String = "origin") {
  let command = RubyCommand(commandID: "", methodName: "git_tag_exists", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag),
                                                                                                RubyCommand.Argument(name: "remote", value: remote),
                                                                                                RubyCommand.Argument(name: "remote_name", value: remoteName)])
  _ = runner.executeCommand(command)
}
func githubApi(serverUrl: String = "https://api.github.com",
               apiToken: String,
               httpMethod: String = "GET",
               body: [String : Any] = [:],
               rawBody: String? = nil,
               path: String? = nil,
               url: String? = nil,
               errorHandlers: [String : Any] = [:],
               headers: [String : Any] = [:],
               secure: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "github_api", className: nil, args: [RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                            RubyCommand.Argument(name: "api_token", value: apiToken),
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
func googlePlayTrackVersionCodes(packageName: String,
                                 track: String = "production",
                                 key: String? = nil,
                                 issuer: String? = nil,
                                 jsonKey: String? = nil,
                                 jsonKeyData: String? = nil,
                                 rootUrl: String? = nil,
                                 timeout: Int = 300) {
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
func gradle(task: String,
            flavor: String? = nil,
            buildType: String? = nil,
            flags: String? = nil,
            projectDir: String = ".",
            gradlePath: String? = nil,
            properties: String? = nil,
            systemProperties: String? = nil,
            serial: String = "",
            printCommand: Bool = true,
            printCommandOutput: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "gradle", className: nil, args: [RubyCommand.Argument(name: "task", value: task),
                                                                                        RubyCommand.Argument(name: "flavor", value: flavor),
                                                                                        RubyCommand.Argument(name: "build_type", value: buildType),
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
func gym(workspace: String? = gymfile.workspace,
         project: String? = gymfile.project,
         scheme: String? = gymfile.scheme,
         clean: Bool = gymfile.clean,
         outputDirectory: String = gymfile.outputDirectory,
         outputName: String? = gymfile.outputName,
         configuration: String? = gymfile.configuration,
         silent: Bool = gymfile.silent,
         codesigningIdentity: String? = gymfile.codesigningIdentity,
         skipPackageIpa: Bool = gymfile.skipPackageIpa,
         includeSymbols: Bool? = gymfile.includeSymbols,
         includeBitcode: Bool? = gymfile.includeBitcode,
         exportMethod: String? = gymfile.exportMethod,
         exportOptions: [String : Any]? = gymfile.exportOptions,
         exportXcargs: String? = gymfile.exportXcargs,
         skipBuildArchive: Bool? = gymfile.skipBuildArchive,
         skipArchive: Bool? = gymfile.skipArchive,
         buildPath: String? = gymfile.buildPath,
         archivePath: String? = gymfile.archivePath,
         derivedDataPath: String? = gymfile.derivedDataPath,
         resultBundle: Bool = gymfile.resultBundle,
         buildlogPath: String = gymfile.buildlogPath,
         sdk: String? = gymfile.sdk,
         toolchain: String? = gymfile.toolchain,
         destination: String? = gymfile.destination,
         exportTeamId: String? = gymfile.exportTeamId,
         xcargs: String? = gymfile.xcargs,
         xcconfig: String? = gymfile.xcconfig,
         suppressXcodeOutput: String? = gymfile.suppressXcodeOutput,
         disableXcpretty: String? = gymfile.disableXcpretty,
         xcprettyTestFormat: String? = gymfile.xcprettyTestFormat,
         xcprettyFormatter: String? = gymfile.xcprettyFormatter,
         xcprettyReportJunit: String? = gymfile.xcprettyReportJunit,
         xcprettyReportHtml: String? = gymfile.xcprettyReportHtml,
         xcprettyReportJson: String? = gymfile.xcprettyReportJson,
         analyzeBuildTime: String? = gymfile.analyzeBuildTime,
         xcprettyUtf: String? = gymfile.xcprettyUtf,
         skipProfileDetection: Bool = gymfile.skipProfileDetection) {
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
                                                                                     RubyCommand.Argument(name: "include_symbols", value: includeSymbols),
                                                                                     RubyCommand.Argument(name: "include_bitcode", value: includeBitcode),
                                                                                     RubyCommand.Argument(name: "export_method", value: exportMethod),
                                                                                     RubyCommand.Argument(name: "export_options", value: exportOptions),
                                                                                     RubyCommand.Argument(name: "export_xcargs", value: exportXcargs),
                                                                                     RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive),
                                                                                     RubyCommand.Argument(name: "skip_archive", value: skipArchive),
                                                                                     RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                     RubyCommand.Argument(name: "archive_path", value: archivePath),
                                                                                     RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath),
                                                                                     RubyCommand.Argument(name: "result_bundle", value: resultBundle),
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
                                                                                     RubyCommand.Argument(name: "skip_profile_detection", value: skipProfileDetection)])
  _ = runner.executeCommand(command)
}
func hgAddTag(tag: String) {
  let command = RubyCommand(commandID: "", methodName: "hg_add_tag", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag)])
  _ = runner.executeCommand(command)
}
func hgCommitVersionBump(message: String = "Version Bump",
                         xcodeproj: String? = nil,
                         force: Bool = false,
                         testDirtyFiles: String = "file1, file2",
                         testExpectedFiles: String = "file1, file2") {
  let command = RubyCommand(commandID: "", methodName: "hg_commit_version_bump", className: nil, args: [RubyCommand.Argument(name: "message", value: message),
                                                                                                        RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                        RubyCommand.Argument(name: "force", value: force),
                                                                                                        RubyCommand.Argument(name: "test_dirty_files", value: testDirtyFiles),
                                                                                                        RubyCommand.Argument(name: "test_expected_files", value: testExpectedFiles)])
  _ = runner.executeCommand(command)
}
func hgEnsureCleanStatus() {
  let command = RubyCommand(commandID: "", methodName: "hg_ensure_clean_status", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func hgPush(force: Bool = false,
            destination: String = "") {
  let command = RubyCommand(commandID: "", methodName: "hg_push", className: nil, args: [RubyCommand.Argument(name: "force", value: force),
                                                                                         RubyCommand.Argument(name: "destination", value: destination)])
  _ = runner.executeCommand(command)
}
func hipchat(message: String = "",
             channel: String,
             apiToken: String,
             customColor: String? = nil,
             success: Bool = true,
             version: String,
             notifyRoom: Bool = false,
             apiHost: String = "api.hipchat.com",
             messageFormat: String = "html",
             includeHtmlHeader: Bool = true,
             from: String = "fastlane") {
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
func hockey(apk: String? = nil,
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
            dsaSignature: String = "") {
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
func ifttt(apiKey: String,
           eventName: String,
           value1: String? = nil,
           value2: String? = nil,
           value3: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "ifttt", className: nil, args: [RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                       RubyCommand.Argument(name: "event_name", value: eventName),
                                                                                       RubyCommand.Argument(name: "value1", value: value1),
                                                                                       RubyCommand.Argument(name: "value2", value: value2),
                                                                                       RubyCommand.Argument(name: "value3", value: value3)])
  _ = runner.executeCommand(command)
}
func importCertificate(keychainName: String,
                       keychainPath: String? = nil,
                       keychainPassword: String? = nil,
                       certificatePath: String,
                       certificatePassword: String? = nil,
                       logOutput: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "import_certificate", className: nil, args: [RubyCommand.Argument(name: "keychain_name", value: keychainName),
                                                                                                    RubyCommand.Argument(name: "keychain_path", value: keychainPath),
                                                                                                    RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                    RubyCommand.Argument(name: "certificate_path", value: certificatePath),
                                                                                                    RubyCommand.Argument(name: "certificate_password", value: certificatePassword),
                                                                                                    RubyCommand.Argument(name: "log_output", value: logOutput)])
  _ = runner.executeCommand(command)
}
@discardableResult func incrementBuildNumber(buildNumber: String? = nil,
                                             xcodeproj: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "increment_build_number", className: nil, args: [RubyCommand.Argument(name: "build_number", value: buildNumber),
                                                                                                        RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  return runner.executeCommand(command)
}
@discardableResult func incrementVersionNumber(bumpType: String = "patch",
                                               versionNumber: String? = nil,
                                               xcodeproj: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "increment_version_number", className: nil, args: [RubyCommand.Argument(name: "bump_type", value: bumpType),
                                                                                                          RubyCommand.Argument(name: "version_number", value: versionNumber),
                                                                                                          RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  return runner.executeCommand(command)
}
func installOnDevice(extra: String? = nil,
                     deviceId: String? = nil,
                     skipWifi: String? = nil,
                     ipa: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "install_on_device", className: nil, args: [RubyCommand.Argument(name: "extra", value: extra),
                                                                                                   RubyCommand.Argument(name: "device_id", value: deviceId),
                                                                                                   RubyCommand.Argument(name: "skip_wifi", value: skipWifi),
                                                                                                   RubyCommand.Argument(name: "ipa", value: ipa)])
  _ = runner.executeCommand(command)
}
func installXcodePlugin(url: String,
                        github: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "install_xcode_plugin", className: nil, args: [RubyCommand.Argument(name: "url", value: url),
                                                                                                      RubyCommand.Argument(name: "github", value: github)])
  _ = runner.executeCommand(command)
}
func installr(apiToken: String,
              ipa: String,
              notes: String? = nil,
              notify: String? = nil,
              add: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "installr", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                          RubyCommand.Argument(name: "ipa", value: ipa),
                                                                                          RubyCommand.Argument(name: "notes", value: notes),
                                                                                          RubyCommand.Argument(name: "notify", value: notify),
                                                                                          RubyCommand.Argument(name: "add", value: add)])
  _ = runner.executeCommand(command)
}
func ipa(workspace: String? = nil,
         project: String? = nil,
         configuration: String? = nil,
         scheme: String? = nil,
         clean: String? = nil,
         archive: String? = nil,
         destination: String? = nil,
         embed: String? = nil,
         identity: String? = nil,
         sdk: String? = nil,
         ipa: String? = nil,
         xcconfig: String? = nil,
         xcargs: String? = nil) {
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
@discardableResult func isCi() -> Bool {
  let command = RubyCommand(commandID: "", methodName: "is_ci", className: nil, args: [])
  return parseBool(fromString: runner.executeCommand(command))
}
func jazzy(config: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "jazzy", className: nil, args: [RubyCommand.Argument(name: "config", value: config)])
  _ = runner.executeCommand(command)
}
func jira(url: String,
          contextPath: String = "",
          username: String,
          password: String,
          ticketId: String,
          commentText: String) {
  let command = RubyCommand(commandID: "", methodName: "jira", className: nil, args: [RubyCommand.Argument(name: "url", value: url),
                                                                                      RubyCommand.Argument(name: "context_path", value: contextPath),
                                                                                      RubyCommand.Argument(name: "username", value: username),
                                                                                      RubyCommand.Argument(name: "password", value: password),
                                                                                      RubyCommand.Argument(name: "ticket_id", value: ticketId),
                                                                                      RubyCommand.Argument(name: "comment_text", value: commentText)])
  _ = runner.executeCommand(command)
}
@discardableResult func laneContext() -> [String : Any] {
  let command = RubyCommand(commandID: "", methodName: "lane_context", className: nil, args: [])
  return parseDictionary(fromString: runner.executeCommand(command))
}
@discardableResult func lastGitCommit() -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "last_git_commit", className: nil, args: [])
  return parseDictionary(fromString: runner.executeCommand(command))
}
@discardableResult func lastGitTag() -> String {
  let command = RubyCommand(commandID: "", methodName: "last_git_tag", className: nil, args: [])
  return runner.executeCommand(command)
}
@discardableResult func latestTestflightBuildNumber(live: Bool = false,
                                                    appIdentifier: String,
                                                    username: String,
                                                    version: String? = nil,
                                                    platform: String = "ios",
                                                    initialBuildNumber: Int = 1,
                                                    teamId: String? = nil,
                                                    teamName: String? = nil) -> Int {
  let command = RubyCommand(commandID: "", methodName: "latest_testflight_build_number", className: nil, args: [RubyCommand.Argument(name: "live", value: live),
                                                                                                                RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                                RubyCommand.Argument(name: "username", value: username),
                                                                                                                RubyCommand.Argument(name: "version", value: version),
                                                                                                                RubyCommand.Argument(name: "platform", value: platform),
                                                                                                                RubyCommand.Argument(name: "initial_build_number", value: initialBuildNumber),
                                                                                                                RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                                RubyCommand.Argument(name: "team_name", value: teamName)])
  return parseInt(fromString: runner.executeCommand(command))
}
func lcov(projectName: String,
          scheme: String,
          arch: String = "i386",
          outputDir: String = "coverage_reports") {
  let command = RubyCommand(commandID: "", methodName: "lcov", className: nil, args: [RubyCommand.Argument(name: "project_name", value: projectName),
                                                                                      RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                      RubyCommand.Argument(name: "arch", value: arch),
                                                                                      RubyCommand.Argument(name: "output_dir", value: outputDir)])
  _ = runner.executeCommand(command)
}
func mailgun(mailgunSandboxDomain: String? = nil,
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
             attachment: String? = nil,
             customPlaceholders: [String : Any] = [:]) {
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
func makeChangelogFromJenkins(fallbackChangelog: String = "",
                              includeCommitBody: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "make_changelog_from_jenkins", className: nil, args: [RubyCommand.Argument(name: "fallback_changelog", value: fallbackChangelog),
                                                                                                             RubyCommand.Argument(name: "include_commit_body", value: includeCommitBody)])
  _ = runner.executeCommand(command)
}
func match(type: String = matchfile.type,
           readonly: Bool = matchfile.readonly,
           appIdentifier: [String] = matchfile.appIdentifier,
           username: String = matchfile.username,
           teamId: String? = matchfile.teamId,
           teamName: String? = matchfile.teamName,
           storageMode: String = matchfile.storageMode,
           gitUrl: String = matchfile.gitUrl,
           gitBranch: String = matchfile.gitBranch,
           gitFullName: String? = matchfile.gitFullName,
           gitUserEmail: String? = matchfile.gitUserEmail,
           shallowClone: Bool = matchfile.shallowClone,
           cloneBranchDirectly: Bool = matchfile.cloneBranchDirectly,
           googleCloudBucketName: String? = matchfile.googleCloudBucketName,
           googleCloudKeysFile: String? = matchfile.googleCloudKeysFile,
           googleCloudProjectId: String? = matchfile.googleCloudProjectId,
           keychainName: String = matchfile.keychainName,
           keychainPassword: String? = matchfile.keychainPassword,
           force: Bool = matchfile.force,
           forceForNewDevices: Bool = matchfile.forceForNewDevices,
           skipConfirmation: Bool = matchfile.skipConfirmation,
           skipDocs: Bool = matchfile.skipDocs,
           platform: String = matchfile.platform,
           templateName: String? = matchfile.templateName,
           outputPath: String? = matchfile.outputPath,
           verbose: Bool = matchfile.verbose) {
  let command = RubyCommand(commandID: "", methodName: "match", className: nil, args: [RubyCommand.Argument(name: "type", value: type),
                                                                                       RubyCommand.Argument(name: "readonly", value: readonly),
                                                                                       RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
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
                                                                                       RubyCommand.Argument(name: "google_cloud_bucket_name", value: googleCloudBucketName),
                                                                                       RubyCommand.Argument(name: "google_cloud_keys_file", value: googleCloudKeysFile),
                                                                                       RubyCommand.Argument(name: "google_cloud_project_id", value: googleCloudProjectId),
                                                                                       RubyCommand.Argument(name: "keychain_name", value: keychainName),
                                                                                       RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                       RubyCommand.Argument(name: "force", value: force),
                                                                                       RubyCommand.Argument(name: "force_for_new_devices", value: forceForNewDevices),
                                                                                       RubyCommand.Argument(name: "skip_confirmation", value: skipConfirmation),
                                                                                       RubyCommand.Argument(name: "skip_docs", value: skipDocs),
                                                                                       RubyCommand.Argument(name: "platform", value: platform),
                                                                                       RubyCommand.Argument(name: "template_name", value: templateName),
                                                                                       RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                       RubyCommand.Argument(name: "verbose", value: verbose)])
  _ = runner.executeCommand(command)
}
func minFastlaneVersion() {
  let command = RubyCommand(commandID: "", methodName: "min_fastlane_version", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func modifyServices(username: String,
                    appIdentifier: String,
                    services: [String : Any] = [:],
                    teamId: String? = nil,
                    teamName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "modify_services", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                                 RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                 RubyCommand.Argument(name: "services", value: services),
                                                                                                 RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                 RubyCommand.Argument(name: "team_name", value: teamName)])
  _ = runner.executeCommand(command)
}
func nexusUpload(file: String,
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
                 proxyPort: String? = nil) {
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
func notification(title: String = "fastlane",
                  subtitle: String? = nil,
                  message: String,
                  sound: String? = nil,
                  activate: String? = nil,
                  appIcon: String? = nil,
                  contentImage: String? = nil,
                  open: String? = nil,
                  execute: String? = nil) {
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
func notify() {
  let command = RubyCommand(commandID: "", methodName: "notify", className: nil, args: [])
  _ = runner.executeCommand(command)
}
@discardableResult func numberOfCommits(all: String? = nil) -> Int {
  let command = RubyCommand(commandID: "", methodName: "number_of_commits", className: nil, args: [RubyCommand.Argument(name: "all", value: all)])
  return parseInt(fromString: runner.executeCommand(command))
}
func oclint(oclintPath: String = "oclint",
            compileCommands: String = "compile_commands.json",
            selectReqex: String? = nil,
            selectRegex: String? = nil,
            excludeRegex: String? = nil,
            reportType: String = "html",
            reportPath: String? = nil,
            listEnabledRules: Bool = false,
            rc: String? = nil,
            thresholds: String? = nil,
            enableRules: String? = nil,
            disableRules: String? = nil,
            maxPriority1: String? = nil,
            maxPriority2: String? = nil,
            maxPriority3: String? = nil,
            enableClangStaticAnalyzer: Bool = false,
            enableGlobalAnalysis: Bool = false,
            allowDuplicatedViolations: Bool = false) {
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
                                                                                        RubyCommand.Argument(name: "allow_duplicated_violations", value: allowDuplicatedViolations)])
  _ = runner.executeCommand(command)
}
func onesignal(authToken: String,
               appName: String,
               androidToken: String? = nil,
               androidGcmSenderId: String? = nil,
               apnsP12: String? = nil,
               apnsP12Password: String? = nil,
               apnsEnv: String = "production") {
  let command = RubyCommand(commandID: "", methodName: "onesignal", className: nil, args: [RubyCommand.Argument(name: "auth_token", value: authToken),
                                                                                           RubyCommand.Argument(name: "app_name", value: appName),
                                                                                           RubyCommand.Argument(name: "android_token", value: androidToken),
                                                                                           RubyCommand.Argument(name: "android_gcm_sender_id", value: androidGcmSenderId),
                                                                                           RubyCommand.Argument(name: "apns_p12", value: apnsP12),
                                                                                           RubyCommand.Argument(name: "apns_p12_password", value: apnsP12Password),
                                                                                           RubyCommand.Argument(name: "apns_env", value: apnsEnv)])
  _ = runner.executeCommand(command)
}
func optOutCrashReporting() {
  let command = RubyCommand(commandID: "", methodName: "opt_out_crash_reporting", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func optOutUsage() {
  let command = RubyCommand(commandID: "", methodName: "opt_out_usage", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func pem(development: Bool = false,
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
         newProfile: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "pem", className: nil, args: [RubyCommand.Argument(name: "development", value: development),
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
func pilot(username: String,
           appIdentifier: String? = nil,
           appPlatform: String = "ios",
           appleId: String? = nil,
           ipa: String? = nil,
           demoAccountRequired: Bool = false,
           betaAppReviewInfo: [String : Any]? = nil,
           localizedAppInfo: [String : Any]? = nil,
           betaAppDescription: String? = nil,
           betaAppFeedbackEmail: String? = nil,
           localizedBuildInfo: [String : Any]? = nil,
           changelog: String? = nil,
           skipSubmission: Bool = false,
           skipWaitingForBuildProcessing: Bool = false,
           updateBuildInfoOnUpload: Bool = false,
           distributeExternal: Bool = false,
           notifyExternalTesters: Bool = true,
           firstName: String? = nil,
           lastName: String? = nil,
           email: String? = nil,
           testersFilePath: String = "./testers.csv",
           groups: [String]? = nil,
           teamId: String? = nil,
           teamName: String? = nil,
           devPortalTeamId: String? = nil,
           itcProvider: String? = nil,
           waitProcessingInterval: Int = 30,
           waitForUploadedBuild: Bool = false,
           rejectBuildWaitingForReview: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "pilot", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
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
                                                                                       RubyCommand.Argument(name: "distribute_external", value: distributeExternal),
                                                                                       RubyCommand.Argument(name: "notify_external_testers", value: notifyExternalTesters),
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
func pluginScores(outputPath: String,
                  templatePath: String,
                  cachePath: String) {
  let command = RubyCommand(commandID: "", methodName: "plugin_scores", className: nil, args: [RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                               RubyCommand.Argument(name: "template_path", value: templatePath),
                                                                                               RubyCommand.Argument(name: "cache_path", value: cachePath)])
  _ = runner.executeCommand(command)
}
func podLibLint(useBundleExec: Bool = true,
                podspec: String? = nil,
                verbose: String? = nil,
                allowWarnings: String? = nil,
                sources: [String]? = nil,
                swiftVersion: String? = nil,
                useLibraries: Bool = false,
                failFast: Bool = false,
                `private`: Bool = false,
                quick: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "pod_lib_lint", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                              RubyCommand.Argument(name: "podspec", value: podspec),
                                                                                              RubyCommand.Argument(name: "verbose", value: verbose),
                                                                                              RubyCommand.Argument(name: "allow_warnings", value: allowWarnings),
                                                                                              RubyCommand.Argument(name: "sources", value: sources),
                                                                                              RubyCommand.Argument(name: "swift_version", value: swiftVersion),
                                                                                              RubyCommand.Argument(name: "use_libraries", value: useLibraries),
                                                                                              RubyCommand.Argument(name: "fail_fast", value: failFast),
                                                                                              RubyCommand.Argument(name: "private", value: `private`),
                                                                                              RubyCommand.Argument(name: "quick", value: quick)])
  _ = runner.executeCommand(command)
}
func podPush(useBundleExec: Bool = false,
             path: String? = nil,
             repo: String? = nil,
             allowWarnings: String? = nil,
             useLibraries: String? = nil,
             sources: [String]? = nil,
             swiftVersion: String? = nil,
             verbose: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "pod_push", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                          RubyCommand.Argument(name: "path", value: path),
                                                                                          RubyCommand.Argument(name: "repo", value: repo),
                                                                                          RubyCommand.Argument(name: "allow_warnings", value: allowWarnings),
                                                                                          RubyCommand.Argument(name: "use_libraries", value: useLibraries),
                                                                                          RubyCommand.Argument(name: "sources", value: sources),
                                                                                          RubyCommand.Argument(name: "swift_version", value: swiftVersion),
                                                                                          RubyCommand.Argument(name: "verbose", value: verbose)])
  _ = runner.executeCommand(command)
}
func podioItem(clientId: String,
               clientSecret: String,
               appId: String,
               appToken: String,
               identifyingField: String,
               identifyingValue: String,
               otherFields: [String : Any]? = nil) {
  let command = RubyCommand(commandID: "", methodName: "podio_item", className: nil, args: [RubyCommand.Argument(name: "client_id", value: clientId),
                                                                                            RubyCommand.Argument(name: "client_secret", value: clientSecret),
                                                                                            RubyCommand.Argument(name: "app_id", value: appId),
                                                                                            RubyCommand.Argument(name: "app_token", value: appToken),
                                                                                            RubyCommand.Argument(name: "identifying_field", value: identifyingField),
                                                                                            RubyCommand.Argument(name: "identifying_value", value: identifyingValue),
                                                                                            RubyCommand.Argument(name: "other_fields", value: otherFields)])
  _ = runner.executeCommand(command)
}
func precheck(appIdentifier: String = precheckfile.appIdentifier,
              username: String = precheckfile.username,
              teamId: String? = precheckfile.teamId,
              teamName: String? = precheckfile.teamName,
              defaultRuleLevel: String = precheckfile.defaultRuleLevel,
              includeInAppPurchases: Bool = precheckfile.includeInAppPurchases,
              freeStuffInIap: String? = precheckfile.freeStuffInIap) {
  let command = RubyCommand(commandID: "", methodName: "precheck", className: nil, args: [RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                          RubyCommand.Argument(name: "username", value: username),
                                                                                          RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                          RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                          RubyCommand.Argument(name: "default_rule_level", value: defaultRuleLevel),
                                                                                          RubyCommand.Argument(name: "include_in_app_purchases", value: includeInAppPurchases),
                                                                                          RubyCommand.Argument(name: "free_stuff_in_iap", value: freeStuffInIap)])
  _ = runner.executeCommand(command)
}
func println(message: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "println", className: nil, args: [RubyCommand.Argument(name: "message", value: message)])
  _ = runner.executeCommand(command)
}
func produce(username: String,
             appIdentifier: String,
             bundleIdentifierSuffix: String? = nil,
             appName: String,
             appVersion: String? = nil,
             sku: String,
             platform: String = "ios",
             language: String = "English",
             companyName: String? = nil,
             skipItc: Bool = false,
             itcUsers: [String]? = nil,
             enabledFeatures: [String : Any] = [:],
             enableServices: [String : Any] = [:],
             skipDevcenter: Bool = false,
             teamId: String? = nil,
             teamName: String? = nil,
             itcTeamId: String? = nil,
             itcTeamName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "produce", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                         RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                         RubyCommand.Argument(name: "bundle_identifier_suffix", value: bundleIdentifierSuffix),
                                                                                         RubyCommand.Argument(name: "app_name", value: appName),
                                                                                         RubyCommand.Argument(name: "app_version", value: appVersion),
                                                                                         RubyCommand.Argument(name: "sku", value: sku),
                                                                                         RubyCommand.Argument(name: "platform", value: platform),
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
@discardableResult func prompt(text: String = "Please enter some text: ",
                               ciInput: String = "",
                               boolean: Bool = false,
                               secureText: Bool = false,
                               multiLineEndKeyword: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "prompt", className: nil, args: [RubyCommand.Argument(name: "text", value: text),
                                                                                        RubyCommand.Argument(name: "ci_input", value: ciInput),
                                                                                        RubyCommand.Argument(name: "boolean", value: boolean),
                                                                                        RubyCommand.Argument(name: "secure_text", value: secureText),
                                                                                        RubyCommand.Argument(name: "multi_line_end_keyword", value: multiLineEndKeyword)])
  return runner.executeCommand(command)
}
func pushGitTags(force: Bool = false,
                 remote: String = "origin",
                 tag: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "push_git_tags", className: nil, args: [RubyCommand.Argument(name: "force", value: force),
                                                                                               RubyCommand.Argument(name: "remote", value: remote),
                                                                                               RubyCommand.Argument(name: "tag", value: tag)])
  _ = runner.executeCommand(command)
}
func pushToGitRemote(localBranch: String? = nil,
                     remoteBranch: String? = nil,
                     force: Bool = false,
                     forceWithLease: Bool = false,
                     tags: Bool = true,
                     remote: String = "origin") {
  let command = RubyCommand(commandID: "", methodName: "push_to_git_remote", className: nil, args: [RubyCommand.Argument(name: "local_branch", value: localBranch),
                                                                                                    RubyCommand.Argument(name: "remote_branch", value: remoteBranch),
                                                                                                    RubyCommand.Argument(name: "force", value: force),
                                                                                                    RubyCommand.Argument(name: "force_with_lease", value: forceWithLease),
                                                                                                    RubyCommand.Argument(name: "tags", value: tags),
                                                                                                    RubyCommand.Argument(name: "remote", value: remote)])
  _ = runner.executeCommand(command)
}
func puts(message: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "puts", className: nil, args: [RubyCommand.Argument(name: "message", value: message)])
  _ = runner.executeCommand(command)
}
@discardableResult func readPodspec(path: String) -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "read_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
  return parseDictionary(fromString: runner.executeCommand(command))
}
func recreateSchemes(project: String) {
  let command = RubyCommand(commandID: "", methodName: "recreate_schemes", className: nil, args: [RubyCommand.Argument(name: "project", value: project)])
  _ = runner.executeCommand(command)
}
@discardableResult func registerDevice(name: String,
                                       udid: String,
                                       teamId: String? = nil,
                                       teamName: String? = nil,
                                       username: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "register_device", className: nil, args: [RubyCommand.Argument(name: "name", value: name),
                                                                                                 RubyCommand.Argument(name: "udid", value: udid),
                                                                                                 RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                 RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                 RubyCommand.Argument(name: "username", value: username)])
  return runner.executeCommand(command)
}
func registerDevices(devices: [String : Any]? = nil,
                     devicesFile: String? = nil,
                     teamId: String? = nil,
                     teamName: String? = nil,
                     username: String,
                     platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "register_devices", className: nil, args: [RubyCommand.Argument(name: "devices", value: devices),
                                                                                                  RubyCommand.Argument(name: "devices_file", value: devicesFile),
                                                                                                  RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                                  RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                                  RubyCommand.Argument(name: "username", value: username),
                                                                                                  RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
func resetGitRepo(files: String? = nil,
                  force: Bool = false,
                  skipClean: Bool = false,
                  disregardGitignore: Bool = true,
                  exclude: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "reset_git_repo", className: nil, args: [RubyCommand.Argument(name: "files", value: files),
                                                                                                RubyCommand.Argument(name: "force", value: force),
                                                                                                RubyCommand.Argument(name: "skip_clean", value: skipClean),
                                                                                                RubyCommand.Argument(name: "disregard_gitignore", value: disregardGitignore),
                                                                                                RubyCommand.Argument(name: "exclude", value: exclude)])
  _ = runner.executeCommand(command)
}
func resetSimulatorContents(ios: [String]? = nil) {
  let command = RubyCommand(commandID: "", methodName: "reset_simulator_contents", className: nil, args: [RubyCommand.Argument(name: "ios", value: ios)])
  _ = runner.executeCommand(command)
}
func resign(ipa: String,
            signingIdentity: String,
            entitlements: String? = nil,
            provisioningProfile: String,
            version: String? = nil,
            displayName: String? = nil,
            shortVersion: String? = nil,
            bundleVersion: String? = nil,
            bundleId: String? = nil,
            useAppEntitlements: String? = nil,
            keychainPath: String? = nil) {
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
func restoreFile(path: String) {
  let command = RubyCommand(commandID: "", methodName: "restore_file", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
@discardableResult func rocket() -> String {
  let command = RubyCommand(commandID: "", methodName: "rocket", className: nil, args: [])
  return runner.executeCommand(command)
}
func rspec() {
  let command = RubyCommand(commandID: "", methodName: "rspec", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func rsync(extra: String = "-av",
           source: String,
           destination: String) {
  let command = RubyCommand(commandID: "", methodName: "rsync", className: nil, args: [RubyCommand.Argument(name: "extra", value: extra),
                                                                                       RubyCommand.Argument(name: "source", value: source),
                                                                                       RubyCommand.Argument(name: "destination", value: destination)])
  _ = runner.executeCommand(command)
}
func rubocop() {
  let command = RubyCommand(commandID: "", methodName: "rubocop", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func rubyVersion() {
  let command = RubyCommand(commandID: "", methodName: "ruby_version", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func runTests(workspace: String? = nil,
              project: String? = nil,
              scheme: String? = nil,
              device: String? = nil,
              devices: [String]? = nil,
              skipDetectDevices: Bool = false,
              resetSimulator: Bool = false,
              reinstallApp: Bool = false,
              appIdentifier: String? = nil,
              onlyTesting: String? = nil,
              skipTesting: String? = nil,
              xctestrun: String? = nil,
              toolchain: String? = nil,
              clean: Bool = false,
              codeCoverage: Bool? = nil,
              addressSanitizer: Bool? = nil,
              threadSanitizer: Bool? = nil,
              openReport: Bool = false,
              outputDirectory: String = "./test_output",
              outputStyle: String? = nil,
              outputTypes: String = "html,junit",
              outputFiles: String? = nil,
              buildlogPath: String = "~/Library/Logs/scan",
              includeSimulatorLogs: Bool = false,
              suppressXcodeOutput: String? = nil,
              formatter: String? = nil,
              xcprettyArgs: String? = nil,
              derivedDataPath: String? = nil,
              shouldZipBuildProducts: Bool = false,
              resultBundle: Bool = false,
              useClangReportName: Bool = false,
              maxConcurrentSimulators: Int? = nil,
              disableConcurrentTesting: Bool = false,
              skipBuild: Bool = false,
              testWithoutBuilding: Bool? = nil,
              buildForTesting: Bool? = nil,
              sdk: String? = nil,
              configuration: String? = nil,
              xcargs: String? = nil,
              xcconfig: String? = nil,
              slackUrl: String? = nil,
              slackChannel: String? = nil,
              slackMessage: String? = nil,
              slackUseWebhookConfiguredUsernameAndIcon: Bool = false,
              slackUsername: String = "fastlane",
              slackIconUrl: String = "https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png",
              skipSlack: Bool = false,
              slackOnlyOnFailure: Bool = false,
              destination: String? = nil,
              customReportFileName: String? = nil,
              failBuild: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "run_tests", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                           RubyCommand.Argument(name: "project", value: project),
                                                                                           RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                           RubyCommand.Argument(name: "device", value: device),
                                                                                           RubyCommand.Argument(name: "devices", value: devices),
                                                                                           RubyCommand.Argument(name: "skip_detect_devices", value: skipDetectDevices),
                                                                                           RubyCommand.Argument(name: "reset_simulator", value: resetSimulator),
                                                                                           RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                           RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                           RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                           RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                           RubyCommand.Argument(name: "xctestrun", value: xctestrun),
                                                                                           RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                           RubyCommand.Argument(name: "clean", value: clean),
                                                                                           RubyCommand.Argument(name: "code_coverage", value: codeCoverage),
                                                                                           RubyCommand.Argument(name: "address_sanitizer", value: addressSanitizer),
                                                                                           RubyCommand.Argument(name: "thread_sanitizer", value: threadSanitizer),
                                                                                           RubyCommand.Argument(name: "open_report", value: openReport),
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
                                                                                           RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                           RubyCommand.Argument(name: "use_clang_report_name", value: useClangReportName),
                                                                                           RubyCommand.Argument(name: "max_concurrent_simulators", value: maxConcurrentSimulators),
                                                                                           RubyCommand.Argument(name: "disable_concurrent_testing", value: disableConcurrentTesting),
                                                                                           RubyCommand.Argument(name: "skip_build", value: skipBuild),
                                                                                           RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                           RubyCommand.Argument(name: "build_for_testing", value: buildForTesting),
                                                                                           RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                           RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                           RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                           RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                           RubyCommand.Argument(name: "slack_url", value: slackUrl),
                                                                                           RubyCommand.Argument(name: "slack_channel", value: slackChannel),
                                                                                           RubyCommand.Argument(name: "slack_message", value: slackMessage),
                                                                                           RubyCommand.Argument(name: "slack_use_webhook_configured_username_and_icon", value: slackUseWebhookConfiguredUsernameAndIcon),
                                                                                           RubyCommand.Argument(name: "slack_username", value: slackUsername),
                                                                                           RubyCommand.Argument(name: "slack_icon_url", value: slackIconUrl),
                                                                                           RubyCommand.Argument(name: "skip_slack", value: skipSlack),
                                                                                           RubyCommand.Argument(name: "slack_only_on_failure", value: slackOnlyOnFailure),
                                                                                           RubyCommand.Argument(name: "destination", value: destination),
                                                                                           RubyCommand.Argument(name: "custom_report_file_name", value: customReportFileName),
                                                                                           RubyCommand.Argument(name: "fail_build", value: failBuild)])
  _ = runner.executeCommand(command)
}
func s3(ipa: String? = nil,
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
        acl: String = "public_read") {
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
func say(text: String,
         mute: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "say", className: nil, args: [RubyCommand.Argument(name: "text", value: text),
                                                                                     RubyCommand.Argument(name: "mute", value: mute)])
  _ = runner.executeCommand(command)
}
func scan(workspace: String? = scanfile.workspace,
          project: String? = scanfile.project,
          scheme: String? = scanfile.scheme,
          device: String? = scanfile.device,
          devices: [String]? = scanfile.devices,
          skipDetectDevices: Bool = scanfile.skipDetectDevices,
          resetSimulator: Bool = scanfile.resetSimulator,
          reinstallApp: Bool = scanfile.reinstallApp,
          appIdentifier: String? = scanfile.appIdentifier,
          onlyTesting: String? = scanfile.onlyTesting,
          skipTesting: String? = scanfile.skipTesting,
          xctestrun: String? = scanfile.xctestrun,
          toolchain: String? = scanfile.toolchain,
          clean: Bool = scanfile.clean,
          codeCoverage: Bool? = scanfile.codeCoverage,
          addressSanitizer: Bool? = scanfile.addressSanitizer,
          threadSanitizer: Bool? = scanfile.threadSanitizer,
          openReport: Bool = scanfile.openReport,
          outputDirectory: String = scanfile.outputDirectory,
          outputStyle: String? = scanfile.outputStyle,
          outputTypes: String = scanfile.outputTypes,
          outputFiles: String? = scanfile.outputFiles,
          buildlogPath: String = scanfile.buildlogPath,
          includeSimulatorLogs: Bool = scanfile.includeSimulatorLogs,
          suppressXcodeOutput: String? = scanfile.suppressXcodeOutput,
          formatter: String? = scanfile.formatter,
          xcprettyArgs: String? = scanfile.xcprettyArgs,
          derivedDataPath: String? = scanfile.derivedDataPath,
          shouldZipBuildProducts: Bool = scanfile.shouldZipBuildProducts,
          resultBundle: Bool = scanfile.resultBundle,
          useClangReportName: Bool = scanfile.useClangReportName,
          maxConcurrentSimulators: Int? = scanfile.maxConcurrentSimulators,
          disableConcurrentTesting: Bool = scanfile.disableConcurrentTesting,
          skipBuild: Bool = scanfile.skipBuild,
          testWithoutBuilding: Bool? = scanfile.testWithoutBuilding,
          buildForTesting: Bool? = scanfile.buildForTesting,
          sdk: String? = scanfile.sdk,
          configuration: String? = scanfile.configuration,
          xcargs: String? = scanfile.xcargs,
          xcconfig: String? = scanfile.xcconfig,
          slackUrl: String? = scanfile.slackUrl,
          slackChannel: String? = scanfile.slackChannel,
          slackMessage: String? = scanfile.slackMessage,
          slackUseWebhookConfiguredUsernameAndIcon: Bool = scanfile.slackUseWebhookConfiguredUsernameAndIcon,
          slackUsername: String = scanfile.slackUsername,
          slackIconUrl: String = scanfile.slackIconUrl,
          skipSlack: Bool = scanfile.skipSlack,
          slackOnlyOnFailure: Bool = scanfile.slackOnlyOnFailure,
          destination: String? = scanfile.destination,
          customReportFileName: String? = scanfile.customReportFileName,
          failBuild: Bool = scanfile.failBuild) {
  let command = RubyCommand(commandID: "", methodName: "scan", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace),
                                                                                      RubyCommand.Argument(name: "project", value: project),
                                                                                      RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                      RubyCommand.Argument(name: "device", value: device),
                                                                                      RubyCommand.Argument(name: "devices", value: devices),
                                                                                      RubyCommand.Argument(name: "skip_detect_devices", value: skipDetectDevices),
                                                                                      RubyCommand.Argument(name: "reset_simulator", value: resetSimulator),
                                                                                      RubyCommand.Argument(name: "reinstall_app", value: reinstallApp),
                                                                                      RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                      RubyCommand.Argument(name: "only_testing", value: onlyTesting),
                                                                                      RubyCommand.Argument(name: "skip_testing", value: skipTesting),
                                                                                      RubyCommand.Argument(name: "xctestrun", value: xctestrun),
                                                                                      RubyCommand.Argument(name: "toolchain", value: toolchain),
                                                                                      RubyCommand.Argument(name: "clean", value: clean),
                                                                                      RubyCommand.Argument(name: "code_coverage", value: codeCoverage),
                                                                                      RubyCommand.Argument(name: "address_sanitizer", value: addressSanitizer),
                                                                                      RubyCommand.Argument(name: "thread_sanitizer", value: threadSanitizer),
                                                                                      RubyCommand.Argument(name: "open_report", value: openReport),
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
                                                                                      RubyCommand.Argument(name: "result_bundle", value: resultBundle),
                                                                                      RubyCommand.Argument(name: "use_clang_report_name", value: useClangReportName),
                                                                                      RubyCommand.Argument(name: "max_concurrent_simulators", value: maxConcurrentSimulators),
                                                                                      RubyCommand.Argument(name: "disable_concurrent_testing", value: disableConcurrentTesting),
                                                                                      RubyCommand.Argument(name: "skip_build", value: skipBuild),
                                                                                      RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding),
                                                                                      RubyCommand.Argument(name: "build_for_testing", value: buildForTesting),
                                                                                      RubyCommand.Argument(name: "sdk", value: sdk),
                                                                                      RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                      RubyCommand.Argument(name: "xcargs", value: xcargs),
                                                                                      RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                      RubyCommand.Argument(name: "slack_url", value: slackUrl),
                                                                                      RubyCommand.Argument(name: "slack_channel", value: slackChannel),
                                                                                      RubyCommand.Argument(name: "slack_message", value: slackMessage),
                                                                                      RubyCommand.Argument(name: "slack_use_webhook_configured_username_and_icon", value: slackUseWebhookConfiguredUsernameAndIcon),
                                                                                      RubyCommand.Argument(name: "slack_username", value: slackUsername),
                                                                                      RubyCommand.Argument(name: "slack_icon_url", value: slackIconUrl),
                                                                                      RubyCommand.Argument(name: "skip_slack", value: skipSlack),
                                                                                      RubyCommand.Argument(name: "slack_only_on_failure", value: slackOnlyOnFailure),
                                                                                      RubyCommand.Argument(name: "destination", value: destination),
                                                                                      RubyCommand.Argument(name: "custom_report_file_name", value: customReportFileName),
                                                                                      RubyCommand.Argument(name: "fail_build", value: failBuild)])
  _ = runner.executeCommand(command)
}
func scp(username: String,
         password: String? = nil,
         host: String,
         port: String = "22",
         upload: [String : Any]? = nil,
         download: [String : Any]? = nil) {
  let command = RubyCommand(commandID: "", methodName: "scp", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                     RubyCommand.Argument(name: "password", value: password),
                                                                                     RubyCommand.Argument(name: "host", value: host),
                                                                                     RubyCommand.Argument(name: "port", value: port),
                                                                                     RubyCommand.Argument(name: "upload", value: upload),
                                                                                     RubyCommand.Argument(name: "download", value: download)])
  _ = runner.executeCommand(command)
}
func screengrab(androidHome: String? = screengrabfile.androidHome,
                buildToolsVersion: String? = screengrabfile.buildToolsVersion,
                locales: [String] = screengrabfile.locales,
                clearPreviousScreenshots: Bool = screengrabfile.clearPreviousScreenshots,
                outputDirectory: String = screengrabfile.outputDirectory,
                skipOpenSummary: Bool = screengrabfile.skipOpenSummary,
                appPackageName: String = screengrabfile.appPackageName,
                testsPackageName: String? = screengrabfile.testsPackageName,
                useTestsInPackages: [String]? = screengrabfile.useTestsInPackages,
                useTestsInClasses: [String]? = screengrabfile.useTestsInClasses,
                launchArguments: [String]? = screengrabfile.launchArguments,
                testInstrumentationRunner: String = screengrabfile.testInstrumentationRunner,
                endingLocale: String = screengrabfile.endingLocale,
                appApkPath: String? = screengrabfile.appApkPath,
                testsApkPath: String? = screengrabfile.testsApkPath,
                specificDevice: String? = screengrabfile.specificDevice,
                deviceType: String = screengrabfile.deviceType,
                exitOnTestFailure: Bool = screengrabfile.exitOnTestFailure,
                reinstallApp: Bool = screengrabfile.reinstallApp) {
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
                                                                                            RubyCommand.Argument(name: "app_apk_path", value: appApkPath),
                                                                                            RubyCommand.Argument(name: "tests_apk_path", value: testsApkPath),
                                                                                            RubyCommand.Argument(name: "specific_device", value: specificDevice),
                                                                                            RubyCommand.Argument(name: "device_type", value: deviceType),
                                                                                            RubyCommand.Argument(name: "exit_on_test_failure", value: exitOnTestFailure),
                                                                                            RubyCommand.Argument(name: "reinstall_app", value: reinstallApp)])
  _ = runner.executeCommand(command)
}
func setBuildNumberRepository(useHgRevisionNumber: Bool = false,
                              xcodeproj: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "set_build_number_repository", className: nil, args: [RubyCommand.Argument(name: "use_hg_revision_number", value: useHgRevisionNumber),
                                                                                                             RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  _ = runner.executeCommand(command)
}
func setChangelog(appIdentifier: String,
                  username: String,
                  version: String? = nil,
                  changelog: String? = nil,
                  teamId: String? = nil,
                  teamName: String? = nil,
                  platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "set_changelog", className: nil, args: [RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                               RubyCommand.Argument(name: "username", value: username),
                                                                                               RubyCommand.Argument(name: "version", value: version),
                                                                                               RubyCommand.Argument(name: "changelog", value: changelog),
                                                                                               RubyCommand.Argument(name: "team_id", value: teamId),
                                                                                               RubyCommand.Argument(name: "team_name", value: teamName),
                                                                                               RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
@discardableResult func setGithubRelease(repositoryName: String,
                                         serverUrl: String = "https://api.github.com",
                                         apiToken: String,
                                         tagName: String,
                                         name: String? = nil,
                                         commitish: String? = nil,
                                         description: String? = nil,
                                         isDraft: Bool = false,
                                         isPrerelease: Bool = false,
                                         uploadAssets: [String]? = nil) -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "set_github_release", className: nil, args: [RubyCommand.Argument(name: "repository_name", value: repositoryName),
                                                                                                    RubyCommand.Argument(name: "server_url", value: serverUrl),
                                                                                                    RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                    RubyCommand.Argument(name: "tag_name", value: tagName),
                                                                                                    RubyCommand.Argument(name: "name", value: name),
                                                                                                    RubyCommand.Argument(name: "commitish", value: commitish),
                                                                                                    RubyCommand.Argument(name: "description", value: description),
                                                                                                    RubyCommand.Argument(name: "is_draft", value: isDraft),
                                                                                                    RubyCommand.Argument(name: "is_prerelease", value: isPrerelease),
                                                                                                    RubyCommand.Argument(name: "upload_assets", value: uploadAssets)])
  return parseDictionary(fromString: runner.executeCommand(command))
}
func setInfoPlistValue(key: String,
                       subkey: String? = nil,
                       value: String,
                       path: String,
                       outputFileName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "set_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key),
                                                                                                      RubyCommand.Argument(name: "subkey", value: subkey),
                                                                                                      RubyCommand.Argument(name: "value", value: value),
                                                                                                      RubyCommand.Argument(name: "path", value: path),
                                                                                                      RubyCommand.Argument(name: "output_file_name", value: outputFileName)])
  _ = runner.executeCommand(command)
}
func setPodKey(useBundleExec: Bool = true,
               key: String,
               value: String,
               project: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "set_pod_key", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec),
                                                                                             RubyCommand.Argument(name: "key", value: key),
                                                                                             RubyCommand.Argument(name: "value", value: value),
                                                                                             RubyCommand.Argument(name: "project", value: project)])
  _ = runner.executeCommand(command)
}
func setupCircleCi(force: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "setup_circle_ci", className: nil, args: [RubyCommand.Argument(name: "force", value: force)])
  _ = runner.executeCommand(command)
}
func setupJenkins(force: Bool = false,
                  unlockKeychain: Bool = true,
                  addKeychainToSearchList: String = "replace",
                  setDefaultKeychain: Bool = true,
                  keychainPath: String? = nil,
                  keychainPassword: String,
                  setCodeSigningIdentity: Bool = true,
                  codeSigningIdentity: String? = nil,
                  outputDirectory: String = "./output",
                  derivedDataPath: String = "./derivedData",
                  resultBundle: Bool = true) {
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
func setupTravis(force: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "setup_travis", className: nil, args: [RubyCommand.Argument(name: "force", value: force)])
  _ = runner.executeCommand(command)
}
@discardableResult func sh(command: String,
                           log: Bool = true,
                           errorCallback: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "sh", className: nil, args: [RubyCommand.Argument(name: "command", value: command),
                                                                                    RubyCommand.Argument(name: "log", value: log),
                                                                                    RubyCommand.Argument(name: "error_callback", value: errorCallback)])
  return runner.executeCommand(command)
}
func sigh(adhoc: Bool = false,
          developerId: Bool = false,
          development: Bool = false,
          skipInstall: Bool = false,
          force: Bool = false,
          appIdentifier: String,
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
          platform: String = "ios",
          readonly: Bool = false,
          templateName: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "sigh", className: nil, args: [RubyCommand.Argument(name: "adhoc", value: adhoc),
                                                                                      RubyCommand.Argument(name: "developer_id", value: developerId),
                                                                                      RubyCommand.Argument(name: "development", value: development),
                                                                                      RubyCommand.Argument(name: "skip_install", value: skipInstall),
                                                                                      RubyCommand.Argument(name: "force", value: force),
                                                                                      RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
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
                                                                                      RubyCommand.Argument(name: "template_name", value: templateName)])
  _ = runner.executeCommand(command)
}
func skipDocs() {
  let command = RubyCommand(commandID: "", methodName: "skip_docs", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func slack(message: String? = nil,
           pretext: String? = nil,
           channel: String? = nil,
           useWebhookConfiguredUsernameAndIcon: Bool = false,
           slackUrl: String,
           username: String = "fastlane",
           iconUrl: String = "https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png",
           payload: [String : Any] = [:],
           defaultPayloads: [String]? = nil,
           attachmentProperties: [String : Any] = [:],
           success: Bool = true,
           failOnError: Bool = true,
           linkNames: Bool = false) {
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
func slackTrain() {
  let command = RubyCommand(commandID: "", methodName: "slack_train", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func slackTrainCrash() {
  let command = RubyCommand(commandID: "", methodName: "slack_train_crash", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func slackTrainStart(distance: Int = 5,
                     train: String = "🚝",
                     rail: String = "=",
                     reverseDirection: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "slack_train_start", className: nil, args: [RubyCommand.Argument(name: "distance", value: distance),
                                                                                                   RubyCommand.Argument(name: "train", value: train),
                                                                                                   RubyCommand.Argument(name: "rail", value: rail),
                                                                                                   RubyCommand.Argument(name: "reverse_direction", value: reverseDirection)])
  _ = runner.executeCommand(command)
}
func slather(buildDirectory: String? = nil,
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
             llvmCov: String? = nil,
             html: Bool? = nil,
             show: Bool = false,
             sourceDirectory: String? = nil,
             outputDirectory: String? = nil,
             ignore: String? = nil,
             verbose: Bool? = nil,
             useBundleExec: Bool = false,
             binaryBasename: Bool = false,
             binaryFile: Bool = false,
             arch: String? = nil,
             sourceFiles: Bool = false,
             decimals: Bool = false) {
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
                                                                                         RubyCommand.Argument(name: "llvm_cov", value: llvmCov),
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
func snapshot(workspace: String? = snapshotfile.workspace,
              project: String? = snapshotfile.project,
              xcargs: String? = snapshotfile.xcargs,
              xcconfig: String? = snapshotfile.xcconfig,
              devices: [String]? = snapshotfile.devices,
              languages: [String] = snapshotfile.languages,
              launchArguments: [String] = snapshotfile.launchArguments,
              outputDirectory: String = snapshotfile.outputDirectory,
              outputSimulatorLogs: Bool = snapshotfile.outputSimulatorLogs,
              iosVersion: String? = snapshotfile.iosVersion,
              skipOpenSummary: Bool = snapshotfile.skipOpenSummary,
              skipHelperVersionCheck: Bool = snapshotfile.skipHelperVersionCheck,
              clearPreviousScreenshots: Bool = snapshotfile.clearPreviousScreenshots,
              reinstallApp: Bool = snapshotfile.reinstallApp,
              eraseSimulator: Bool = snapshotfile.eraseSimulator,
              localizeSimulator: Bool = snapshotfile.localizeSimulator,
              appIdentifier: String? = snapshotfile.appIdentifier,
              addPhotos: [String]? = snapshotfile.addPhotos,
              addVideos: [String]? = snapshotfile.addVideos,
              buildlogPath: String = snapshotfile.buildlogPath,
              clean: Bool = snapshotfile.clean,
              testWithoutBuilding: Bool? = snapshotfile.testWithoutBuilding,
              configuration: String? = snapshotfile.configuration,
              xcprettyArgs: String? = snapshotfile.xcprettyArgs,
              sdk: String? = snapshotfile.sdk,
              scheme: String? = snapshotfile.scheme,
              numberOfRetries: Int = snapshotfile.numberOfRetries,
              stopAfterFirstError: Bool = snapshotfile.stopAfterFirstError,
              derivedDataPath: String? = snapshotfile.derivedDataPath,
              resultBundle: Bool = snapshotfile.resultBundle,
              testTargetName: String? = snapshotfile.testTargetName,
              namespaceLogFiles: String? = snapshotfile.namespaceLogFiles,
              concurrentSimulators: Bool = snapshotfile.concurrentSimulators) {
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
                                                                                          RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator),
                                                                                          RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                          RubyCommand.Argument(name: "add_photos", value: addPhotos),
                                                                                          RubyCommand.Argument(name: "add_videos", value: addVideos),
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
                                                                                          RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators)])
  _ = runner.executeCommand(command)
}
func sonar(projectConfigurationPath: String? = nil,
           projectKey: String? = nil,
           projectName: String? = nil,
           projectVersion: String? = nil,
           sourcesPath: String? = nil,
           projectLanguage: String? = nil,
           sourceEncoding: String? = nil,
           sonarRunnerArgs: String? = nil,
           sonarLogin: String? = nil,
           sonarUrl: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "sonar", className: nil, args: [RubyCommand.Argument(name: "project_configuration_path", value: projectConfigurationPath),
                                                                                       RubyCommand.Argument(name: "project_key", value: projectKey),
                                                                                       RubyCommand.Argument(name: "project_name", value: projectName),
                                                                                       RubyCommand.Argument(name: "project_version", value: projectVersion),
                                                                                       RubyCommand.Argument(name: "sources_path", value: sourcesPath),
                                                                                       RubyCommand.Argument(name: "project_language", value: projectLanguage),
                                                                                       RubyCommand.Argument(name: "source_encoding", value: sourceEncoding),
                                                                                       RubyCommand.Argument(name: "sonar_runner_args", value: sonarRunnerArgs),
                                                                                       RubyCommand.Argument(name: "sonar_login", value: sonarLogin),
                                                                                       RubyCommand.Argument(name: "sonar_url", value: sonarUrl)])
  _ = runner.executeCommand(command)
}
func splunkmint(dsym: String? = nil,
                apiKey: String,
                apiToken: String,
                verbose: Bool = false,
                uploadProgress: Bool = false,
                proxyUsername: String? = nil,
                proxyPassword: String? = nil,
                proxyAddress: String? = nil,
                proxyPort: String? = nil) {
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
func spm(command: String = "build",
         buildPath: String? = nil,
         packagePath: String? = nil,
         xcconfig: String? = nil,
         configuration: String? = nil,
         xcprettyOutput: String? = nil,
         verbose: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "spm", className: nil, args: [RubyCommand.Argument(name: "command", value: command),
                                                                                     RubyCommand.Argument(name: "build_path", value: buildPath),
                                                                                     RubyCommand.Argument(name: "package_path", value: packagePath),
                                                                                     RubyCommand.Argument(name: "xcconfig", value: xcconfig),
                                                                                     RubyCommand.Argument(name: "configuration", value: configuration),
                                                                                     RubyCommand.Argument(name: "xcpretty_output", value: xcprettyOutput),
                                                                                     RubyCommand.Argument(name: "verbose", value: verbose)])
  _ = runner.executeCommand(command)
}
func ssh(username: String,
         password: String? = nil,
         host: String,
         port: String = "22",
         commands: [String]? = nil,
         log: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "ssh", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
                                                                                     RubyCommand.Argument(name: "password", value: password),
                                                                                     RubyCommand.Argument(name: "host", value: host),
                                                                                     RubyCommand.Argument(name: "port", value: port),
                                                                                     RubyCommand.Argument(name: "commands", value: commands),
                                                                                     RubyCommand.Argument(name: "log", value: log)])
  _ = runner.executeCommand(command)
}
func supply(packageName: String,
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
            versionCodesToRetain: [String]? = nil) {
  let command = RubyCommand(commandID: "", methodName: "supply", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
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
                                                                                        RubyCommand.Argument(name: "version_codes_to_retain", value: versionCodesToRetain)])
  _ = runner.executeCommand(command)
}
func swiftlint(mode: String = "lint",
               path: String? = nil,
               outputFile: String? = nil,
               configFile: String? = nil,
               strict: Bool = false,
               files: String? = nil,
               ignoreExitStatus: Bool = false,
               reporter: String? = nil,
               quiet: Bool = false,
               executable: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "swiftlint", className: nil, args: [RubyCommand.Argument(name: "mode", value: mode),
                                                                                           RubyCommand.Argument(name: "path", value: path),
                                                                                           RubyCommand.Argument(name: "output_file", value: outputFile),
                                                                                           RubyCommand.Argument(name: "config_file", value: configFile),
                                                                                           RubyCommand.Argument(name: "strict", value: strict),
                                                                                           RubyCommand.Argument(name: "files", value: files),
                                                                                           RubyCommand.Argument(name: "ignore_exit_status", value: ignoreExitStatus),
                                                                                           RubyCommand.Argument(name: "reporter", value: reporter),
                                                                                           RubyCommand.Argument(name: "quiet", value: quiet),
                                                                                           RubyCommand.Argument(name: "executable", value: executable)])
  _ = runner.executeCommand(command)
}
func syncCodeSigning(type: String = "development",
                     readonly: Bool = false,
                     appIdentifier: [String],
                     username: String,
                     teamId: String? = nil,
                     teamName: String? = nil,
                     storageMode: String = "git",
                     gitUrl: String,
                     gitBranch: String = "master",
                     gitFullName: String? = nil,
                     gitUserEmail: String? = nil,
                     shallowClone: Bool = false,
                     cloneBranchDirectly: Bool = false,
                     googleCloudBucketName: String? = nil,
                     googleCloudKeysFile: String? = nil,
                     googleCloudProjectId: String? = nil,
                     keychainName: String = "login.keychain",
                     keychainPassword: String? = nil,
                     force: Bool = false,
                     forceForNewDevices: Bool = false,
                     skipConfirmation: Bool = false,
                     skipDocs: Bool = false,
                     platform: String = "ios",
                     templateName: String? = nil,
                     outputPath: String? = nil,
                     verbose: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "sync_code_signing", className: nil, args: [RubyCommand.Argument(name: "type", value: type),
                                                                                                   RubyCommand.Argument(name: "readonly", value: readonly),
                                                                                                   RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
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
                                                                                                   RubyCommand.Argument(name: "google_cloud_bucket_name", value: googleCloudBucketName),
                                                                                                   RubyCommand.Argument(name: "google_cloud_keys_file", value: googleCloudKeysFile),
                                                                                                   RubyCommand.Argument(name: "google_cloud_project_id", value: googleCloudProjectId),
                                                                                                   RubyCommand.Argument(name: "keychain_name", value: keychainName),
                                                                                                   RubyCommand.Argument(name: "keychain_password", value: keychainPassword),
                                                                                                   RubyCommand.Argument(name: "force", value: force),
                                                                                                   RubyCommand.Argument(name: "force_for_new_devices", value: forceForNewDevices),
                                                                                                   RubyCommand.Argument(name: "skip_confirmation", value: skipConfirmation),
                                                                                                   RubyCommand.Argument(name: "skip_docs", value: skipDocs),
                                                                                                   RubyCommand.Argument(name: "platform", value: platform),
                                                                                                   RubyCommand.Argument(name: "template_name", value: templateName),
                                                                                                   RubyCommand.Argument(name: "output_path", value: outputPath),
                                                                                                   RubyCommand.Argument(name: "verbose", value: verbose)])
  _ = runner.executeCommand(command)
}
func teamId() {
  let command = RubyCommand(commandID: "", methodName: "team_id", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func teamName() {
  let command = RubyCommand(commandID: "", methodName: "team_name", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func testfairy(apiKey: String,
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
               timeout: Int? = nil) {
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
                                                                                           RubyCommand.Argument(name: "timeout", value: timeout)])
  _ = runner.executeCommand(command)
}
func testflight(username: String,
                appIdentifier: String? = nil,
                appPlatform: String = "ios",
                appleId: String? = nil,
                ipa: String? = nil,
                demoAccountRequired: Bool = false,
                betaAppReviewInfo: [String : Any]? = nil,
                localizedAppInfo: [String : Any]? = nil,
                betaAppDescription: String? = nil,
                betaAppFeedbackEmail: String? = nil,
                localizedBuildInfo: [String : Any]? = nil,
                changelog: String? = nil,
                skipSubmission: Bool = false,
                skipWaitingForBuildProcessing: Bool = false,
                updateBuildInfoOnUpload: Bool = false,
                distributeExternal: Bool = false,
                notifyExternalTesters: Bool = true,
                firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                testersFilePath: String = "./testers.csv",
                groups: [String]? = nil,
                teamId: String? = nil,
                teamName: String? = nil,
                devPortalTeamId: String? = nil,
                itcProvider: String? = nil,
                waitProcessingInterval: Int = 30,
                waitForUploadedBuild: Bool = false,
                rejectBuildWaitingForReview: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "testflight", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
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
                                                                                            RubyCommand.Argument(name: "distribute_external", value: distributeExternal),
                                                                                            RubyCommand.Argument(name: "notify_external_testers", value: notifyExternalTesters),
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
func tryouts(appId: String,
             apiToken: String,
             buildFile: String,
             notes: String? = nil,
             notesPath: String? = nil,
             notify: Int = 1,
             status: Int = 2) {
  let command = RubyCommand(commandID: "", methodName: "tryouts", className: nil, args: [RubyCommand.Argument(name: "app_id", value: appId),
                                                                                         RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                         RubyCommand.Argument(name: "build_file", value: buildFile),
                                                                                         RubyCommand.Argument(name: "notes", value: notes),
                                                                                         RubyCommand.Argument(name: "notes_path", value: notesPath),
                                                                                         RubyCommand.Argument(name: "notify", value: notify),
                                                                                         RubyCommand.Argument(name: "status", value: status)])
  _ = runner.executeCommand(command)
}
func twitter(consumerKey: String,
             consumerSecret: String,
             accessToken: String,
             accessTokenSecret: String,
             message: String) {
  let command = RubyCommand(commandID: "", methodName: "twitter", className: nil, args: [RubyCommand.Argument(name: "consumer_key", value: consumerKey),
                                                                                         RubyCommand.Argument(name: "consumer_secret", value: consumerSecret),
                                                                                         RubyCommand.Argument(name: "access_token", value: accessToken),
                                                                                         RubyCommand.Argument(name: "access_token_secret", value: accessTokenSecret),
                                                                                         RubyCommand.Argument(name: "message", value: message)])
  _ = runner.executeCommand(command)
}
func typetalk() {
  let command = RubyCommand(commandID: "", methodName: "typetalk", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func unlockKeychain(path: String = "login",
                    password: String,
                    addToSearchList: Bool = true,
                    setDefault: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "unlock_keychain", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                 RubyCommand.Argument(name: "password", value: password),
                                                                                                 RubyCommand.Argument(name: "add_to_search_list", value: addToSearchList),
                                                                                                 RubyCommand.Argument(name: "set_default", value: setDefault)])
  _ = runner.executeCommand(command)
}
func updateAppGroupIdentifiers(entitlementsFile: String,
                               appGroupIdentifiers: String) {
  let command = RubyCommand(commandID: "", methodName: "update_app_group_identifiers", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile),
                                                                                                              RubyCommand.Argument(name: "app_group_identifiers", value: appGroupIdentifiers)])
  _ = runner.executeCommand(command)
}
func updateAppIdentifier(xcodeproj: String,
                         plistPath: String,
                         appIdentifier: String) {
  let command = RubyCommand(commandID: "", methodName: "update_app_identifier", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                       RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                       RubyCommand.Argument(name: "app_identifier", value: appIdentifier)])
  _ = runner.executeCommand(command)
}
func updateFastlane(nightly: Bool = false,
                    noUpdate: Bool = false,
                    tools: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "update_fastlane", className: nil, args: [RubyCommand.Argument(name: "nightly", value: nightly),
                                                                                                 RubyCommand.Argument(name: "no_update", value: noUpdate),
                                                                                                 RubyCommand.Argument(name: "tools", value: tools)])
  _ = runner.executeCommand(command)
}
func updateIcloudContainerIdentifiers(entitlementsFile: String,
                                      icloudContainerIdentifiers: String) {
  let command = RubyCommand(commandID: "", methodName: "update_icloud_container_identifiers", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile),
                                                                                                                     RubyCommand.Argument(name: "icloud_container_identifiers", value: icloudContainerIdentifiers)])
  _ = runner.executeCommand(command)
}
func updateInfoPlist(xcodeproj: String? = nil,
                     plistPath: String? = nil,
                     scheme: String? = nil,
                     appIdentifier: String? = nil,
                     displayName: String? = nil,
                     block: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "update_info_plist", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                   RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                   RubyCommand.Argument(name: "scheme", value: scheme),
                                                                                                   RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
                                                                                                   RubyCommand.Argument(name: "display_name", value: displayName),
                                                                                                   RubyCommand.Argument(name: "block", value: block)])
  _ = runner.executeCommand(command)
}
func updatePlist(plistPath: String? = nil,
                 block: String) {
  let command = RubyCommand(commandID: "", methodName: "update_plist", className: nil, args: [RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                              RubyCommand.Argument(name: "block", value: block)])
  _ = runner.executeCommand(command)
}
func updateProjectCodeSigning(path: String,
                              udid: String? = nil,
                              uuid: String) {
  let command = RubyCommand(commandID: "", methodName: "update_project_code_signing", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                             RubyCommand.Argument(name: "udid", value: udid),
                                                                                                             RubyCommand.Argument(name: "uuid", value: uuid)])
  _ = runner.executeCommand(command)
}
func updateProjectProvisioning(xcodeproj: String? = nil,
                               profile: String,
                               targetFilter: String? = nil,
                               buildConfigurationFilter: String? = nil,
                               buildConfiguration: String? = nil,
                               certificate: String = "/tmp/AppleIncRootCertificate.cer",
                               codeSigningIdentity: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "update_project_provisioning", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj),
                                                                                                             RubyCommand.Argument(name: "profile", value: profile),
                                                                                                             RubyCommand.Argument(name: "target_filter", value: targetFilter),
                                                                                                             RubyCommand.Argument(name: "build_configuration_filter", value: buildConfigurationFilter),
                                                                                                             RubyCommand.Argument(name: "build_configuration", value: buildConfiguration),
                                                                                                             RubyCommand.Argument(name: "certificate", value: certificate),
                                                                                                             RubyCommand.Argument(name: "code_signing_identity", value: codeSigningIdentity)])
  _ = runner.executeCommand(command)
}
func updateProjectTeam(path: String,
                       targets: [String]? = nil,
                       teamid: String) {
  let command = RubyCommand(commandID: "", methodName: "update_project_team", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                     RubyCommand.Argument(name: "targets", value: targets),
                                                                                                     RubyCommand.Argument(name: "teamid", value: teamid)])
  _ = runner.executeCommand(command)
}
func updateUrbanAirshipConfiguration(plistPath: String,
                                     developmentAppKey: String? = nil,
                                     developmentAppSecret: String? = nil,
                                     productionAppKey: String? = nil,
                                     productionAppSecret: String? = nil,
                                     detectProvisioningMode: Bool? = nil) {
  let command = RubyCommand(commandID: "", methodName: "update_urban_airship_configuration", className: nil, args: [RubyCommand.Argument(name: "plist_path", value: plistPath),
                                                                                                                    RubyCommand.Argument(name: "development_app_key", value: developmentAppKey),
                                                                                                                    RubyCommand.Argument(name: "development_app_secret", value: developmentAppSecret),
                                                                                                                    RubyCommand.Argument(name: "production_app_key", value: productionAppKey),
                                                                                                                    RubyCommand.Argument(name: "production_app_secret", value: productionAppSecret),
                                                                                                                    RubyCommand.Argument(name: "detect_provisioning_mode", value: detectProvisioningMode)])
  _ = runner.executeCommand(command)
}
func updateUrlSchemes(path: String,
                      urlSchemes: String? = nil,
                      updateUrlSchemes: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "update_url_schemes", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                    RubyCommand.Argument(name: "url_schemes", value: urlSchemes),
                                                                                                    RubyCommand.Argument(name: "update_url_schemes", value: updateUrlSchemes)])
  _ = runner.executeCommand(command)
}
func uploadSymbolsToCrashlytics(dsymPath: String = "./spec/fixtures/dSYM/Themoji2.dSYM",
                                dsymPaths: [String]? = nil,
                                apiToken: String? = nil,
                                gspPath: String? = nil,
                                binaryPath: String? = nil,
                                platform: String = "ios",
                                dsymWorkerThreads: Int = 1) {
  let command = RubyCommand(commandID: "", methodName: "upload_symbols_to_crashlytics", className: nil, args: [RubyCommand.Argument(name: "dsym_path", value: dsymPath),
                                                                                                               RubyCommand.Argument(name: "dsym_paths", value: dsymPaths),
                                                                                                               RubyCommand.Argument(name: "api_token", value: apiToken),
                                                                                                               RubyCommand.Argument(name: "gsp_path", value: gspPath),
                                                                                                               RubyCommand.Argument(name: "binary_path", value: binaryPath),
                                                                                                               RubyCommand.Argument(name: "platform", value: platform),
                                                                                                               RubyCommand.Argument(name: "dsym_worker_threads", value: dsymWorkerThreads)])
  _ = runner.executeCommand(command)
}
func uploadSymbolsToSentry(apiHost: String = "https://app.getsentry.com/api/0",
                           apiKey: String? = nil,
                           authToken: String? = nil,
                           orgSlug: String,
                           projectSlug: String,
                           dsymPath: String? = nil,
                           dsymPaths: String? = nil) {
  let command = RubyCommand(commandID: "", methodName: "upload_symbols_to_sentry", className: nil, args: [RubyCommand.Argument(name: "api_host", value: apiHost),
                                                                                                          RubyCommand.Argument(name: "api_key", value: apiKey),
                                                                                                          RubyCommand.Argument(name: "auth_token", value: authToken),
                                                                                                          RubyCommand.Argument(name: "org_slug", value: orgSlug),
                                                                                                          RubyCommand.Argument(name: "project_slug", value: projectSlug),
                                                                                                          RubyCommand.Argument(name: "dsym_path", value: dsymPath),
                                                                                                          RubyCommand.Argument(name: "dsym_paths", value: dsymPaths)])
  _ = runner.executeCommand(command)
}
func uploadToAppStore(username: String,
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
                      automaticRelease: Bool = false,
                      autoReleaseDate: String? = nil,
                      phasedRelease: Bool = false,
                      resetRatings: Bool = false,
                      priceTier: String? = nil,
                      appRatingConfigPath: String? = nil,
                      submissionInformation: String? = nil,
                      teamId: String? = nil,
                      teamName: String? = nil,
                      devPortalTeamId: String? = nil,
                      devPortalTeamName: String? = nil,
                      itcProvider: String? = nil,
                      runPrecheckBeforeSubmit: Bool = true,
                      precheckDefaultRuleLevel: String = "warn",
                      individualMetadataItems: [String] = [],
                      appIcon: String? = nil,
                      appleWatchAppIcon: String? = nil,
                      copyright: String? = nil,
                      primaryCategory: String? = nil,
                      secondaryCategory: String? = nil,
                      primaryFirstSubCategory: String? = nil,
                      primarySecondSubCategory: String? = nil,
                      secondaryFirstSubCategory: String? = nil,
                      secondarySecondSubCategory: String? = nil,
                      tradeRepresentativeContactInformation: [String : Any]? = nil,
                      appReviewInformation: [String : Any]? = nil,
                      description: String? = nil,
                      name: String? = nil,
                      subtitle: [String : Any]? = nil,
                      keywords: [String : Any]? = nil,
                      promotionalText: [String : Any]? = nil,
                      releaseNotes: String? = nil,
                      privacyUrl: String? = nil,
                      supportUrl: String? = nil,
                      marketingUrl: String? = nil,
                      languages: [String]? = nil,
                      ignoreLanguageDirectoryValidation: Bool = false,
                      precheckIncludeInAppPurchases: Bool = true,
                      app: String) {
  let command = RubyCommand(commandID: "", methodName: "upload_to_app_store", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
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
                                                                                                     RubyCommand.Argument(name: "description", value: description),
                                                                                                     RubyCommand.Argument(name: "name", value: name),
                                                                                                     RubyCommand.Argument(name: "subtitle", value: subtitle),
                                                                                                     RubyCommand.Argument(name: "keywords", value: keywords),
                                                                                                     RubyCommand.Argument(name: "promotional_text", value: promotionalText),
                                                                                                     RubyCommand.Argument(name: "release_notes", value: releaseNotes),
                                                                                                     RubyCommand.Argument(name: "privacy_url", value: privacyUrl),
                                                                                                     RubyCommand.Argument(name: "support_url", value: supportUrl),
                                                                                                     RubyCommand.Argument(name: "marketing_url", value: marketingUrl),
                                                                                                     RubyCommand.Argument(name: "languages", value: languages),
                                                                                                     RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation),
                                                                                                     RubyCommand.Argument(name: "precheck_include_in_app_purchases", value: precheckIncludeInAppPurchases),
                                                                                                     RubyCommand.Argument(name: "app", value: app)])
  _ = runner.executeCommand(command)
}
func uploadToPlayStore(packageName: String,
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
                       versionCodesToRetain: [String]? = nil) {
  let command = RubyCommand(commandID: "", methodName: "upload_to_play_store", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName),
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
                                                                                                      RubyCommand.Argument(name: "version_codes_to_retain", value: versionCodesToRetain)])
  _ = runner.executeCommand(command)
}
func uploadToTestflight(username: String,
                        appIdentifier: String? = nil,
                        appPlatform: String = "ios",
                        appleId: String? = nil,
                        ipa: String? = nil,
                        demoAccountRequired: Bool = false,
                        betaAppReviewInfo: [String : Any]? = nil,
                        localizedAppInfo: [String : Any]? = nil,
                        betaAppDescription: String? = nil,
                        betaAppFeedbackEmail: String? = nil,
                        localizedBuildInfo: [String : Any]? = nil,
                        changelog: String? = nil,
                        skipSubmission: Bool = false,
                        skipWaitingForBuildProcessing: Bool = false,
                        updateBuildInfoOnUpload: Bool = false,
                        distributeExternal: Bool = false,
                        notifyExternalTesters: Bool = true,
                        firstName: String? = nil,
                        lastName: String? = nil,
                        email: String? = nil,
                        testersFilePath: String = "./testers.csv",
                        groups: [String]? = nil,
                        teamId: String? = nil,
                        teamName: String? = nil,
                        devPortalTeamId: String? = nil,
                        itcProvider: String? = nil,
                        waitProcessingInterval: Int = 30,
                        waitForUploadedBuild: Bool = false,
                        rejectBuildWaitingForReview: Bool = false) {
  let command = RubyCommand(commandID: "", methodName: "upload_to_testflight", className: nil, args: [RubyCommand.Argument(name: "username", value: username),
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
                                                                                                      RubyCommand.Argument(name: "distribute_external", value: distributeExternal),
                                                                                                      RubyCommand.Argument(name: "notify_external_testers", value: notifyExternalTesters),
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
func verifyBuild(provisioningType: String? = nil,
                 provisioningUuid: String? = nil,
                 teamIdentifier: String? = nil,
                 teamName: String? = nil,
                 appName: String? = nil,
                 bundleIdentifier: String? = nil,
                 ipaPath: String? = nil,
                 buildPath: String? = nil) {
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
func verifyPodKeys() {
  let command = RubyCommand(commandID: "", methodName: "verify_pod_keys", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func verifyXcode(xcodePath: String) {
  let command = RubyCommand(commandID: "", methodName: "verify_xcode", className: nil, args: [RubyCommand.Argument(name: "xcode_path", value: xcodePath)])
  _ = runner.executeCommand(command)
}
func versionBumpPodspec(path: String,
                        bumpType: String = "patch",
                        versionNumber: String? = nil,
                        versionAppendix: String? = nil,
                        requireVariablePrefix: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "version_bump_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                      RubyCommand.Argument(name: "bump_type", value: bumpType),
                                                                                                      RubyCommand.Argument(name: "version_number", value: versionNumber),
                                                                                                      RubyCommand.Argument(name: "version_appendix", value: versionAppendix),
                                                                                                      RubyCommand.Argument(name: "require_variable_prefix", value: requireVariablePrefix)])
  _ = runner.executeCommand(command)
}
func versionGetPodspec(path: String,
                       requireVariablePrefix: Bool = true) {
  let command = RubyCommand(commandID: "", methodName: "version_get_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path),
                                                                                                     RubyCommand.Argument(name: "require_variable_prefix", value: requireVariablePrefix)])
  _ = runner.executeCommand(command)
}
func xcarchive() {
  let command = RubyCommand(commandID: "", methodName: "xcarchive", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcbuild() {
  let command = RubyCommand(commandID: "", methodName: "xcbuild", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcclean() {
  let command = RubyCommand(commandID: "", methodName: "xcclean", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcexport() {
  let command = RubyCommand(commandID: "", methodName: "xcexport", className: nil, args: [])
  _ = runner.executeCommand(command)
}
@discardableResult func xcodeInstall(version: String,
                                     username: String,
                                     teamId: String? = nil) -> String {
  let command = RubyCommand(commandID: "", methodName: "xcode_install", className: nil, args: [RubyCommand.Argument(name: "version", value: version),
                                                                                               RubyCommand.Argument(name: "username", value: username),
                                                                                               RubyCommand.Argument(name: "team_id", value: teamId)])
  return runner.executeCommand(command)
}
func xcodeSelect() {
  let command = RubyCommand(commandID: "", methodName: "xcode_select", className: nil, args: [])
  _ = runner.executeCommand(command)
}
@discardableResult func xcodeServerGetAssets(host: String,
                                             botName: String,
                                             integrationNumber: String? = nil,
                                             username: String = "",
                                             password: String? = nil,
                                             targetFolder: String = "./xcs_assets",
                                             keepAllAssets: Bool = false,
                                             trustSelfSignedCerts: Bool = true) -> [String] {
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
func xcodebuild() {
  let command = RubyCommand(commandID: "", methodName: "xcodebuild", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcov(workspace: String? = nil,
          project: String? = nil,
          scheme: String? = nil,
          configuration: String? = nil,
          sourceDirectory: String? = nil,
          derivedDataPath: String? = nil,
          outputDirectory: String = "./xcov_report",
          htmlReport: Bool = true,
          markdownReport: Bool = false,
          jsonReport: Bool = false,
          minimumCoveragePercentage: Int = 0,
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
          ideFoundationPath: String = "/Applications/Xcode-10.1.app/Contents/Developer/../Frameworks/IDEFoundation.framework/Versions/A/IDEFoundation",
          legacySupport: Bool = false) {
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
func xctest() {
  let command = RubyCommand(commandID: "", methodName: "xctest", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xctool() {
  let command = RubyCommand(commandID: "", methodName: "xctool", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcversion(version: String) {
  let command = RubyCommand(commandID: "", methodName: "xcversion", className: nil, args: [RubyCommand.Argument(name: "version", value: version)])
  _ = runner.executeCommand(command)
}
@discardableResult func zip(path: String,
                            outputPath: String? = nil,
                            verbose: Bool = true,
                            password: String? = nil,
                            symlinks: Bool = false) -> String {
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

func parseDictionary(fromString: String, function: String = #function) -> [String : String] {
    return parseDictionaryHelper(fromString: fromString, function: function) as! [String: String]
}

func parseDictionary(fromString: String, function: String = #function) -> [String : Any] {
    return parseDictionaryHelper(fromString: fromString, function: function)
}

func parseDictionaryHelper(fromString: String, function: String = #function) -> [String : Any] {
  verbose(message: "parsing an Array from data: \(fromString), from function: \(function)")
  let potentialDictionary: String
  if fromString.count < 2 {
    verbose(message: "Dictionary value too small: \(fromString), from function: \(function)")
    potentialDictionary = "{}"
  } else {
      potentialDictionary = fromString
  }
  let dictionary: [String : Any] = try! JSONSerialization.jsonObject(with: potentialDictionary.data(using: .utf8)!, options: []) as! [String : Any]
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
      
let deliverfile: Deliverfile = Deliverfile()
let gymfile: Gymfile = Gymfile()
let matchfile: Matchfile = Matchfile()
let precheckfile: Precheckfile = Precheckfile()
let scanfile: Scanfile = Scanfile()
let screengrabfile: Screengrabfile = Screengrabfile()
let snapshotfile: Snapshotfile = Snapshotfile()
// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.42]
