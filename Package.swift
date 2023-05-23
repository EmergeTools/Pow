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
            checksum: "d4a3deb1695350ba768b9e75a9e7d44d5271b0fe6abab30c41660581f7300667"
        ),
    ]
)
