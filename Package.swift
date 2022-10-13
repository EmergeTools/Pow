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
            url: "https://packages.movingparts.io/binaries/pow/0.1.0/Pow.xcframework.zip",
            checksum: "27bfbae340405068387782b4f3712b58fa07225003c85c347f4d3c2122df8507"
        ),
    ]
)
