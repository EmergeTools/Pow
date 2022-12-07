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
            url: "https://packages.movingparts.io/binaries/pow/0.2.0/Pow.xcframework.zip",
            checksum: "a53a9ea09101af0de662543cf9b833acb0d6e496ccc5737c2b6f5799bf50774c"
        ),
    ]
)
