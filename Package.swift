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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.5/Transitions.xcframework.zip",
            checksum: "40267fc58dc7ecdbb5908d79ff90c6f072f31d162419a9125a97336a14389b98"
        ),
    ]
)
