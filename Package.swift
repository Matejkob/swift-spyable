// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-spyable",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13),
  ],
  products: [
    .library(
      name: "Spyable",
      targets: ["Spyable"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"601.0.0-prerelease")
  ],
  targets: [
    .macro(
      name: "SpyableMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "Spyable",
      dependencies: [
        "SpyableMacro"
      ]
    ),
    .testTarget(
      name: "SpyableMacroTests",
      dependencies: [
        "SpyableMacro",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
