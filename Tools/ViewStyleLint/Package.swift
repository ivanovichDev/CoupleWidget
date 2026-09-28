// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ViewStyleLint",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "view-style-lint", targets: ["ViewStyleLint"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .target(
            name: "ViewStyleRules",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .executableTarget(
            name: "ViewStyleLint",
            dependencies: ["ViewStyleRules"]
        ),
        .testTarget(
            name: "ViewStyleRulesTests",
            dependencies: ["ViewStyleRules"]
        )
    ]
)
