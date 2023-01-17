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
            checksum: "9a253884c397cd7d615ea848143fc32f9f85351417a5eae6dc84430b1c4baea6"
        ),
    ]
)
