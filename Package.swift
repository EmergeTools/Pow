// swift-tools-version: 5.3
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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.1/Transitions.xcframework.zip",
            checksum: "e0f092957fca059428ce8567f0004bd750268edb56b152b6ba506d98564809d1"
        ),
    ]
)
