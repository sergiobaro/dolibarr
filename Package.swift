// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dolibarr",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "dolibarr", targets: ["dolibarr"]),
        .library(name: "dolibarrLib", targets: ["dolibarrLib"])
    ],
    dependencies: [
      .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.2.0")
    ],
    targets: [
        .target(
            name: "dolibarr",
            dependencies: ["dolibarrLib"]
        ),
        .target(
            name: "dolibarrLib",
            dependencies: ["SwiftSoup"]
        ),
        .testTarget(
            name: "dolibarrLibTests",
            dependencies: ["dolibarrLib"]
        )
    ]
)
