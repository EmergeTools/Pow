// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let enablePreviews = false

let package = Package(
    name: "Pow",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Pow",
            targets: ["Pow"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/EmergeTools/SnapshotPreviews-iOS", exact: "0.7.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Pow",
            dependencies: enablePreviews ? [.product(name: "SnapshotPreferences", package: "SnapshotPreviews-iOS", condition: .when(platforms: [.iOS]))] : [],
            resources: [.process("Assets.xcassets")],
            swiftSettings: enablePreviews ? [.define("EMG_PREVIEWS")] : nil),
        .testTarget(
            name: "PowTests",
            dependencies: ["Pow"]),
    ]
)
