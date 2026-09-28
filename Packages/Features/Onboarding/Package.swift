// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "OnboardingFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"])
    ],
    dependencies: [
        .package(path: "../../Domain"),
        .package(path: "../../DesignSystem")
    ],
    targets: [
        .target(
            name: "OnboardingFeature",
            dependencies: ["Domain", "DesignSystem"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "OnboardingFeatureTests",
            dependencies: ["OnboardingFeature"]
        )
    ]
)
