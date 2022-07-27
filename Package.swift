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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.3/Transitions.xcframework.zip",
            checksum: "8142eaa78b652055ef8af0f0a8ef2d41ee40d1d0430567e5c0ee3b5a8197153e"
        ),
    ]
)
