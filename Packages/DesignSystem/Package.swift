// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"])
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)
