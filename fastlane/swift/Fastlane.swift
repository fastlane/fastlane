func adb(serial: String = "", command: String, adbPath: String = "adb") -> String {
  let command = RubyCommand(commandID: "", methodName: "adb", className: nil, args: [RubyCommand.Argument(name: "serial", value: serial), RubyCommand.Argument(name: "command", value: command), RubyCommand.Argument(name: "adb_path", value: adbPath)])
  return runner.executeCommand(command) as! String
}
func adbDevices(adbPath: String = "adb") {
  let command = RubyCommand(commandID: "", methodName: "adb_devices", className: nil, args: [RubyCommand.Argument(name: "adb_path", value: adbPath)])
  _ = runner.executeCommand(command)
}
func addExtraPlatforms(platforms: String = "") {
  let command = RubyCommand(commandID: "", methodName: "add_extra_platforms", className: nil, args: [RubyCommand.Argument(name: "platforms", value: platforms)])
  _ = runner.executeCommand(command)
}
func addGitTag(tag: String, grouping: String = "builds", prefix🚀: String = "", buildNumber: String, message: String, commit: String, force: String = "false", sign: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "add_git_tag", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag), RubyCommand.Argument(name: "grouping", value: grouping), RubyCommand.Argument(name: "prefix", value: prefix🚀), RubyCommand.Argument(name: "build_number", value: buildNumber), RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "commit", value: commit), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "sign", value: sign)])
  _ = runner.executeCommand(command)
}
func appStoreBuildNumber(initialBuildNumber: String = "1", appIdentifier: String, username: String, teamId: String, live: String = "true", version: String, teamName: String) {
  let command = RubyCommand(commandID: "", methodName: "app_store_build_number", className: nil, args: [RubyCommand.Argument(name: "initial_build_number", value: initialBuildNumber), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "live", value: live), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "team_name", value: teamName)])
  _ = runner.executeCommand(command)
}
func appaloosa(binary: String, apiToken: String, storeId: String, groupIds: String = "", screenshots: String, locale: String = "en-US", device: String, description: String) {
  let command = RubyCommand(commandID: "", methodName: "appaloosa", className: nil, args: [RubyCommand.Argument(name: "binary", value: binary), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "store_id", value: storeId), RubyCommand.Argument(name: "group_ids", value: groupIds), RubyCommand.Argument(name: "screenshots", value: screenshots), RubyCommand.Argument(name: "locale", value: locale), RubyCommand.Argument(name: "device", value: device), RubyCommand.Argument(name: "description", value: description)])
  _ = runner.executeCommand(command)
}
func appetize(apiToken: String, url: String, platform: String = "ios", path: String, publicKey: String, note: String) {
  let command = RubyCommand(commandID: "", methodName: "appetize", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "url", value: url), RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "public_key", value: publicKey), RubyCommand.Argument(name: "note", value: note)])
  _ = runner.executeCommand(command)
}
func appetizeViewingUrlGenerator(publicKey: String, baseUrl: String = "https://appetize.io/embed", device: String = "iphone5s", scale: String, orientation: String = "portrait", language: String, color: String = "black", launchUrl: String, osVersion: String, params: String, proxy: String) {
  let command = RubyCommand(commandID: "", methodName: "appetize_viewing_url_generator", className: nil, args: [RubyCommand.Argument(name: "public_key", value: publicKey), RubyCommand.Argument(name: "base_url", value: baseUrl), RubyCommand.Argument(name: "device", value: device), RubyCommand.Argument(name: "scale", value: scale), RubyCommand.Argument(name: "orientation", value: orientation), RubyCommand.Argument(name: "language", value: language), RubyCommand.Argument(name: "color", value: color), RubyCommand.Argument(name: "launch_url", value: launchUrl), RubyCommand.Argument(name: "os_version", value: osVersion), RubyCommand.Argument(name: "params", value: params), RubyCommand.Argument(name: "proxy", value: proxy)])
  _ = runner.executeCommand(command)
}
func appium(platform: String, specPath: String, appPath: String, invokeAppiumServer: String = "true", host: String = "0.0.0.0", port: String = "4723", appiumPath: String, caps: String) {
  let command = RubyCommand(commandID: "", methodName: "appium", className: nil, args: [RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "spec_path", value: specPath), RubyCommand.Argument(name: "app_path", value: appPath), RubyCommand.Argument(name: "invoke_appium_server", value: invokeAppiumServer), RubyCommand.Argument(name: "host", value: host), RubyCommand.Argument(name: "port", value: port), RubyCommand.Argument(name: "appium_path", value: appiumPath), RubyCommand.Argument(name: "caps", value: caps)])
  _ = runner.executeCommand(command)
}
func appledoc(input: String, output: String, templates: String, docsetInstallPath: String, include: String, ignore: String, excludeOutput: String, indexDesc: String, projectName: String, projectVersion: String, projectCompany: String, companyId: String, createHtml: String = "false", createDocset: String = "false", installDocset: String = "false", publishDocset: String = "false", htmlAnchors: String, cleanOutput: String = "false", docsetBundleId: String, docsetBundleName: String, docsetDesc: String, docsetCopyright: String, docsetFeedName: String, docsetFeedUrl: String, docsetFeedFormats: String, docsetPackageUrl: String, docsetFallbackUrl: String, docsetPublisherId: String, docsetPublisherName: String, docsetMinXcodeVersion: String, docsetPlatformFamily: String, docsetCertIssuer: String, docsetCertSigner: String, docsetBundleFilename: String, docsetAtomFilename: String, docsetXmlFilename: String, docsetPackageFilename: String, options: String, crossrefFormat: String, exitThreshold: String = "2", docsSectionTitle: String, warnings: String, logformat: String, verbose: String) {
  let command = RubyCommand(commandID: "", methodName: "appledoc", className: nil, args: [RubyCommand.Argument(name: "input", value: input), RubyCommand.Argument(name: "output", value: output), RubyCommand.Argument(name: "templates", value: templates), RubyCommand.Argument(name: "docset_install_path", value: docsetInstallPath), RubyCommand.Argument(name: "include", value: include), RubyCommand.Argument(name: "ignore", value: ignore), RubyCommand.Argument(name: "exclude_output", value: excludeOutput), RubyCommand.Argument(name: "index_desc", value: indexDesc), RubyCommand.Argument(name: "project_name", value: projectName), RubyCommand.Argument(name: "project_version", value: projectVersion), RubyCommand.Argument(name: "project_company", value: projectCompany), RubyCommand.Argument(name: "company_id", value: companyId), RubyCommand.Argument(name: "create_html", value: createHtml), RubyCommand.Argument(name: "create_docset", value: createDocset), RubyCommand.Argument(name: "install_docset", value: installDocset), RubyCommand.Argument(name: "publish_docset", value: publishDocset), RubyCommand.Argument(name: "html_anchors", value: htmlAnchors), RubyCommand.Argument(name: "clean_output", value: cleanOutput), RubyCommand.Argument(name: "docset_bundle_id", value: docsetBundleId), RubyCommand.Argument(name: "docset_bundle_name", value: docsetBundleName), RubyCommand.Argument(name: "docset_desc", value: docsetDesc), RubyCommand.Argument(name: "docset_copyright", value: docsetCopyright), RubyCommand.Argument(name: "docset_feed_name", value: docsetFeedName), RubyCommand.Argument(name: "docset_feed_url", value: docsetFeedUrl), RubyCommand.Argument(name: "docset_feed_formats", value: docsetFeedFormats), RubyCommand.Argument(name: "docset_package_url", value: docsetPackageUrl), RubyCommand.Argument(name: "docset_fallback_url", value: docsetFallbackUrl), RubyCommand.Argument(name: "docset_publisher_id", value: docsetPublisherId), RubyCommand.Argument(name: "docset_publisher_name", value: docsetPublisherName), RubyCommand.Argument(name: "docset_min_xcode_version", value: docsetMinXcodeVersion), RubyCommand.Argument(name: "docset_platform_family", value: docsetPlatformFamily), RubyCommand.Argument(name: "docset_cert_issuer", value: docsetCertIssuer), RubyCommand.Argument(name: "docset_cert_signer", value: docsetCertSigner), RubyCommand.Argument(name: "docset_bundle_filename", value: docsetBundleFilename), RubyCommand.Argument(name: "docset_atom_filename", value: docsetAtomFilename), RubyCommand.Argument(name: "docset_xml_filename", value: docsetXmlFilename), RubyCommand.Argument(name: "docset_package_filename", value: docsetPackageFilename), RubyCommand.Argument(name: "options", value: options), RubyCommand.Argument(name: "crossref_format", value: crossrefFormat), RubyCommand.Argument(name: "exit_threshold", value: exitThreshold), RubyCommand.Argument(name: "docs_section_title", value: docsSectionTitle), RubyCommand.Argument(name: "warnings", value: warnings), RubyCommand.Argument(name: "logformat", value: logformat), RubyCommand.Argument(name: "verbose", value: verbose)])
  _ = runner.executeCommand(command)
}
func appstore(username: String, appIdentifier: String, app: String, editLive: String = "false", ipa: String, pkg: String, platform: String = "ios", metadataPath: String, screenshotsPath: String, skipBinaryUpload: String = "false", skipScreenshots: String = "false", appVersion: String, skipMetadata: String = "false", skipAppVersionUpdate: String = "false", force: String = "false", submitForReview: String = "false", automaticRelease: String = "false", phasedRelease: String, priceTier: String, buildNumber: String, appRatingConfigPath: String, submissionInformation: String, teamId: String, teamName: String, devPortalTeamId: String, devPortalTeamName: String, itcProvider: String, overwriteScreenshots: String = "false", runPrecheckBeforeSubmit: String = "true", precheckDefaultRuleLevel: String = "warn", appIcon: String, appleWatchAppIcon: String, copyright: String, primaryCategory: String, secondaryCategory: String, primaryFirstSubCategory: String, primarySecondSubCategory: String, secondaryFirstSubCategory: String, secondarySecondSubCategory: String, tradeRepresentativeContactInformation: String, appReviewInformation: String, description: String, name: String, subtitle: String, keywords: String, promotionalText: String, releaseNotes: String, privacyUrl: String, supportUrl: String, marketingUrl: String, languages: String, ignoreLanguageDirectoryValidation: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "appstore", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "app", value: app), RubyCommand.Argument(name: "edit_live", value: editLive), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "pkg", value: pkg), RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "metadata_path", value: metadataPath), RubyCommand.Argument(name: "screenshots_path", value: screenshotsPath), RubyCommand.Argument(name: "skip_binary_upload", value: skipBinaryUpload), RubyCommand.Argument(name: "skip_screenshots", value: skipScreenshots), RubyCommand.Argument(name: "app_version", value: appVersion), RubyCommand.Argument(name: "skip_metadata", value: skipMetadata), RubyCommand.Argument(name: "skip_app_version_update", value: skipAppVersionUpdate), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "submit_for_review", value: submitForReview), RubyCommand.Argument(name: "automatic_release", value: automaticRelease), RubyCommand.Argument(name: "phased_release", value: phasedRelease), RubyCommand.Argument(name: "price_tier", value: priceTier), RubyCommand.Argument(name: "build_number", value: buildNumber), RubyCommand.Argument(name: "app_rating_config_path", value: appRatingConfigPath), RubyCommand.Argument(name: "submission_information", value: submissionInformation), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId), RubyCommand.Argument(name: "dev_portal_team_name", value: devPortalTeamName), RubyCommand.Argument(name: "itc_provider", value: itcProvider), RubyCommand.Argument(name: "overwrite_screenshots", value: overwriteScreenshots), RubyCommand.Argument(name: "run_precheck_before_submit", value: runPrecheckBeforeSubmit), RubyCommand.Argument(name: "precheck_default_rule_level", value: precheckDefaultRuleLevel), RubyCommand.Argument(name: "app_icon", value: appIcon), RubyCommand.Argument(name: "apple_watch_app_icon", value: appleWatchAppIcon), RubyCommand.Argument(name: "copyright", value: copyright), RubyCommand.Argument(name: "primary_category", value: primaryCategory), RubyCommand.Argument(name: "secondary_category", value: secondaryCategory), RubyCommand.Argument(name: "primary_first_sub_category", value: primaryFirstSubCategory), RubyCommand.Argument(name: "primary_second_sub_category", value: primarySecondSubCategory), RubyCommand.Argument(name: "secondary_first_sub_category", value: secondaryFirstSubCategory), RubyCommand.Argument(name: "secondary_second_sub_category", value: secondarySecondSubCategory), RubyCommand.Argument(name: "trade_representative_contact_information", value: tradeRepresentativeContactInformation), RubyCommand.Argument(name: "app_review_information", value: appReviewInformation), RubyCommand.Argument(name: "description", value: description), RubyCommand.Argument(name: "name", value: name), RubyCommand.Argument(name: "subtitle", value: subtitle), RubyCommand.Argument(name: "keywords", value: keywords), RubyCommand.Argument(name: "promotional_text", value: promotionalText), RubyCommand.Argument(name: "release_notes", value: releaseNotes), RubyCommand.Argument(name: "privacy_url", value: privacyUrl), RubyCommand.Argument(name: "support_url", value: supportUrl), RubyCommand.Argument(name: "marketing_url", value: marketingUrl), RubyCommand.Argument(name: "languages", value: languages), RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation)])
  _ = runner.executeCommand(command)
}
func apteligent(dsym: String, appId: String, apiKey: String) {
  let command = RubyCommand(commandID: "", methodName: "apteligent", className: nil, args: [RubyCommand.Argument(name: "dsym", value: dsym), RubyCommand.Argument(name: "app_id", value: appId), RubyCommand.Argument(name: "api_key", value: apiKey)])
  _ = runner.executeCommand(command)
}
func artifactory(file: String, repo: String, repoPath: String, endpoint: String, username: String, password: String, properties: String = "{}", sslPemFile: String, sslVerify: String = "true", proxyUsername: String, proxyPassword: String, proxyAddress: String, proxyPort: String) {
  let command = RubyCommand(commandID: "", methodName: "artifactory", className: nil, args: [RubyCommand.Argument(name: "file", value: file), RubyCommand.Argument(name: "repo", value: repo), RubyCommand.Argument(name: "repo_path", value: repoPath), RubyCommand.Argument(name: "endpoint", value: endpoint), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "properties", value: properties), RubyCommand.Argument(name: "ssl_pem_file", value: sslPemFile), RubyCommand.Argument(name: "ssl_verify", value: sslVerify), RubyCommand.Argument(name: "proxy_username", value: proxyUsername), RubyCommand.Argument(name: "proxy_password", value: proxyPassword), RubyCommand.Argument(name: "proxy_address", value: proxyAddress), RubyCommand.Argument(name: "proxy_port", value: proxyPort)])
  _ = runner.executeCommand(command)
}
func automaticCodeSigning(path: String, useAutomaticSigning: String = "false", teamId: String, targets: String) {
  let command = RubyCommand(commandID: "", methodName: "automatic_code_signing", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "use_automatic_signing", value: useAutomaticSigning), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "targets", value: targets)])
  _ = runner.executeCommand(command)
}
func backupFile(path: String) {
  let command = RubyCommand(commandID: "", methodName: "backup_file", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func backupXcarchive(xcarchive: String, destination: String, zip: String = "true", versioned: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "backup_xcarchive", className: nil, args: [RubyCommand.Argument(name: "xcarchive", value: xcarchive), RubyCommand.Argument(name: "destination", value: destination), RubyCommand.Argument(name: "zip", value: zip), RubyCommand.Argument(name: "versioned", value: versioned)])
  _ = runner.executeCommand(command)
}
func badge(dark: String, custom: String, noBadge: String, shield: String, alpha: String, path: String = ".", shieldIoTimeout: String, glob: String, alphaChannel: String, shieldGravity: String, shieldNoResize: String) {
  let command = RubyCommand(commandID: "", methodName: "badge", className: nil, args: [RubyCommand.Argument(name: "dark", value: dark), RubyCommand.Argument(name: "custom", value: custom), RubyCommand.Argument(name: "no_badge", value: noBadge), RubyCommand.Argument(name: "shield", value: shield), RubyCommand.Argument(name: "alpha", value: alpha), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "shield_io_timeout", value: shieldIoTimeout), RubyCommand.Argument(name: "glob", value: glob), RubyCommand.Argument(name: "alpha_channel", value: alphaChannel), RubyCommand.Argument(name: "shield_gravity", value: shieldGravity), RubyCommand.Argument(name: "shield_no_resize", value: shieldNoResize)])
  _ = runner.executeCommand(command)
}
func buildAndUploadToAppetize(xcodebuild: String = "{}", scheme: String, apiToken: String) {
  let command = RubyCommand(commandID: "", methodName: "build_and_upload_to_appetize", className: nil, args: [RubyCommand.Argument(name: "xcodebuild", value: xcodebuild), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "api_token", value: apiToken)])
  _ = runner.executeCommand(command)
}
func bundleInstall(binstubs: String, clean: String = "false", fullIndex: String = "false", gemfile: String, jobs: String, local: String = "false", deployment: String = "false", noCache: String = "false", noPrune: String = "false", path: String, system: String = "false", quiet: String = "false", retry: String, shebang: String, standalone: String, trustPolicy: String, without: String, with: String) {
  let command = RubyCommand(commandID: "", methodName: "bundle_install", className: nil, args: [RubyCommand.Argument(name: "binstubs", value: binstubs), RubyCommand.Argument(name: "clean", value: clean), RubyCommand.Argument(name: "full_index", value: fullIndex), RubyCommand.Argument(name: "gemfile", value: gemfile), RubyCommand.Argument(name: "jobs", value: jobs), RubyCommand.Argument(name: "local", value: local), RubyCommand.Argument(name: "deployment", value: deployment), RubyCommand.Argument(name: "no_cache", value: noCache), RubyCommand.Argument(name: "no_prune", value: noPrune), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "system", value: system), RubyCommand.Argument(name: "quiet", value: quiet), RubyCommand.Argument(name: "retry", value: retry), RubyCommand.Argument(name: "shebang", value: shebang), RubyCommand.Argument(name: "standalone", value: standalone), RubyCommand.Argument(name: "trust_policy", value: trustPolicy), RubyCommand.Argument(name: "without", value: without), RubyCommand.Argument(name: "with", value: with)])
  _ = runner.executeCommand(command)
}
func carthage(command: String = "bootstrap", dependencies: [String] = [], useSsh: String, useSubmodules: String, useBinaries: String, noBuild: String, noSkipCurrent: String, derivedData: String, verbose: String, platform: String, cacheBuilds: String = "false", frameworks: [String] = [], output: String, configuration: String, toolchain: String, projectDirectory: String) {
  let command = RubyCommand(commandID: "", methodName: "carthage", className: nil, args: [RubyCommand.Argument(name: "command", value: command), RubyCommand.Argument(name: "dependencies", value: dependencies), RubyCommand.Argument(name: "use_ssh", value: useSsh), RubyCommand.Argument(name: "use_submodules", value: useSubmodules), RubyCommand.Argument(name: "use_binaries", value: useBinaries), RubyCommand.Argument(name: "no_build", value: noBuild), RubyCommand.Argument(name: "no_skip_current", value: noSkipCurrent), RubyCommand.Argument(name: "derived_data", value: derivedData), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "cache_builds", value: cacheBuilds), RubyCommand.Argument(name: "frameworks", value: frameworks), RubyCommand.Argument(name: "output", value: output), RubyCommand.Argument(name: "configuration", value: configuration), RubyCommand.Argument(name: "toolchain", value: toolchain), RubyCommand.Argument(name: "project_directory", value: projectDirectory)])
  _ = runner.executeCommand(command)
}
func cert(development: String = "false", force: String = "false", username: String, teamId: String, teamName: String, outputPath: String = ".", keychainPath: String = "/Users/jliebowitz/Library/Keychains/login.keychain-db", keychainPassword: String, platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "cert", className: nil, args: [RubyCommand.Argument(name: "development", value: development), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "output_path", value: outputPath), RubyCommand.Argument(name: "keychain_path", value: keychainPath), RubyCommand.Argument(name: "keychain_password", value: keychainPassword), RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
func changelogFromGitCommits(between: String, commitsCount: String, pretty: String = "%B", dateFormat: String, ancestryPath: String = "false", tagMatchPattern: String, matchLightweightTag: String = "true", includeMerges: String, mergeCommitFiltering: String = "include_merges") -> String {
  let command = RubyCommand(commandID: "", methodName: "changelog_from_git_commits", className: nil, args: [RubyCommand.Argument(name: "between", value: between), RubyCommand.Argument(name: "commits_count", value: commitsCount), RubyCommand.Argument(name: "pretty", value: pretty), RubyCommand.Argument(name: "date_format", value: dateFormat), RubyCommand.Argument(name: "ancestry_path", value: ancestryPath), RubyCommand.Argument(name: "tag_match_pattern", value: tagMatchPattern), RubyCommand.Argument(name: "match_lightweight_tag", value: matchLightweightTag), RubyCommand.Argument(name: "include_merges", value: includeMerges), RubyCommand.Argument(name: "merge_commit_filtering", value: mergeCommitFiltering)])
  return runner.executeCommand(command) as! String
}
func chatwork(apiToken: String, message: String, roomid: String, success: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "chatwork", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "roomid", value: roomid), RubyCommand.Argument(name: "success", value: success)])
  _ = runner.executeCommand(command)
}
func cleanBuildArtifacts(excludePattern: String) {
  let command = RubyCommand(commandID: "", methodName: "clean_build_artifacts", className: nil, args: [RubyCommand.Argument(name: "exclude_pattern", value: excludePattern)])
  _ = runner.executeCommand(command)
}
func cleanCocoapodsCache(name: String) {
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
func cloc(binaryPath: String = "/usr/local/bin/cloc", excludeDir: String, outputDirectory: String = "build", sourceDirectory: String = "", xml: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "cloc", className: nil, args: [RubyCommand.Argument(name: "binary_path", value: binaryPath), RubyCommand.Argument(name: "exclude_dir", value: excludeDir), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "source_directory", value: sourceDirectory), RubyCommand.Argument(name: "xml", value: xml)])
  _ = runner.executeCommand(command)
}
func cocoapods(clean: String = "true", integrate: String = "true", repoUpdate: String = "false", silent: String = "false", verbose: String = "false", ansi: String = "true", useBundleExec: String = "true", podfile: String, errorCallback: String) {
  let command = RubyCommand(commandID: "", methodName: "cocoapods", className: nil, args: [RubyCommand.Argument(name: "clean", value: clean), RubyCommand.Argument(name: "integrate", value: integrate), RubyCommand.Argument(name: "repo_update", value: repoUpdate), RubyCommand.Argument(name: "silent", value: silent), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "ansi", value: ansi), RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec), RubyCommand.Argument(name: "podfile", value: podfile), RubyCommand.Argument(name: "error_callback", value: errorCallback)])
  _ = runner.executeCommand(command)
}
func commitGithubFile(repositoryName: String, serverUrl: String = "https://api.github.com", apiToken: String, branch: String = "master", path: String, message: String, secure: String = "true") -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "commit_github_file", className: nil, args: [RubyCommand.Argument(name: "repository_name", value: repositoryName), RubyCommand.Argument(name: "server_url", value: serverUrl), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "branch", value: branch), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "secure", value: secure)])
  return runner.executeCommand(command) as! [String : String]
}
func commitVersionBump(message: String, xcodeproj: String, force: String = "false", settings: String = "false", ignore: String) {
  let command = RubyCommand(commandID: "", methodName: "commit_version_bump", className: nil, args: [RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "xcodeproj", value: xcodeproj), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "settings", value: settings), RubyCommand.Argument(name: "ignore", value: ignore)])
  _ = runner.executeCommand(command)
}
func copyArtifacts(keepOriginal: String = "true", targetPath: String = "artifacts", artifacts: [String] = [], failOnMissing: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "copy_artifacts", className: nil, args: [RubyCommand.Argument(name: "keep_original", value: keepOriginal), RubyCommand.Argument(name: "target_path", value: targetPath), RubyCommand.Argument(name: "artifacts", value: artifacts), RubyCommand.Argument(name: "fail_on_missing", value: failOnMissing)])
  _ = runner.executeCommand(command)
}
func crashlytics(ipaPath: String, apkPath: String, crashlyticsPath: String, apiToken: String, buildSecret: String, notesPath: String, notes: String, groups: String, emails: String, notifications: String = "true", debug: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "crashlytics", className: nil, args: [RubyCommand.Argument(name: "ipa_path", value: ipaPath), RubyCommand.Argument(name: "apk_path", value: apkPath), RubyCommand.Argument(name: "crashlytics_path", value: crashlyticsPath), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "build_secret", value: buildSecret), RubyCommand.Argument(name: "notes_path", value: notesPath), RubyCommand.Argument(name: "notes", value: notes), RubyCommand.Argument(name: "groups", value: groups), RubyCommand.Argument(name: "emails", value: emails), RubyCommand.Argument(name: "notifications", value: notifications), RubyCommand.Argument(name: "debug", value: debug)])
  _ = runner.executeCommand(command)
}
func createKeychain(name: String, path: String, password: String, defaultKeychain: String = "false", unlock: String = "false", timeout: String = "300", lockWhenSleeps: String = "false", lockAfterTimeout: String = "false", addToSearchList: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "create_keychain", className: nil, args: [RubyCommand.Argument(name: "name", value: name), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "default_keychain", value: defaultKeychain), RubyCommand.Argument(name: "unlock", value: unlock), RubyCommand.Argument(name: "timeout", value: timeout), RubyCommand.Argument(name: "lock_when_sleeps", value: lockWhenSleeps), RubyCommand.Argument(name: "lock_after_timeout", value: lockAfterTimeout), RubyCommand.Argument(name: "add_to_search_list", value: addToSearchList)])
  _ = runner.executeCommand(command)
}
func createPullRequest(apiToken: String, repo: String, title: String, body: String, head: String = "swift-gen", base: String = "master", apiUrl: String = "https://api.github.com") {
  let command = RubyCommand(commandID: "", methodName: "create_pull_request", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "repo", value: repo), RubyCommand.Argument(name: "title", value: title), RubyCommand.Argument(name: "body", value: body), RubyCommand.Argument(name: "head", value: head), RubyCommand.Argument(name: "base", value: base), RubyCommand.Argument(name: "api_url", value: apiUrl)])
  _ = runner.executeCommand(command)
}
func danger(useBundleExec: String = "true", verbose: String = "false", dangerId: String, dangerfile: String, githubApiToken: String, failOnErrors: String = "false", newComment: String = "false", base: String, head: String) {
  let command = RubyCommand(commandID: "", methodName: "danger", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "danger_id", value: dangerId), RubyCommand.Argument(name: "dangerfile", value: dangerfile), RubyCommand.Argument(name: "github_api_token", value: githubApiToken), RubyCommand.Argument(name: "fail_on_errors", value: failOnErrors), RubyCommand.Argument(name: "new_comment", value: newComment), RubyCommand.Argument(name: "base", value: base), RubyCommand.Argument(name: "head", value: head)])
  _ = runner.executeCommand(command)
}
func deleteKeychain(name: String, keychainPath: String) {
  let command = RubyCommand(commandID: "", methodName: "delete_keychain", className: nil, args: [RubyCommand.Argument(name: "name", value: name), RubyCommand.Argument(name: "keychain_path", value: keychainPath)])
  _ = runner.executeCommand(command)
}
func deliver(username: String, appIdentifier: String, app: String, editLive: String = "false", ipa: String, pkg: String, platform: String = "ios", metadataPath: String, screenshotsPath: String, skipBinaryUpload: String = "false", skipScreenshots: String = "false", appVersion: String, skipMetadata: String = "false", skipAppVersionUpdate: String = "false", force: String = "false", submitForReview: String = "false", automaticRelease: String = "false", phasedRelease: String, priceTier: String, buildNumber: String, appRatingConfigPath: String, submissionInformation: String, teamId: String, teamName: String, devPortalTeamId: String, devPortalTeamName: String, itcProvider: String, overwriteScreenshots: String = "false", runPrecheckBeforeSubmit: String = "true", precheckDefaultRuleLevel: String = "warn", appIcon: String, appleWatchAppIcon: String, copyright: String, primaryCategory: String, secondaryCategory: String, primaryFirstSubCategory: String, primarySecondSubCategory: String, secondaryFirstSubCategory: String, secondarySecondSubCategory: String, tradeRepresentativeContactInformation: String, appReviewInformation: String, description: String, name: String, subtitle: String, keywords: String, promotionalText: String, releaseNotes: String, privacyUrl: String, supportUrl: String, marketingUrl: String, languages: String, ignoreLanguageDirectoryValidation: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "deliver", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "app", value: app), RubyCommand.Argument(name: "edit_live", value: editLive), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "pkg", value: pkg), RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "metadata_path", value: metadataPath), RubyCommand.Argument(name: "screenshots_path", value: screenshotsPath), RubyCommand.Argument(name: "skip_binary_upload", value: skipBinaryUpload), RubyCommand.Argument(name: "skip_screenshots", value: skipScreenshots), RubyCommand.Argument(name: "app_version", value: appVersion), RubyCommand.Argument(name: "skip_metadata", value: skipMetadata), RubyCommand.Argument(name: "skip_app_version_update", value: skipAppVersionUpdate), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "submit_for_review", value: submitForReview), RubyCommand.Argument(name: "automatic_release", value: automaticRelease), RubyCommand.Argument(name: "phased_release", value: phasedRelease), RubyCommand.Argument(name: "price_tier", value: priceTier), RubyCommand.Argument(name: "build_number", value: buildNumber), RubyCommand.Argument(name: "app_rating_config_path", value: appRatingConfigPath), RubyCommand.Argument(name: "submission_information", value: submissionInformation), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId), RubyCommand.Argument(name: "dev_portal_team_name", value: devPortalTeamName), RubyCommand.Argument(name: "itc_provider", value: itcProvider), RubyCommand.Argument(name: "overwrite_screenshots", value: overwriteScreenshots), RubyCommand.Argument(name: "run_precheck_before_submit", value: runPrecheckBeforeSubmit), RubyCommand.Argument(name: "precheck_default_rule_level", value: precheckDefaultRuleLevel), RubyCommand.Argument(name: "app_icon", value: appIcon), RubyCommand.Argument(name: "apple_watch_app_icon", value: appleWatchAppIcon), RubyCommand.Argument(name: "copyright", value: copyright), RubyCommand.Argument(name: "primary_category", value: primaryCategory), RubyCommand.Argument(name: "secondary_category", value: secondaryCategory), RubyCommand.Argument(name: "primary_first_sub_category", value: primaryFirstSubCategory), RubyCommand.Argument(name: "primary_second_sub_category", value: primarySecondSubCategory), RubyCommand.Argument(name: "secondary_first_sub_category", value: secondaryFirstSubCategory), RubyCommand.Argument(name: "secondary_second_sub_category", value: secondarySecondSubCategory), RubyCommand.Argument(name: "trade_representative_contact_information", value: tradeRepresentativeContactInformation), RubyCommand.Argument(name: "app_review_information", value: appReviewInformation), RubyCommand.Argument(name: "description", value: description), RubyCommand.Argument(name: "name", value: name), RubyCommand.Argument(name: "subtitle", value: subtitle), RubyCommand.Argument(name: "keywords", value: keywords), RubyCommand.Argument(name: "promotional_text", value: promotionalText), RubyCommand.Argument(name: "release_notes", value: releaseNotes), RubyCommand.Argument(name: "privacy_url", value: privacyUrl), RubyCommand.Argument(name: "support_url", value: supportUrl), RubyCommand.Argument(name: "marketing_url", value: marketingUrl), RubyCommand.Argument(name: "languages", value: languages), RubyCommand.Argument(name: "ignore_language_directory_validation", value: ignoreLanguageDirectoryValidation)])
  _ = runner.executeCommand(command)
}
func deploygate(apiToken: String, user: String, ipa: String, apk: String, message: String = "No changelog provided", distributionKey: String, releaseNote: String, disableNotify: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "deploygate", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "user", value: user), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "apk", value: apk), RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "distribution_key", value: distributionKey), RubyCommand.Argument(name: "release_note", value: releaseNote), RubyCommand.Argument(name: "disable_notify", value: disableNotify)])
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
func downloadDsyms(username: String, appIdentifier: String, teamId: String, teamName: String, platform: String, version: String, buildNumber: String) {
  let command = RubyCommand(commandID: "", methodName: "download_dsyms", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "build_number", value: buildNumber)])
  _ = runner.executeCommand(command)
}
func dsymZip(archivePath: String, dsymPath: String, all: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "dsym_zip", className: nil, args: [RubyCommand.Argument(name: "archive_path", value: archivePath), RubyCommand.Argument(name: "dsym_path", value: dsymPath), RubyCommand.Argument(name: "all", value: all)])
  _ = runner.executeCommand(command)
}
func ensureGitBranch(branch: String = "master") {
  let command = RubyCommand(commandID: "", methodName: "ensure_git_branch", className: nil, args: [RubyCommand.Argument(name: "branch", value: branch)])
  _ = runner.executeCommand(command)
}
func ensureGitStatusClean(showUncommittedChanges: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "ensure_git_status_clean", className: nil, args: [RubyCommand.Argument(name: "show_uncommitted_changes", value: showUncommittedChanges)])
  _ = runner.executeCommand(command)
}
func ensureNoDebugCode(text: String, path: String = ".", extension🚀: String, extensions: String, exclude: String, excludeDirs: String) {
  let command = RubyCommand(commandID: "", methodName: "ensure_no_debug_code", className: nil, args: [RubyCommand.Argument(name: "text", value: text), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "extension", value: extension🚀), RubyCommand.Argument(name: "extensions", value: extensions), RubyCommand.Argument(name: "exclude", value: exclude), RubyCommand.Argument(name: "exclude_dirs", value: excludeDirs)])
  _ = runner.executeCommand(command)
}
func ensureXcodeVersion(version: String) {
  let command = RubyCommand(commandID: "", methodName: "ensure_xcode_version", className: nil, args: [RubyCommand.Argument(name: "version", value: version)])
  _ = runner.executeCommand(command)
}
func erb(template: String, destination: String, placeholders: String = "{}") {
  let command = RubyCommand(commandID: "", methodName: "erb", className: nil, args: [RubyCommand.Argument(name: "template", value: template), RubyCommand.Argument(name: "destination", value: destination), RubyCommand.Argument(name: "placeholders", value: placeholders)])
  _ = runner.executeCommand(command)
}
func flock(message: String, token: String, baseUrl: String = "https://api.flock.co/hooks/sendMessage") {
  let command = RubyCommand(commandID: "", methodName: "flock", className: nil, args: [RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "token", value: token), RubyCommand.Argument(name: "base_url", value: baseUrl)])
  _ = runner.executeCommand(command)
}
func frameit(white: String, silver: String, roseGold: String, gold: String, forceDeviceType: String, useLegacyIphone5s: String = "false", useLegacyIphone6s: String = "false", path: String = "./") {
  let command = RubyCommand(commandID: "", methodName: "frameit", className: nil, args: [RubyCommand.Argument(name: "white", value: white), RubyCommand.Argument(name: "silver", value: silver), RubyCommand.Argument(name: "rose_gold", value: roseGold), RubyCommand.Argument(name: "gold", value: gold), RubyCommand.Argument(name: "force_device_type", value: forceDeviceType), RubyCommand.Argument(name: "use_legacy_iphone5s", value: useLegacyIphone5s), RubyCommand.Argument(name: "use_legacy_iphone6s", value: useLegacyIphone6s), RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func gcovr() {
  let command = RubyCommand(commandID: "", methodName: "gcovr", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func getBuildNumber(xcodeproj: String) {
  let command = RubyCommand(commandID: "", methodName: "get_build_number", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  _ = runner.executeCommand(command)
}
func getBuildNumberRepository(useHgRevisionNumber: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "get_build_number_repository", className: nil, args: [RubyCommand.Argument(name: "use_hg_revision_number", value: useHgRevisionNumber)])
  _ = runner.executeCommand(command)
}
func getGithubRelease(url: String, serverUrl: String = "https://api.github.com", version: String, apiToken: String) {
  let command = RubyCommand(commandID: "", methodName: "get_github_release", className: nil, args: [RubyCommand.Argument(name: "url", value: url), RubyCommand.Argument(name: "server_url", value: serverUrl), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "api_token", value: apiToken)])
  _ = runner.executeCommand(command)
}
func getInfoPlistValue(key: String, path: String) {
  let command = RubyCommand(commandID: "", methodName: "get_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key), RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func getIpaInfoPlistValue(key: String, ipa: String) {
  let command = RubyCommand(commandID: "", methodName: "get_ipa_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key), RubyCommand.Argument(name: "ipa", value: ipa)])
  _ = runner.executeCommand(command)
}
func getVersionNumber(xcodeproj: String, scheme: String, target: String) {
  let command = RubyCommand(commandID: "", methodName: "get_version_number", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "target", value: target)])
  _ = runner.executeCommand(command)
}
func gitAdd(path: String, pathspec: String) {
  let command = RubyCommand(commandID: "", methodName: "git_add", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "pathspec", value: pathspec)])
  _ = runner.executeCommand(command)
}
func gitBranch() {
  let command = RubyCommand(commandID: "", methodName: "git_branch", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func gitCommit(path: String, message: String) {
  let command = RubyCommand(commandID: "", methodName: "git_commit", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "message", value: message)])
  _ = runner.executeCommand(command)
}
func gitPull(onlyTags: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "git_pull", className: nil, args: [RubyCommand.Argument(name: "only_tags", value: onlyTags)])
  _ = runner.executeCommand(command)
}
func gitTagExists(tag: String) {
  let command = RubyCommand(commandID: "", methodName: "git_tag_exists", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag)])
  _ = runner.executeCommand(command)
}
func githubApi(serverUrl: String = "https://api.github.com", apiToken: String, httpMethod: String = "GET", body: String = "{}", rawBody: String, path: String, url: String, errorHandlers: String = "{}", headers: String = "{}", secure: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "github_api", className: nil, args: [RubyCommand.Argument(name: "server_url", value: serverUrl), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "http_method", value: httpMethod), RubyCommand.Argument(name: "body", value: body), RubyCommand.Argument(name: "raw_body", value: rawBody), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "url", value: url), RubyCommand.Argument(name: "error_handlers", value: errorHandlers), RubyCommand.Argument(name: "headers", value: headers), RubyCommand.Argument(name: "secure", value: secure)])
  _ = runner.executeCommand(command)
}
func googlePlayTrackVersionCodes(packageName: String, track: String = "production", key: String, issuer: String, jsonKey: String, jsonKeyData: String, rootUrl: String) {
  let command = RubyCommand(commandID: "", methodName: "google_play_track_version_codes", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName), RubyCommand.Argument(name: "track", value: track), RubyCommand.Argument(name: "key", value: key), RubyCommand.Argument(name: "issuer", value: issuer), RubyCommand.Argument(name: "json_key", value: jsonKey), RubyCommand.Argument(name: "json_key_data", value: jsonKeyData), RubyCommand.Argument(name: "root_url", value: rootUrl)])
  _ = runner.executeCommand(command)
}
func gradle(task: String, flavor: String, buildType: String, flags: String, projectDir: String = ".", gradlePath: String, properties: String, serial: String = "", printCommand: String = "true", printCommandOutput: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "gradle", className: nil, args: [RubyCommand.Argument(name: "task", value: task), RubyCommand.Argument(name: "flavor", value: flavor), RubyCommand.Argument(name: "build_type", value: buildType), RubyCommand.Argument(name: "flags", value: flags), RubyCommand.Argument(name: "project_dir", value: projectDir), RubyCommand.Argument(name: "gradle_path", value: gradlePath), RubyCommand.Argument(name: "properties", value: properties), RubyCommand.Argument(name: "serial", value: serial), RubyCommand.Argument(name: "print_command", value: printCommand), RubyCommand.Argument(name: "print_command_output", value: printCommandOutput)])
  _ = runner.executeCommand(command)
}
func gym(workspace: String, project: String, scheme: String, clean: String = "false", outputDirectory: String = ".", outputName: String, configuration: String, silent: String = "false", codesigningIdentity: String, skipPackageIpa: String = "false", includeSymbols: String, includeBitcode: String, exportMethod: String, exportOptions: String, exportXcargs: String, skipBuildArchive: String, buildPath: String, archivePath: String, derivedDataPath: String, resultBundle: String, buildlogPath: String = "~/Library/Logs/gym", sdk: String, toolchain: String, destination: String, exportTeamId: String, xcargs: String, xcconfig: String, suppressXcodeOutput: String, disableXcpretty: String, xcprettyTestFormat: String, xcprettyFormatter: String, xcprettyReportJunit: String, xcprettyReportHtml: String, xcprettyReportJson: String, analyzeBuildTime: String, xcprettyUtf: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "gym", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace), RubyCommand.Argument(name: "project", value: project), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "clean", value: clean), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "output_name", value: outputName), RubyCommand.Argument(name: "configuration", value: configuration), RubyCommand.Argument(name: "silent", value: silent), RubyCommand.Argument(name: "codesigning_identity", value: codesigningIdentity), RubyCommand.Argument(name: "skip_package_ipa", value: skipPackageIpa), RubyCommand.Argument(name: "include_symbols", value: includeSymbols), RubyCommand.Argument(name: "include_bitcode", value: includeBitcode), RubyCommand.Argument(name: "export_method", value: exportMethod), RubyCommand.Argument(name: "export_options", value: exportOptions), RubyCommand.Argument(name: "export_xcargs", value: exportXcargs), RubyCommand.Argument(name: "skip_build_archive", value: skipBuildArchive), RubyCommand.Argument(name: "build_path", value: buildPath), RubyCommand.Argument(name: "archive_path", value: archivePath), RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath), RubyCommand.Argument(name: "result_bundle", value: resultBundle), RubyCommand.Argument(name: "buildlog_path", value: buildlogPath), RubyCommand.Argument(name: "sdk", value: sdk), RubyCommand.Argument(name: "toolchain", value: toolchain), RubyCommand.Argument(name: "destination", value: destination), RubyCommand.Argument(name: "export_team_id", value: exportTeamId), RubyCommand.Argument(name: "xcargs", value: xcargs), RubyCommand.Argument(name: "xcconfig", value: xcconfig), RubyCommand.Argument(name: "suppress_xcode_output", value: suppressXcodeOutput), RubyCommand.Argument(name: "disable_xcpretty", value: disableXcpretty), RubyCommand.Argument(name: "xcpretty_test_format", value: xcprettyTestFormat), RubyCommand.Argument(name: "xcpretty_formatter", value: xcprettyFormatter), RubyCommand.Argument(name: "xcpretty_report_junit", value: xcprettyReportJunit), RubyCommand.Argument(name: "xcpretty_report_html", value: xcprettyReportHtml), RubyCommand.Argument(name: "xcpretty_report_json", value: xcprettyReportJson), RubyCommand.Argument(name: "analyze_build_time", value: analyzeBuildTime), RubyCommand.Argument(name: "xcpretty_utf", value: xcprettyUtf)])
  return runner.executeCommand(command) as! String
}
func hgAddTag(tag: String) {
  let command = RubyCommand(commandID: "", methodName: "hg_add_tag", className: nil, args: [RubyCommand.Argument(name: "tag", value: tag)])
  _ = runner.executeCommand(command)
}
func hgCommitVersionBump(message: String = "Version Bump", xcodeproj: String, force: String = "false", testDirtyFiles: String = "file1, file2", testExpectedFiles: String = "file1, file2") {
  let command = RubyCommand(commandID: "", methodName: "hg_commit_version_bump", className: nil, args: [RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "xcodeproj", value: xcodeproj), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "test_dirty_files", value: testDirtyFiles), RubyCommand.Argument(name: "test_expected_files", value: testExpectedFiles)])
  _ = runner.executeCommand(command)
}
func hgPush(force: String = "false", destination: String = "") {
  let command = RubyCommand(commandID: "", methodName: "hg_push", className: nil, args: [RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "destination", value: destination)])
  _ = runner.executeCommand(command)
}
func hipchat(message: String = "", channel: String, apiToken: String, customColor: String, success: String = "true", version: String, notifyRoom: String = "false", apiHost: String = "api.hipchat.com", messageFormat: String = "html", includeHtmlHeader: String = "true", from: String = "fastlane") {
  let command = RubyCommand(commandID: "", methodName: "hipchat", className: nil, args: [RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "channel", value: channel), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "custom_color", value: customColor), RubyCommand.Argument(name: "success", value: success), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "notify_room", value: notifyRoom), RubyCommand.Argument(name: "api_host", value: apiHost), RubyCommand.Argument(name: "message_format", value: messageFormat), RubyCommand.Argument(name: "include_html_header", value: includeHtmlHeader), RubyCommand.Argument(name: "from", value: from)])
  _ = runner.executeCommand(command)
}
func hockey(apk: String, apiToken: String, ipa: String, dsym: String, createUpdate: String = "false", notes: String = "No changelog given", notify: String = "1", status: String = "2", notesType: String = "1", releaseType: String = "0", mandatory: String = "0", teams: String, users: String, tags: String, bundleShortVersion: String, bundleVersion: String, publicIdentifier: String, commitSha: String, repositoryUrl: String, buildServerUrl: String, uploadDsymOnly: String = "false", ownerId: String, strategy: String = "add", bypassCdn: String = "false", dsaSignature: String = "") {
  let command = RubyCommand(commandID: "", methodName: "hockey", className: nil, args: [RubyCommand.Argument(name: "apk", value: apk), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "dsym", value: dsym), RubyCommand.Argument(name: "create_update", value: createUpdate), RubyCommand.Argument(name: "notes", value: notes), RubyCommand.Argument(name: "notify", value: notify), RubyCommand.Argument(name: "status", value: status), RubyCommand.Argument(name: "notes_type", value: notesType), RubyCommand.Argument(name: "release_type", value: releaseType), RubyCommand.Argument(name: "mandatory", value: mandatory), RubyCommand.Argument(name: "teams", value: teams), RubyCommand.Argument(name: "users", value: users), RubyCommand.Argument(name: "tags", value: tags), RubyCommand.Argument(name: "bundle_short_version", value: bundleShortVersion), RubyCommand.Argument(name: "bundle_version", value: bundleVersion), RubyCommand.Argument(name: "public_identifier", value: publicIdentifier), RubyCommand.Argument(name: "commit_sha", value: commitSha), RubyCommand.Argument(name: "repository_url", value: repositoryUrl), RubyCommand.Argument(name: "build_server_url", value: buildServerUrl), RubyCommand.Argument(name: "upload_dsym_only", value: uploadDsymOnly), RubyCommand.Argument(name: "owner_id", value: ownerId), RubyCommand.Argument(name: "strategy", value: strategy), RubyCommand.Argument(name: "bypass_cdn", value: bypassCdn), RubyCommand.Argument(name: "dsa_signature", value: dsaSignature)])
  _ = runner.executeCommand(command)
}
func ifttt(apiKey: String, eventName: String, value1: String, value2: String, value3: String) {
  let command = RubyCommand(commandID: "", methodName: "ifttt", className: nil, args: [RubyCommand.Argument(name: "api_key", value: apiKey), RubyCommand.Argument(name: "event_name", value: eventName), RubyCommand.Argument(name: "value1", value: value1), RubyCommand.Argument(name: "value2", value: value2), RubyCommand.Argument(name: "value3", value: value3)])
  _ = runner.executeCommand(command)
}
func importCertificate(keychainName: String, keychainPath: String, keychainPassword: String, certificatePath: String, certificatePassword: String = "", logOutput: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "import_certificate", className: nil, args: [RubyCommand.Argument(name: "keychain_name", value: keychainName), RubyCommand.Argument(name: "keychain_path", value: keychainPath), RubyCommand.Argument(name: "keychain_password", value: keychainPassword), RubyCommand.Argument(name: "certificate_path", value: certificatePath), RubyCommand.Argument(name: "certificate_password", value: certificatePassword), RubyCommand.Argument(name: "log_output", value: logOutput)])
  _ = runner.executeCommand(command)
}
func importFromGit(url: String, branch: String = "HEAD", path: String = "fastlane/Fastfile") {
  let command = RubyCommand(commandID: "", methodName: "import_from_git", className: nil, args: [RubyCommand.Argument(name: "url", value: url), RubyCommand.Argument(name: "branch", value: branch), RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func incrementBuildNumber(buildNumber: String, xcodeproj: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "increment_build_number", className: nil, args: [RubyCommand.Argument(name: "build_number", value: buildNumber), RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  return runner.executeCommand(command) as! String
}
func incrementVersionNumber(bumpType: String = "patch", versionNumber: String, xcodeproj: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "increment_version_number", className: nil, args: [RubyCommand.Argument(name: "bump_type", value: bumpType), RubyCommand.Argument(name: "version_number", value: versionNumber), RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  return runner.executeCommand(command) as! String
}
func installOnDevice(extra: String, deviceId: String, skipWifi: String, ipa: String) {
  let command = RubyCommand(commandID: "", methodName: "install_on_device", className: nil, args: [RubyCommand.Argument(name: "extra", value: extra), RubyCommand.Argument(name: "device_id", value: deviceId), RubyCommand.Argument(name: "skip_wifi", value: skipWifi), RubyCommand.Argument(name: "ipa", value: ipa)])
  _ = runner.executeCommand(command)
}
func installXcodePlugin(url: String, github: String) {
  let command = RubyCommand(commandID: "", methodName: "install_xcode_plugin", className: nil, args: [RubyCommand.Argument(name: "url", value: url), RubyCommand.Argument(name: "github", value: github)])
  _ = runner.executeCommand(command)
}
func installr(apiToken: String, ipa: String, notes: String, notify: String, add: String) {
  let command = RubyCommand(commandID: "", methodName: "installr", className: nil, args: [RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "notes", value: notes), RubyCommand.Argument(name: "notify", value: notify), RubyCommand.Argument(name: "add", value: add)])
  _ = runner.executeCommand(command)
}
func ipa(workspace: String, project: String, configuration: String, scheme: String, clean: String, archive: String, destination: String, embed: String, identity: String, sdk: String, ipa: String, xcconfig: String, xcargs: String) {
  let command = RubyCommand(commandID: "", methodName: "ipa", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace), RubyCommand.Argument(name: "project", value: project), RubyCommand.Argument(name: "configuration", value: configuration), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "clean", value: clean), RubyCommand.Argument(name: "archive", value: archive), RubyCommand.Argument(name: "destination", value: destination), RubyCommand.Argument(name: "embed", value: embed), RubyCommand.Argument(name: "identity", value: identity), RubyCommand.Argument(name: "sdk", value: sdk), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "xcconfig", value: xcconfig), RubyCommand.Argument(name: "xcargs", value: xcargs)])
  _ = runner.executeCommand(command)
}
func isCi() -> Bool {
  let command = RubyCommand(commandID: "", methodName: "is_ci", className: nil, args: [])
  return runner.executeCommand(command) as! Bool
}
func jazzy(config: String) {
  let command = RubyCommand(commandID: "", methodName: "jazzy", className: nil, args: [RubyCommand.Argument(name: "config", value: config)])
  _ = runner.executeCommand(command)
}
func jira(url: String, username: String, password: String, ticketId: String, commentText: String) {
  let command = RubyCommand(commandID: "", methodName: "jira", className: nil, args: [RubyCommand.Argument(name: "url", value: url), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "ticket_id", value: ticketId), RubyCommand.Argument(name: "comment_text", value: commentText)])
  _ = runner.executeCommand(command)
}
func laneContext() {
  let command = RubyCommand(commandID: "", methodName: "lane_context", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func lastGitTag() -> String {
  let command = RubyCommand(commandID: "", methodName: "last_git_tag", className: nil, args: [])
  return runner.executeCommand(command) as! String
}
func latestTestflightBuildNumber(live: String = "false", appIdentifier: String, username: String, version: String, initialBuildNumber: String = "1", teamId: String, teamName: String) -> Int {
  let command = RubyCommand(commandID: "", methodName: "latest_testflight_build_number", className: nil, args: [RubyCommand.Argument(name: "live", value: live), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "initial_build_number", value: initialBuildNumber), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName)])
  return runner.executeCommand(command) as! Int
}
func lcov(projectName: String, scheme: String, arch: String = "i386", outputDir: String = "coverage_reports") {
  let command = RubyCommand(commandID: "", methodName: "lcov", className: nil, args: [RubyCommand.Argument(name: "project_name", value: projectName), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "arch", value: arch), RubyCommand.Argument(name: "output_dir", value: outputDir)])
  _ = runner.executeCommand(command)
}
func mailgun(mailgunSandboxDomain: String, mailgunSandboxPostmaster: String, mailgunApikey: String, postmaster: String, apikey: String, to: String, from: String = "Mailgun Sandbox", message: String, subject: String = "fastlane build", success: String = "true", appLink: String, ciBuildLink: String, templatePath: String, replyTo: String, attachment: String) {
  let command = RubyCommand(commandID: "", methodName: "mailgun", className: nil, args: [RubyCommand.Argument(name: "mailgun_sandbox_domain", value: mailgunSandboxDomain), RubyCommand.Argument(name: "mailgun_sandbox_postmaster", value: mailgunSandboxPostmaster), RubyCommand.Argument(name: "mailgun_apikey", value: mailgunApikey), RubyCommand.Argument(name: "postmaster", value: postmaster), RubyCommand.Argument(name: "apikey", value: apikey), RubyCommand.Argument(name: "to", value: to), RubyCommand.Argument(name: "from", value: from), RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "subject", value: subject), RubyCommand.Argument(name: "success", value: success), RubyCommand.Argument(name: "app_link", value: appLink), RubyCommand.Argument(name: "ci_build_link", value: ciBuildLink), RubyCommand.Argument(name: "template_path", value: templatePath), RubyCommand.Argument(name: "reply_to", value: replyTo), RubyCommand.Argument(name: "attachment", value: attachment)])
  _ = runner.executeCommand(command)
}
func makeChangelogFromJenkins(fallbackChangelog: String = "", includeCommitBody: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "make_changelog_from_jenkins", className: nil, args: [RubyCommand.Argument(name: "fallback_changelog", value: fallbackChangelog), RubyCommand.Argument(name: "include_commit_body", value: includeCommitBody)])
  _ = runner.executeCommand(command)
}
func match(gitUrl: String, gitBranch: String = "master", type: String = "development", appIdentifier: String, username: String, keychainName: String = "login.keychain", keychainPassword: String, readonly: String = "false", teamId: String, gitFullName: String, gitUserEmail: String, teamName: String, verbose: String = "false", force: String = "false", skipConfirmation: String = "false", shallowClone: String = "false", cloneBranchDirectly: String = "false", workspace: String, forceForNewDevices: String = "false", skipDocs: String = "false", platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "match", className: nil, args: [RubyCommand.Argument(name: "git_url", value: gitUrl), RubyCommand.Argument(name: "git_branch", value: gitBranch), RubyCommand.Argument(name: "type", value: type), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "keychain_name", value: keychainName), RubyCommand.Argument(name: "keychain_password", value: keychainPassword), RubyCommand.Argument(name: "readonly", value: readonly), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "git_full_name", value: gitFullName), RubyCommand.Argument(name: "git_user_email", value: gitUserEmail), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "skip_confirmation", value: skipConfirmation), RubyCommand.Argument(name: "shallow_clone", value: shallowClone), RubyCommand.Argument(name: "clone_branch_directly", value: cloneBranchDirectly), RubyCommand.Argument(name: "workspace", value: workspace), RubyCommand.Argument(name: "force_for_new_devices", value: forceForNewDevices), RubyCommand.Argument(name: "skip_docs", value: skipDocs), RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
func modifyServices(username: String, appIdentifier: String, services: String = "{}", teamId: String, teamName: String) {
  let command = RubyCommand(commandID: "", methodName: "modify_services", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "services", value: services), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName)])
  _ = runner.executeCommand(command)
}
func nexusUpload(file: String, repoId: String, repoGroupId: String, repoProjectName: String, repoProjectVersion: String, repoClassifier: String, endpoint: String, mountPath: String = "/nexus", username: String, password: String, sslVerify: String = "true", verbose: String = "false", proxyUsername: String, proxyPassword: String, proxyAddress: String, proxyPort: String) {
  let command = RubyCommand(commandID: "", methodName: "nexus_upload", className: nil, args: [RubyCommand.Argument(name: "file", value: file), RubyCommand.Argument(name: "repo_id", value: repoId), RubyCommand.Argument(name: "repo_group_id", value: repoGroupId), RubyCommand.Argument(name: "repo_project_name", value: repoProjectName), RubyCommand.Argument(name: "repo_project_version", value: repoProjectVersion), RubyCommand.Argument(name: "repo_classifier", value: repoClassifier), RubyCommand.Argument(name: "endpoint", value: endpoint), RubyCommand.Argument(name: "mount_path", value: mountPath), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "ssl_verify", value: sslVerify), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "proxy_username", value: proxyUsername), RubyCommand.Argument(name: "proxy_password", value: proxyPassword), RubyCommand.Argument(name: "proxy_address", value: proxyAddress), RubyCommand.Argument(name: "proxy_port", value: proxyPort)])
  _ = runner.executeCommand(command)
}
func notification(title: String = "fastlane", subtitle: String, message: String, sound: String, activate: String, appIcon: String, contentImage: String, open: String, execute: String) {
  let command = RubyCommand(commandID: "", methodName: "notification", className: nil, args: [RubyCommand.Argument(name: "title", value: title), RubyCommand.Argument(name: "subtitle", value: subtitle), RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "sound", value: sound), RubyCommand.Argument(name: "activate", value: activate), RubyCommand.Argument(name: "app_icon", value: appIcon), RubyCommand.Argument(name: "content_image", value: contentImage), RubyCommand.Argument(name: "open", value: open), RubyCommand.Argument(name: "execute", value: execute)])
  _ = runner.executeCommand(command)
}
func numberOfCommits(all: String) -> Int {
  let command = RubyCommand(commandID: "", methodName: "number_of_commits", className: nil, args: [RubyCommand.Argument(name: "all", value: all)])
  return runner.executeCommand(command) as! Int
}
func oclint(oclintPath: String = "oclint", compileCommands: String = "compile_commands.json", selectReqex: String, selectRegex: String, excludeRegex: String, reportType: String = "html", reportPath: String, listEnabledRules: String = "false", rc: String, thresholds: String, enableRules: String, disableRules: String, maxPriority1: String, maxPriority2: String, maxPriority3: String, enableClangStaticAnalyzer: String = "false", enableGlobalAnalysis: String = "false", allowDuplicatedViolations: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "oclint", className: nil, args: [RubyCommand.Argument(name: "oclint_path", value: oclintPath), RubyCommand.Argument(name: "compile_commands", value: compileCommands), RubyCommand.Argument(name: "select_reqex", value: selectReqex), RubyCommand.Argument(name: "select_regex", value: selectRegex), RubyCommand.Argument(name: "exclude_regex", value: excludeRegex), RubyCommand.Argument(name: "report_type", value: reportType), RubyCommand.Argument(name: "report_path", value: reportPath), RubyCommand.Argument(name: "list_enabled_rules", value: listEnabledRules), RubyCommand.Argument(name: "rc", value: rc), RubyCommand.Argument(name: "thresholds", value: thresholds), RubyCommand.Argument(name: "enable_rules", value: enableRules), RubyCommand.Argument(name: "disable_rules", value: disableRules), RubyCommand.Argument(name: "max_priority_1", value: maxPriority1), RubyCommand.Argument(name: "max_priority_2", value: maxPriority2), RubyCommand.Argument(name: "max_priority_3", value: maxPriority3), RubyCommand.Argument(name: "enable_clang_static_analyzer", value: enableClangStaticAnalyzer), RubyCommand.Argument(name: "enable_global_analysis", value: enableGlobalAnalysis), RubyCommand.Argument(name: "allow_duplicated_violations", value: allowDuplicatedViolations)])
  _ = runner.executeCommand(command)
}
func onesignal(authToken: String, appName: String, androidToken: String, apnsP12: String, apnsP12Password: String, apnsEnv: String = "production") {
  let command = RubyCommand(commandID: "", methodName: "onesignal", className: nil, args: [RubyCommand.Argument(name: "auth_token", value: authToken), RubyCommand.Argument(name: "app_name", value: appName), RubyCommand.Argument(name: "android_token", value: androidToken), RubyCommand.Argument(name: "apns_p12", value: apnsP12), RubyCommand.Argument(name: "apns_p12_password", value: apnsP12Password), RubyCommand.Argument(name: "apns_env", value: apnsEnv)])
  _ = runner.executeCommand(command)
}
func pem(development: String = "false", generateP12: String = "true", activeDaysLimit: String = "30", force: String = "false", savePrivateKey: String = "true", appIdentifier: String, username: String, teamId: String, teamName: String, p12Password: String = "", pemName: String, outputPath: String = ".", newProfile: String) {
  let command = RubyCommand(commandID: "", methodName: "pem", className: nil, args: [RubyCommand.Argument(name: "development", value: development), RubyCommand.Argument(name: "generate_p12", value: generateP12), RubyCommand.Argument(name: "active_days_limit", value: activeDaysLimit), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "save_private_key", value: savePrivateKey), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "p12_password", value: p12Password), RubyCommand.Argument(name: "pem_name", value: pemName), RubyCommand.Argument(name: "output_path", value: outputPath), RubyCommand.Argument(name: "new_profile", value: newProfile)])
  _ = runner.executeCommand(command)
}
func pilot(username: String, appIdentifier: String, appPlatform: String, ipa: String, changelog: String, betaAppDescription: String, betaAppFeedbackEmail: String, skipSubmission: String = "false", skipWaitingForBuildProcessing: String = "false", updateBuildInfoOnUpload: String = "false", appleId: String, distributeExternal: String = "false", firstName: String, lastName: String, email: String, testersFilePath: String = "./testers.csv", waitProcessingInterval: String = "30", teamId: String, teamName: String, devPortalTeamId: String, itcProvider: String, groups: String) {
  let command = RubyCommand(commandID: "", methodName: "pilot", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "app_platform", value: appPlatform), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "changelog", value: changelog), RubyCommand.Argument(name: "beta_app_description", value: betaAppDescription), RubyCommand.Argument(name: "beta_app_feedback_email", value: betaAppFeedbackEmail), RubyCommand.Argument(name: "skip_submission", value: skipSubmission), RubyCommand.Argument(name: "skip_waiting_for_build_processing", value: skipWaitingForBuildProcessing), RubyCommand.Argument(name: "update_build_info_on_upload", value: updateBuildInfoOnUpload), RubyCommand.Argument(name: "apple_id", value: appleId), RubyCommand.Argument(name: "distribute_external", value: distributeExternal), RubyCommand.Argument(name: "first_name", value: firstName), RubyCommand.Argument(name: "last_name", value: lastName), RubyCommand.Argument(name: "email", value: email), RubyCommand.Argument(name: "testers_file_path", value: testersFilePath), RubyCommand.Argument(name: "wait_processing_interval", value: waitProcessingInterval), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId), RubyCommand.Argument(name: "itc_provider", value: itcProvider), RubyCommand.Argument(name: "groups", value: groups)])
  _ = runner.executeCommand(command)
}
func pluginScores(outputPath: String, templatePath: String) {
  let command = RubyCommand(commandID: "", methodName: "plugin_scores", className: nil, args: [RubyCommand.Argument(name: "output_path", value: outputPath), RubyCommand.Argument(name: "template_path", value: templatePath)])
  _ = runner.executeCommand(command)
}
func podLibLint(useBundleExec: String = "true", verbose: String, allowWarnings: String, sources: String, useLibraries: String = "false", failFast: String = "false", private🚀: String = "false", quick: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "pod_lib_lint", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "allow_warnings", value: allowWarnings), RubyCommand.Argument(name: "sources", value: sources), RubyCommand.Argument(name: "use_libraries", value: useLibraries), RubyCommand.Argument(name: "fail_fast", value: failFast), RubyCommand.Argument(name: "private", value: private🚀), RubyCommand.Argument(name: "quick", value: quick)])
  _ = runner.executeCommand(command)
}
func podPush(path: String, repo: String, allowWarnings: String, useLibraries: String, sources: String, verbose: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "pod_push", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "repo", value: repo), RubyCommand.Argument(name: "allow_warnings", value: allowWarnings), RubyCommand.Argument(name: "use_libraries", value: useLibraries), RubyCommand.Argument(name: "sources", value: sources), RubyCommand.Argument(name: "verbose", value: verbose)])
  _ = runner.executeCommand(command)
}
func podioItem(clientId: String, clientSecret: String, appId: String, appToken: String, identifyingField: String, identifyingValue: String, otherFields: String) {
  let command = RubyCommand(commandID: "", methodName: "podio_item", className: nil, args: [RubyCommand.Argument(name: "client_id", value: clientId), RubyCommand.Argument(name: "client_secret", value: clientSecret), RubyCommand.Argument(name: "app_id", value: appId), RubyCommand.Argument(name: "app_token", value: appToken), RubyCommand.Argument(name: "identifying_field", value: identifyingField), RubyCommand.Argument(name: "identifying_value", value: identifyingValue), RubyCommand.Argument(name: "other_fields", value: otherFields)])
  _ = runner.executeCommand(command)
}
func precheck(appIdentifier: String, username: String, teamId: String, teamName: String, defaultRuleLevel: String = "error", negativeAppleSentiment: String, placeholderText: String, otherPlatforms: String, futureFunctionality: String, testWords: String, curseWords: String, customText: String, copyrightDate: String, unreachableUrls: String) -> Bool {
  let command = RubyCommand(commandID: "", methodName: "precheck", className: nil, args: [RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "default_rule_level", value: defaultRuleLevel), RubyCommand.Argument(name: "negative_apple_sentiment", value: negativeAppleSentiment), RubyCommand.Argument(name: "placeholder_text", value: placeholderText), RubyCommand.Argument(name: "other_platforms", value: otherPlatforms), RubyCommand.Argument(name: "future_functionality", value: futureFunctionality), RubyCommand.Argument(name: "test_words", value: testWords), RubyCommand.Argument(name: "curse_words", value: curseWords), RubyCommand.Argument(name: "custom_text", value: customText), RubyCommand.Argument(name: "copyright_date", value: copyrightDate), RubyCommand.Argument(name: "unreachable_urls", value: unreachableUrls)])
  return runner.executeCommand(command) as! Bool
}
func produce(username: String, appIdentifier: String, bundleIdentifierSuffix: String, appName: String, appVersion: String, sku: String = "1504029578", platform: String = "ios", language: String = "English", companyName: String, skipItc: String = "false", itcUsers: String, enabledFeatures: String = "{}", enableServices: String = "{}", skipDevcenter: String = "false", teamId: String, teamName: String, itcTeamId: String, itcTeamName: String) {
  let command = RubyCommand(commandID: "", methodName: "produce", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "bundle_identifier_suffix", value: bundleIdentifierSuffix), RubyCommand.Argument(name: "app_name", value: appName), RubyCommand.Argument(name: "app_version", value: appVersion), RubyCommand.Argument(name: "sku", value: sku), RubyCommand.Argument(name: "platform", value: platform), RubyCommand.Argument(name: "language", value: language), RubyCommand.Argument(name: "company_name", value: companyName), RubyCommand.Argument(name: "skip_itc", value: skipItc), RubyCommand.Argument(name: "itc_users", value: itcUsers), RubyCommand.Argument(name: "enabled_features", value: enabledFeatures), RubyCommand.Argument(name: "enable_services", value: enableServices), RubyCommand.Argument(name: "skip_devcenter", value: skipDevcenter), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "itc_team_id", value: itcTeamId), RubyCommand.Argument(name: "itc_team_name", value: itcTeamName)])
  _ = runner.executeCommand(command)
}
func prompt(text: String = "Please enter a text: ", ciInput: String = "", boolean: String = "false", multiLineEndKeyword: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "prompt", className: nil, args: [RubyCommand.Argument(name: "text", value: text), RubyCommand.Argument(name: "ci_input", value: ciInput), RubyCommand.Argument(name: "boolean", value: boolean), RubyCommand.Argument(name: "multi_line_end_keyword", value: multiLineEndKeyword)])
  return runner.executeCommand(command) as! String
}
func pushGitTags(force: String = "false", remote: String) {
  let command = RubyCommand(commandID: "", methodName: "push_git_tags", className: nil, args: [RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "remote", value: remote)])
  _ = runner.executeCommand(command)
}
func pushToGitRemote(localBranch: String, remoteBranch: String, force: String = "false", tags: String = "true", remote: String = "origin") {
  let command = RubyCommand(commandID: "", methodName: "push_to_git_remote", className: nil, args: [RubyCommand.Argument(name: "local_branch", value: localBranch), RubyCommand.Argument(name: "remote_branch", value: remoteBranch), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "tags", value: tags), RubyCommand.Argument(name: "remote", value: remote)])
  _ = runner.executeCommand(command)
}
func readPodspec(path: String) -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "read_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
  return runner.executeCommand(command) as! [String : String]
}
func recreateSchemes(project: String) {
  let command = RubyCommand(commandID: "", methodName: "recreate_schemes", className: nil, args: [RubyCommand.Argument(name: "project", value: project)])
  _ = runner.executeCommand(command)
}
func registerDevice(name: String, udid: String, teamId: String, teamName: String, username: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "register_device", className: nil, args: [RubyCommand.Argument(name: "name", value: name), RubyCommand.Argument(name: "udid", value: udid), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "username", value: username)])
  return runner.executeCommand(command) as! String
}
func registerDevices(devices: String, devicesFile: String, teamId: String, teamName: String, username: String) {
  let command = RubyCommand(commandID: "", methodName: "register_devices", className: nil, args: [RubyCommand.Argument(name: "devices", value: devices), RubyCommand.Argument(name: "devices_file", value: devicesFile), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "username", value: username)])
  _ = runner.executeCommand(command)
}
func resetGitRepo(files: String, force: String = "false", skipClean: String = "false", disregardGitignore: String = "true", exclude: String) {
  let command = RubyCommand(commandID: "", methodName: "reset_git_repo", className: nil, args: [RubyCommand.Argument(name: "files", value: files), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "skip_clean", value: skipClean), RubyCommand.Argument(name: "disregard_gitignore", value: disregardGitignore), RubyCommand.Argument(name: "exclude", value: exclude)])
  _ = runner.executeCommand(command)
}
func resetSimulatorContents(ios: String) {
  let command = RubyCommand(commandID: "", methodName: "reset_simulator_contents", className: nil, args: [RubyCommand.Argument(name: "ios", value: ios)])
  _ = runner.executeCommand(command)
}
func resign(ipa: String, signingIdentity: String, entitlements: String, provisioningProfile: String, version: String, displayName: String, shortVersion: String, bundleVersion: String, bundleId: String, useAppEntitlements: String, keychainPath: String) {
  let command = RubyCommand(commandID: "", methodName: "resign", className: nil, args: [RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "signing_identity", value: signingIdentity), RubyCommand.Argument(name: "entitlements", value: entitlements), RubyCommand.Argument(name: "provisioning_profile", value: provisioningProfile), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "display_name", value: displayName), RubyCommand.Argument(name: "short_version", value: shortVersion), RubyCommand.Argument(name: "bundle_version", value: bundleVersion), RubyCommand.Argument(name: "bundle_id", value: bundleId), RubyCommand.Argument(name: "use_app_entitlements", value: useAppEntitlements), RubyCommand.Argument(name: "keychain_path", value: keychainPath)])
  _ = runner.executeCommand(command)
}
func restoreFile(path: String) {
  let command = RubyCommand(commandID: "", methodName: "restore_file", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
  _ = runner.executeCommand(command)
}
func rocket() -> String {
  let command = RubyCommand(commandID: "", methodName: "rocket", className: nil, args: [])
  return runner.executeCommand(command) as! String
}
func rsync(extra: String = "-av", source: String, destination: String) {
  let command = RubyCommand(commandID: "", methodName: "rsync", className: nil, args: [RubyCommand.Argument(name: "extra", value: extra), RubyCommand.Argument(name: "source", value: source), RubyCommand.Argument(name: "destination", value: destination)])
  _ = runner.executeCommand(command)
}
func s3(ipa: String, dsym: String, uploadMetadata: String = "true", plistTemplatePath: String, plistFileName: String, htmlTemplatePath: String, htmlFileName: String, versionTemplatePath: String, versionFileName: String, accessKey: String, secretAccessKey: String, bucket: String, region: String, path: String = "v{CFBundleShortVersionString}_b{CFBundleVersion}/", source: String, acl: String = "public_read") {
  let command = RubyCommand(commandID: "", methodName: "s3", className: nil, args: [RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "dsym", value: dsym), RubyCommand.Argument(name: "upload_metadata", value: uploadMetadata), RubyCommand.Argument(name: "plist_template_path", value: plistTemplatePath), RubyCommand.Argument(name: "plist_file_name", value: plistFileName), RubyCommand.Argument(name: "html_template_path", value: htmlTemplatePath), RubyCommand.Argument(name: "html_file_name", value: htmlFileName), RubyCommand.Argument(name: "version_template_path", value: versionTemplatePath), RubyCommand.Argument(name: "version_file_name", value: versionFileName), RubyCommand.Argument(name: "access_key", value: accessKey), RubyCommand.Argument(name: "secret_access_key", value: secretAccessKey), RubyCommand.Argument(name: "bucket", value: bucket), RubyCommand.Argument(name: "region", value: region), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "source", value: source), RubyCommand.Argument(name: "acl", value: acl)])
  _ = runner.executeCommand(command)
}
func scan(workspace: String, project: String, device: String, toolchain: String, devices: String, scheme: String, clean: String = "false", codeCoverage: String, addressSanitizer: String, threadSanitizer: String, skipBuild: String = "false", outputDirectory: String = "./test_output", outputStyle: String, outputTypes: String = "html,junit", outputFiles: String, buildlogPath: String = "~/Library/Logs/scan", includeSimulatorLogs: String = "false", formatter: String, testWithoutBuilding: String, buildForTesting: String, xctestrun: String, derivedDataPath: String, resultBundle: String, sdk: String, openReport: String = "false", configuration: String, destination: String, xcargs: String, xcconfig: String, onlyTesting: String, skipTesting: String, slackUrl: String, slackChannel: String, slackMessage: String, skipSlack: String = "false", slackOnlyOnFailure: String = "false", useClangReportName: String = "false", customReportFileName: String, failBuild: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "scan", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace), RubyCommand.Argument(name: "project", value: project), RubyCommand.Argument(name: "device", value: device), RubyCommand.Argument(name: "toolchain", value: toolchain), RubyCommand.Argument(name: "devices", value: devices), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "clean", value: clean), RubyCommand.Argument(name: "code_coverage", value: codeCoverage), RubyCommand.Argument(name: "address_sanitizer", value: addressSanitizer), RubyCommand.Argument(name: "thread_sanitizer", value: threadSanitizer), RubyCommand.Argument(name: "skip_build", value: skipBuild), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "output_style", value: outputStyle), RubyCommand.Argument(name: "output_types", value: outputTypes), RubyCommand.Argument(name: "output_files", value: outputFiles), RubyCommand.Argument(name: "buildlog_path", value: buildlogPath), RubyCommand.Argument(name: "include_simulator_logs", value: includeSimulatorLogs), RubyCommand.Argument(name: "formatter", value: formatter), RubyCommand.Argument(name: "test_without_building", value: testWithoutBuilding), RubyCommand.Argument(name: "build_for_testing", value: buildForTesting), RubyCommand.Argument(name: "xctestrun", value: xctestrun), RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath), RubyCommand.Argument(name: "result_bundle", value: resultBundle), RubyCommand.Argument(name: "sdk", value: sdk), RubyCommand.Argument(name: "open_report", value: openReport), RubyCommand.Argument(name: "configuration", value: configuration), RubyCommand.Argument(name: "destination", value: destination), RubyCommand.Argument(name: "xcargs", value: xcargs), RubyCommand.Argument(name: "xcconfig", value: xcconfig), RubyCommand.Argument(name: "only_testing", value: onlyTesting), RubyCommand.Argument(name: "skip_testing", value: skipTesting), RubyCommand.Argument(name: "slack_url", value: slackUrl), RubyCommand.Argument(name: "slack_channel", value: slackChannel), RubyCommand.Argument(name: "slack_message", value: slackMessage), RubyCommand.Argument(name: "skip_slack", value: skipSlack), RubyCommand.Argument(name: "slack_only_on_failure", value: slackOnlyOnFailure), RubyCommand.Argument(name: "use_clang_report_name", value: useClangReportName), RubyCommand.Argument(name: "custom_report_file_name", value: customReportFileName), RubyCommand.Argument(name: "fail_build", value: failBuild)])
  _ = runner.executeCommand(command)
}
func scp(username: String, password: String, host: String, port: String = "22", upload: String, download: String) {
  let command = RubyCommand(commandID: "", methodName: "scp", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "host", value: host), RubyCommand.Argument(name: "port", value: port), RubyCommand.Argument(name: "upload", value: upload), RubyCommand.Argument(name: "download", value: download)])
  _ = runner.executeCommand(command)
}
func screengrab(androidHome: String, buildToolsVersion: String, locales: [String] = ["en-US"], clearPreviousScreenshots: String = "false", outputDirectory: String = "fastlane/metadata/android", skipOpenSummary: String = "false", appPackageName: String, testsPackageName: String, useTestsInPackages: String, useTestsInClasses: String, launchArguments: String, testInstrumentationRunner: String = "android.support.test.runner.AndroidJUnitRunner", endingLocale: String = "en-US", appApkPath: String, testsApkPath: String, specificDevice: String, deviceType: String = "phone", exitOnTestFailure: String = "true", reinstallApp: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "screengrab", className: nil, args: [RubyCommand.Argument(name: "android_home", value: androidHome), RubyCommand.Argument(name: "build_tools_version", value: buildToolsVersion), RubyCommand.Argument(name: "locales", value: locales), RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary), RubyCommand.Argument(name: "app_package_name", value: appPackageName), RubyCommand.Argument(name: "tests_package_name", value: testsPackageName), RubyCommand.Argument(name: "use_tests_in_packages", value: useTestsInPackages), RubyCommand.Argument(name: "use_tests_in_classes", value: useTestsInClasses), RubyCommand.Argument(name: "launch_arguments", value: launchArguments), RubyCommand.Argument(name: "test_instrumentation_runner", value: testInstrumentationRunner), RubyCommand.Argument(name: "ending_locale", value: endingLocale), RubyCommand.Argument(name: "app_apk_path", value: appApkPath), RubyCommand.Argument(name: "tests_apk_path", value: testsApkPath), RubyCommand.Argument(name: "specific_device", value: specificDevice), RubyCommand.Argument(name: "device_type", value: deviceType), RubyCommand.Argument(name: "exit_on_test_failure", value: exitOnTestFailure), RubyCommand.Argument(name: "reinstall_app", value: reinstallApp)])
  _ = runner.executeCommand(command)
}
func setBuildNumberRepository(useHgRevisionNumber: String = "false", xcodeproj: String) {
  let command = RubyCommand(commandID: "", methodName: "set_build_number_repository", className: nil, args: [RubyCommand.Argument(name: "use_hg_revision_number", value: useHgRevisionNumber), RubyCommand.Argument(name: "xcodeproj", value: xcodeproj)])
  _ = runner.executeCommand(command)
}
func setChangelog(appIdentifier: String, username: String, version: String, changelog: String, teamId: String, teamName: String) {
  let command = RubyCommand(commandID: "", methodName: "set_changelog", className: nil, args: [RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "changelog", value: changelog), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName)])
  _ = runner.executeCommand(command)
}
func setGithubRelease(repositoryName: String, serverUrl: String = "https://api.github.com", apiToken: String, tagName: String, name: String, commitish: String, description: String, isDraft: String = "false", isPrerelease: String = "false", uploadAssets: String) -> [String : String] {
  let command = RubyCommand(commandID: "", methodName: "set_github_release", className: nil, args: [RubyCommand.Argument(name: "repository_name", value: repositoryName), RubyCommand.Argument(name: "server_url", value: serverUrl), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "tag_name", value: tagName), RubyCommand.Argument(name: "name", value: name), RubyCommand.Argument(name: "commitish", value: commitish), RubyCommand.Argument(name: "description", value: description), RubyCommand.Argument(name: "is_draft", value: isDraft), RubyCommand.Argument(name: "is_prerelease", value: isPrerelease), RubyCommand.Argument(name: "upload_assets", value: uploadAssets)])
  return runner.executeCommand(command) as! [String : String]
}
func setInfoPlistValue(key: String, subkey: String, value: String, path: String, outputFileName: String) {
  let command = RubyCommand(commandID: "", methodName: "set_info_plist_value", className: nil, args: [RubyCommand.Argument(name: "key", value: key), RubyCommand.Argument(name: "subkey", value: subkey), RubyCommand.Argument(name: "value", value: value), RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "output_file_name", value: outputFileName)])
  _ = runner.executeCommand(command)
}
func setPodKey(useBundleExec: String = "true", key: String, value: String, project: String) {
  let command = RubyCommand(commandID: "", methodName: "set_pod_key", className: nil, args: [RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec), RubyCommand.Argument(name: "key", value: key), RubyCommand.Argument(name: "value", value: value), RubyCommand.Argument(name: "project", value: project)])
  _ = runner.executeCommand(command)
}
func setupJenkins(force: String = "false", unlockKeychain: String = "true", addKeychainToSearchList: String = "replace", setDefaultKeychain: String = "true", keychainPath: String, keychainPassword: String = "", setCodeSigningIdentity: String = "true", codeSigningIdentity: String, outputDirectory: String = "./output", derivedDataPath: String = "./derivedData", resultBundle: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "setup_jenkins", className: nil, args: [RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "unlock_keychain", value: unlockKeychain), RubyCommand.Argument(name: "add_keychain_to_search_list", value: addKeychainToSearchList), RubyCommand.Argument(name: "set_default_keychain", value: setDefaultKeychain), RubyCommand.Argument(name: "keychain_path", value: keychainPath), RubyCommand.Argument(name: "keychain_password", value: keychainPassword), RubyCommand.Argument(name: "set_code_signing_identity", value: setCodeSigningIdentity), RubyCommand.Argument(name: "code_signing_identity", value: codeSigningIdentity), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath), RubyCommand.Argument(name: "result_bundle", value: resultBundle)])
  _ = runner.executeCommand(command)
}
func setupTravis(force: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "setup_travis", className: nil, args: [RubyCommand.Argument(name: "force", value: force)])
  _ = runner.executeCommand(command)
}
func sh(command: String, log: String = "true", errorCallback: String) {
  let command = RubyCommand(commandID: "", methodName: "sh", className: nil, args: [RubyCommand.Argument(name: "command", value: command), RubyCommand.Argument(name: "log", value: log), RubyCommand.Argument(name: "error_callback", value: errorCallback)])
  _ = runner.executeCommand(command)
}
func sigh(adhoc: String = "false", development: String = "false", skipInstall: String = "false", force: String = "false", appIdentifier: String, username: String, teamId: String, teamName: String, provisioningName: String, ignoreProfilesWithDifferentName: String = "false", outputPath: String = ".", certId: String, certOwnerName: String, filename: String, skipFetchProfiles: String = "false", skipCertificateVerification: String = "false", platform: String = "ios") -> String {
  let command = RubyCommand(commandID: "", methodName: "sigh", className: nil, args: [RubyCommand.Argument(name: "adhoc", value: adhoc), RubyCommand.Argument(name: "development", value: development), RubyCommand.Argument(name: "skip_install", value: skipInstall), RubyCommand.Argument(name: "force", value: force), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "provisioning_name", value: provisioningName), RubyCommand.Argument(name: "ignore_profiles_with_different_name", value: ignoreProfilesWithDifferentName), RubyCommand.Argument(name: "output_path", value: outputPath), RubyCommand.Argument(name: "cert_id", value: certId), RubyCommand.Argument(name: "cert_owner_name", value: certOwnerName), RubyCommand.Argument(name: "filename", value: filename), RubyCommand.Argument(name: "skip_fetch_profiles", value: skipFetchProfiles), RubyCommand.Argument(name: "skip_certificate_verification", value: skipCertificateVerification), RubyCommand.Argument(name: "platform", value: platform)])
  return runner.executeCommand(command) as! String
}
func slack(message: String, channel: String, useWebhookConfiguredUsernameAndIcon: String = "false", slackUrl: String, username: String = "fastlane", iconUrl: String = "https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png", payload: String = "{}", defaultPayloads: String, attachmentProperties: String = "{}", success: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "slack", className: nil, args: [RubyCommand.Argument(name: "message", value: message), RubyCommand.Argument(name: "channel", value: channel), RubyCommand.Argument(name: "use_webhook_configured_username_and_icon", value: useWebhookConfiguredUsernameAndIcon), RubyCommand.Argument(name: "slack_url", value: slackUrl), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "icon_url", value: iconUrl), RubyCommand.Argument(name: "payload", value: payload), RubyCommand.Argument(name: "default_payloads", value: defaultPayloads), RubyCommand.Argument(name: "attachment_properties", value: attachmentProperties), RubyCommand.Argument(name: "success", value: success)])
  _ = runner.executeCommand(command)
}
func slather(buildDirectory: String, proj: String, workspace: String, scheme: String, configuration: String, inputFormat: String, buildkite: String, teamcity: String, jenkins: String, travis: String, circleci: String, coveralls: String, simpleOutput: String, gutterJson: String, coberturaXml: String, html: String, show: String = "false", sourceDirectory: String, outputDirectory: String, ignore: String, verbose: String, useBundleExec: String = "false", binaryBasename: String = "false", binaryFile: String = "false", sourceFiles: String = "false", decimals: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "slather", className: nil, args: [RubyCommand.Argument(name: "build_directory", value: buildDirectory), RubyCommand.Argument(name: "proj", value: proj), RubyCommand.Argument(name: "workspace", value: workspace), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "configuration", value: configuration), RubyCommand.Argument(name: "input_format", value: inputFormat), RubyCommand.Argument(name: "buildkite", value: buildkite), RubyCommand.Argument(name: "teamcity", value: teamcity), RubyCommand.Argument(name: "jenkins", value: jenkins), RubyCommand.Argument(name: "travis", value: travis), RubyCommand.Argument(name: "circleci", value: circleci), RubyCommand.Argument(name: "coveralls", value: coveralls), RubyCommand.Argument(name: "simple_output", value: simpleOutput), RubyCommand.Argument(name: "gutter_json", value: gutterJson), RubyCommand.Argument(name: "cobertura_xml", value: coberturaXml), RubyCommand.Argument(name: "html", value: html), RubyCommand.Argument(name: "show", value: show), RubyCommand.Argument(name: "source_directory", value: sourceDirectory), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "ignore", value: ignore), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "use_bundle_exec", value: useBundleExec), RubyCommand.Argument(name: "binary_basename", value: binaryBasename), RubyCommand.Argument(name: "binary_file", value: binaryFile), RubyCommand.Argument(name: "source_files", value: sourceFiles), RubyCommand.Argument(name: "decimals", value: decimals)])
  _ = runner.executeCommand(command)
}
func snapshot(workspace: String, project: String, xcargs: String, devices: String, languages: [String] = ["en-US"], launchArguments: [String] = [""], outputDirectory: String = "screenshots", outputSimulatorLogs: String = "false", iosVersion: String, skipOpenSummary: String = "false", skipHelperVersionCheck: String = "false", clearPreviousScreenshots: String = "false", reinstallApp: String = "false", eraseSimulator: String = "false", localizeSimulator: String = "false", appIdentifier: String, addPhotos: String, addVideos: String, buildlogPath: String = "~/Library/Logs/snapshot", clean: String = "false", configuration: String, xcprettyArgs: String, sdk: String, scheme: String, numberOfRetries: String = "1", stopAfterFirstError: String = "false", derivedDataPath: String, testTargetName: String, namespaceLogFiles: String, concurrentSimulators: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "snapshot", className: nil, args: [RubyCommand.Argument(name: "workspace", value: workspace), RubyCommand.Argument(name: "project", value: project), RubyCommand.Argument(name: "xcargs", value: xcargs), RubyCommand.Argument(name: "devices", value: devices), RubyCommand.Argument(name: "languages", value: languages), RubyCommand.Argument(name: "launch_arguments", value: launchArguments), RubyCommand.Argument(name: "output_directory", value: outputDirectory), RubyCommand.Argument(name: "output_simulator_logs", value: outputSimulatorLogs), RubyCommand.Argument(name: "ios_version", value: iosVersion), RubyCommand.Argument(name: "skip_open_summary", value: skipOpenSummary), RubyCommand.Argument(name: "skip_helper_version_check", value: skipHelperVersionCheck), RubyCommand.Argument(name: "clear_previous_screenshots", value: clearPreviousScreenshots), RubyCommand.Argument(name: "reinstall_app", value: reinstallApp), RubyCommand.Argument(name: "erase_simulator", value: eraseSimulator), RubyCommand.Argument(name: "localize_simulator", value: localizeSimulator), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "add_photos", value: addPhotos), RubyCommand.Argument(name: "add_videos", value: addVideos), RubyCommand.Argument(name: "buildlog_path", value: buildlogPath), RubyCommand.Argument(name: "clean", value: clean), RubyCommand.Argument(name: "configuration", value: configuration), RubyCommand.Argument(name: "xcpretty_args", value: xcprettyArgs), RubyCommand.Argument(name: "sdk", value: sdk), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "number_of_retries", value: numberOfRetries), RubyCommand.Argument(name: "stop_after_first_error", value: stopAfterFirstError), RubyCommand.Argument(name: "derived_data_path", value: derivedDataPath), RubyCommand.Argument(name: "test_target_name", value: testTargetName), RubyCommand.Argument(name: "namespace_log_files", value: namespaceLogFiles), RubyCommand.Argument(name: "concurrent_simulators", value: concurrentSimulators)])
  _ = runner.executeCommand(command)
}
func sonar(projectConfigurationPath: String, projectKey: String, projectName: String, projectVersion: String, sourcesPath: String, projectLanguage: String, sourceEncoding: String, sonarRunnerArgs: String, sonarLogin: String) {
  let command = RubyCommand(commandID: "", methodName: "sonar", className: nil, args: [RubyCommand.Argument(name: "project_configuration_path", value: projectConfigurationPath), RubyCommand.Argument(name: "project_key", value: projectKey), RubyCommand.Argument(name: "project_name", value: projectName), RubyCommand.Argument(name: "project_version", value: projectVersion), RubyCommand.Argument(name: "sources_path", value: sourcesPath), RubyCommand.Argument(name: "project_language", value: projectLanguage), RubyCommand.Argument(name: "source_encoding", value: sourceEncoding), RubyCommand.Argument(name: "sonar_runner_args", value: sonarRunnerArgs), RubyCommand.Argument(name: "sonar_login", value: sonarLogin)])
  _ = runner.executeCommand(command)
}
func splunkmint(dsym: String, apiKey: String, apiToken: String, verbose: String = "false", uploadProgress: String = "false", proxyUsername: String, proxyPassword: String, proxyAddress: String, proxyPort: String) {
  let command = RubyCommand(commandID: "", methodName: "splunkmint", className: nil, args: [RubyCommand.Argument(name: "dsym", value: dsym), RubyCommand.Argument(name: "api_key", value: apiKey), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "verbose", value: verbose), RubyCommand.Argument(name: "upload_progress", value: uploadProgress), RubyCommand.Argument(name: "proxy_username", value: proxyUsername), RubyCommand.Argument(name: "proxy_password", value: proxyPassword), RubyCommand.Argument(name: "proxy_address", value: proxyAddress), RubyCommand.Argument(name: "proxy_port", value: proxyPort)])
  _ = runner.executeCommand(command)
}
func ssh(username: String, password: String, host: String, port: String = "22", commands: String, log: String = "true") {
  let command = RubyCommand(commandID: "", methodName: "ssh", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "host", value: host), RubyCommand.Argument(name: "port", value: port), RubyCommand.Argument(name: "commands", value: commands), RubyCommand.Argument(name: "log", value: log)])
  _ = runner.executeCommand(command)
}
func supply(packageName: String, track: String = "production", rollout: String, metadataPath: String, key: String, issuer: String, jsonKey: String, jsonKeyData: String, apk: String, apkPaths: String, skipUploadApk: String = "false", skipUploadMetadata: String = "false", skipUploadImages: String = "false", skipUploadScreenshots: String = "false", trackPromoteTo: String, validateOnly: String = "false", mapping: String, mappingPaths: String, rootUrl: String, checkSupersededTracks: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "supply", className: nil, args: [RubyCommand.Argument(name: "package_name", value: packageName), RubyCommand.Argument(name: "track", value: track), RubyCommand.Argument(name: "rollout", value: rollout), RubyCommand.Argument(name: "metadata_path", value: metadataPath), RubyCommand.Argument(name: "key", value: key), RubyCommand.Argument(name: "issuer", value: issuer), RubyCommand.Argument(name: "json_key", value: jsonKey), RubyCommand.Argument(name: "json_key_data", value: jsonKeyData), RubyCommand.Argument(name: "apk", value: apk), RubyCommand.Argument(name: "apk_paths", value: apkPaths), RubyCommand.Argument(name: "skip_upload_apk", value: skipUploadApk), RubyCommand.Argument(name: "skip_upload_metadata", value: skipUploadMetadata), RubyCommand.Argument(name: "skip_upload_images", value: skipUploadImages), RubyCommand.Argument(name: "skip_upload_screenshots", value: skipUploadScreenshots), RubyCommand.Argument(name: "track_promote_to", value: trackPromoteTo), RubyCommand.Argument(name: "validate_only", value: validateOnly), RubyCommand.Argument(name: "mapping", value: mapping), RubyCommand.Argument(name: "mapping_paths", value: mappingPaths), RubyCommand.Argument(name: "root_url", value: rootUrl), RubyCommand.Argument(name: "check_superseded_tracks", value: checkSupersededTracks)])
  _ = runner.executeCommand(command)
}
func swiftlint(mode: String = "lint", outputFile: String, configFile: String, strict: String = "false", files: String, ignoreExitStatus: String = "false", reporter: String, quiet: String = "false", executable: String) {
  let command = RubyCommand(commandID: "", methodName: "swiftlint", className: nil, args: [RubyCommand.Argument(name: "mode", value: mode), RubyCommand.Argument(name: "output_file", value: outputFile), RubyCommand.Argument(name: "config_file", value: configFile), RubyCommand.Argument(name: "strict", value: strict), RubyCommand.Argument(name: "files", value: files), RubyCommand.Argument(name: "ignore_exit_status", value: ignoreExitStatus), RubyCommand.Argument(name: "reporter", value: reporter), RubyCommand.Argument(name: "quiet", value: quiet), RubyCommand.Argument(name: "executable", value: executable)])
  _ = runner.executeCommand(command)
}
func testfairy(apiKey: String, ipa: String, symbolsFile: String, testersGroups: [String] = [], metrics: [String] = [], iconWatermark: String = "off", comment: String = "No comment provided", autoUpdate: String = "off", notify: String = "off", options: [String] = []) {
  let command = RubyCommand(commandID: "", methodName: "testfairy", className: nil, args: [RubyCommand.Argument(name: "api_key", value: apiKey), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "symbols_file", value: symbolsFile), RubyCommand.Argument(name: "testers_groups", value: testersGroups), RubyCommand.Argument(name: "metrics", value: metrics), RubyCommand.Argument(name: "icon_watermark", value: iconWatermark), RubyCommand.Argument(name: "comment", value: comment), RubyCommand.Argument(name: "auto_update", value: autoUpdate), RubyCommand.Argument(name: "notify", value: notify), RubyCommand.Argument(name: "options", value: options)])
  _ = runner.executeCommand(command)
}
func testflight(username: String, appIdentifier: String, appPlatform: String, ipa: String, changelog: String, betaAppDescription: String, betaAppFeedbackEmail: String, skipSubmission: String = "false", skipWaitingForBuildProcessing: String = "false", updateBuildInfoOnUpload: String = "false", appleId: String, distributeExternal: String = "false", firstName: String, lastName: String, email: String, testersFilePath: String = "./testers.csv", waitProcessingInterval: String = "30", teamId: String, teamName: String, devPortalTeamId: String, itcProvider: String, groups: String) {
  let command = RubyCommand(commandID: "", methodName: "testflight", className: nil, args: [RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "app_platform", value: appPlatform), RubyCommand.Argument(name: "ipa", value: ipa), RubyCommand.Argument(name: "changelog", value: changelog), RubyCommand.Argument(name: "beta_app_description", value: betaAppDescription), RubyCommand.Argument(name: "beta_app_feedback_email", value: betaAppFeedbackEmail), RubyCommand.Argument(name: "skip_submission", value: skipSubmission), RubyCommand.Argument(name: "skip_waiting_for_build_processing", value: skipWaitingForBuildProcessing), RubyCommand.Argument(name: "update_build_info_on_upload", value: updateBuildInfoOnUpload), RubyCommand.Argument(name: "apple_id", value: appleId), RubyCommand.Argument(name: "distribute_external", value: distributeExternal), RubyCommand.Argument(name: "first_name", value: firstName), RubyCommand.Argument(name: "last_name", value: lastName), RubyCommand.Argument(name: "email", value: email), RubyCommand.Argument(name: "testers_file_path", value: testersFilePath), RubyCommand.Argument(name: "wait_processing_interval", value: waitProcessingInterval), RubyCommand.Argument(name: "team_id", value: teamId), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "dev_portal_team_id", value: devPortalTeamId), RubyCommand.Argument(name: "itc_provider", value: itcProvider), RubyCommand.Argument(name: "groups", value: groups)])
  _ = runner.executeCommand(command)
}
func tryouts(appId: String, apiToken: String, buildFile: String, notes: String, notesPath: String, notify: String = "1", status: String = "2") {
  let command = RubyCommand(commandID: "", methodName: "tryouts", className: nil, args: [RubyCommand.Argument(name: "app_id", value: appId), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "build_file", value: buildFile), RubyCommand.Argument(name: "notes", value: notes), RubyCommand.Argument(name: "notes_path", value: notesPath), RubyCommand.Argument(name: "notify", value: notify), RubyCommand.Argument(name: "status", value: status)])
  _ = runner.executeCommand(command)
}
func twitter(consumerKey: String, consumerSecret: String, accessToken: String, accessTokenSecret: String, message: String) {
  let command = RubyCommand(commandID: "", methodName: "twitter", className: nil, args: [RubyCommand.Argument(name: "consumer_key", value: consumerKey), RubyCommand.Argument(name: "consumer_secret", value: consumerSecret), RubyCommand.Argument(name: "access_token", value: accessToken), RubyCommand.Argument(name: "access_token_secret", value: accessTokenSecret), RubyCommand.Argument(name: "message", value: message)])
  _ = runner.executeCommand(command)
}
func typetalk() {
  let command = RubyCommand(commandID: "", methodName: "typetalk", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func unlockKeychain(path: String, password: String, addToSearchList: String = "true", setDefault: String = "false") {
  let command = RubyCommand(commandID: "", methodName: "unlock_keychain", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "add_to_search_list", value: addToSearchList), RubyCommand.Argument(name: "set_default", value: setDefault)])
  _ = runner.executeCommand(command)
}
func updateAppGroupIdentifiers(entitlementsFile: String, appGroupIdentifiers: String) {
  let command = RubyCommand(commandID: "", methodName: "update_app_group_identifiers", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile), RubyCommand.Argument(name: "app_group_identifiers", value: appGroupIdentifiers)])
  _ = runner.executeCommand(command)
}
func updateAppIdentifier(xcodeproj: String, plistPath: String, appIdentifier: String) {
  let command = RubyCommand(commandID: "", methodName: "update_app_identifier", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj), RubyCommand.Argument(name: "plist_path", value: plistPath), RubyCommand.Argument(name: "app_identifier", value: appIdentifier)])
  _ = runner.executeCommand(command)
}
func updateFastlane(nightly: String = "false", noUpdate: String = "false", tools: String) {
  let command = RubyCommand(commandID: "", methodName: "update_fastlane", className: nil, args: [RubyCommand.Argument(name: "nightly", value: nightly), RubyCommand.Argument(name: "no_update", value: noUpdate), RubyCommand.Argument(name: "tools", value: tools)])
  _ = runner.executeCommand(command)
}
func updateIcloudContainerIdentifiers(entitlementsFile: String, icloudContainerIdentifiers: String) {
  let command = RubyCommand(commandID: "", methodName: "update_icloud_container_identifiers", className: nil, args: [RubyCommand.Argument(name: "entitlements_file", value: entitlementsFile), RubyCommand.Argument(name: "icloud_container_identifiers", value: icloudContainerIdentifiers)])
  _ = runner.executeCommand(command)
}
func updateInfoPlist(xcodeproj: String, plistPath: String, scheme: String, appIdentifier: String, displayName: String, block: String) {
  let command = RubyCommand(commandID: "", methodName: "update_info_plist", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj), RubyCommand.Argument(name: "plist_path", value: plistPath), RubyCommand.Argument(name: "scheme", value: scheme), RubyCommand.Argument(name: "app_identifier", value: appIdentifier), RubyCommand.Argument(name: "display_name", value: displayName), RubyCommand.Argument(name: "block", value: block)])
  _ = runner.executeCommand(command)
}
func updateProjectCodeSigning(path: String, udid: String, uuid: String) {
  let command = RubyCommand(commandID: "", methodName: "update_project_code_signing", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "udid", value: udid), RubyCommand.Argument(name: "uuid", value: uuid)])
  _ = runner.executeCommand(command)
}
func updateProjectProvisioning(xcodeproj: String, profile: String, targetFilter: String, buildConfigurationFilter: String, buildConfiguration: String, certificate: String = "/tmp/AppleIncRootCertificate.cer") {
  let command = RubyCommand(commandID: "", methodName: "update_project_provisioning", className: nil, args: [RubyCommand.Argument(name: "xcodeproj", value: xcodeproj), RubyCommand.Argument(name: "profile", value: profile), RubyCommand.Argument(name: "target_filter", value: targetFilter), RubyCommand.Argument(name: "build_configuration_filter", value: buildConfigurationFilter), RubyCommand.Argument(name: "build_configuration", value: buildConfiguration), RubyCommand.Argument(name: "certificate", value: certificate)])
  _ = runner.executeCommand(command)
}
func updateProjectTeam(path: String, teamid: String) {
  let command = RubyCommand(commandID: "", methodName: "update_project_team", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "teamid", value: teamid)])
  _ = runner.executeCommand(command)
}
func updateUrbanAirshipConfiguration(plistPath: String, developmentAppKey: String, developmentAppSecret: String, productionAppKey: String, productionAppSecret: String, detectProvisioningMode: String) {
  let command = RubyCommand(commandID: "", methodName: "update_urban_airship_configuration", className: nil, args: [RubyCommand.Argument(name: "plist_path", value: plistPath), RubyCommand.Argument(name: "development_app_key", value: developmentAppKey), RubyCommand.Argument(name: "development_app_secret", value: developmentAppSecret), RubyCommand.Argument(name: "production_app_key", value: productionAppKey), RubyCommand.Argument(name: "production_app_secret", value: productionAppSecret), RubyCommand.Argument(name: "detect_provisioning_mode", value: detectProvisioningMode)])
  _ = runner.executeCommand(command)
}
func updateUrlSchemes(path: String, urlSchemes: String) {
  let command = RubyCommand(commandID: "", methodName: "update_url_schemes", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "url_schemes", value: urlSchemes)])
  _ = runner.executeCommand(command)
}
func uploadSymbolsToCrashlytics(dsymPath: String = "./spec/fixtures/dSYM/Themoji.dSYM", apiToken: String, binaryPath: String, platform: String = "ios") {
  let command = RubyCommand(commandID: "", methodName: "upload_symbols_to_crashlytics", className: nil, args: [RubyCommand.Argument(name: "dsym_path", value: dsymPath), RubyCommand.Argument(name: "api_token", value: apiToken), RubyCommand.Argument(name: "binary_path", value: binaryPath), RubyCommand.Argument(name: "platform", value: platform)])
  _ = runner.executeCommand(command)
}
func uploadSymbolsToSentry(apiHost: String = "https://app.getsentry.com/api/0", apiKey: String, authToken: String, orgSlug: String, projectSlug: String, dsymPath: String, dsymPaths: String) {
  let command = RubyCommand(commandID: "", methodName: "upload_symbols_to_sentry", className: nil, args: [RubyCommand.Argument(name: "api_host", value: apiHost), RubyCommand.Argument(name: "api_key", value: apiKey), RubyCommand.Argument(name: "auth_token", value: authToken), RubyCommand.Argument(name: "org_slug", value: orgSlug), RubyCommand.Argument(name: "project_slug", value: projectSlug), RubyCommand.Argument(name: "dsym_path", value: dsymPath), RubyCommand.Argument(name: "dsym_paths", value: dsymPaths)])
  _ = runner.executeCommand(command)
}
func verifyBuild(provisioningType: String, provisioningUuid: String, teamIdentifier: String, teamName: String, appName: String, bundleIdentifier: String, ipaPath: String) {
  let command = RubyCommand(commandID: "", methodName: "verify_build", className: nil, args: [RubyCommand.Argument(name: "provisioning_type", value: provisioningType), RubyCommand.Argument(name: "provisioning_uuid", value: provisioningUuid), RubyCommand.Argument(name: "team_identifier", value: teamIdentifier), RubyCommand.Argument(name: "team_name", value: teamName), RubyCommand.Argument(name: "app_name", value: appName), RubyCommand.Argument(name: "bundle_identifier", value: bundleIdentifier), RubyCommand.Argument(name: "ipa_path", value: ipaPath)])
  _ = runner.executeCommand(command)
}
func verifyXcode(xcodePath: String = "/Applications/Xcode.app") {
  let command = RubyCommand(commandID: "", methodName: "verify_xcode", className: nil, args: [RubyCommand.Argument(name: "xcode_path", value: xcodePath)])
  _ = runner.executeCommand(command)
}
func versionBumpPodspec(path: String, bumpType: String = "patch", versionNumber: String, versionAppendix: String) {
  let command = RubyCommand(commandID: "", methodName: "version_bump_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "bump_type", value: bumpType), RubyCommand.Argument(name: "version_number", value: versionNumber), RubyCommand.Argument(name: "version_appendix", value: versionAppendix)])
  _ = runner.executeCommand(command)
}
func versionGetPodspec(path: String) {
  let command = RubyCommand(commandID: "", methodName: "version_get_podspec", className: nil, args: [RubyCommand.Argument(name: "path", value: path)])
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
func xcodeInstall(version: String, username: String, teamId: String) -> String {
  let command = RubyCommand(commandID: "", methodName: "xcode_install", className: nil, args: [RubyCommand.Argument(name: "version", value: version), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "team_id", value: teamId)])
  return runner.executeCommand(command) as! String
}
func xcodeServerGetAssets(host: String, botName: String, integrationNumber: String, username: String = "", password: String = "", targetFolder: String = "./xcs_assets", keepAllAssets: String = "false", trustSelfSignedCerts: String = "true") -> [String] {
  let command = RubyCommand(commandID: "", methodName: "xcode_server_get_assets", className: nil, args: [RubyCommand.Argument(name: "host", value: host), RubyCommand.Argument(name: "bot_name", value: botName), RubyCommand.Argument(name: "integration_number", value: integrationNumber), RubyCommand.Argument(name: "username", value: username), RubyCommand.Argument(name: "password", value: password), RubyCommand.Argument(name: "target_folder", value: targetFolder), RubyCommand.Argument(name: "keep_all_assets", value: keepAllAssets), RubyCommand.Argument(name: "trust_self_signed_certs", value: trustSelfSignedCerts)])
  return runner.executeCommand(command) as! [String]
}
func xcodebuild() {
  let command = RubyCommand(commandID: "", methodName: "xcodebuild", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcov() {
  let command = RubyCommand(commandID: "", methodName: "xcov", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xctest() {
  let command = RubyCommand(commandID: "", methodName: "xctest", className: nil, args: [])
  _ = runner.executeCommand(command)
}
func xcversion(version: String) {
  let command = RubyCommand(commandID: "", methodName: "xcversion", className: nil, args: [RubyCommand.Argument(name: "version", value: version)])
  _ = runner.executeCommand(command)
}
func zip(path: String, outputPath: String, verbose: String = "true") -> String {
  let command = RubyCommand(commandID: "", methodName: "zip", className: nil, args: [RubyCommand.Argument(name: "path", value: path), RubyCommand.Argument(name: "output_path", value: outputPath), RubyCommand.Argument(name: "verbose", value: verbose)])
  return runner.executeCommand(command) as! String
}
