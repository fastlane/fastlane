// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Fastlane",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(name: "Fastlane", targets: ["Fastlane"])
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        .target(
            name: "Fastlane",
            dependencies: ["SwiftShell"],
            path: "./fastlane/swift",
            exclude: ["Actions.swift", "Plugins.swift", "main.swift", "formatting", "FastlaneSwiftRunner"]
        ),
    ],
    swiftLanguageVersions: [.v4]
)
 
