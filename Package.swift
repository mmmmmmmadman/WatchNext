// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleTVSearch",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AppleTVSearch",
            targets: ["AppleTVSearch"]),
    ],
    targets: [
        .target(
            name: "AppleTVSearch",
            path: "AppleTVSearch"),
    ]
)
