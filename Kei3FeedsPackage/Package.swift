// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kei3FeedsPackage",
    platforms: [.iOS(.v17)],
    products: [
      .library(name: "Feature", targets: ["Feature"]),
      .library(name: "Core", targets: ["Core"]),
      .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
      .package(url: "https://github.com/nmdias/FeedKit.git", from: "9.1.2"),
      .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.7"),
      .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
    ],
    targets: [
      .target(name: "Core"),
      .target(name: "Data", dependencies: ["FeedKit", "Domain", "Core", "SwiftSoup"]),
      .target(name: "Domain", dependencies: ["Core"]),
      .target(name: "Feature", dependencies: ["Domain", "Core", "Kingfisher"]),
    ]
)
