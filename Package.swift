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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.10/Transitions.xcframework.zip",
            checksum: "1c12f798dffe2a801c61345bb188eeadb5ff90489dd05c6bd7fcdf9f48d99e1f"
        ),
    ]
)
