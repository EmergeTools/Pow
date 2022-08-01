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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.8/Transitions.xcframework.zip",
            checksum: "0775656d360ae125f341ead29a64368bdf4b2eeaaf463fe9e3b6ed41a4b1c489"
        ),
    ]
)
