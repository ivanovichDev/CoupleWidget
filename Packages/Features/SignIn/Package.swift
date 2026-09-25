// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SignInFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "SignInFeature", targets: ["SignInFeature"]),
    ],
    dependencies: [
        .package(path: "../../Domain"),
        .package(path: "../../DesignSystem"),
    ],
    targets: [
        .target(
            name: "SignInFeature",
            dependencies: ["Domain", "DesignSystem"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "SignInFeatureTests",
            dependencies: ["SignInFeature"]
        ),
    ]
)
