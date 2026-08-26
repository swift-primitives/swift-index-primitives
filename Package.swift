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
            url: "https://github.com/swift-molecules/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-affine.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-comparison.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Index",
            dependencies: [
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Affine", package: "swift-affine"),
                .product(name: "Comparison", package: "swift-comparison"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Index Test Support",
            dependencies: [
                "Index",
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
                .product(
                    name: "Ordinal Test Support",
                    package: "swift-ordinal"
                ),
                .product(
                    name: "Cardinal Test Support",
                    package: "swift-cardinal"
                ),
                .product(
                    name: "Affine Test Support",
                    package: "swift-affine"
                ),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Index Tests",
            dependencies: [
                "Index",
                "Index Test Support",
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
