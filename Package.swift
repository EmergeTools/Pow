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
            url: "https://packages.movingparts.io/binaries/pow/0.2.1/Pow.xcframework.zip",
            checksum: "ab861b6666ad7f0915feebfff4390cb6d2b4bb03598ab64f6700f2f5a1dee84d"
        ),
    ]
)
