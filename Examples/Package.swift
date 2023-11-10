// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "Examples",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13),
  ],
  products: [
    .library(
      name: "Examples",
      targets: ["Examples"]
    )
  ],
  dependencies: [
    .package(name: "swift-spyable", path: "../")
  ],
  targets: [
    .target(
      name: "Examples",
      dependencies: [
        .product(name: "Spyable", package: "swift-spyable")
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "ExamplesTests",
      dependencies: ["Examples"],
      path: "Tests"
    ),
  ]
)
