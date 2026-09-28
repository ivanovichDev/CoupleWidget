// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Data", targets: ["Data"])
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(name: "DataTests", dependencies: ["Data"])
    ]
)
