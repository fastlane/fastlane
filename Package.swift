// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Fastlane",
    products: [
        .library(name: "Fastlane", targets: ["Fastlane"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Fastlane",
            dependencies: [],
            path: "./fastlane/swift",
            exclude: ["Actions.swift", "Plugins.swift", "main.swift", "formatting", "FastlaneSwiftRunner"]
        ),
    ],
    swiftLanguageVersions: [4]
)
 
