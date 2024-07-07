// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v15), .watchOS(.v8)],
    products: [
        .library(name: "App", targets: ["View", "Model", "SWGraphQL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios", .upToNextMajor(from: "1.13.0")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", .upToNextMajor(from: "1.3.0")),
    ],
    targets: [
        .target(name: "View", dependencies: [
            "Model",
        ]),
        .target(name: "Model", dependencies: [
            "SWGraphQL",
            .product(name: "Dependencies", package: "swift-dependencies"),
        ]),
        .target(name: "SWGraphQL", dependencies: [
            .product(name: "Apollo", package: "apollo-ios"),
        ])
    ]
)
