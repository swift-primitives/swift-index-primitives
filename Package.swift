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
        ),
        .library(
            name: "Hash Index Primitives",
            targets: ["Hash Index Primitives"]
        )
    ],
    dependencies: [
        .package(path: "../swift-affine-primitives"),
        .package(path: "../swift-comparison-primitives"),
        .package(path: "../swift-identity-primitives"),
        .package(path: "../swift-hash-primitives")
    ],
    targets: [
        .target(
            name: "Index Primitives",
            dependencies: [
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
                .product(name: "Identity Primitives", package: "swift-identity-primitives")
            ]
        ),
        .target(
            name: "Hash Index Primitives",
            dependencies: [
                "Index Primitives",
                .product(name: "Hash Primitives", package: "swift-hash-primitives")
            ]
        ),
        .testTarget(
            name: "Index Primitives Tests",
            dependencies: ["Index Primitives"]
        ),
        .testTarget(
            name: "Hash Index Primitives Tests",
            dependencies: [
                "Hash Index Primitives",
                .product(name: "Hash Primitives", package: "swift-hash-primitives")
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
