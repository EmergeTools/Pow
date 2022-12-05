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
            checksum: "e4455686b25aff51a821bc46bc54c07cb4554e721d37d84fdbcf5e1e3dab59ef"
        ),
    ]
)
