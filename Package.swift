// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Pow",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .macOS(.v12),
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
            url: "https://packages.movingparts.io/binaries/pow/0.3.1/Pow.xcframework.zip",
            checksum: "d69a6023276202aeaca0e35e552647d95fece7a365af5bc243e264287ff75b68"
        ),
    ]
)
