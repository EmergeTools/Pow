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
            checksum: "fd5c8cd34e1dfedca7e6ab13686e2c54e1fcd9415d1d588661a4129b8adcab26"
        ),
    ]
)
