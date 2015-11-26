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

func setLanguage(app: XCUIApplication)
{
    Snapshot.setLanguage(app)
}

func setLaunchArguments(app: XCUIApplication)
{
    Snapshot.setLaunchArguments(app)
}

func setupSnapshot(app: XCUIApplication)
{
    setLanguage(app)
    setLaunchArguments(app)
}

func snapshot(name: String, waitForLoadingIndicator: Bool = true)
{
    Snapshot.snapshot(name, waitForLoadingIndicator: waitForLoadingIndicator)
}



@objc class Snapshot: NSObject
{
    class func setLanguage(app: XCUIApplication)
    {
        let path = "/tmp/language.txt"
        
        do {
            let locale = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            deviceLanguage = locale.substringToIndex(locale.startIndex.advancedBy(2, limit:locale.endIndex))
            app.launchArguments += ["-AppleLanguages", "(\(deviceLanguage))", "-AppleLocale", "\"\(locale)\"","-ui_testing"]
        } catch {
            print("Couldn't detect/set language...")
        }
    }

    class func setLaunchArguments(app: XCUIApplication)
    {
        let path = "/tmp/snapshot-launch_arguments.txt"
        
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "1"]

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
    
    class func snapshot(name: String, waitForLoadingIndicator: Bool = false)
    {
        if (waitForLoadingIndicator)
        {
            waitForLoadingIndicatorToDisappear()
        }
        print("snapshot: \(name)") // more information about this, check out https://github.com/krausefx/snapshot
        
        let view = XCUIApplication()
        let start = view.coordinateWithNormalizedOffset(CGVectorMake(32.10, 30000))
        let finish = view.coordinateWithNormalizedOffset(CGVectorMake(31, 30000))
        start.pressForDuration(0, thenDragToCoordinate: finish)
        sleep(1)
    }
    
    class func waitForLoadingIndicatorToDisappear()
    {
        let query = XCUIApplication().statusBars.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other)
        
        while (query.count > 4) {
            sleep(1)
            print("Number of Elements in Status Bar: \(query.count)... waiting for status bar to disappear")
        }
    }
}
