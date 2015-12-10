//
//  SnapshotHelper.swift
//  Example
//
//  Created by Felix Krause on 10/8/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

import Foundation
import XCTest

var deviceLanguage = ""

@available(*, deprecated, message="use setupSnapshot: instead")
func setLanguage(app: XCUIApplication) {
    setupSnapshot(app)
}

func setupSnapshot(app: XCUIApplication) {
    Snapshot.setupSnapshot(app)
}

func snapshot(name: String, waitForLoadingIndicator: Bool = false) {
    Snapshot.snapshot(name, waitForLoadingIndicator: waitForLoadingIndicator)
}

class Snapshot: NSObject {

    class func setupSnapshot(app: XCUIApplication) {
        setLanguage(app)
        setLaunchArguments(app)
    }

    class func setLanguage(app: XCUIApplication) {
        let path = "/tmp/language.txt"

        do {
            let locale = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            deviceLanguage = locale.substringToIndex(locale.startIndex.advancedBy(2, limit:locale.endIndex))
            app.launchArguments += ["-AppleLanguages", "(\(deviceLanguage))", "-AppleLocale", "\"\(locale)\"", "-ui_testing"]
        } catch {
            print("Couldn't detect/set language...")
        }
    }

    class func setLaunchArguments(app: XCUIApplication) {
        let path = "/tmp/snapshot-launch_arguments.txt"

        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES"]

        do {
            let launchArguments = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            let regex = try NSRegularExpression(pattern: "(\\\".+?\\\"|\\S+)", options: [])
            let matches = regex.matchesInString(launchArguments, options: [], range: NSRange(location:0, length:launchArguments.characters.count))
            let results = matches.map { result -> String in
                (launchArguments as NSString).substringWithRange(result.range)
            }
            app.launchArguments += results
        } catch {
            print("Couldn't detect/set launch_arguments...")
        }
    }

    class func snapshot(name: String, waitForLoadingIndicator: Bool = false) {
        if waitForLoadingIndicator {
            waitForLoadingIndicatorToDisappear()
        }

        print("snapshot: \(name)") // more information about this, check out https://github.com/krausefx/snapshot

        sleep(1) // Waiting for the animation to be finished (kind of)
        XCUIDevice.sharedDevice().orientation = .Unknown
    }

    class func waitForLoadingIndicatorToDisappear() {
        let query = XCUIApplication().statusBars.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other)
        
        while query.count > 4 {
            sleep(1)
            print("Number of Elements in Status Bar: \(query.count)... waiting for status bar to disappear")
        }
    }
}

// Please don't remove the lines below
// They are used to detect outdated configuration files
// SnapshotHelperVersion [[1.0]]
