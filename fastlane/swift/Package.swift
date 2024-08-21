// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "fastlane-swift",
  platforms: [.macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    .package(url: "https://github.com/fastlane/fastlane", from: "2.222.0"),
  ],
  targets: [
    .executableTarget(
      name: "fastlane-swift",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Fastlane", package: "fastlane"),
      ]
    )
  ]
)
