// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-index-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Index Primitives",
            targets: ["Index Primitives"]
        )
    ],
    dependencies: [
        .package(path: "../swift-affine-primitives"),
        .package(path: "../swift-comparison-primitives"),
        .package(path: "../swift-cyclic-primitives"),
        .package(path: "../swift-identity-primitives"),
    ],
    targets: [
        .target(
            name: "Index Primitives",
            dependencies: [
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Cyclic Primitives", package: "swift-cyclic-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
            ]
        ),
        .target(
            name: "Index Primitives Test Support",
            dependencies: [
                "Index Primitives",
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Index Primitives Tests",
            dependencies: [
                "Index Primitives",
                "Index Primitives Test Support"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety()
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
