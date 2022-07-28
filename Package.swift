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
            checksum: "f59ac0c103ebb1bc5ebdd0eba9b8116a58f16e56b32a01a1115ff3e089e8d0f3"
        ),
    ]
)
