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
            url: "https://packages.movingparts.io/binaries/pow/0.1.1/Pow.xcframework.zip",
            checksum: "5ae07875130ecb40d9310460b13da6aaa6f783d1e6e9af88b7c96a1ba32fd22a"
        ),
    ]
)
