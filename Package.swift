// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Fastlane",
    products: [
        .library(name: "Fastlane", targets: ["Fastlane"])
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "Fastlane",
            dependencies: [
                .product(name: "SwiftShell", package: "SwiftShell")
            ]
        )
    ]
)
