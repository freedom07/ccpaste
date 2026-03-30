// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ccpaste",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/KristopherGBaker/libcmark_gfm.git", from: "0.29.4"),
    ],
    targets: [
        .executableTarget(
            name: "ccpaste",
            dependencies: [
                .product(name: "libcmark_gfm", package: "libcmark_gfm"),
            ],
            path: "Sources/ccpaste",
            exclude: ["Info.plist"]
        ),
    ]
)
