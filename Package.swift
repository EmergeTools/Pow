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
            checksum: "dd12f4ed5db23a191964d40b0c74272b96a4a4912c706216b0387b046ee1f353"
        ),
    ]
)
