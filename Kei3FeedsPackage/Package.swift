// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kei3FeedsPackage",
    platforms: [.iOS(.v17)],
    products: [
      .library(name: "Feature", targets: ["Feature"]),
    ],
    dependencies: [
      .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2")
    ],
    targets: [
      .target(name: "Core"),
      .target(name: "Data", dependencies: ["FeedKit", "Domain", "Core"]),
      .target(name: "Domain", dependencies: ["Core"]),
      .target(name: "Feature", dependencies: ["Domain", "Core"]),
    ]
)
