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
            url: "https://packages.movingparts.io/binaries/pow/0.0.13/Pow.xcframework.zip",
            checksum: "4fd8a2e00b886d5e5a41159a68f7991ba45217ad1e8690cb7f158cfa96fc831b"
        ),
    ]
)
