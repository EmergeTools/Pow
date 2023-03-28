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
            checksum: "28a6565d0570394e512ae177a49dcddf38f53f9bb567cb899f8405901190b1eb"
        ),
    ]
)
