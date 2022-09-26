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
            checksum: "fd78f49c581ddce087f1477407ec87f448c71049f54cbbb940930ea77ddf482f"
        ),
    ]
)
