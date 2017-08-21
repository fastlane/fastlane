//
//  SnapshotHelper.swift
//  Example
//
//  Created by Felix Krause on 10/8/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

// -----------------------------------------------------
// IMPORTANT: When modifying this file, make sure to
//            increment the version number at the very
//            bottom of the file to notify users about
//            the new SnapshotHelper.swift
// -----------------------------------------------------

import Foundation
import XCTest

var deviceLanguage = ""
var locale = ""

@available(*, deprecated, message: "use setupSnapshot: instead")
func setLanguage(_ app: XCUIApplication) {
    setupSnapshot(app)
}

func setupSnapshot(_ app: XCUIApplication) {
    Snapshot.setupSnapshot(app)
}

func snapshot(_ name: String, waitForLoadingIndicator: Bool = true) {
    Snapshot.snapshot(name, waitForLoadingIndicator: waitForLoadingIndicator)
}

enum SnapshotError: Error, CustomDebugStringConvertible {
    case cannotDetectUser
    case cannotFindHomeDirectory
    case cannotFindSimulatorHomeDirectory
    case cannotAccessSimulatorHomeDirectory(String)
    
    var debugDescription: String {
        switch self {
        case .cannotDetectUser:
            return "Couldn't find Snapshot configuration files - can't detect current user "
        case .cannotFindHomeDirectory:
            return "Couldn't find Snapshot configuration files - can't detect `Users` dir"
        case .cannotFindSimulatorHomeDirectory:
            return "Couldn't find simulator home location. Please, check SIMULATOR_HOST_HOME env variable."
        case .cannotAccessSimulatorHomeDirectory(let simulatorHostHome):
            return "Can't prepare environment. Simulator home location is inaccessible. Does \(simulatorHostHome) exist?"
        }
    }
}

open class Snapshot: NSObject {
    static var app: XCUIApplication!
    static var cacheDirectory: URL!
    static var screenshotsDirectory: URL? {
        return cacheDirectory.appendingPathComponent("screenshots", isDirectory: true)
    }

    open class func setupSnapshot(_ app: XCUIApplication) {
        do {
            let cacheDir = try pathPrefix()
            Snapshot.cacheDirectory = cacheDir
            Snapshot.app = app
            setLanguage(app)
            setLocale(app)
            setLaunchArguments(app)
        } catch let error {
            print(error)
        }
    }

    class func setLanguage(_ app: XCUIApplication) {
        let path = cacheDirectory.appendingPathComponent("language.txt")

        do {
            let trimCharacterSet = CharacterSet.whitespacesAndNewlines
            deviceLanguage = try String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: trimCharacterSet)
            app.launchArguments += ["-AppleLanguages", "(\(deviceLanguage))"]
        } catch {
            print("Couldn't detect/set language...")
        }
    }

    class func setLocale(_ app: XCUIApplication) {
        let path = cacheDirectory.appendingPathComponent("locale.txt")

        do {
            let trimCharacterSet = CharacterSet.whitespacesAndNewlines
            locale = try String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: trimCharacterSet)
        } catch {
            print("Couldn't detect/set locale...")
        }
        if locale.isEmpty {
            locale = Locale(identifier: deviceLanguage).identifier
        }
        app.launchArguments += ["-AppleLocale", "\"\(locale)\""]
    }

    class func setLaunchArguments(_ app: XCUIApplication) {
        let path = cacheDirectory.appendingPathComponent("snapshot-launch_arguments.txt")
        app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES", "-ui_testing"]

        do {
            let launchArguments = try String(contentsOf: path, encoding: String.Encoding.utf8)
            let regex = try NSRegularExpression(pattern: "(\\\".+?\\\"|\\S+)", options: [])
            let matches = regex.matches(in: launchArguments, options: [], range: NSRange(location:0, length:launchArguments.characters.count))
            let results = matches.map { result -> String in
                (launchArguments as NSString).substring(with: result.range)
            }
            app.launchArguments += results
        } catch {
            print("Couldn't detect/set launch_arguments...")
        }
    }

    open class func snapshot(_ name: String, waitForLoadingIndicator: Bool = true) {
        if waitForLoadingIndicator {
            waitForLoadingIndicatorToDisappear()
        }

        print("snapshot: \(name)") // more information about this, check out https://github.com/fastlane/fastlane/tree/master/snapshot#how-does-it-work

        sleep(1) // Waiting for the animation to be finished (kind of)

        #if os(OSX)
            XCUIApplication().typeKey(XCUIKeyboardKeySecondaryFn, modifierFlags: [])
        #else
            let screenshot = app.windows.firstMatch.screenshot()
            guard let simulator = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"], let screenshotsDir = screenshotsDirectory else { return }
            let path = screenshotsDir.appendingPathComponent("\(simulator)-\(name).png")
            do {
                try screenshot.pngRepresentation.write(to: path)
            } catch let error {
                print("Problem writing screenshot: \(name) to \(path)")
                print(error)
            }
        #endif
    }

    class func waitForLoadingIndicatorToDisappear() {
        #if os(tvOS)
            return
        #endif

        let query = XCUIApplication().statusBars.children(matching: .other).element(boundBy: 1).children(matching: .other)

        while (0..<query.count).map({ query.element(boundBy: $0) }).contains(where: { $0.isLoadingIndicator }) {
            sleep(1)
            print("Waiting for loading indicator to disappear...")
        }
    }

    class func pathPrefix() throws -> URL? {
        let homeDir: URL
        // on OSX config is stored in /Users/<username>/Library
        // and on iOS/tvOS/WatchOS it's in simulator's home dir
        #if os(OSX)
            guard let user = ProcessInfo().environment["USER"] else {
                throw SnapshotError.cannotDetectUser
            }

            guard let usersDir =  FileManager.default.urls(for: .userDirectory, in: .localDomainMask).first else {
                throw SnapshotError.cannotFindHomeDirectory
            }

            homeDir = usersDir.appendingPathComponent(user)
        #else
            guard let simulatorHostHome = ProcessInfo().environment["SIMULATOR_HOST_HOME"] else {
                throw SnapshotError.cannotFindSimulatorHomeDirectory
            }
            guard let homeDirUrl = URL(string: simulatorHostHome) else {
                throw SnapshotError.cannotAccessSimulatorHomeDirectory(simulatorHostHome)
            }
            homeDir = URL(fileURLWithPath: homeDirUrl.path)
        #endif
        return homeDir.appendingPathComponent("Library/Caches/tools.fastlane")
    }
}

extension XCUIElement {
    var isLoadingIndicator: Bool {
        let whiteListedLoaders = ["GeofenceLocationTrackingOn", "StandardLocationTrackingOn"]
        if whiteListedLoaders.contains(self.identifier) {
            return false
        }
        return self.frame.size == CGSize(width: 10, height: 20)
    }
}

// Please don't remove the lines below
// They are used to detect outdated configuration files
// SnapshotHelperVersion [1.5]
