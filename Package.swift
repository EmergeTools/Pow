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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.6/Transitions.xcframework.zip",
            checksum: "bda64aca7f37760fed48465b5de6409fbcd67759e8e82283773130a64814c6d5"
        ),
    ]
)
