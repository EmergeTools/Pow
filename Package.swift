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
            url: "https://packages.movingparts.io/binaries/pow/0.3.0/Pow.xcframework.zip",
            checksum: "d60782300a127d66a5df56060a34643ef0e04e86dcd6558ea4f2a3617e196c5c"
        ),
    ]
)
