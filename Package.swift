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
            url: "https://packages.movingparts.io/binaries/pow/0.0.11/Pow.xcframework.zip",
            checksum: "db7f9e15e8f083c9434697f36b1aa3950f11118df36f97106f30c051c0d71ea6"
        ),
    ]
)
