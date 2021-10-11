// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EndpointModel",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "EndpointModel",
            targets: ["EndpointModel"]
        ),
    ],
    targets: [
        .target(
            name: "EndpointModel",
            dependencies: []
        ),
    ]
)
