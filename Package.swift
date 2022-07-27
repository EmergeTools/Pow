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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.2/Transitions.xcframework.zip",
            checksum: "bb70c4e731c0bb63ff07e63d8afb034c104fb9d4872e0cfb15a67ac2d35fee30"
        ),
    ]
)
