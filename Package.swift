// swift-tools-version:5.6

import PackageDescription
import class Foundation.ProcessInfo

let cmarkPackageName = ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil ? "swift-cmark" : "cmark"

let package = Package(
  name: "swift-markdown-ui",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "MarkdownUI",
      targets: ["MarkdownUI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/gonzalezreal/NetworkImage", from: "6.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0"),
  ],
  targets: [
    .target(
      name: "MarkdownUI",
      dependencies: [
        .product(name: "cmark-gfm", package: cmarkPackageName),
        .product(name: "cmark-gfm-extensions", package: cmarkPackageName),
        .product(name: "NetworkImage", package: "NetworkImage"),
      ]
    ),
    
    .testTarget(
      name: "MarkdownUITests",
      dependencies: [
        "MarkdownUI",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)


// If the `SWIFTCI_USE_LOCAL_DEPS` environment variable is set,
// we're building in the Swift.org CI system alongside other projects in the Swift toolchain and
// we can depend on local versions of our dependencies instead of fetching them remotely.
if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
    // Building standalone, so fetch all dependencies remotely.
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-cmark.git", branch: "gfm"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    ]
    
    // SwiftPM command plugins are only supported by Swift version 5.6 and later.
    #if swift(>=5.6)
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ]
    #endif
} else {
    // Building in the Swift.org CI system, so rely on local versions of dependencies.
    package.dependencies += [
        .package(path: "../cmark"),
        .package(path: "../swift-argument-parser"),
    ]
}
