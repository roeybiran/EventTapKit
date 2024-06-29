// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EventTapKit",
  platforms: [.macOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "EventTapKit",
      targets: ["EventTapKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/roeybiran/RBKit", branch: "main"),
    .package(url: "https://github.com/airbnb/swift", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "EventTapKit",
      dependencies: [
        .product(name: "RBKit", package: "RBKit"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ],
    ),
    .testTarget(
      name: "EventTapKitTests",
      dependencies: ["EventTapKit"]),
  ]
)
