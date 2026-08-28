// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-index",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Index",
            targets: ["Index"]
        ),

        .library(
            name: "Index Test Support",
            targets: ["Index Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Index",
            dependencies: [
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Index Test Support",
            dependencies: [
                .target(name: "Index"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Index Tests",
            dependencies: [
                .target(name: "Index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
