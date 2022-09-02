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
            url: "https://packages.movingparts.io/binaries/pow/0.0.12/Pow.xcframework.zip",
            checksum: "51f1479bb77bcdb775e0cfdfb14be5231185012e3fe8c2dcf994d381295a797c"
        ),
    ]
)
