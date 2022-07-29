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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.7/Transitions.xcframework.zip",
            checksum: "423a15f00967395eea4221334e73df0c38b723938932dfd4eed3bb0cf3950204"
        ),
    ]
)
