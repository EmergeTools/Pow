// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Transitions",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Transitions",
            targets: ["Transitions"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "Transitions",
            url: "https://packages.movingparts.io/binaries/transitions/0.0.9/Transitions.xcframework.zip",
            checksum: "3a2937753fdb6f669afebf6665a54efd3f5a0f5c7426e62372cf4612e272e19d"
        ),
    ]
)
