// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Pow",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Pow",
            targets: ["Pow"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "Pow",
            url: "https://packages.movingparts.io/binaries/pow/0.2.0/Pow.xcframework.zip",
            checksum: "c2a61e0a0444da2aa6b1c4813932e8c7ee3ddc485dad4fc2bfb03da689bfac9b"
        ),
    ]
)
