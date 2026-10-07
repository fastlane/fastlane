// swift-tools-version:5.5
import PackageDescription

/// A minimal executable using fastlane as a Swift package, the way users do, built from this checkout.
let package = Package(
    name: "Runner",
    dependencies: [.package(name: "Fastlane", path: "../../../..")],
    targets: [.executableTarget(name: "Runner", dependencies: [.product(name: "Fastlane", package: "Fastlane")])]
)
