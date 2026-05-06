// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-linter-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Linter Primitives",
            targets: ["Linter Primitives"]
        ),
        .library(
            name: "Linter Primitives Test Support",
            targets: ["Linter Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-source-primitives"),
        .package(path: "../swift-diagnostic-primitives"),
        .package(path: "../swift-cardinal-primitives"),
        .package(path: "../swift-tagged-primitives"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"603.0.0"),
    ],
    targets: [
        .target(
            name: "Linter Primitives",
            dependencies: [
                .product(name: "Source Primitives", package: "swift-source-primitives"),
                .product(name: "Diagnostic Primitives", package: "swift-diagnostic-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Linter Primitives Test Support",
            dependencies: [
                "Linter Primitives",
                .product(name: "Source Primitives Test Support", package: "swift-source-primitives"),
                .product(name: "Diagnostic Primitives Test Support", package: "swift-diagnostic-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Linter Primitives Tests",
            dependencies: [
                "Linter Primitives",
                "Linter Primitives Test Support",
            ],
            path: "Tests/Linter Primitives Tests"
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
