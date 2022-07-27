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
            url: "https://packages.movingparts.io/binaries/transitions/0.0.4/Transitions.xcframework.zip",
            checksum: "74b62b89ab66e3df57522963fb5a2f9324a92a9c1bdd762985d073c867e825fe"
        ),
    ]
)
