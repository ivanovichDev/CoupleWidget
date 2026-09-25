// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MainFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "MainFeature", targets: ["MainFeature"]),
    ],
    dependencies: [
        .package(path: "../../Domain"),
        .package(path: "../../DesignSystem"),
    ],
    targets: [
        .target(
            name: "MainFeature",
            dependencies: ["Domain", "DesignSystem"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
    ]
)
